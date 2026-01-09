local cmp = require('cmp')

-- Get the default capabilities for cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('cmp').setup({
	snippet = {
		expand = function(args) require('luasnip').lsp_expand(args.body) end,
	},
	mapping = cmp.mapping.preset.insert({
		['<Tab>'] = cmp.mapping.select_next_item(),
		['<S-Tab>'] = cmp.mapping.select_prev_item(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	})
})
