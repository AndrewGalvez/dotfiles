-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.8',
		-- or                            , branch = '0.1.x',
		requires = { { 'nvim-lua/plenary.nvim' } }
	}

	use({
		'rose-pine/neovim',
		as = 'rose-pine',
		config = function()
			vim.cmd('colorscheme rose-pine')
		end
	})

	use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdtate' })

	use 'nvim-treesitter/playground'

	use 'theprimeagen/harpoon'

	use 'mbbill/undotree'

	use 'tpope/vim-fugitive'

	use 'neovim/nvim-lspconfig'

	use 'hrsh7th/cmp-nvim-lsp'

	use 'hrsh7th/cmp-buffer'

	use 'hrsh7th/cmp-path'

	use 'hrsh7th/cmp-cmdline'

	use 'hrsh7th/nvim-cmp'

	use 'L3MON4D3/LuaSnip'

	use 'saadparwaiz1/cmp_luasnip'

	use 'nvim-tree/nvim-tree.lua'

	use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' }

	use 'mhartington/formatter.nvim'

	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'nvim-tree/nvim-web-devicons', opt = true }
	}

	use "levouh/tint.nvim"

	use({
		"kdheepak/lazygit.nvim",
		-- optional for floating window border decoration
		requires = {
			"nvim-lua/plenary.nvim",
		},
	})

	use 'CRAG666/code_runner.nvim'

	use 'CRAG666/betterTerm.nvim'

	use 'rachartier/tiny-inline-diagnostic.nvim'
end)
