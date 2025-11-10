local opt = vim.opt
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api

-- General settings
opt.mouse = 'a'
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.list = true
opt.listchars = { tab = '¦ ' }
opt.foldmethod = 'syntax'
opt.foldnestmax = 1
opt.foldlevelstart = 3
opt.number = true
opt.ignorecase = true
opt.backup = false
opt.writebackup = false
opt.swapfile = false
vim.o.encoding = 'UTF-8'
opt.synmaxcol = 3000
opt.lazyredraw = true

if fn.has('win32') == 1 then
  opt.clipboard = 'unnamed'
else
  opt.clipboard = 'unnamedplus'
end

cmd('syntax on')

-- Filetype-specific folds
api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*.json',
  callback = function()
    vim.opt_local.foldmethod = 'indent'
  end,
})

-- Auto reload when files change outside of Neovim
local checktime_group = api.nvim_create_augroup('AutoCheckTime', { clear = true })

local function should_checktime()
  local mode = api.nvim_get_mode().mode
  if mode:match('^c') or mode:match('^r') or mode == '!' or mode == 't' then
    return false
  end
  if fn.getcmdwintype() ~= '' then
    return false
  end
  return true
end

api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI', 'FocusGained', 'BufEnter' }, {
  group = checktime_group,
  callback = function()
    if should_checktime() then
      cmd('checktime')
    end
  end,
})

api.nvim_create_autocmd('FileChangedShellPost', {
  group = checktime_group,
  callback = function()
    api.nvim_echo({ { 'File changed on disk. Buffer reloaded.', 'WarningMsg' } }, false, {})
  end,
})

-- Key mappings
local map = vim.keymap.set
map('n', '<M-Right>', '<cmd>vertical resize +1<CR>')
map('n', '<M-Left>', '<cmd>vertical resize -1<CR>')
map('n', '<M-Down>', '<cmd>resize +1<CR>')
map('n', '<M-Up>', '<cmd>resize -1<CR>')
map('n', '/\\', '<cmd>noh<CR>')
map('n', '<leader>bd', '<cmd>bp | sp | bn | bd<CR>', { silent = true })

cmd([[vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>]])
cmd([[vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>]])

-- Plugins (vim-plug)
local Plug = fn['plug#']

vim.call('plug#begin', fn.stdpath('config') .. '/plugged')

Plug('noorwachid/nvim-nightsky')
Plug('navarasu/onedark.nvim')
Plug('tribela/vim-transparent')
Plug('preservim/nerdtree')
Plug('Xuyuanp/nerdtree-git-plugin')
Plug('ryanoasis/vim-devicons')
Plug('unkiwii/vim-nerdtree-sync')
Plug('jcharum/vim-nerdtree-syntax-highlight', { branch = 'escape-keys' })
Plug('junegunn/fzf', { ['do'] = function() fn['fzf#install']() end })
Plug('junegunn/fzf.vim')
Plug('vim-airline/vim-airline')
Plug('vim-airline/vim-airline-themes')
Plug('voldikss/vim-floaterm')
Plug('neoclide/coc.nvim', { branch = 'release' })
Plug('jiangmiao/auto-pairs')
Plug('RRethy/vim-illuminate')

Plug('mattn/emmet-vim')
Plug('preservim/nerdcommenter')
-- Plug('vim-python/python-syntax')
Plug('pappasam/coc-jedi', {
  ['do'] = 'yarn install --frozen-lockfile && yarn build',
  branch = 'main',
})
Plug('yaegassy/coc-ruff', { ['do'] = 'yarn install --frozen-lockfile' })
Plug('tpope/vim-fugitive')
Plug('tpope/vim-rhubarb')
Plug('airblade/vim-gitgutter')
Plug('samoshkin/vim-mergetool')
Plug('tmhedberg/SimpylFold')
Plug('907th/vim-auto-save')
Plug('dart-lang/dart-vim-plugin')
Plug('nvim-lua/plenary.nvim')
Plug('stevearc/dressing.nvim')
Plug('akinsho/flutter-tools.nvim')
Plug('echasnovski/mini.nvim', { branch = 'stable' })
Plug 'preservim/nerdtree'

vim.call('plug#end')

-- Theme and highlights
cmd('colorscheme onedark')
cmd('highlight Comment cterm=bold')

g.python_highlight_all = 1
g.NERDTreeShowHidden = 1
g.auto_save = 1
g.auto_save_silent = 1

opt.guifont = 'FiraCode Nerd Font Mono:h9:cANSI'

-- Refresh NERDTree after saving a buffer
local nerdtree_group = api.nvim_create_augroup('NerdTreeAutoRefresh', { clear = true })
api.nvim_create_autocmd('BufWritePost', {
  group = nerdtree_group,
  callback = function()
    if fn.exists(':NERDTreeFocus') == 0 then
      return
    end
    cmd('NERDTreeFocus')
    cmd('normal R')
    cmd('wincmd p')
  end,
})

-- Source additional settings (both Vimscript and Lua)
local function source_glob(pattern)
  local files = fn.glob(pattern, 0, 1)
  for _, file in ipairs(files) do
    cmd('source ' .. file)
  end
end

local config_path = fn.stdpath('config')
source_glob(config_path .. '/settings/*.vim')
source_glob(config_path .. '/settings/*.lua')

-- Load custom modules written for this config
require('custom').setup()

-- Plugin-specific Lua setups
local ok, flutter = pcall(require, 'flutter-tools')
if ok then
  flutter.setup({})
end

api.nvim_create_user_command('ReloadConfig', function()
  cmd('luafile ' .. config_path .. '/init.lua')
  vim.notify('Ok! Updated configuration.')
end, {})
