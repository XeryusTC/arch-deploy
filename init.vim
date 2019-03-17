execute pathogen#infect()
filetype plugin indent on
syntax enable
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set breakindent
set breakindentopt=shift:2,min:40
set colorcolumn=80,120
hi ColorColumn ctermbg=yellow
let g:pyindent_open_paren = '&sw'
let g:pyindent_nested_paren = '&sw'

" automagically remove trailing whitespace for certain files when saving
function! <SID>StripTrailingWhitespaces()
	" Preparation: save last search, and cursor position
	let _s=@/
	let l = line(".")
	let c = col(".")
	" Do the business:
	%s/\s\+$//e
	" Clean up: restore previous search history and cursor position
	let @/=_s
	call cursor(l, c)
endfunction
autocmd FileType c,cpp,php,html,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

