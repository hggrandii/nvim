return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")
    conform.setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        python = { "black" },
        lua = { "stylua" },
        go = { "gofmt" },
        rust = { "rustfmt" },
        mojo = { "mojo_formatter" },
        zed = { "zed_formatter" },
        dart = { "dartfmt" },
      },
      formatters = {
        black = {
          prepend_args = { "--fast", "--quiet" },
          timeout_ms = 5000,
        },
        zigfmt = {
          command = "zig",
          args = { "fmt", "$FILENAME" },
          stdin = false,
          timeout_ms = 5000,
        },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 5000,
      },
    })
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 5000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
