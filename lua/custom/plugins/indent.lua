return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			enabled = true,

			indent = {
				char = "▏",
			},

			-- IMPORTANT: force at least level 1

			scope = {
				enabled = false,
			},
		},
		config = function(_, opts)
			require("ibl").setup(opts)

			-- make it VERY visible for testing
			vim.cmd([[highlight IblIndent guifg=red]])
		end,
	},
}
