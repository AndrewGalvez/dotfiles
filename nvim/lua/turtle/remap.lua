vim.g.mapleader = " "
vim.keymap.set("n", "<leader><CR>", "za")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>gg", '<cmd>LazyGit<CR>');
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })
