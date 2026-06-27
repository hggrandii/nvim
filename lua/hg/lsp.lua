vim.diagnostic.config({
  virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
  signs = { severity = { min = vim.diagnostic.severity.WARN } },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    header = "",
    prefix = "",
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local bufnr = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client and vim.bo[bufnr].buftype == "" then
      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,
      })
    end

    if client and client.name == "clangd" then
      local ft = vim.bo[bufnr].filetype

      local allowed = {
        c = true,
        cpp = true,
        objc = true,
        objcpp = true,
        cuda = true,
      }

      if not allowed[ft] then
        vim.lsp.buf_detach_client(bufnr, client.id)
        vim.diagnostic.reset(nil, bufnr)
        return
      end
    end

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        silent = true,
        desc = desc,
      })
    end

    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "K", vim.lsp.buf.hover, "Hover documentation")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "gr", vim.lsp.buf.references, "Go to references")
    map("n", "<space>D", vim.lsp.buf.type_definition, "Type definition")
    map("n", "<space>rn", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>vca", vim.lsp.buf.code_action, "Code action")
    map("n", "<space>f", function()
      vim.lsp.buf.format({ async = true })
    end, "Format")
    map("n", "<leader>e", function()
      vim.diagnostic.open_float(nil, { focusable = false })
    end, "Show diagnostics")
    map("n", "<space>q", vim.diagnostic.setloclist, "Diagnostics to location list")
    map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
  end,
})

local servers = {
  clangd = "clangd",
  gopls = "gopls",
  lua_ls = "lua-language-server",
  rust_analyzer = "rust-analyzer",
  zls = "zls",
  ruff = "ruff",
  dartls = "dart",
  sourcekit = "xcrun",
}

for server, cmd in pairs(servers) do
  if vim.fn.executable(cmd) == 1 then
    vim.lsp.enable(server)
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(event)
    local ft = vim.bo[event.buf].filetype

    local allowed = {
      go = true,
      lua = true,
      rust = true,
      zig = true,
      c = true,
      cpp = true,
      dart = true,
      python = true,
    }

    if not allowed[ft] then
      return
    end

    vim.lsp.buf.format({
      bufnr = event.buf,
      timeout_ms = 3000,
    })
  end,
})

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   callback = function(event)
--     local allowed = {
--       go = true,
--       lua = true,
--       rust = true,
--       zig = true,
--       c = true,
--       cpp = true,
--       dart = true,
--       python = true,
--     }
--
--     if not allowed[vim.bo[event.buf].filetype] then
--       return
--     end
--
--     vim.lsp.buf.format({
--       bufnr = event.buf,
--       timeout_ms = 3000,
--     })
--   end,
-- })
