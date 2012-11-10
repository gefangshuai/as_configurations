set encoding=utf-8
"set colorscheme
"colorscheme darkocean
colorscheme ir_black
"Toggle Menu and Toolbar
set guioptions-=m
set guioptions-=T
map <silent> <F8> :if &guioptions =~# 'T' <Bar>
        \set guioptions-=T <Bar>
        \set guioptions-=m <bar>
    \else <Bar>
        \set guioptions+=T <Bar>
        \set guioptions+=m <Bar>
    \endif<CR>
