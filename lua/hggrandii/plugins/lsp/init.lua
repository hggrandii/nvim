return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"j-hui/fidget.nvim",
	},
	config = function()
		vim.deprecate = function() end

		local keymaps = require("hggrandii.plugins.lsp._keymaps")
		local cmp_lsp = require("cmp_nvim_lsp")
		local enabled = require("hggrandii.plugins.lsp._enabled")

		require("fidget").setup({})
		require("mason").setup()

		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		vim.diagnostic.config({
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				header = "",
				prefix = "",
			},
			virtual_text = {
				severity = { min = vim.diagnostic.severity.WARN },
			},
			signs = {
				severity = { min = vim.diagnostic.severity.WARN },
			},
			underline = {
				severity = { min = vim.diagnostic.severity.WARN },
			},
		})

		for server_name, is_enabled in pairs(enabled) do
			if is_enabled then
				local ok, server_config = pcall(require, "hggrandii.plugins.lsp.servers." .. server_name)
				if ok then
					local final_config = vim.tbl_deep_extend("force", {
						capabilities = capabilities,
						on_attach = keymaps.on_attach,
					}, server_config or {})
					require("lspconfig")[server_name].setup(final_config)
				end
			end
		end

		local mason_registry = require("mason-registry")
		local tools_to_install = { "ruff" }
		for _, tool in ipairs(tools_to_install) do
			if not mason_registry.is_installed(tool) then
				vim.cmd("MasonInstall " .. tool)
			end
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "python",
			callback = function()
				vim.opt_local.expandtab = true
				vim.opt_local.shiftwidth = 4
				vim.opt_local.tabstop = 4
				vim.opt_local.softtabstop = 4
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "c", "cpp", "zig" },
			callback = function()
				vim.keymap.set(
					"n",
					"gd",
					"<cmd>lua require('telescope.builtin').lsp_definitions()<CR>",
					{ buffer = true }
				)
			end,
		})
	end,
}
