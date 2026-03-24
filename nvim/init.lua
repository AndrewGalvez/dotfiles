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
