local vim = vim
local opt = vim.opt
local map = vim.keymap.set

opt.winborder = 'rounded'
opt.shiftwidth = 4
opt.softtabstop = -1
opt.expandtab = true

-- Disable arrow keys in normal mode
map({ 'n', 'v' }, '<Up>', '<cmd>echo "Use k to move up"<CR>')
map({ 'n', 'v' }, '<Down>', '<cmd>echo "Use j to move down"<CR>')
map({ 'n', 'v' }, '<Left>', '<cmd>echo "Use h to move left"<CR>')
map({ 'n', 'v' }, '<Right>', '<cmd>echo "Use l to move right"<CR>')

-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '

-- [[ Setting options ]] See `:h vim.o`
-- NOTE: You can change these options as you wish!
-- For more options, you can see `:help option-list`
-- To see documentation for an option, you can use `:h 'optionname'`, for example `:h 'number'`
-- (Note the single quotes)

-- Print the line number in front of each line
opt.number = true

-- Use relative line numbers, so that it is easier to jump with j, k. This will affect the 'number'
-- option above, see `:h number_relativenumber`
opt.relativenumber = true

-- Sync clipboard between OS and Neovim. Schedule the setting after `UiEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.api.nvim_create_autocmd('UIEnter', {
    callback = function()
        opt.clipboard = 'unnamedplus'
    end,
})

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true

-- Highlight the line where the cursor is on
opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

-- Show <tab> and trailing spaces
opt.list = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s) See `:help 'confirm'`
opt.confirm = true

-- [[ Set up keymaps ]] See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- Use <Esc> to exit terminal mode
map('t', '<Esc>', '<C-\\><C-n>')

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
map({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
map({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
map({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
map({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
map({ 'n' }, '<A-h>', '<C-w>h')
map({ 'n' }, '<A-j>', '<C-w>j')
map({ 'n' }, '<A-k>', '<C-w>k')
map({ 'n' }, '<A-l>', '<C-w>l')

map({ 'n' }, '<leader>h', ':Pick help<CR>')
map({ 'n' }, '<leader>f', ':Pick files<CR>')
map({ 'n' }, '<leader>ne', ':NnnExplorer<CR>')
map({ 'n' }, '<leader>nf', ':NnnPicker<CR>')
map({ 'n' }, '<leader>lf', vim.lsp.buf.format)

-- [[ Basic Autocommands ]].
-- See `:h lua-guide-autocommands`, `:h autocmd`, `:h nvim_create_autocmd()`

-- Highlight when yanking (copying) text.
-- Try it with `yap` in normal mode. See `:h vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    callback = function()
        vim.hl.on_yank()
    end,
})

-- [[ Create user commands ]]
-- See `:h nvim_create_user_command()` and `:h user-commands`

-- Create a command `:GitBlameLine` that print the git blame for the current line
vim.api.nvim_create_user_command('GitBlameLine', function()
    local line_number = vim.fn.line('.') -- Get the current line number. See `:h line()`
    local filename = vim.api.nvim_buf_get_name(0)
    print(vim.system({ 'git', 'blame', '-L', line_number .. ',+1', filename }):wait().stdout)
end, { desc = 'Print the git blame for the current line' })

-- [[ Add optional packages ]]
-- Nvim comes bundled with a set of packages that are not enabled by
-- default. You can enable any of them by using the `:packadd` command.

-- For example, to add the "nohlsearch" package to automatically turn off search highlighting after
-- 'updatetime' and when going to insert mode
vim.cmd('packadd! nohlsearch')

-- [[ Install plugins ]]
-- Nvim functionality can be extended by installing external plugins.
-- One way to do it is with a built-in plugin manager. See `:h vim.pack`.
vim.pack.add({
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/echasnovski/mini.nvim' },
    { src = 'https://github.com/luukvbaal/nnn.nvim' },
})

vim.lsp.enable({ 'lua_ls', 'clangd' })

require('mini.basics').setup()

local my_palette = require('base16')
require('mini.base16').setup({
    palette = my_palette,
    use_cterm = true,
    plugins = {
        default = true,
    },
})

require('mini.statusline').setup()

require('mini.pairs').setup()

require('mini.pick').setup()

local miniclue = require('mini.clue')
miniclue.setup({
    triggers = {
        -- Leader triggers
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },

        -- Built-in completion
        { mode = 'i', keys = '<C-x>' },

        -- `g` key
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },

        -- Marks
        { mode = 'n', keys = "'" },
        { mode = 'n', keys = '`' },
        { mode = 'x', keys = "'" },
        { mode = 'x', keys = '`' },

        -- Registers
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        { mode = 'i', keys = '<C-r>' },
        { mode = 'c', keys = '<C-r>' },

        -- Window commands
        { mode = 'n', keys = '<C-w>' },

        -- `z` key
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },
    },

    clues = {
        -- Enhance this by adding descriptions for <Leader> mapping groups
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
    },
})

require('mini.hipatterns').setup()

require('mini.completion').setup()

require('mini.icons').setup()
MiniIcons.tweak_lsp_kind()

require('mini.snippets').setup()

require('nnn').setup()

-- [[ Post-load options ]]
-- Transparent background
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })
