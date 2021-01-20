local base_url = "https://cht.sh"
local filetype = vim.bo.filetype

local vimcmd

if vim.api ~= nil then
    vimcmd = vim.api.nvim_command
else
    vimcmd = vim.command
end

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
    local stats = vim.api.nvim_list_uis()[1]

    local width = math.floor(stats.width * window_props.width)
    local height = math.floor(stats.height * window_props.height)

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

    local top_half_line = math.floor(((width - 2) - string.len(window_props.name)) / 2)
    local top = "╭" .. string.rep("─", top_half_line) .. window_props.name .. string.rep("─", width - 2 - string.len(window_props.name) - top_half_line) .. "╮"
    local mid = "│" .. string.rep(" ", width - 2) .. "│"
    local bot = "╰" .. string.rep("─", width - 2) .. "╯"

    local lines = {}
    table.insert(lines, top)
    for i=1,height-2 do
        table.insert(lines, mid)
    end
    table.insert(lines, bot)

    local buf_background = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf_background, 0, -1, true, lines)
    local win_background = vim.api.nvim_open_win(buf_background, true, opts)
    vimcmd("setlocal winhighlight=Normal:Title")

    local buf_result = vim.api.nvim_create_buf(false, true)

    opts.height = height - 4
    opts.width = 75
    opts.col = col + math.floor(width - 75) / 2
    opts.row = row + 2

    if width - 75 <= 0 then
        opts.width = width - 4
        opts.col = col + 2
    end

    local win_result = vim.api.nvim_open_win(buf_result, true, opts)
    vimcmd("setlocal winhighlight=Normal:TermCursorNC")

    vimcmd(string.format("augroup WipeBuffer | autocmd BufLeave,WinLeave,BufWipeout <buffer> :bw %d %d | autocmd! WipeBuffer | augroup END", buf_result, buf_background))
    vimcmd("setlocal wrap | setlocal filetype=" .. filetype)
end

local function create_split_window()
    local split

    if layout["split"] == "horizontal" then
        split = "split"
    elseif layout["split"] == "vertical" then
        split = "vsplit"
    end

    vimcmd(string.format([[
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
            name = " Cheat Sheet ",
            width = window_settings["width"][false],
            height = window_settings["height"][false],
        }
    else
        create_split_window()
    end

    local result = get_result(command)

    if result == "" or result == nil then
        vimcmd("r !echo \"No Result Found\"")
    end

    vimcmd("1")
    vim.api.nvim_del_current_line()
end

local function write_result_in_current_buffer(command)
    get_result(command)
end

local function cheat_search(props)
    local command = get_query_and_command(props.include_comments)

    if command ~= nil then
        if props.result_in_current_buffer == nil then
            props.result_in_current_buffer = vim.g["chtsh_result_in_current_buffer"]
        end

        if props.result_in_current_buffer == 0 then
            display_result_in_created_buffer(command)
        else
            write_result_in_current_buffer(command)
        end
    end
end

local function cheat_list()
    create_floating_window{
        name = string.format(" Cheat List (%s) ", filetype),
        width = 0.4,
        height = 0.7,
    }

    if filetype == "tex" then
        vimcmd(string.format("r !curl --silent %s/latex/:list", base_url))
    else
        vimcmd(string.format("r !curl --silent %s/%s/:list", base_url, filetype))
    end

    vimcmd("1")
    vim.api.nvim_del_current_line()
end

return {
    cheat_search = cheat_search,
    cheat_list = cheat_list
}
