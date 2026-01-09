require('betterTerm').setup {
	prefix = "Term",
	position = "bot",
	size = 10,
	startInserted = true,
	show_tabs = true,
	new_tab_mapping = "<C-t>",
	jump_tab_mapping = "<C-$tab>",
	active_tab_hl = "TabLineSel",
	inactive_tab_hl = "TabLine",
	new_tab_hl = "BetterTermSymbol",
	new_tab_icon = "+",
	index_base = 1,
}

vim.keymap.set({ "n", "t" }, "<C-;>", function() require('betterTerm').open() end, { desc = "Toggle terminal" })
