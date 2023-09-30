local float_win = require("vim-chtsh.window")
local cheat = require("vim-chtsh.cheat")

local layout = vim.g["chtsh_layout"]


local function get_query(search_mode)
    return vim.fn.input(search_mode .. " > ")
end


local function get_result(query, options)
    if query ~= nil and query ~= "" then
        local url = cheat.get_url(query, options)
        return cheat.get_result(url)
    end
    return nil
end


local function create_floating_window(window_props, opts)
    local win_opts = {
        title = window_props.title,
        height_percentage = window_props.height,
        width_percentage = window_props.width,
    }

    local window = float_win.create_float_win(win_opts)
    vim.api.nvim_set_option_value("wrap", true, { win=window.win_id })
    vim.api.nvim_set_option_value("filetype", opts.filetype, { buf = window.bufnr })
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


local function display_result(result, opts)
    if result ~= nil then
        if opts.win_opts ~= nil then
            create_floating_window(opts.win_opts, opts)
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


local function run_cheat(opts)
    local raw_query = get_query(opts.mode)
    local query_obj = cheat.process_query(raw_query, opts.query_included_language)
    local query = query_obj.query

    if query ~= nil then
        local filetype = query_obj.filetype
        local search_options = {
            include_comments = vim.g["chtsh_include_comments"],
            language = filetype,
        }
        local result = get_result(query, search_options)

        opts.filetype = filetype

        if opts.win_opts ~= nil then
            opts.win_opts.title = opts.win_opts.title .. string.format(" (%s)", filetype)
        end

        display_result(result, opts)
    end
end


local function cheat_sheet()
    local win_opts
    if layout["window"] then
        local window_settings = layout["window"]
        win_opts = {
            title = "Cheat Sheet",
            width = window_settings["width"],
            height = window_settings["height"],
        }
    end
    run_cheat({
        mode = "Cheat Sheet",
        query_included_language = false,
        win_opts = win_opts
    })
end


local function cheat_search()
    local win_opts
    if layout["window"] then
        local window_settings = layout["window"]
        win_opts = {
            title = "Cheat Search",
            width = window_settings["width"],
            height = window_settings["height"],
        }
    end
    run_cheat({
        mode = "Cheat Search",
        query_included_language = true,
        win_opts = win_opts
    })
end

return {
    cheat_sheet = cheat_sheet,
    cheat_search = cheat_search,
}
