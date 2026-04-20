require("turtle.remap")
require("turtle.packer")
vim.cmd("set number")
vim.cmd("set shiftwidth=2")
vim.g.everforest_background = 'hard'
vim.cmd.colorscheme("everforest");
vim.o.background = dark
vim.o.laststatus = 3

vim.keymap.set("n", "<leader>r", function()
	require("betterTerm").send("\x03", 1)
	vim.defer_fn(function()
		require("betterTerm").send("g++ main.cpp -o main && ./main\n", 1)
	end, 100)
end)

vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
	pattern = { "*.*" },
	desc = "save view (folds), when closing file",
	command = "mkview",
})
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	pattern = { "*.*" },
	desc = "load view (folds), when opening file",
	command = "silent! loadview"
})

vim.keymap.set("i", "<Tab>", "<C-X><C-F>")
