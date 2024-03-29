local M = { 'general.commands', desc = 'General functions and commands' }

local CM = require('one.config')
local util = require('one.util')

M.commands = {
	Q = { ':q!', { desc = 'quit current buffer without saving' } },
	Qa = { ':qa!', { desc = 'quit all buffers without saving' } },
	CD = { ':lcd %:p:h', { desc = 'Change PWD in current buffer' } },

	Cheatsheet = {
		function()
			local lang = table.unpack(vim.split(string.lower(vim.v.lang), '.', { plain = true }))
			local url = 'https://vim.rtorr.com/lang/' .. lang
			vim.fn['openbrowser#open'](url)
		end,
		{ desc = 'Open vim cheatsheet in browser' },
	},

	GetWinConfig = {
		function()
			util.notify(vim.inspect(vim.api.nvim_win_get_config(0)))
		end,
		{ desc = 'Print current window config' },
	},

	FixLineBreak = {
		function()
			vim.cmd [[
				e ++ff=dos
				set ff=unix
				w
			]]
		end,
	},

	ProfileStart = {
		function()
			vim.cmd [[
				profile start profile.log
				profile func *
				profile file *
			]]
		end,
		{ desc = 'ProfileStart/ProfileEnd' },
	},

	ProfileEnd = {
		function()
			vim.cmd ':profile pause'
		end,
		{ desc = 'ProfileStart/ProfileEnd' },
	},

	OpenGithub = {
		function()
			local text = vim.fn.expand('<cfile>')
			vim.fn.OpenBrowser('https://github.com/' .. text)
		end,
		{ desc = 'Open github url in browser' },
	},

	ShowConfig = {
		function()
			local w = util.newWindow({ title = '[one.nvim config]', ft = 'lua' })
			local write = w.write
			write({ '-- The content generated by :ShowConfig', '-- config --' })

			local config = vim.tbl_extend('keep', CM.config, {})

			local lines = vim.split(vim.inspect(config), '\n')
			lines = vim.tbl_map(function(line)
				return line:gsub('<table %d+>', '"%1"'):gsub('<(%d+)>{', '--[[<table %1>--]]{'):gsub(
					'<function %d+>', '"%1"'):gsub('<metatable>', '["%1"]')
			end, lines)

			write(lines)

			w.resetCursor()
		end,
		{ desc = 'Show the merged config of one' },
	},

	ShowPlugins = {
		function()
			local w = util.newWindow({ title = '[one.nvim plugins]', ft = 'lua' })
			local write = w.write

			local PM = require('one.plugin-manager')
			write('-- The content generated by :ShowPlugins')

			local disabledPlugs = {}
			local enabledPlugs = {}
			for _, p in pairs(PM.plugs) do
				if p.disable then
					disabledPlugs[#disabledPlugs + 1] = p
				else
					enabledPlugs[#enabledPlugs + 1] = p
				end
			end

			local omitFields = { 'config', 'id' }
			local writePlug = function(p)
				write({ '', '-- id: ' .. p.id })

				local result = {}
				for key, val in pairs(p) do
					if not vim.tbl_contains(omitFields, key) then result[key] = val end
				end

				local lines = vim.split(vim.inspect(result), '\n')
				lines = vim.tbl_map(function(line)
					return line:gsub('<table %d+>', '"%1"'):gsub('<(%d+)>{', '--[[<table %1>--]]{'):gsub(
						'<function %d+>', '"%1"'):gsub('<metatable>', '["%1"]')
				end, lines)
				write(lines)
			end

			write({ '', '-- Disabled plugins --' })
			for _, p in pairs(disabledPlugs) do writePlug(p) end

			write({ '', '-- Enabled plugins --' })
			for _, p in pairs(enabledPlugs) do writePlug(p) end

			w.resetCursor()
		end,
		{ desc = 'Show plugins of one' },
	},
}

return M
