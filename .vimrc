" colorscheme ir_black
set number
set autoindent
set smartindent
set showmatch
set guioptions-=T
set ruler
set hlsearch
set incsearch
set shiftwidth=2
set tabstop=2
set confirm
set completeopt=longest,menu
set tags=/home/andersen/.vim/tags
set grepprg=grep\ -nH\ $*
filetype plugin indent on
set ofu=syntaxcomplete#Complete
autocmd FileType ruby set shiftwidth=2 | set expandtab
autocmd FileType yaml set shiftwidth=2 | set expandtab
syntax on
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1 
map <F3> :bp <CR>
map <F4> :bn <CR>
map <PageUp> :bp <CR>
map <PageDown> :bn <CR>
au BufWritePost *.coffee silent CoffeeMake! -b -o /tmp | cwindow | redraw!
au BufNewFile,BufReadPost *.coffee setl shiftwidth=2 expandtab
au BufNewFile,BufRead Capfile	setf ruby
augroup filetype
  au! BufRead,BufNewFile *.proto setfiletype proto
augroup end

" for html5
" Disable event-handler attributes support:
" let g:html5_event_handler_attributes_complete = 0

" Disable RDFa attributes support:
" let g:html5_rdfa_attributes_complete = 0

" Disable microdata attributes support:
" let g:html5_microdata_attributes_complete = 0

" Disable WAI-ARIA attribute support:
" let g:html5_aria_attributes_complete = 0

" for instant markdown
" let g:instant_markdown_slow = 1

