local float_win = require("vim-chtsh.window.float_win")
local cheat = require("vim-chtsh.cheat")
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')

local filetype = vim.bo.filetype
local layout = vim.g["chtsh_layout"]

local function get_query()
    local query = vim.fn.input("Cheat Sheet > ")
    return query
end

local function get_result(options)
    local query = get_query()
    if query ~= "" then
        local obj = cheat.get_url(query, options)

        if obj.filetype then
            filetype = obj.filetype
        end

        return cheat.get_result(obj.url)
    else
        return nil
    end
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
        file CheatSheet
        setlocal filetype=%s
    ]], split, filetype))
end

local function display_result(result, win_opts)
    if result ~= nil then
        if win_opts ~= nil then
            create_floating_window{
                title = win_opts.title,
                width = win_opts.width,
                height = win_opts.height,
                highlight_group = win_opts.highlight_group
            }
        else
            create_split_window()
        end

        if table.getn(result) == 0 then
            vim.cmd("r !echo \"No Result Found\"")
        else
            vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, true, result)
        end
    else
        error("No result found")
    end
end

local function cheat_sheet()
    local search_options = {
        include_comments = vim.g["chtsh_include_comments"],
        query_include_language = 0
    }

    local result = get_result(search_options)
    local win_opts = nil

    if layout["window"] then
        local window_settings = layout["window"]
        win_opts = {
            title = "Cheat Sheet",
            width = window_settings["width"][false],
            height = window_settings["height"][false],
            highlight_group = "TermCursorNr"
        }
    end

    display_result(result, win_opts)
end

local function cheat_search()
    local search_options = {
        include_comments = vim.g["chtsh_include_comments"],
        query_include_language = 1
    }

    local result = get_result(search_options)
    local window_opts = nil

    if layout["window"] then
        local window_settings = layout["window"]
        win_opts = {
            title = string.format("Cheat Search (%s)", filetype),
            width = window_settings["width"][false],
            height = window_settings["height"][false],
            highlight_group = "TermCursorNr"
        }
    end

    display_result(result, win_opts)
end

local function list_result_picker(results)
    pickers.new {
        prompt_title = 'Cheat List',
        finder = finders.new_table {
            results=results,
            entry_maker = function(line)
                return {
                    display = line,
                }
            end
        },
        attach_mappings = function (prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                local search_options = {
                    include_comments = vim.g["chtsh_include_comments"],
                    query_include_language = 1
                }

                local obj = cheat.get_url(selection.display, search_options)
                local result = cheat.get_result(obj.url)
                local window_opts = nil

                if layout["window"] then
                    local window_settings = layout["window"]
                    win_opts = {
                        title = string.format("Cheat Search (%s)", filetype),
                        width = window_settings["width"][false],
                        height = window_settings["height"][false],
                        highlight_group = "TermCursorNr"
                    }
                end

                display_result(result, win_opts)
            end)
            return true
        end
  }:find()
end

local function cheat_list()
    local search_options = {
        include_comments = 0,
        query_include_language = 0
    }

    local obj = cheat.get_url(":list", search_options)
    local result = cheat.get_result(obj.url)

    if result ~= nil or table.getn(result) ~= 0 then
        list_result_picker(result)
    else
        error("No result found")
    end
end

return {
    cheat_sheet = cheat_sheet,
    cheat_search = cheat_search,
    cheat_list = cheat_list
}
