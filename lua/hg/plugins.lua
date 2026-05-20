vim.pack.add({
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/EdenEast/nightfox.nvim" },
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/christoomey/vim-tmux-navigator" },
})

require("nvim-treesitter").setup()

require("nvim-autopairs").setup({
  check_ts = false,
  disable_filetype = { "snacks_picker_input" },
})

require("snacks").setup({
  explorer = {
    enabled = true,
    replace_netrw = true,
  },

  picker = {
    enabled = true,
    sources = {
      explorer = {
        auto_close = true,
        jump = { close = true },
        layout = { preset = "sidebar" },
      },
    },
  },

  dashboard = { enabled = false },
  notifier = { enabled = false },
  indent = { enabled = false },
  input = { enabled = false },
})

local function make_transparent()
  local groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "LineNr",
    "CursorLineNr",
    "EndOfBuffer",
    "StatusLine",
    "StatusLineNC",
    "WinSeparator",
    "WinBar",
    "WinBarNC",

    "SnacksPicker",
    "SnacksPickerInput",
    "SnacksPickerList",
    "SnacksPickerPreview",
    "SnacksPickerBorder",
    "SnacksExplorerNormal",
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end

vim.cmd.colorscheme("nightfox")
make_transparent()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = make_transparent,
})


vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
