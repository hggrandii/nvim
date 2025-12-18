return {
	settings = {
		["rust-analyzer"] = {
			checkOnSave = true,
			inlayHints = { enable = true },
			cargo = {
				loadOutDirsFromCheck = true,
				allFeatures = true,
			},
			procMacro = {
				enable = true,
				attributes = {
					enable = true,
				},
			},
		},
	},
}
