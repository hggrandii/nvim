return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
		"folke/trouble.nvim",
		"akinsho/flutter-tools.nvim",
		"nvim-lua/plenary.nvim",
		"stevearc/dressing.nvim",
		"mfussenegger/nvim-lint",
		"mhartington/formatter.nvim",
	},

	config = function()
		vim.deprecate = function() end

		local notify = vim.notify
		vim.notify = function(msg, ...)
			if msg and (msg:match("deprecated") or msg:match("WARNING")) then
				return
			end
			return notify(msg, ...)
		end

		local cmp = require("cmp")
		local cmp_lsp = require("cmp_nvim_lsp")
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		require("fidget").setup({})

		require("mason").setup()

		local mason_registry = require("mason-registry")
		local tools_to_install = { "ruff" }
		for _, tool in ipairs(tools_to_install) do
			if not mason_registry.is_installed(tool) then
				vim.cmd("MasonInstall " .. tool)
			end
		end

		local on_attach = function(client, bufnr)
			local function buf_set_keymap(...)
				vim.api.nvim_buf_set_keymap(bufnr, ...)
			end
			local opts = { noremap = true, silent = true }

			-- if client.server_capabilities.inlayHintProvider then
			--   vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			-- end

			-- buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
			-- buf_set_keymap("n", "gd", "<cmd>lua require('telescope.builtin').lsp_definitions()<CR>", opts)
			vim.keymap.set("n", "gd", function()
				local ok, tb = pcall(require, "telescope.builtin")
				if ok then
					tb.lsp_definitions()
				else
					vim.lsp.buf.definition()
				end
			end, { buffer = bufnr, silent = true, desc = "Go to Definition" })
			buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
			buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
			buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
			buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
			buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
			buf_set_keymap(
				"n",
				"<space>wl",
				"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
				opts
			)
			buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
			buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
			buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
			buf_set_keymap(
				"n",
				"<leader>e",
				"<cmd>lua vim.defer_fn(function() vim.diagnostic.open_float(nil, { focusable = false }) end, 10)<CR>",
				opts
			)
			buf_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
			buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
			buf_set_keymap("n", "<leader>vca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
			-- buf_set_keymap("n", "<leader>th",
			--   "<cmd>lua vim.lsp.inlay_hint.toggle(); print('Inlay hints: ' .. (vim.lsp.inlay_hint.is_enabled() and 'ON' or 'OFF'))<CR>",
			--   opts)
		end

		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"ruff",
				-- "eslint",
				"zls",
				"pyright",
				"ts_ls",
				"clangd",
			},
			handlers = {
				function(server_name)
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
						on_attach = on_attach,
					})
				end,

				["lua_ls"] = function()
					require("lspconfig").lua_ls.setup({
						capabilities = capabilities,
						on_attach = on_attach,
						settings = {
							Lua = {
								runtime = { version = "LuaJIT" },
								diagnostics = {
									globals = { "vim" },
								},
								workspace = {
									library = vim.api.nvim_get_runtime_file("", true),
								},
							},
						},
					})
				end,

				["clangd"] = function()
					require("lspconfig").clangd.setup({
						capabilities = capabilities,
						on_attach = on_attach,
						cmd = {
							"clangd",
							"--background-index",
							"--clang-tidy",
							"--header-insertion=iwyu",
							"--completion-style=detailed",
							"--function-arg-placeholders",
							"--fallback-style=llvm",
						},
						init_options = {
							usePlaceholders = true,
							completeUnimported = true,
							clangdFileStatus = true,
						},
					})
				end,

				-- ["eslint"] = function()
				--   require("lspconfig").eslint.setup({
				--     capabilities = capabilities,
				--     on_attach = function(client, bufnr)
				--       on_attach(client, bufnr)
				--
				--       vim.api.nvim_create_autocmd("BufWritePre", {
				--         buffer = bufnr,
				--         command = "EslintFixAll",
				--       })
				--     end,
				--     settings = {
				--       workingDirectory = { mode = "auto" }
				--     }
				--   })
				-- end,

				["pyright"] = function()
					require("lspconfig").pyright.setup({
						capabilities = capabilities,
						on_attach = on_attach,
						settings = {
							python = {
								analysis = {
									diagnosticMode = "none",
									typeCheckingMode = "off",
									autoSearchPaths = false,
									useLibraryCodeForTypes = false,
								},
							},
						},
					})
				end,
			},
		})

		require("lspconfig").gopls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
					},
					staticcheck = true,
					gofumpt = true,
					usePlaceholders = true,
					completeUnimported = true,
					deepCompletion = true,
					experimentalWorkspaceModule = true,
				},
			},
		})

		require("lspconfig").rust_analyzer.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				["rust-analyzer"] = {
					checkOnSave = true,
					inlayHints = { enable = true },
					cargo = { loadOutDirsFromCheck = true, allFeatures = true },
				},
			},
		})

		-- require("lspconfig").rust_analyzer.setup({
		--   capabilities = capabilities,
		--   on_attach = on_attach,
		--   settings = {
		--     ["rust-analyzer"] = {
		--       checkOnSave = true,
		--       cargo = {
		--         loadOutDirsFromCheck = true,
		--         allFeatures = true,
		--       },
		--
		--       inlayHints = {
		--         enable = true,
		--
		--         typeHints = {
		--           enable = true,
		--           hideClosureInitialization = true,
		--           hideNamedConstructor = true,
		--         },
		--
		--         parameterHints = { enable = false },
		--         chainingHints = { enable = false },
		--         closureReturnTypeHints = { enable = false },
		--         discriminantHints = { enable = false },
		--         lifetimeElisionHints = { enable = false },
		--
		--         maxLength = 15,
		--       },
		--     },
		--   },
		-- })

		require("flutter-tools").setup({
			lsp = {
				capabilities = capabilities,
				on_attach = on_attach,
			},
			debugger = {
				enabled = true,
				run_via_dap = true,
			},
		})

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
				["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer" },
			}),
		})

		require("trouble").setup({})

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

		require("lint").linters_by_ft = {
			python = { "ruff" },
		}

		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			callback = function()
				require("lint").try_lint()
			end,
		})

		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = "*.py",
			command = "FormatWrite",
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)

				if client and client.name == "gopls" then
					vim.defer_fn(function()
						local clients = vim.lsp.get_active_clients({ name = "gopls" })
						if #clients > 1 then
							for _, c in ipairs(clients) do
								if vim.tbl_isempty(c.config.settings or {}) then
									vim.lsp.stop_client(c.id)
									print("Auto-killed duplicate gopls client (ID: " .. c.id .. ")")
									break
								end
							end
						end
					end, 100)
				end

				vim.api.nvim_create_autocmd("LspAttach", {
					callback = function(args)
						local client = vim.lsp.get_client_by_id(args.data.client_id)
						if not client or client.name ~= "zls" then
							return
						end

						vim.defer_fn(function()
							local clients = vim.lsp.get_active_clients({ name = "zls" })
							local home = vim.loop.os_homedir()
							local std_pattern = home .. "/zig%-[%d%.]+/lib/"

							for _, c in ipairs(clients) do
								local root = (c.config and c.config.root_dir) or c.root_dir or ""
								if root:match(std_pattern) then
									vim.lsp.stop_client(c.id)
									print("Auto-killed stdlib zls client (ID: " .. c.id .. ")")
								end
							end
						end, 100)
					end,
				})

				if client and client.name == "rust_analyzer" then
					vim.defer_fn(function()
						local clients = vim.lsp.get_active_clients({ name = "rust_analyzer" })
						if #clients > 1 then
							for _, c in ipairs(clients) do
								if vim.tbl_isempty(c.config.settings or {}) then
									vim.lsp.stop_client(c.id)
									print("Auto-killed duplicate rust-analyzer client (ID: " .. c.id .. ")")
									break
								end
							end
						end
					end, 100)
				end
			end,
		})

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
