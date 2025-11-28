return {
	"akinsho/flutter-tools.nvim",
	ft = "dart",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"neovim/nvim-lspconfig",
	},
	config = function()
		local keymaps = require("hggrandii.plugins.lsp._keymaps")

		local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			has_cmp and cmp_lsp.default_capabilities() or {}
		)

		require("flutter-tools").setup({
			lsp = {
				capabilities = capabilities,
				on_attach = keymaps.on_attach,
				flags = { allow_incremental_sync = false },
				settings = {
					dart = {
						completeFunctionCalls = true,
						updateImportsOnRename = true,
						showTodos = true,
					},
				},
			},
			debugger = {
				enabled = true,
				run_via_dap = true,
			},
		})
	end,
}
