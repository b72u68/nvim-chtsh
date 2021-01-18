# vim-chtsh

A simple NeoVim plugin to browse [cheat.sh](https://cheat.sh).

![Vim-chtsh Demo](/doc/vim-chtsh-demo.png)

## About vim-chtsh

This is a personal, light-weight plugin so there are not many features.

Checkout the official ![cheat.sh-vim](https://github.com/dbeniamine/cheat.sh-vim)
plugin for more interesting useful tools.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'b72u68/vim-chtsh'
```

Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('b72u68/vim-chtsh')
```

## Usage

```viml
" Search result contains comments (initial value = 1)
let g:chtsh_include_comments = 1

" Search result is written under the cursor in current bufer (initial value = 0)
" (The result is initial placed in a floating buffer)
let g:chtsh_result_under_cursor = 0

" Search for query
nnoremap <leader>ch :call CheatSheet()<CR>
```

Calling CheatSheet() function will ask user for search query ("Cheat Sheet > ").
The plugin will automatically take the filetype as the language query using vim
filetype. The search result will be placed in a floating buffer.
