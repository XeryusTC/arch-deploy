let g:python_host_prog = '/home/xeryus/.pyenv/versions/neovim2/bin/python'
let g:python3_host_prog = '/home/xeryus/.pyenv/versions/neovim3/bin/python'

" call plug#begin('~/.local/share/nvim/plugged')
call plug#begin()
if has('nvim')
	Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
	Plug 'Shougo/deoplete.nvim'
	Plug 'roxma/nvim-yarp'
	Plug 'roxma/vim-hug-neovim-rpc'
endif
" Code completion
Plug 'zchee/deoplete-jedi'
Plug 'racer-rust/vim-racer'

" Other
Plug 'jiangmiao/auto-pairs'
Plug 'machakann/vim-highlightedyank'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
call plug#end()

filetype plugin on
set hidden
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set breakindent
set breakindentopt=shift:2,min:40
set colorcolumn=80,120
hi ColorColumn ctermbg=red

" Python
let g:pyindent_open_paren = '&sw'
let g:pyindent_nested_paren = '&sw'
let g:deoplete#enable_at_startup = 1
" Rust
let g:racer_cmd = '/home/xeryus/.cargo/bin/racer'
let g:racer_insert_paren = 1

" Close preview window on leaving the insert mode
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" Nerdtree
map <C-e> :NERDTreeToggle<CR>

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

