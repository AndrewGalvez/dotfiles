require('lualine').setup {
	sections = {
		lualine_a = { { 'mode' } },
		lualine_b = { { 'branch' } },
		lualine_c = { { 'filename', } },
		lualine_x = { { 'location' } },
		lualine_y = { { function()
			local handle = io.popen([[playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null]])
			if not handle then return "No player" end
			local out = handle:read("*a")
			handle:close()
			out = out and out:gsub("[<>%%]", "?"):gsub("\n", "") or ""
			return out ~= "" and out or "No player"
		end } },
		lualine_z = {
			{ function() return os.date("%a %b %d %r") end }
		},
	}
}
