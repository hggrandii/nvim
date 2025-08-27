return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"ThePrimeagen/harpoon",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local state = require("telescope.actions.state")
		local harpoon = require("harpoon")
		local mark = require("harpoon.mark")
		local conf = require("telescope.config").values

		harpoon.setup()

		local function toggle_telescope()
			local marks = harpoon.get_mark_config().marks
			local file_paths = {}
			for _, mark in ipairs(marks) do
				table.insert(file_paths, mark.filename)
			end

			local function refresh_picker(current_picker)
				local updated_marks = harpoon.get_mark_config().marks
				local updated_file_paths = {}
				for _, updated_mark in ipairs(updated_marks) do
					table.insert(updated_file_paths, updated_mark.filename)
				end
				current_picker:refresh(
					require("telescope.finders").new_table({
						results = updated_file_paths,
					}),
					{ reset_prompt = true }
				)
			end

			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr, map)
						map("i", "<C-d>", function()
							local selected_entry = state.get_selected_entry()
							local current_picker = state.get_current_picker(prompt_bufnr)

							mark.rm_file(selected_entry.value)

							refresh_picker(current_picker)

							print("Removed from Harpoon: " .. selected_entry.value)
						end)
						return true
					end,
				})
				:find()
		end

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
		})

		telescope.load_extension("fzf")

		local keymap = vim.keymap

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
		keymap.set("n", "<C-e>", function()
			toggle_telescope()
		end, { desc = "Open Harpoon window" })
	end,
}
