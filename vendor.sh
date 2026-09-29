#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

dest=pack/vendor/opt
lock=vendor.lock

plugins=(
  "snacks.nvim         https://github.com/folke/snacks.nvim                -"
  "nightfox.nvim       https://github.com/EdenEast/nightfox.nvim           -"
  "nvim-autopairs      https://github.com/windwp/nvim-autopairs            -"
  "nvim-treesitter     https://github.com/nvim-treesitter/nvim-treesitter  main"
  "vim-tmux-navigator  https://github.com/christoomey/vim-tmux-navigator   -"
  "nvim-surround       https://github.com/kylechui/nvim-surround           -"
  "mini.icons          https://github.com/nvim-mini/mini.icons             -"
)

# --- plugins ---------------------------------------------------------------
rm -rf "$dest"
mkdir -p "$dest"
: > "$lock"

for entry in "${plugins[@]}"; do
  read -r name url ref <<<"$entry"
  if [[ $ref == - ]]; then
    git clone --quiet --depth 1 "$url" "$dest/$name"
  else
    git clone --quiet --depth 1 --branch "$ref" "$url" "$dest/$name"
  fi
  sha=$(git -C "$dest/$name" rev-parse HEAD)
  rm -rf "$dest/$name/.git"
  echo "$name $sha" >> "$lock"
  echo "vendored $name @ ${sha:0:12}"
done

# --- parsers ---------------------------------------------------------------
plat="$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)"
echo "building parsers -> site/$plat"
nvim --headless "+TSUpdateMine" +qa
echo "done; run :checkhealth nvim-treesitter to verify"
