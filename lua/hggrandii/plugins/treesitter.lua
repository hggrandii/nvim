return {
	"nvim-treesitter/nvim-treesitter",
  branch = "main",
	build = ":TSUpdate",
	config = function()
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
