-- lua/custom/plugins/cmp.lua
return {
	{
		"saghen/blink.cmp",
		config = function()
			local cmp = require("blink.cmp")

			cmp.setup({
				keymap = {
					preset = "default", -- start from default preset

					-- Confirm selection with Enter
					["<CR>"] = { "select_and_accept", "fallback" },

					-- Manual completion
					["<C-Space>"] = { "show" },

					-- Optional: navigate items with Tab / Shift-Tab
					["<Tab>"] = { "select_next", "fallback" },
					["<S-Tab>"] = { "select_prev", "fallback" },
				},
			})
		end,
	},
}
