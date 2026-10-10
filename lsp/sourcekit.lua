return {
  cmd = { "sourcekit-lsp" },
  filetypes = { "swift" },
  root_markers = { "buildServer.json", "Package.swift", "compile_commands.json", ".git" },
  capabilities = {
    workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
  },
}
