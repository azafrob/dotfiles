local my_palette = require('colors.base16')

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
                palette = my_palette,
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
