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
  callback = function(event)
    if not pcall(vim.treesitter.start, event.buf) then
      return
    end
    local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
    if lang and vim.treesitter.query.get(lang, "indents") then
      vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter.indent'.get_indent(v:lnum)"
    end
  end,
})
