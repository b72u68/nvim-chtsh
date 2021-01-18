let g:chtsh_include_comments = 1
let g:chtsh_result_under_cursor = 0

fun! CheatSheet()
    lua for k in pairs(package.loaded) do if k:match("^vim%-chtsh") then package.loaded[k] = nil end end
    lua require("vim-chtsh").search()
endfun

augroup CheatSheet
    autocmd!
    nnoremap <leader>ch :call CheatSheet()<CR>
augroup END
