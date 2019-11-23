-- git add .
-- git commit -m "setup"
-- git push origin master

local dump;
local path = "D:/A1/Coding/Lua/dumper/";

local function clone(tbl)
	return setmetatable({}, {__index = tbl});
end

do
	-- visual studio is being weird with require --
	local string_lib = loadstring(io.open(path .. "string_library.lua"):read("*all"))();

	dump = {
		data = {
			source = "";
		};
	};

	function dump.new(data)
		local self = clone(dump);
		self.new = nil;

		for k, v in next, data or {} do
			self.data[k] = v;
		end
 
		return self;
	end

	function dump.gather_variables(self)
		self.dumped_variables = string_lib.dump(self);
	end

	function dump.modify_source(self)

		local src = self.data.source;
		local final = src;

		-- string source functions --

		local function insert_text(src, text, location)
			return src:sub(1, location) .. text .. src:sub(location + 1);
		end

		-- line functions --

		self.lines = string_lib.lines(self);
		local function get_before(line)
			return self.lines[line - 1];
		end
		local function get_next(line)
			return self.lines[line + 1];
		end
		local function get_line(char_location)
			for line, positions in pairs(self.lines) do
				if char_location > positions[1] and char_location < positions[2] then
					return line;
				end
			end
		end

		-- eq --

		local eq_locations = self.dumped_variables["findeq"];
		for _, location in pairs(eq_locations) do
			local line = get_before(get_line(location[1]));
			local end_line = line[2];
			local var1, var2 = location[2]:match(".(.-)~=(.+)");
			final = insert_text(src, (" print('eq:',%s,\"==\",%s)"):format(var1, var2), end_line);
		end

		-- --

		local success, err = pcall(loadstring(final));
		print(err);
	end
end

local src = io.open(path .. "src.lua"):read("*all");
local dumper = dump.new{source = src, type = "ironbrew"};
dumper:gather_variables();
dumper:modify_source();