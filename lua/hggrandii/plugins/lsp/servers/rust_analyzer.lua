return {
	settings = {
		["rust-analyzer"] = {
			checkOnSave = true,
			inlayHints = { enable = true },
			cargo = {
				loadOutDirsFromCheck = true,
				allFeatures = true,
			},
		},
	},
}
