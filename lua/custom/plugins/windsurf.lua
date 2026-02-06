return {
	"Exafunction/windsurf.vim",
	config = function()
		vim.keymap.set("i", "<Tab>", function()
			local suggestion = vim.fn["codeium#GetCompletion"]()
			if suggestion ~= "" then
				return vim.fn["codeium#Accept"]()
			else
				return "<Tab>"
			end
		end, { expr = true, silent = true })
		-- Change '<C-g>' here to any keycode you like.
		vim.keymap.set("i", "<C-g>", function()
			return vim.fn["codeium#Accept"]()
		end, { expr = true, silent = true })
		vim.keymap.set("i", "<c-;>", function()
			return vim.fn["codeium#CycleCompletions"](1)
		end, { expr = true, silent = true })
		vim.keymap.set("i", "<c-,>", function()
			return vim.fn["codeium#CycleCompletions"](-1)
		end, { expr = true, silent = true })
		vim.keymap.set("i", "<c-x>", function()
			return vim.fn["codeium#Clear"]()
		end, { expr = true, silent = true })
	end,
}
