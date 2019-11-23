-- git add .
-- git commit -m "setup"
-- git push origin master

local clipboard = require("clipboard");

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

	function dump.add_edits(self, edits)
		local final = self.data.source;
		local add, least_location = 0, 0; -- add onto char location if less than least_location

		-- string source functions --

		local function insert_text(src, text, location)
			return src:sub(1, location) .. text .. src:sub(location + 1);
		end

		-- modifying the source --

		for _, edit in pairs(edits) do
			local type, text, location1, location2 = unpack(edit);
			
			-- need to add replace --
			if type == "insert" then
				if least_location > location1 then
					least_location = location1;
				end

				if location1 > least_location and location1 ~= least_location then
					location1 = location1 + add;
					add = add + #text;
				end

				final = insert_text(final, text, location1);
			end
		end

		return final;
	end

	function dump.modify_source(self)

		local src = self.data.source;

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

		local change_locations = {};

		-- eq --

		local eq_locations = self.dumped_variables["findeq"];
		for _, location in pairs(eq_locations) do
			local var1, var2 = location[2]:match(".(.-)~=(.+)");
			local loc = location[1] - 5; -- if statement offset --
			change_locations[#change_locations + 1] = {
				"insert", 
				(" print(\"eq: (\"..tostring(%s)..\" == \"..tostring(%s)..\")\", %s == %s)"):format(var1, var2, var1, var2),
				loc
			};
		end

		-- modifying the source --

		self.final = self:add_edits(change_locations);
	end

	function dump.run_final(self)
		assert(self.final, "no final code");
		clipboard.settext(self.final);
		print("Set code to clipboard!")

		local f, lexical_error = loadstring(self.final);
		if not f then 
			error(lexical_error);
		end

		local success, return_message = pcall(f);
		if success then 
			print("returned:", return_message)
		else
			error(return_message);
		end
	end

end

-- running --

local src = io.open(path .. "sources/src.lua"):read("*all");
local dumper = dump.new{source = src, type = "ironbrew"};
dumper:gather_variables();
dumper:modify_source();
dumper:run_final();
