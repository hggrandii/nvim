return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"vimdoc",
				"javascript",
				"typescript",
				"c",
				"lua",
				"rust",
				"jsdoc",
				"bash",
				"python",
				"go",
				"html",
			},
			sync_install = false,
			auto_install = true,
			indent = {
				enable = true,
			},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "markdown" },
			},
		})

		local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
		treesitter_parser_config.templ = {
			install_info = {
				url = "https://github.com/vrischmann/tree-sitter-templ.git",
				files = { "src/parser.c", "src/scanner.c" },
				branch = "master",
			},
		}
		vim.treesitter.language.register("templ", "templ")

		vim.treesitter.query.set(
			"rust",
			"injections",
			[[
			(macro_invocation
				macro: (identifier) @_rsx (#eq? @_rsx "rsx")
				(token_tree) @injection.content
				(#set! injection.language "html"))
		]]
		)
	end,
}
