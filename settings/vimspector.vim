nnoremap  <F29> :call vimspector#Launch()<CR>
nnoremap  <Leader>ds :call vimspector#Reset()<CR>
nnoremap  <Leader>dc :call vimspector#Continue()<CR>

nnoremap  <Leader>dt :call vimspector#ToggleBreakpoint()<CR>
nnoremap  <Leader>dT :call vimspector#ClearBreakpoints()<CR>

nmap      <Leader>dr <Plug>VimspectorRestart
nmap      <F10>de <Plug>VimspectorStepOut
nmap      <F11>di <Plug>VimspectorStepInto
nmap      <F35>do <Plug>VimspectorStepOver
