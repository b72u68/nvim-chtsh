local cheat = {}

local base_url = "https://cht.sh"

cheat.default_options = {
    include_comments = 1,
    filetype = vim.bo.filetype
}


function cheat.process_query(query, included_language)
    local filetype
    local words = {}

    for w in string.gmatch(query, "%w+") do
        table.insert(words, w)
    end

    if #words == 0 then
        return { query = nil }
    elseif #words > 1 and included_language then
        filetype = words[1]
        query = table.concat(words, " ", 2)
    else
        filetype = cheat.default_options.filetype
        query = table.concat(words, " ")
    end

    return { query = query, filetype = filetype }
end


function cheat.get_url(query, options)
    local url, tag
    local filetype = options.language or cheat.default_options.filetype
    local include_comments = options.include_comments or cheat.default_options.include_comments

    query = string.gsub(query, "%s+", "+")

    if include_comments == 0 then
        tag = "\\?QT"
    else
        tag = "\\?T"
    end

    url = string.format("%s/%s/%s%s",
        base_url,
        filetype,
        query,
        tag
    )

    return url
end


function cheat.get_result(url)
    local command = "!curl --silent " .. url
    local result = vim.api.nvim_exec(command, true)

    local lines = {}
    local line = ""

    for i=1,string.len(result) do
        local c = result:sub(i, i)
        if c == "\n" then
            if line:gsub("%s+", "") ~= "" then
                table.insert(lines, line)
            end
            line = ""
        else
            line = line .. c
        end
    end

    return { unpack(lines, 2) }
end

return cheat
