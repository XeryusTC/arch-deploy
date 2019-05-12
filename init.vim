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
" Typescript
Plug 'HerringtonDarkholme/yats.vim'
Plug 'mhartington/nvim-typescript', {'do': './install.sh'}

" Code folding
Plug 'tmhedberg/SimpylFold'
Plug 'Konfekt/FastFold'

" Python syntax highlighting
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}

" Color scheme
Plug 'NLKNguyen/papercolor-theme'

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
set foldlevelstart=20
set foldmethod=syntax

" Python
let g:pyindent_open_paren = '&sw'
let g:pyindent_nested_paren = '&sw'
let g:deoplete#enable_at_startup = 1
" Make sure deople doesn't interfere to much with Semshi
let g:deoplete#auto_complete_delay = 100
" Rust
let g:racer_cmd = '/home/xeryus/.cargo/bin/racer'
let g:racer_insert_paren = 1

" Close preview window on leaving the insert mode
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" Nerdtree
map <C-e> :NERDTreeToggle<CR>

" Color scheme
let g:PaperColor_Theme_Options = {
			\	'theme': {
			\		'default': {
			\			'transparent_background': 1
			\		}
			\	}
			\}
set background=dark
colorscheme PaperColor

" Semshi setup
nmap <silent> <leader>rr :Semshi rename<CR>
nmap <silent> <Tab> :Semshi goto name next<CR>
nmap <silent> <S-Tab> :Semshi goto name prev<CR>
nmap <silent> <leader>c :Semshi goto class next<CR>
nmap <silent> <leader>C :Semshi goto class prev<CR>
nmap <silent> <leader>f :Semshi goto function next<CR>
nmap <silent> <leader>F :Semshi goto function prev<CR>
nmap <silent> <leader>ee :Semshi error<CR>
nmap <silent> <leader>ge :Semshi goto error<CR>

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

