let g:chtsh_include_comments = 1
let g:chtsh_layout = { "window": {"width": 0.7, "height": 0.7 } }

fun! CheatSheet()
    lua for k in pairs(package.loaded) do if k:match("^vim%-chtsh") then package.loaded[k] = nil end end
    lua require("vim-chtsh").cheat_sheet()
endfun

fun! CheatSearch()
    lua for k in pairs(package.loaded) do if k:match("^vim%-chtsh") then package.loaded[k] = nil end end
    lua require("vim-chtsh").cheat_search()
endfun

augroup CheatSheet
    autocmd!
augroup END

command! CheatSheet call CheatSheet()
command! CheatSearch call CheatSearch()
