let g:chtsh_include_comments = 1
let g:chtsh_result_in_current_buffer = 0
let g:chtsh_layout = { "window": {"width": 0.7, "height": 0.7 } }

fun! CheatSheet()
    lua for k in pairs(package.loaded) do if k:match("^vim%-chtsh") then package.loaded[k] = nil end end
    lua require("vim-chtsh").cheat_search {}
endfun

fun! CheatPaste()
    lua for k in pairs(package.loaded) do if k:match("^vim%-chtsh") then package.loaded[k] = nil end end
    lua require("vim-chtsh").cheat_search { include_comments = 0, result_in_current_buffer = 1 }
endfun

fun! CheatList()
    lua for k in pairs(package.loaded) do if k:match("^vim%-chtsh") then package.loaded[k] = nil end end
    lua require("vim-chtsh").cheat_list()
endfun

augroup CheatSheet
    autocmd!
    nnoremap <leader>ch :call CheatSheet()<CR>
    nnoremap <leader>cp :call CheatPaste()<CR>
    nnoremap <leader>cl :call CheatList()<CR>
augroup END
