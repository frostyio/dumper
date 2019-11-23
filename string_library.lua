local string_lib = {
    patterns = {
        ["ironbrew"] = {
            [1] = {"wrapfunc", "local function %a+%(%a+,%s+%a+,%s+%a+%)", "last"},
            [2] = {"whiletrue", "while true do"},
            [3] = {"findinstr", "~whiletrue~%s+(%a+)%s+=%s+%a+%[%a+%]"},
            [4] = {"findeq", "~whiletrue~.%a+%[%a+%[2%]%]%s+~=%s+%a+%[%a+%[5%]%]", "all"}
        }
    }
};

local function find_pattern(type, pattern_name)
    local patterns = assert(string_lib.patterns[type], "unable to dump for " .. type);
    for _, v in pairs(patterns) do
        if v[1] == pattern_name then
            return v[2];
        end
    end
end

-- dump variables and opcodes --

function string_lib.dump(self)
    local data = self.data;
    local source = data.source;

    local patterns = assert(string_lib.patterns[data.type], "unable to dump for " .. data.type);
    local environment = {};

    for _, v in pairs(patterns) do
        local name, pattern, src = v[1], v[2], source;
        local end_match = 0;

        -- get previous matches to use --
        pattern = pattern:gsub("~(%w+)~", function(match) 
            assert(environment[match], "invalid previous match " .. match .. " for " .. name)
            end_match = environment[match][3] - 1;
            src = src:sub(end_match);
            return "";
        end)

        -- get all matches --
        local matches, last = {}, 0;
        src:gsub(pattern, function(match) 
            local find = src:find(pattern, last)
            if find then
                last = find + 1;
                find = find + end_match;
                table.insert(matches, {find, match, find + #match - 1});
            end
        end)

        -- output the results --

        local position = v[3] or 1;
        if position == "last" then
            position = #matches;
        end

        environment[name] = matches[position];
        if position == "all" then
            environment[name] = matches;
        end

        if environment[name] == nil then
            print(("Cannot find match for %s"):find(name));
        end

    end

    -- will add other variables --

    return environment;
end

function string_lib.lines(self)
    local data = self.data;
    local source = data.source;
    local lines = {};

    local last = 0;
    while true do
        local new_line = source:find("\n", last);
        if not new_line then break end;

        lines[#lines + 1] = {last, new_line};

        last = new_line + 1;
    end

    return lines;
end

return string_lib;