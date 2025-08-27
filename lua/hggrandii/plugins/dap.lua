return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",
		"rcarriga/nvim-dap-ui",
		"theHamsta/nvim-dap-virtual-text",
		"nvim-neotest/nvim-nio",
	},

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("mason-nvim-dap").setup({
			ensure_installed = {
				"codelldb",
				"delve",
			},
			automatic_installation = true,
		})

		dapui.setup({
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.25 },
						"breakpoints",
						"stacks",
						"watches",
					},
					size = 40,
					position = "left",
				},
				{
					elements = {
						"repl",
						"console",
					},
					size = 0.25,
					position = "bottom",
				},
			},
		})

		require("nvim-dap-virtual-text").setup({
			enabled = true,
			enabled_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = false,
			show_stop_reason = true,
			commented = false,
		})

		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = "codelldb",
				args = { "--port", "${port}" },
			},
		}

		dap.configurations.rust = {
			{
				name = "Launch",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},
			},
		}

		dap.configurations.c = {
			{
				name = "Launch",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},
			},
			{
				name = "Launch with arguments",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = function()
					local args_string = vim.fn.input("Arguments: ")
					return vim.split(args_string, " ")
				end,
			},
		}

		dap.configurations.cpp = dap.configurations.c

		dap.configurations.zig = {
			{
				name = "Launch",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/zig-out/bin/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},
			},
		}

		dap.adapters.delve = {
			type = "server",
			port = "${port}",
			executable = {
				command = "dlv",
				args = { "dap", "-l", "127.0.0.1:${port}" },
			},
		}

		dap.configurations.go = {
			{
				type = "delve",
				name = "Debug",
				request = "launch",
				program = "${file}",
			},
			{
				type = "delve",
				name = "Debug test",
				request = "launch",
				mode = "test",
				program = "${file}",
			},
			{
				type = "delve",
				name = "Debug test (go.mod)",
				request = "launch",
				mode = "test",
				program = "./${relativeFileDirname}",
			},
		}

		vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>dB", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "Conditional Breakpoint" })
		vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
		vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to Cursor" })
		vim.keymap.set("n", "<leader>dg", dap.goto_, { desc = "Go to line (no execute)" })
		vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
		vim.keymap.set("n", "<leader>dj", dap.down, { desc = "Down" })
		vim.keymap.set("n", "<leader>dk", dap.up, { desc = "Up" })
		vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
		vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step Out" })
		vim.keymap.set("n", "<leader>dO", dap.step_over, { desc = "Step Over" })
		vim.keymap.set("n", "<leader>dp", dap.pause, { desc = "Pause" })
		vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
		vim.keymap.set("n", "<leader>ds", dap.session, { desc = "Session" })
		vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
		vim.keymap.set("n", "<leader>dw", function()
			require("dap.ui.widgets").hover()
		end, { desc = "Widgets" })

		vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
		vim.keymap.set("n", "<leader>dv", dapui.eval, { desc = "Eval under cursor" })
		vim.keymap.set("v", "<leader>dv", dapui.eval, { desc = "Eval selection" })

		vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "", linehl = "", numhl = "" })
		vim.fn.sign_define("DapLogPoint", { text = "🔵", texthl = "", linehl = "", numhl = "" })
		vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "", linehl = "", numhl = "" })
		vim.fn.sign_define("DapBreakpointRejected", { text = "❌", texthl = "", linehl = "", numhl = "" })
	end,
}
