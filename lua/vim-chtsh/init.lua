local baseUrl = "https://cht.sh"
local filetype = vim.bo.filetype

local vimcmd

if vim.api ~= nil then
    vimcmd = vim.api.nvim_command
else
    vimcmd = vim.command
end

local window_settings = vim.g["chtsh_window_settings"]

local function getSearchStringAndCommand(include_comments)
    local searchQuery = vim.fn.input("Cheat Sheet > ")
    searchQuery = (searchQuery:gsub("% ", "+")):gsub("%s+", "")

    local command

    if searchQuery ~= "" and searchQuery ~= nil then
        local url = string.format("%s/%s/%s", baseUrl, filetype, searchQuery)

        if include_comments == nil then
            include_comments = vim.g["chtsh_include_comments"]
        end

        if include_comments == 0 then
            command = "r !curl --silent " .. (url .. "\\?QT")
        else
            command = "r !curl --silent " .. (url .. "\\?T")
        end
    end

    return command
end

local function createFloatingWindow()
    local stats = vim.api.nvim_list_uis()[1]

    local width = math.floor(stats.width * window_settings["width"][false])
    local height = math.floor(stats.height * window_settings["height"][false])

    if width == 0 then
        width = math.floor(stats.width * 0.7)
    end

    if height == 0 then
        height = math.floor(stats.height * 0.7)
    end

    local col = math.floor((stats.width - width) / 2)
    local row = math.floor((stats.height - height) / 2)

    vimcmd(string.format('let top = " " . repeat("─", %d - 2) . " " | let mid = "│" . repeat(" ", %d - 2) . "│" | let bot = " " . repeat("─", %d - 2) . " " | let lines = [top] + repeat([mid], %d - 2) + [bot] | let s:buf = nvim_create_buf(v:false, v:true) | call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines) | call nvim_open_win(s:buf, v:true, {"relative": "editor", "row": %d, "col": %d, "width": %d, "height": %d, "style": "minimal"})',
    width, width, width, height, row, col, width, height))
    vimcmd("set winhighlight=Normal:NonText")

    local bufh = vim.api.nvim_create_buf(false, true)
    local winId = vim.api.nvim_open_win(bufh, true, {
        relative = "editor",
        width = width - 4,
        height = height - 2,
        col = col + 2,
        row = row + 1,
        style="minimal"
    })

    return winId
end

local function displayResultInWindow(command)
    local winId = createFloatingWindow()

    if winId ~= 0 or winID ~= nil then
        vimcmd("augroup LeaveBuffer | autocmd BufLeave <buffer> exe 'bw '.s:buf | q! | autocmd! LeaveBuffer | augroup END")
        vimcmd("augroup RemoveBuffer | autocmd BufWipeout <buffer> exe 'bw '.s:buf | autocmd! RemoveBuffer | augroup END")

        local result = vim.api.nvim_exec(command, true)
        result = (result:gsub("^:!curl [^\n]*\n", "")):gsub("%s+", "")

        if result == '' or result == nil then
            vimcmd("r !echo \" No Result Found \"")
        else
            vimcmd("set filetype=" .. filetype)
        end

        vimcmd("setlocal winhighlight=Normal:LineNr | set wrap | 1 | 1,1d")
    else
        print("Error Creating Windows")
    end
end

local function writeResultUnderCursor(command)
    vimcmd(command)
end

local function cheat(include_comments, result_under_cursor)
    local command = getSearchStringAndCommand(include_comments)

    if command ~= nil then
        if result_under_cursor == nil then
            result_under_cursor = vim.g["chtsh_result_under_cursor"]
        end

        if result_under_cursor == 0 then
            displayResultInWindow(command)
        else
            writeResultUnderCursor(command)
        end
    end
end

return {
    cheat = cheat
}
