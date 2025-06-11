vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<leader><CR>", "za")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<F3>", "<cmd>!make && ./main<CR>")
vim.keymap.set("n", "<leader>c", '<cmd>!notify-send "$(date)"<CR><CR>');
vim.keymap.set("n", "<leader>gg", '<cmd>LazyGit<CR>');
vim.keymap.set('t', '<C-Space>', "<C-\\><C-n>", { silent = true })
