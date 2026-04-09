  -- disable netrw at the very start of your init.lua
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  -- optionally enable 24-bit colour
  vim.opt.termguicolors = true

require("nvim-tree").setup()
 
vim.keymap.set("n", "<leader>t", function() require("nvim-tree.api").tree.toggle({}) end)
