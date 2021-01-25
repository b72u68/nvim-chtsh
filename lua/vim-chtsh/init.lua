local float_win = require("vim-chtsh.window.float_win")

local base_url = "https://cht.sh"
local filetype = vim.bo.filetype

local layout = vim.g["chtsh_layout"]

local function get_query_and_command(include_comments)
    local search_query = vim.fn.input("Cheat Sheet > ")
    search_query = (search_query:gsub("% ", "+")):gsub("%s+", "")

    local command

    if search_query ~= "" and search_query ~= nil then
        local url

        if filetype == "tex" then
            url = string.format("%s/latex/%s", base_url, search_query)
        else
            url = string.format("%s/%s/%s", base_url, filetype, search_query)
        end

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

local function create_floating_window(window_props)
    local options = {
        title = window_props.title,
        height_percentage = window_props.height,
        width_percentage = window_props.width,
        highlight_group = "TermCursorNC"
    }

    float_win.create_float_win(options)

    vim.cmd("setlocal wrap | setlocal filetype=" .. filetype)
end

local function create_split_window()
    local split

    if layout["split"] == "horizontal" then
        split = "split"
    elseif layout["split"] == "vertical" then
        split = "vsplit"
    end

    vim.cmd(string.format([[
        %s
        noswapfile hide enew
        setlocal buftype=nofile
        setlocal bufhidden=hide
        file scratch
        setlocal filetype=%s
    ]], split, filetype))
end

local function get_result(command)
    local result = vim.api.nvim_exec(command, true)
    result = (result:gsub("^:!curl [^\n]*\n", "")):gsub("%s+", "")

    return result
end

local function display_result_in_created_buffer(command)
    if layout["window"] then
        local window_settings = layout["window"]
        create_floating_window{
            title = "Cheat Sheet",
            width = window_settings["width"][false],
            height = window_settings["height"][false],
        }
    else
        create_split_window()
    end

    local result = get_result(command)

    if result == "" or result == nil then
        vim.cmd("r !echo \"No Result Found\"")
    end

    vim.cmd("1")
    vim.api.nvim_del_current_line()
end

local function cheat_search(props)
    local command = get_query_and_command(props.include_comments)

    if command ~= nil then
        if props.result_in_current_buffer == nil then
            props.result_in_current_buffer = vim.g["chtsh_result_in_current_buffer"]
        end

        display_result_in_created_buffer(command)
    end
end

local function cheat_list()
    create_floating_window{
        title = string.format("Cheat List (%s)", filetype),
        width = 0.4,
        height = 0.7,
    }

    if filetype == "tex" then
        vim.cmd(string.format("r !curl --silent %s/latex/:list", base_url))
    else
        vim.cmd(string.format("r !curl --silent %s/%s/:list", base_url, filetype))
    end

    vim.cmd("1 | set cursorline")
    vim.api.nvim_del_current_line()
end

return {
    cheat_search = cheat_search,
    cheat_list = cheat_list
}
