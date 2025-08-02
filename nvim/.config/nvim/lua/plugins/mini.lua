return {
	{
		'echasnovski/mini.nvim',
		enabled = true,
		config = function()
            -- mini.statusline
			local statusline = require 'mini.statusline'
			statusline.setup({ use_icons = true })

            -- mini.pairs
            local pairs = require 'mini.pairs'
            pairs.setup()

            -- mini.base16
            require('mini.base16').setup({
                palette = {
                    base00 = '#1e1e2e',
                    base01 = '#181825',
                    base02 = '#313244',
                    base03 = '#45475a',
                    base04 = '#585b70',
                    base05 = '#cdd6f4',
                    base06 = '#f5e0dc',
                    base07 = '#b4befe',
                    base08 = '#f38ba8',
                    base09 = '#fab387',
                    base0A = '#f9e2af',
                    base0B = '#a6e3a1',
                    base0C = '#94e2d5',
                    base0D = '#89b4fa',
                    base0E = '#cba6f7',
                    base0F = '#f2cdcd'
                },
                use_cterm = true,
                plugins = {
                    default = true,
                },
            })

            -- mini.hipatterns
            local hipatterns = require 'mini.hipatterns'
            hipatterns.setup({
                highlighters = {
                    -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
                    fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
                    hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
                    todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
                    note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

                    -- Highlight hex color strings (`#rrggbb`) using that color
                    hex_color = hipatterns.gen_highlighter.hex_color(),
                },
            })
		end
	},
}
