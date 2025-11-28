local M = {}

M.on_attach = function(client, bufnr)
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
	end

	map("n", "gd", function()
		local ok, tb = pcall(require, "telescope.builtin")
		if ok then
			tb.lsp_definitions()
		else
			vim.lsp.buf.definition()
		end
	end, "Go to Definition")

	map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
	map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
	map("n", "gr", vim.lsp.buf.references, "Go to References")
	map("n", "<space>D", vim.lsp.buf.type_definition, "Type Definition")

	map("n", "<space>rn", vim.lsp.buf.rename, "Rename")
	map("n", "<leader>vca", vim.lsp.buf.code_action, "Code Action")
	map("n", "<space>f", function()
		vim.lsp.buf.format({ async = true })
	end, "Format")

	map("n", "<leader>e", function()
		vim.defer_fn(function()
			vim.diagnostic.open_float(nil, { focusable = false })
		end, 10)
	end, "Show Diagnostics")
	map("n", "<space>q", vim.diagnostic.setloclist, "Diagnostics to Location List")

	map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
	map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
	map("n", "<space>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "List Workspace Folders")

	map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
end

return M
