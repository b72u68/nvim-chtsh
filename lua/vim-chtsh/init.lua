local baseUrl = "https://cht.sh"
local filetype = vim.bo.filetype

local function getSearchString()
    local search = vim.fn.input("Cheat Sheet > ")
    search = search:gsub("% ", "+")
    return search
end

local function createFloatingWindow()
    local stats = vim.api.nvim_list_uis()[1]
    local width = stats.width
    local height = stats.height
    local offSet = 10

    local bufh = vim.api.nvim_create_buf(false, true)
    local winId = vim.api.nvim_open_win(bufh, true, {
        relative = "editor",
        width = width - offSet * 4,
        height = height - offSet,
        col = offSet * 2,
        row = offSet / 2,
        style="minimal"
    })
end

local function displayResultInWindow(command)
    createFloatingWindow()

    local result = vim.api.nvim_exec(command, true)
    result = (result:gsub("^:!curl [^\n]*\n", "")):gsub("%s+", "")

    if (result == '' or result == nil) then
        vim.api.nvim_exec("r !echo \" No Result Found \"", true)
    else
        vim.api.nvim_command(string.format("set filetype=%s", filetype))
    end

    vim.api.nvim_command("set wrap | 1 | 1,1d")
end

local function writeResultUnderCursor(command)
    vim.api.nvim_exec(command, true)
end

local function search()
    local searchQuery = (getSearchString()):gsub("%s+", "")

    if searchQuery ~= "" and searchQuery ~= nil then
        local url = string.format("%s/%s/%s", baseUrl, filetype, searchQuery)

        local command

        if vim.g["chtsh_include_comments"] == 0 then
            command = string.format("r !curl --silent %s", (url .. "\\?QT"))
        else
            command = string.format("r !curl --silent %s", (url .. "\\?T"))
        end

        if vim.g["chtsh_result_under_cursor"] == 0 then
            displayResultInWindow(command)
        else
            writeResultUnderCursor(command)
        end
    end
end

return {
    search = search
}
