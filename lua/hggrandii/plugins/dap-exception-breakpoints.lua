return {
	"lucaSartore/nvim-dap-exception-breakpoints",
	dependencies = { "mfussenegger/nvim-dap" },

	config = function()
		local set_exception_breakpoints = require("nvim-dap-exception-breakpoints")

		vim.keymap.set("n", "<leader>dc", set_exception_breakpoints, { desc = "[D]ebug: [C]ondition breakpoints" })
	end,
}
