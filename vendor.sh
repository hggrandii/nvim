#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

dest=pack/vendor/opt
lock=vendor.lock

# name  url  ref ("-" = default branch)
plugins=(
  "snacks.nvim         https://github.com/folke/snacks.nvim                -"
  "nightfox.nvim       https://github.com/EdenEast/nightfox.nvim           -"
  "nvim-autopairs      https://github.com/windwp/nvim-autopairs            -"
  "nvim-treesitter     https://github.com/nvim-treesitter/nvim-treesitter  main"
  "vim-tmux-navigator  https://github.com/christoomey/vim-tmux-navigator   -"
  "nvim-surround       https://github.com/kylechui/nvim-surround           -"
  "mini.icons          https://github.com/nvim-mini/mini.icons             -"
)

mkdir -p "$dest"
: > "$lock"

for entry in "${plugins[@]}"; do
  read -r name url ref <<<"$entry"
  rm -rf "$dest/$name"
  if [[ $ref == - ]]; then
    git clone --quiet --depth 1 "$url" "$dest/$name"
  else
    git clone --quiet --depth 1 --branch "$ref" "$url" "$dest/$name"
  fi
  echo "$name $(git -C "$dest/$name" rev-parse HEAD)" >> "$lock"
  rm -rf "$dest/$name/.git"
  echo "vendored $name"
done
