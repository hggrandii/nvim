#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PACK = ROOT / "pack" / "vendor" / "opt"
SITE = ROOT / "site"
LOCK = ROOT / "vendor.lock"

PLUGINS = [
    ("snacks.nvim", "https://github.com/folke/snacks.nvim", None),
    ("nightfox.nvim", "https://github.com/EdenEast/nightfox.nvim", None),
    ("nvim-autopairs", "https://github.com/windwp/nvim-autopairs", None),
    ("vim-tmux-navigator", "https://github.com/christoomey/vim-tmux-navigator", None),
    ("nvim-surround", "https://github.com/kylechui/nvim-surround", None),
    ("mini.icons", "https://github.com/nvim-mini/mini.icons", None),
]

TREESITTER = ("https://github.com/nvim-treesitter/nvim-treesitter", "main")

LANGS = [
    "c",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
    "go",
    "gomod",
    "rust",
    "zig",
    "cpp",
    "dart",
    "python",
    "javascript",
    "typescript",
    "tsx",
    "json",
    "yaml",
    "toml",
    "bash",
    "html",
    "css",
]

TARGETS = {
    "darwin-arm64": "aarch64-macos",
    "linux-x86_64": "x86_64-linux-gnu.2.17",
    "linux-aarch64": "aarch64-linux-gnu.2.17",
}

STRIP = {".git", ".github", "tests", "test", "spec", "docs", "assets", "CHANGELOG.md"}

TS_KEEP = [
    "LICENSE",
    "plugin/filetypes.lua",
    "plugin/query_predicates.lua",
    "lua/nvim-treesitter/indent.lua",
]


def run(cmd, cwd=None, capture=False):
    r = subprocess.run(cmd, cwd=cwd, text=True, capture_output=True)
    if r.returncode != 0:
        sys.exit(f"failed: {' '.join(map(str, cmd))}\n{r.stderr.strip()}")
    return r.stdout.strip() if capture else None


def clone(url, ref, dest):
    if ref:
        run(["git", "clone", "--quiet", "--depth", "1", "--branch", ref, url, dest])
    else:
        run(["git", "clone", "--quiet", "--depth", "1", url, dest])
    return run(["git", "-C", dest, "rev-parse", "HEAD"], capture=True)


def fetch_rev(url, rev, dest):
    dest.mkdir(parents=True)
    run(["git", "init", "--quiet"], cwd=dest)
    run(["git", "fetch", "--quiet", "--depth", "1", url, rev], cwd=dest)
    run(["git", "checkout", "--quiet", "FETCH_HEAD"], cwd=dest)


def copy_stripped(src, dest):
    shutil.copytree(src, dest, ignore=lambda d, names: [n for n in names if n in STRIP])


def load_parsers(ts_dir, tmp):
    dump = tmp / "dump.lua"
    dump.write_text("io.write(vim.json.encode(dofile(arg[1])))\n")
    out = run(
        ["nvim", "--clean", "-l", dump, ts_dir / "lua/nvim-treesitter/parsers.lua"],
        capture=True,
    )
    return json.loads(out)


def query_langs(parsers, ts_dir):
    seen = set()
    todo = list(LANGS)
    while todo:
        lang = todo.pop()
        if lang in seen:
            continue
        seen.add(lang)
        todo += parsers.get(lang, {}).get("requires", [])
        qdir = ts_dir / "runtime/queries" / lang
        for scm in qdir.glob("*.scm") if qdir.is_dir() else []:
            first = scm.read_text().split("\n", 1)[0]
            if first.startswith("; inherits:"):
                for dep in first.split(":", 1)[1].split(","):
                    todo.append(dep.strip().strip("()"))
    return sorted(seen)


def compile_one(job):
    lang, src, triple, out = job
    files = [src / "parser.c"]
    if (src / "scanner.c").exists():
        files.append(src / "scanner.c")
    cmd = [
        "zig",
        "cc",
        "-target",
        triple,
        "-shared",
        "-fPIC",
        "-O2",
        "-s",
        "-std=c11",
        "-fno-sanitize=undefined",
        "-I",
        src,
        *files,
        "-o",
        out,
    ]
    r = subprocess.run(cmd, text=True, capture_output=True)
    return lang, triple, r.returncode, r.stderr.strip()


def main():
    for tool in ("git", "nvim", "zig"):
        if not shutil.which(tool):
            sys.exit(f"{tool} not found on PATH")

    with tempfile.TemporaryDirectory() as t:
        tmp = Path(t)
        stage_pack = tmp / "pack"
        stage_site = tmp / "site"
        stage_pack.mkdir()
        lock = []

        for name, url, ref in PLUGINS:
            sha = clone(url, ref, tmp / "src" / name)
            copy_stripped(tmp / "src" / name, stage_pack / name)
            lock.append(f"{name} {sha}")
            print(f"vendored {name} @ {sha[:12]}")

        ts_url, ts_ref = TREESITTER
        ts_dir = tmp / "src" / "nvim-treesitter"
        ts_sha = clone(ts_url, ts_ref, ts_dir)
        lock.append(f"nvim-treesitter {ts_sha}")
        print(f"vendored nvim-treesitter @ {ts_sha[:12]} (runtime only)")

        ts_out = stage_pack / "nvim-treesitter"
        for rel in TS_KEEP:
            (ts_out / rel).parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ts_dir / rel, ts_out / rel)

        parsers = load_parsers(ts_dir, tmp)
        missing = [l for l in LANGS if "install_info" not in parsers.get(l, {})]
        if missing:
            sys.exit(f"no parser in nvim-treesitter for: {', '.join(missing)}")

        qlangs = query_langs(parsers, ts_dir)
        for lang in qlangs:
            qdir = ts_dir / "runtime/queries" / lang
            if qdir.is_dir():
                shutil.copytree(qdir, ts_out / "queries" / lang)
        print(f"copied queries: {' '.join(qlangs)}")

        repos = {}
        for lang in LANGS:
            info = parsers[lang]["install_info"]
            if info.get("generate"):
                sys.exit(f"{lang} needs parser generation, not supported")
            repos.setdefault((info["url"], info["revision"]), []).append(lang)

        def fetch(item):
            (url, rev), _ = item
            dest = tmp / "grammars" / f"{Path(url).name}-{rev}"
            fetch_rev(url, rev, dest)
            return url, rev, dest

        with ThreadPoolExecutor(8) as pool:
            fetched = {(u, r): d for u, r, d in pool.map(fetch, repos.items())}
        print(f"fetched {len(fetched)} grammar repos")

        jobs = []
        for lang in LANGS:
            info = parsers[lang]["install_info"]
            src = (
                fetched[(info["url"], info["revision"])]
                / info.get("location", "")
                / "src"
            )
            lock.append(f"parser:{lang} {info['revision']}")
            for plat, triple in TARGETS.items():
                out = stage_site / plat / "parser" / f"{lang}.so"
                out.parent.mkdir(parents=True, exist_ok=True)
                jobs.append((lang, src, triple, out))

        failed = []
        with ThreadPoolExecutor(os.cpu_count() or 4) as pool:
            for lang, triple, code, err in pool.map(compile_one, jobs):
                if code != 0:
                    failed.append(f"{lang} ({triple}):\n{err}")
        if failed:
            sys.exit("compile failed:\n" + "\n".join(failed))
        print(f"built {len(LANGS)} parsers for {', '.join(TARGETS)}")

        shutil.rmtree(PACK, ignore_errors=True)
        shutil.rmtree(SITE, ignore_errors=True)
        PACK.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(stage_pack, PACK)
        shutil.move(stage_site, SITE)
        LOCK.write_text("\n".join(lock) + "\n")

    print("done")


if __name__ == "__main__":
    main()
