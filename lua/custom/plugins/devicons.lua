return {
	{
		"nvim-tree/nvim-web-devicons",
		lazy = false, -- IMPORTANT: load immediately
		priority = 1000,
		config = function()
			require("nvim-web-devicons").setup({
				override = {
					hpp = {
						icon = "",
						color = "#519aba",
						name = "Hpp",
					},
					cpp = {
						icon = "",
						color = "#519aba",
						name = "Cpp",
					},
					json = {
						icon = "",
						color = "#cbcb41",
						name = "Json",
					},
				},
				default = true,
			})
		end,
	},
}
