# vim-chtsh

A simple Neovim plugin to browse [cheat.sh](https://cheat.sh).

![Vim-chtsh Demo](vim-chtsh-demo.png)

## Installation

**Newest Neovim version (NVIM v0.5.0) is required.** Check out [Neovim](https://github.com/neovim/neovim).

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
" Settings

" Show comments in result (default: 1)
" (0: remove comments in result, 1: show comments in result)
let g:chtsh_include_comments = 1

" Config result window size (value: from 0 to 1)
" If you want result to be in the split, change the setting to
" g:chtsh_layout = { "split": "vertical" } (display result in vertical split)
" or g:chtsh_layout = { "split": "horizontal" } (display result in horizontal split)
let g:chtsh_layout = { "window": {"width": 0.7, "height": 0.7 } }


" Some available commands

" Search for query and display result in new window
command! CheatSheet call CheatSheet()

" Search for query and display result in new window (input language)
command! CheatSearch call CheatSearch()

" Display list of available queries on cheat.sh for filetype
command! CheatList call CheatList()
```

Calling CheatSheet() function will ask user for search query (Example: "function",
"class"). After entering the query, the result will be placed in a floating window
or paste to the current working window.

If you want to see other result of the same query, add "\1", "\2", etc.
at the end of the query.

```
Functions\1
Functions\2
```

## TO-DO

- [x] ~~Add border lines around the result buffer.~~
- [x] ~~Show result in split window.~~
- [x] ~~Search with language and query.~~
- [x] ~~Create commands for easier key mapping.~~
- [x] ~~Get list of available keywords.~~
