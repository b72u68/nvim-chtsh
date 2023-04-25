local stats = vim.api.nvim_list_uis()[1]

local float_win = {}

float_win.default_options = {
    title = "",
    height_percentage = 0.7,
    width_percentage = 0.7,
}

float_win.default_border_chars = {
    topleft = "╭",
    topright = "╮",
    horizontal = "─",
    vertical = "│",
    botleft = "╰",
    botright =  "╯"
}

function float_win.get_options(options)
    local height_percentage = options.height_percentage or float_win.height_percentage
    local width_percentage = options.width_percentage or float_win.width_percentage

    local height = math.floor(stats.height * height_percentage)
    local width = math.floor(stats.width * width_percentage)
    local col = math.floor((stats.width - width) / 2)
    local row = math.floor((stats.height - height) / 2)

    return {
        title = options.title,
        height = height,
        width = width,
        col = col,
        row = row,
    }
end

function float_win.get_border_line(content_win_options)
    local lines = {}

    local topleft = float_win.default_border_chars.topleft
    local topright = float_win.default_border_chars.topright
    local horizontal = float_win.default_border_chars.horizontal
    local vertical = float_win.default_border_chars.vertical
    local botleft = float_win.default_border_chars.botleft
    local botright = float_win.default_border_chars.botright

    local topline = nil

    if content_win_options.title then
        local title = content_win_options.title

        if title ~= "" then
            title = string.format(" %s ", title)
        end

        local title_len = string.len(title)

        local left = math.floor((content_win_options.width - 2 - title_len) / 2)
        local right = content_win_options.width - 2 - title_len - left

        topline = string.format("%s%s%s%s%s",
            topleft,
            string.rep(horizontal, left),
            title,
            string.rep(horizontal, right),
            topright
        )
    else
        topline = string.format("%s%s%s",
            topleft,
            string.rep(horizontal, content_win_options.width - 2),
            topright
        )
    end

    table.insert(lines, topline)

    local middle = string.format("%s%s%s",
        vertical,
        string.rep(" ", content_win_options.width - 2),
        vertical
    )

    for _=1,content_win_options.height-2 do
        table.insert(lines, middle)
    end

    local botline = string.format("%s%s%s",
        botleft,
        string.rep(horizontal, content_win_options.width - 2),
        botright
    )

    table.insert(lines, botline)

    return lines
end

function float_win.create_border_win(content_win_options)
    local lines = float_win.get_border_line(content_win_options)

    local width = content_win_options.width
    local height = content_win_options.height
    local row = content_win_options.row
    local col = content_win_options.col

    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal"
    }

    local obj = {}

    obj.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(obj.bufnr, 0, -1, true, lines)

    obj.win_id = vim.api.nvim_open_win(obj.bufnr, true, win_opts)

    return obj
end

function float_win.create_float_win(options)
    options = float_win.get_options(options)

    local height = options.height - 4
    local row = options.row + 2
    local width = 75
    local col = options.col + math.floor(options.width - width) / 2

    if options.width <= 75 then
        width = options.width - 4
        col = options.col + 2
    end

    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal"
    }

    local border = float_win.create_border_win(options)

    local bufnr = vim.api.nvim_create_buf(false, true)
    local win_id = vim.api.nvim_open_win(bufnr, true, win_opts)

    vim.keymap.set("n", "q", function () vim.api.nvim_win_close(win_id, 1) end, { silent = true, buffer = bufnr })
    vim.api.nvim_create_autocmd({"BufLeave", "BufDelete", "WinClosed", "WinLeave"}, {
        buffer = bufnr,
        callback = function()
            vim.api.nvim_win_close(border.win_id, 1)
            vim.api.nvim_win_close(win_id, 1)
        end
    })

    return {
        bufnr = bufnr,
        win_id = win_id,
        border_bufnr = border.bufnr,
        border_win_id = border.win_id
    }
end

return float_win
