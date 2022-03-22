if !has('nvim-0.5')
  echohl WarningMsg
  echom "tabhula.nvim requires Neovim >= 0.5"
  echohl None
  finish
endif

if exists('g:loaded_tabhula') | finish | endif " prevent loading file twice

let g:loaded_tabhula = 1
