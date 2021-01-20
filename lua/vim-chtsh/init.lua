local baseUrl = "https://cht.sh"
local filetype = vim.bo.filetype

local vimcmd

if vim.api ~= nil then
    vimcmd = vim.api.nvim_command
else
    vimcmd = vim.command
end

local layout = vim.g["chtsh_layout"]

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
    local windowSettings = layout["window"]

    local width = math.floor(stats.width * windowSettings["width"][false])
    local height = math.floor(stats.height * windowSettings["height"][false])

    if width == 0 then
        width = math.floor(stats.width * 0.7)
    end

    if height == 0 then
        height = math.floor(stats.height * 0.7)
    end

    local col = math.floor((stats.width - width) / 2)
    local row = math.floor((stats.height - height) / 2)

    local opts = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style="minimal"
    }

    local windowName = " Cheat Sheet "
    local topBorderNumber = math.floor(((width - 2) - string.len(windowName)) / 2)
    local top = "╭" .. string.rep("─", topBorderNumber) .. windowName .. string.rep("─", width - 2 - string.len(windowName) - topBorderNumber) .. "╮"
    local mid = "│" .. string.rep(" ", width - 2) .. "│"
    local bot = "╰" .. string.rep("─", width - 2) .. "╯"

    local lines = {}
    table.insert(lines, top)
    for i=1,height-2 do
        table.insert(lines, mid)
    end
    table.insert(lines, bot)

    local bufBg = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufBg, 0, -1, true, lines)
    local winBg = vim.api.nvim_open_win(bufBg, true, opts)
    vimcmd("setlocal winhighlight=Normal:Title")

    local bufh = vim.api.nvim_create_buf(false, true)

    opts.height = height - 4
    opts.width = 75
    opts.col = col + math.floor(width - 75) / 2
    opts.row = row + 2

    if width - 75 <= 0 then
        opts.width = width - 4
        opts.col = col + 2
    end

    local winId = vim.api.nvim_open_win(bufh, true, opts)
    vimcmd("setlocal winhighlight=Normal:TermCursorNC")

    vimcmd(string.format("augroup LeaveBuffer | autocmd BufLeave,WinLeave <buffer> :bw!%d | bw!%d | autocmd! LeaveBuffer | augroup END", bufh, bufBg))
    vimcmd(string.format("augroup RemoveBuffer | autocmd BufWipeout <buffer> :bw!%d | :bw!%d | autocmd! RemoveBuffer | augroup END", bufh, bufBg))

    vimcmd("setlocal wrap | setlocal filetype=" .. filetype)

    return winId
end

local function createSplitWindow()
    local split
    local createdSplit = 1

    if layout["split"] == "horizontal" then
        split = "split"
    elseif layout["split"] == "vertical" then
        split = "vsplit"
    else
        createdSplit = 0
    end

    vimcmd(string.format([[
        %s
        noswapfile hide enew
        setlocal buftype=nofile
        setlocal bufhidden=hide
        file scratch
        setlocal filetype=%s
    ]], split, filetype))

    return createdSplit
end

local function getResult(command)
    local result = vim.api.nvim_exec(command, true)
    result = (result:gsub("^:!curl [^\n]*\n", "")):gsub("%s+", "")

    return result
end

local function displayResultInBuffer(command)
    local createdBuffer

    if layout["window"] then
        createdBuffer = createFloatingWindow()
    else
        createdBuffer = createSplitWindow()
    end

    if createdBuffer ~= 0 or createdBuffer ~= nil then
        local result = getResult(command)

        if result == '' or result == nil then
            vimcmd("r !echo \"No Result Found\"")
        end

        vimcmd("1 | 1,1d")
    else
        print("Error: Cannot create floating window or split")
    end
end

local function writeResultUnderCursor(command)
    local result = getResult(command)
end

local function cheatSearch(include_comments, result_under_cursor)
    local command = getSearchStringAndCommand(include_comments)

    if command ~= nil then
        if result_under_cursor == nil then
            result_under_cursor = vim.g["chtsh_result_under_cursor"]
        end

        if result_under_cursor == 0 then
            displayResultInBuffer(command)
        else
            writeResultUnderCursor(command)
        end
    end
end

return {
    cheatSearch = cheatSearch
}
