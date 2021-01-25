local float_win = require("vim-chtsh.window.float_win")
local cheat = require("vim-chtsh.cheat")

local filetype = vim.bo.filetype
local layout = vim.g["chtsh_layout"]

local function get_query()
    local query = vim.fn.input("Cheat Sheet > ")
    return query
end

local function get_result(options)
    local query = get_query()
    return cheat.get_result(query, options)
end

local function create_floating_window(window_props)
    local options = {
        title = window_props.title,
        height_percentage = window_props.height,
        width_percentage = window_props.width,
        highlight_group = window_props.highlight_group
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

local function display_result(result)
    if result ~= nil then
        if layout["window"] then
            local window_settings = layout["window"]
            create_floating_window{
                title = "Cheat Sheet",
                width = window_settings["width"][false],
                height = window_settings["height"][false],
                highlight_group = "Title"
            }
        else
            create_split_window()
        end

        if table.getn(result) == 0 then
            vim.cmd("r !echo \"No Result Found\"")
        else
            vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, true, result)
        end
    end
end

local function cheat_sheet()
    local options = {
        include_comments = vim.g["chtsh_include_comments"],
        query_include_language = 0
    }

    local result = get_result(options)

    display_result(result)
end

local function cheat_list()
    local options = {
        include_comments = 0,
        query_include_language = 0
    }

    local result = cheat.get_result(":list", options)

    create_floating_window{
        title = string.format("Cheat List (%s)", filetype),
        width = 0.4,
        height = 0.7,
        highlight_group = "ModeMsg"
    }

    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, true, result)
    vim.cmd("set cursorline")
end

return {
    cheat_sheet = cheat_sheet,
    cheat_list = cheat_list
}
