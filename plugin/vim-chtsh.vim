let g:chtsh_include_comments = 1
let g:chtsh_result_under_cursor = 0
let g:chtsh_window_settings = { "width": 0.7, "height": 0.7 }

fun! CheatSheet()
    lua for k in pairs(package.loaded) do if k:match("^vim%-chtsh") then package.loaded[k] = nil end end
    lua require("vim-chtsh").cheat()
endfun

fun! CheatPaste()
    lua for k in pairs(package.loaded) do if k:match("^vim%-chtsh") then package.loaded[k] = nil end end
    lua require("vim-chtsh").cheat(nil, 1)
endfun

augroup CheatSheet
    autocmd!
augroup END
