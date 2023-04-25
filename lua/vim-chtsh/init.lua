local float_win = require("vim-chtsh.window")
local cheat = require("vim-chtsh.cheat")

local layout = vim.g["chtsh_layout"]
local default_filetype = vim.bo.filetype


local function get_query(search_mode)
    local query = vim.fn.input(search_mode .. " > ")
    local words = {}
    for w in string.gmatch(query, "%w+") do
        table.insert(words, w)
    end
    if #words ~= 0 then
        return table.concat(words, " ")
    end
    return nil
end


local function get_result(query, options)
    if query ~= nil and query ~= "" then
        local url = cheat.get_url(query, options)
        return cheat.get_result(url)
    end
    return nil
end


local function create_floating_window(window_props, options)
    local win_opts = {
        title = window_props.title,
        height_percentage = window_props.height,
        width_percentage = window_props.width,
    }

    local window = float_win.create_float_win(win_opts)
    vim.api.nvim_set_option_value("wrap", true, { buf = window.bufnr })
    vim.api.nvim_set_option_value("filetype", options.filetype, { buf = window.bufnr })
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
        file CheatSheet
        setlocal filetype=%s
    ]], split, filetype))
end

local function display_result(result, win_opts, opts)
    if result ~= nil then
        if win_opts ~= nil then
            create_floating_window({
                title = win_opts.title,
                width = win_opts.width,
                height = win_opts.height,
            }, opts)
        else
            create_split_window()
        end

        if #result == 0 then
            vim.cmd("r !echo \"No Result Found\"")
        else
            vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, true, result)
        end
    else
        print("No result found")
    end
end

local function cheat_sheet()
    local query = get_query("Cheat Sheet")

    if query ~= nil then
        local obj = cheat.process_query(query, false)
        local search_options = {
            include_comments = vim.g["chtsh_include_comments"],
            language = default_filetype,
        }

        local result = get_result(obj.query, search_options)

        local win_opts = nil
        if layout["window"] then
            local window_settings = layout["window"]
            win_opts = {
                title = "Cheat Sheet",
                width = window_settings["width"],
                height = window_settings["height"],
            }
        end

        display_result(result, win_opts, { filetype = default_filetype })
    end
end

local function cheat_search()
    local query = get_query("Cheat Search")

    if query ~= nil then
        local obj = cheat.process_query(query, true)
        local filetype = obj.filetype
        query = obj.filetype
        local search_options = {
            include_comments = vim.g["chtsh_include_comments"],
            language = filetype or default_filetype
        }
        local result = get_result(query, search_options)

        local win_opts

        if layout["window"] then
            local window_settings = layout["window"]
            win_opts = {
                title = string.format("Cheat Search (%s)", filetype),
                width = window_settings["width"],
                height = window_settings["height"],
            }
        end

        display_result(result, win_opts, { filetype = filetype })
    end
end

return {
    cheat_sheet = cheat_sheet,
    cheat_search = cheat_search,
}
