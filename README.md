# vim-chtsh

A simple Neovim plugin to browse [cheat.sh](https://cheat.sh).

![Vim-chtsh Demo](vim-chtsh-demo.png)

## Installation

**Newest Neovim version (NVIM v0.5.0) is required.** Check out here: [Neovim](https://github.com/neovim/neovim/releases).

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'b72u68/vim-chtsh'
```

Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('b72u68/vim-chtsh')
```

## Usage

Default Settings for vim-chtsh:

```viml
" Show comments in result (default: 1)
" (0: remove comments in result, 1: show comments in result)
let g:chtsh_include_comments = 1

" Search result is written under the cursor in current window (default: 0)
" (0: show result in floating window, 1: write result in the working window)
let g:chtsh_result_under_cursor = 0

" Config result window size (value: from 0 to 1)
" If you want result to be in the split, change the setting to
" g:chtsh_layout = { "split": "vertical" } (display result in vertical split)
" or g:chtsh_layout = { "split": "horizontal" } (display result in horizontal split)
let g:chtsh_layout = { "width": 0.7, "height": 0.7 }

" Search for query and display result in new window
nnoremap <leader>ch :call CheatSheet()<CR>

" Search for query and paste the result in current window
nnoremap <leader>cp :call CheatPaste()<CR>
```

Calling CheatSheet() function will ask user for search query ("Cheat Sheet > ").
After entering the query, the result will be placed in a floating window or
paste to the current working window.

## TO-DO

- [x] ~~Add border lines around the result buffer.~~
- [x] ~~Show result in split window.~~
- [ ] Search with language and query.
- [ ] Create commands for easier key mapping.
- [ ] Get list of available keywords.
