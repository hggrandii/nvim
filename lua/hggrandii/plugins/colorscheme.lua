return {
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("nightfox").setup({
				options = {
					transparent = true,
					terminal_colors = true,
					dim_inactive = false,
				},
			})
			vim.cmd.colorscheme("nightfox")
		end,
	},
}
-- return {
-- 	{
-- 		"folke/tokyonight.nvim",
-- 		lazy = false,
-- 		priority = 1000,
-- 		config = function()
-- 			require("tokyonight").setup({
-- 				transparent = true,
-- 				styles = {
-- 					sidebars = "transparent",
-- 					floats = "transparent",
-- 				},
-- 			})
-- 			vim.cmd.colorscheme("tokyonight-night")
-- 		end,
-- 	},
-- }

-- return {
-- 	{
-- 		"rebelot/kanagawa.nvim",
-- 		lazy = false,
-- 		priority = 1000,
-- 		config = function()
-- 			require("kanagawa").setup({
-- 				transparent = true,
-- 				theme = "wave",
-- 			})
-- 			vim.cmd.colorscheme("kanagawa")
-- 		end,
-- 	},
-- }

-- return {
--   {
--     "catppuccin/nvim",
--     lazy = false,
--     name = "catppuccin",
--     priority = 1000,
--     config = function()
--       require("catppuccin").setup({
--         transparent_background = true,
--       })
--       vim.cmd.colorscheme("catppuccin-mocha")
--     end,
--   },
-- }

-- vim.cmd.colorscheme("default")
-- vim.cmd.colorscheme("elflord")
-- vim.cmd.colorscheme("desert")
-- vim.cmd.colorscheme("koehler")
-- vim.cmd.colorscheme("evening")

-- vim.cmd("syntax enable")
--
-- vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
-- vim.cmd("highlight NonText guibg=NONE ctermbg=NONE")
-- vim.cmd("highlight SignColumn guibg=NONE ctermbg=NONE")
-- vim.cmd("highlight EndOfBuffer guibg=NONE ctermbg=NONE")
--
-- return {}
