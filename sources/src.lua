--[[
IronBrew:tm: obfuscation; v20191118

........................................................................................................................................................................................................
........................................................................................................................................................................................................
.....,,...,.............................................................................................................................................................................................
.... MMMMM,.............................................................................................................................................................................................
....MMMMMMM,............................................................................................................................................................................................
....MMMMMMM,............................................................................................................................................................................................
....,MMMMMO.............................................................................................................................................................................................
......,.................................................................................................................................................................................................
..................................................,,,,,,............................................Z$$.................................................................................................
...................................................:::::............................................MMMO................................................................................................
.....:???? ,.......:????....,.8MMMMM,.......,,,MMMMI???INMMM.,................,.?ZMMMMDI:,,.........MMM$................................................................................................
.....MMMMM?,.......MMMMM,,.OMMMMMMMM......, 7MM+?+++++++++?+DM$ .............MMMMMMMMMMMMMM ,,......MMM$................................................................................................
.....MMMMM?,.......MMMMM..NMMMMMMMMM.,...,$M7++++++++++++++++++M$ .........MMMMMMMMMMMMMMMMMN .,....MMM$................................................................................................
.....MMMMM?,.......MMMMMMMMMMM8..,,,.,..,MM?++++++++++++++++++++MM,,......MMMMMMMM~,.+MMMMMMMM......MMM$................................................................................................
.....MMMMM?,.......MMMMMMMMZ ,,.......MMMMMMMMMMMMMDZZZZMMMMMMMMMMMMM ...MMMMMM,,,....., MMMMMM.....MMM$................................,.,,............................................................
.....MMMMM?,.......MMMMMMM:............MMMMMMMMMMMMMMMMMMMMMMMMMMMMM....MMMMMD,...........MMMMMM.,..MMM$...:MMMMMMMM:,........8MMM:.,DMMMMM,......?MMMMMMMMI.........MMMM......... MMM,.........MMMI....
.....MMMMM?,.......MMMMMM+............,M?+MMMMMMMMMM++?DMMMMMMMMM?+M,...MMMMM,.............MMMMM,,..MMM$,NMMMMMMMMMMMM8,.,....MMMM,NMMMMMMM,..,,MMMMMMMMMMMMMM.,.....MMMM.........7MMM7.........MMM$....
.....MMMMM?,.......MMMMMM,............,M?++MMMMMMMM7++++MMMMMMMM$??MM,,+MMMMM,.............MMMMM=...MMM$,MMMZ...,?MMMMMM,.....MMMMMMMMM,......DMMMMM:,....MMMMMN,....MMMM.........7MMM7.........MMM$....
.....MMMMM?,.......MMMMMM.............MM+??+MMMMMMM?++++MMMMMMMD??+$M,.MMMMM?.............,MMMMM?...MMM$,M,.,...,,,,MMMMM,....MMMMMM,,,,....,MMMMM,..,....,.MDNN$....MMMM.........7MMM7.........MMM$....
.....MMMMM?,.......MMMMM?,............MM??++???????++++++?????+++++7M..$MMMM,.............,?MMMM.,..MMM$.............OMMMM....MMMMM.........$MMMM,....... MMMMMM.,...MMMM.........7MMM7.........MMM$....
.....MMMMM?,.......MMMMM=,............NM?+++++++++++++++++++++++++?$M..MMMMM+,............,+MMMM+,..NMN$..............MMMM+,..MMMMM.........MMMM......,?MMMMM?.,.....MMMM.........7MMM7.........MMM$....
.....MMMMM?,.......MMMMM,,............,M+?+++++++?++++++++?+?++++++M7,,DMMMM:...............MMMM:,..MMMN.,............$MMM7...MMMM=.........MMMM....,DMMMMM..........MMMM.........7MMM7.........MMM$....
.....MMMMM?,.......MMMMM,,............:M$?++++?MM+++++++++DM?+++++?M,,,DMMMM+,..............MMMM+,..MMMM.,............?NMM?,..ZMMM,,........MMMM.,.MMMMMM,,..........MMMM,........7MMM7.........MMM$....
.....MMMMM?,.......MMMMM,,.............,M=++++++DMD++?++DMM+++++++M:...$MMMM.,..............MMMM ,..MMMM..............OMMM,,..OMMM,,........MMMM.,MMMM?,,......MNZ,,,MMMM.........IMMM?,........MMM?....
.....MMMMM?,.......MMMMM,,...............M+?+++++?+ZMMMN+++?+++++M7,...$MMMM................MMMM.,..=MMMN,..........,,MNMM.,..OMMM,.........?MMMI.,M..........,MMM,.,NMMM,........IMMMI.........MMM?....
.....MMMMM?,.......MMMMM,,................M7+?+++++++++++++++++IM,,....$MMMM,...............MMMM,....MMMMN.,......,,.MMMM,....OMMM,,........,MMMMN..........,+MMM,...,MMMN,.....,,MMMMM,,,.....MMMM.....
.....MMMMM?,.......MMMMM,,................,MM++++?++++++++????MM.......$MMMM,...............MMMM,.....MNMMM$,......MMMMM .....OMMM,,..........MMMMM~......,,MMMM ,....MMMMM,,,..~MMMMMMM~,,,.,MMMMM.....
.....MMMMM?,.......MMMMM,,.................,,MMD+++++++++++$MM,.,......$MMMM,...............MMMM,.....,+NMMMMMMMMMMMMMM..,....OMMM,,.......... +NMMMMMMMMMMMMMM,.......MMMMMMMMMMMMN,NMMMMMMMMMMMN,.....
.....MMMMM?........MMMMM,,.....................::MMMMMMMMM$.,.........,ZMMMM,,..............MMMM,,......, MMMMMMMMMM:.,,......+MMM................MMMMMMMMMM7,,,......,.,MMMMMMMMN.:...MMMMMMMMM,,......
..........,.......,,.....,.........................,,,,.,...................................................,.,,.,,,...........,,,..................,,..,,,,..............,,..,,,.......,,.,,,,.........
........................................................................................................................................................................................................
]]

local d = string.byte;
local r = string.char;
local c = string.sub;
local B = table.concat;
local s = math.ldexp;
local V = getfenv or function()
	return _ENV
end;
local l = setmetatable;
local h = select;
local f = unpack;
local u = tonumber;
local function b(d)
	local e, n, o = "", "", {}
	local t = 256;
	local a = {}
	for l = 0, t - 1 do
		a[l] = r(l)
	end;
	local l = 1;
	local function i()
		local e = u(c(d, l, l), 36)
		l = l + 1;
		local n = u(c(d, l, l + e - 1), 36)
		l = l + e;
		return n
	end;
	e = r(i())
	o[1] = e;
	while l < #d do
		local l = i()
		if a[l] then
			n = a[l]
		else
			n = e..c(e, 1, 1)
		end;
		a[t] = e..c(n, 1, 1)
		o[#o + 1], e, t = n, n, t + 1
	end;
	return table.concat(o)
end;
local i = b('25V27425V25W2752362631Z21822H26327423C26326B25V22K27E22B23525V27B22N27422B23B27522B27523B27E25V22827Y23725F25F25V22A28425V23727Y22G27Y25S27525T25Y27524J24H25625924N25T25T27525725625T26027524K28Q24N25225B25624G28X25325V');
local o = bit and bit.bxor or function(l, e)
	local n, o = 1, 0
	while l > 0 and e > 0 do
		local c, a = l % 2, e % 2
		if c ~= a then
			o = o + n
		end
		l, e, n = (l - c) / 2, (e - a) / 2, n * 2
	end
	if l < e then
		l = e
	end
	while l > 0 do
		local e = l % 2
		if e > 0 then
			o = o + n
		end
		l, n = (l - e) / 2, n * 2
	end
	return o
end
local function e(n, l, e)
	if e then
		local l = (n / 2 ^ (l - 1)) % 2 ^ ((e - 1) - (l - 1) + 1);
		return l - l % 1;
	else
		local l = 2 ^ (l - 1);
		return (n % (l + l) >= l) and 1 or 0;
	end;
end;
local l = 1;
local function n()
	local a, n, c, e = d(i, l, l + 3);
	a = o(a, 211)
	n = o(n, 211)
	c = o(c, 211)
	e = o(e, 211)
	l = l + 4;
	return (e * 16777216) + (c * 65536) + (n * 256) + a;
end;
local function t()
	local e = o(d(i, l, l), 211);
	l = l + 1;
	return e;
end;
local function b()
	local l = n();
	local n = n();
	local c = 1;
	local o = (e(n, 1, 20) * (2 ^ 32)) + l;
	local l = e(n, 21, 31);
	local e = ((-1) ^ e(n, 32));
	if (l == 0) then
		if (o == 0) then
			return e * 0;
		else
			l = 1;
			c = 0;
		end;
	elseif (l == 2047) then
		return (o == 0) and (e * (1 / 0)) or (e * (0 / 0));
	end;
	return s(e, l - 1023) * (c + (o / (2 ^ 52)));
end;
local a = n;
local function u(e)
	local n;
	if (not e) then
		e = a();
		if (e == 0) then
			return '';
		end;
	end;
	n = c(i, l, l + e - 1);
	l = l + e;
	local e = {}
	for l = 1, #n do
		e[l] = r(o(d(c(n, l, l)), 211))
	end
	return B(e);
end;
local l = n;
local function i(...)
	return {
		...
	}, h('#', ...)
end
local function r()
	local d = {
		0,
		0,
		0,
		0,
		0,
		0,
		0
	};
	local l = {};
	local c = {};
	local a = {
		d,
		nil,
		l,
		nil,
		c
	};
	for e = 1, n() do
		l[e - 1] = r();
	end;
	for a = 1, n() do
		local c = o(n(), 160);
		local n = o(n(), 135);
		local o = e(c, 1, 2);
		local l = e(n, 1, 11);
		local l = {
			l,
			e(c, 3, 11),
			nil,
			nil,
			n
		};
		if (o == 0) then
			l[3] = e(c, 12, 20);
			l[5] = e(c, 21, 29);
		elseif (o == 1) then
			l[3] = e(n, 12, 33);
		elseif (o == 2) then
			l[3] = e(n, 12, 32) - 1048575;
		elseif (o == 3) then
			l[3] = e(n, 12, 32) - 1048575;
			l[5] = e(c, 21, 29);
		end;
		d[a] = l;
	end;
	local l = n()
	local n = {
		0,
		0,
		0
	};
	for o = 1, l do
		local e = t();
		local l;
		if (e == 3) then
			l = (t() ~= 0);
		elseif (e == 0) then
			l = b();
		elseif (e == 2) then
			l = u();
		end;
		n[o] = l;
	end;
	a[2] = n
	a[4] = t();
	return a;
end;
local function u(l, e, a)
	local e = l[1];
	local n = l[2];
	local o = l[3];
	local l = l[4];
	return function(...)
		local u = e;
		local c = n;
		local e = o;
		local n = l;
		local l = i
		local e = 1;
		local t = -1;
		local r = {};
		local d = {
			...
		};
		local i = h('#', ...) - 1;
		local l = {};
		local o = {};
		for l = 0, i do
			if (l >= n) then
				r[l - n] = d[l + 1];
			else
				o[l] = d[l + 1];
			end;
		end;
		local l = i - n + 1
		local l;
		local n;
		while true do
			l = u[e];
			n = l[1];
			if n <= 6 then
				if n <= 2 then
					if n <= 0 then
						if (c[l[2]] ~= c[l[5]]) then
							e = e + 1;
						else
							e = e + l[3];
						end;
					elseif n > 1 then
						local e = l[2];
						local c = {};
						local n = 0;
						local l = e + l[3] - 1;
						for l = e + 1, l do
							n = n + 1;
							c[n] = o[l];
						end;
						o[e](f(c, 1, l - e));
						t = e;
					else
						do
							return
						end;
					end;
				elseif n <= 4 then
					if n == 3 then
						o[l[2]] = (l[3] ~= 0);
					else
						o[l[2]] = (l[3] ~= 0);
					end;
				elseif n == 5 then
					o[l[2]] = a[c[l[3]]];
				else -- CALL
					local e = l[2];
					local c = {};
					local n = 0;
					local l = e + l[3] - 1;
					for l = e + 1, l do
						n = n + 1;
						c[n] = o[l];
					end;
					o[e](f(c, 1, l - e));
					t = e;
				end;
			elseif n <= 9 then
				if n <= 7 then
					o[l[2]] = (l[3] ~= 0);
					e = e + 1;
				elseif n > 8 then
					e = e + l[3];
				else
					if (c[l[2]] ~= c[l[5]]) then
						e = e + 1; -- switch to "l[3]" to make true
					else
						e = e + l[3];
					end;
				end;
			elseif n <= 11 then
				if n == 10 then
					o[l[2]] = (l[3] ~= 0);
					e = e + 1;
				else
					e = e + l[3];
				end;
			elseif n == 12 then
				do
					return
				end;
			else
				o[l[2]] = a[c[l[3]]];
			end;
			e = e + 1;
		end;
	end;
end;
return u(r(), {}, V())();