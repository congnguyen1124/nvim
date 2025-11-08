let g:OmniSharp_server_stdio = 1
let g:OmniSharp_server_display_loading = 1
let g:OmniSharp_server_use_net6 = 1
let g:OmniSharp_loglevel = 'debug'

let g:ale_linters = { 'cs': ['OmniSharp'] }

autocmd BufRead * if expand('%:e') == 'cs' | execute "nmap <silent> gd :OmniSharpGotoDefinition<CR>" | endif
autocmd BufRead * if expand('%:e') == 'cs' | execute "nnoremap <silent> K :OmniSharpDocumentation<CR>" | endif
autocmd BufRead * if expand('%:e') == 'cs' | execute "nnoremap <silent> <C-Y> :OmniSharpCodeFormat<CR>" | endif
