local u = vim.uv.os_uname()
local plat = vim.fn.stdpath("config") .. "/site/" .. (u.sysname .. "-" .. u.machine):lower()
vim.opt.rtp:prepend(plat)

for _, name in ipairs({
  "snacks.nvim",
  "nightfox.nvim",
  "nvim-autopairs",
  "nvim-treesitter",
  "vim-tmux-navigator",
  "nvim-surround",
  "mini.icons",
}) do
  vim.cmd.packadd(name)
end

require("nvim-treesitter").setup({
  install_dir = plat,
})

require("nvim-surround").setup()

require("nvim-autopairs").setup({
  check_ts = false,
  disable_filetype = { "snacks_picker_input" },
})

require("mini.icons").setup()

require("snacks").setup({
  explorer = {
    enabled = true,
    replace_netrw = true,
  },

  picker = {
    enabled = true,
    sources = {
      explorer = {
        hidden = true,
        ignored = true,
        auto_close = true,
        jump = { close = true },
        layout = { preset = "sidebar" },
        win = {
          list = {
            keys = {
              ["<c-c>"] = "cancel",
            },
          },
          input = {
            keys = {
              ["<c-c>"] = { "cancel", mode = { "i", "n" } },
            },
          },
        },
      },
    },
  },

  dashboard = { enabled = false },
  notifier = { enabled = false },
  indent = { enabled = false },
  input = {
    enabled = false,
    win = {
      keys = {
        i_ctrl_c = { "<c-c>", "cancel", mode = { "i", "n" } },
      },
    },
  },
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

local parsers = {
  "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",

  "go", "gomod", "rust", "zig", "cpp", "dart", "python",
  "javascript", "typescript", "tsx", "json", "yaml", "toml",
  "bash", "html", "css",
}

-- Install missing parsers for this platform into site/<plat>.
vim.api.nvim_create_user_command("TSMine", function()
  require("nvim-treesitter").install(parsers):wait(300000)
end, {})

-- Force-rebuild all of them (run after bumping nvim-treesitter).
vim.api.nvim_create_user_command("TSUpdateMine", function()
  require("nvim-treesitter").install(parsers, { force = true }):wait(300000)
end, {})
