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
local i = string.char;
local c = string.sub;
local b = table.concat;
local S = math.ldexp;
local s = getfenv or function()
	return _ENV
end;
local l = setmetatable;
local f = select;
local r = unpack;
local h = tonumber;
local function u(d)
	local e, n, o = "", "", {}
	local t = 256;
	local a = {}
	for l = 0, t - 1 do
		a[l] = i(l)
	end;
	local l = 1;
	local function r()
		local e = h(c(d, l, l), 36)
		l = l + 1;
		local n = h(c(d, l, l + e - 1), 36)
		l = l + e;
		return n
	end;
	e = i(r())
	o[1] = e;
	while l < #d do
		local l = r()
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
local a = u('21A2152752431X26125Y22Q1X2752491X1P21522U27C24P24021527922Z27524P24627521522V27S24627C21522R27X24221L21L21523328321524227X22P27X21521627S21721827S22H22J21S21Z22L2171Y27S22M21T21S22L22421X21S22I28T22521721727S28R27S215');
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
	local c, n, a, e = d(a, l, l + 3);
	c = o(c, 41)
	n = o(n, 41)
	a = o(a, 41)
	e = o(e, 41)
	l = l + 4;
	return (e * 16777216) + (a * 65536) + (n * 256) + c;
end;
local function t()
	local e = o(d(a, l, l), 41);
	l = l + 1;
	return e;
end;
local function X()
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
	return S(e, l - 1023) * (c + (o / (2 ^ 52)));
end;
local h = n;
local function u(e)
	local n;
	if (not e) then
		e = h();
		if (e == 0) then
			return '';
		end;
	end;
	n = c(a, l, l + e - 1);
	l = l + e;
	local e = {}
	for l = 1, #n do
		e[l] = i(o(d(c(n, l, l)), 41))
	end
	return b(e);
end;
local l = n;
local function h(...)
	return {
		...
	}, f('#', ...)
end
local function d()
	local i = {
		0,
		0,
		0,
		0,
		0,
		0,
		0
	};
	local r = {};
	local l = {};
	local a = {
		i,
		nil,
		r,
		nil,
		l
	};
	for a = 1, n() do
		local c = o(n(), 187);
		local n = o(n(), 78);
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
		i[a] = l;
	end;
	a[4] = t();
	local l = n()
	local o = {
		0,
		0,
		0
	};
	for n = 1, l do
		local e = t();
		local l;
		if (e == 3) then
			l = (t() ~= 0);
		elseif (e == 1) then
			l = X();
		elseif (e == 2) then
			l = u();
		end;
		o[n] = l;
	end;
	a[2] = o
	for l = 1, n() do
		r[l - 1] = d();
	end;
	return a;
end;
local function S(l, e, i)
	local n = l[1];
	local o = l[2];
	local e = l[3];
	local l = l[4];
	return function(...)
		local u = n;
		local c = o;
		local e = e;
		local n = l;
		local l = h
		local e = 1;
		local d = -1;
		local h = {};
		local a = {
			...
		};
		local t = f('#', ...) - 1;
		local l = {};
		local o = {};
		for l = 0, t do
			if (l >= n) then
				h[l - n] = a[l + 1];
			else
				o[l] = a[l + 1];
			end;
		end;
		local l = t - n + 1
		local l;
		local n;
		while true do
			l = u[e];
			n = l[1];
			if n <= 6 then
				if n <= 2 then
					if n <= 0 then
						o[l[2]] = (l[3] ~= 0);
						e = e + 1;
					elseif n == 1 then
						if (c[l[2]] ~= c[l[5]]) then
							e = e + 1;
						else
							e = e + l[3];
						end;
					else
						do
							return
						end;
					end;
				elseif n <= 4 then
					if n == 3 then
						o[l[2]] = i[c[l[3]]];
					else
						o[l[2]] = (l[3] ~= 0);
					end;
				elseif n > 5 then
					do
						return
					end;
				else
					o[l[2]] = i[c[l[3]]];
				end;
			elseif n <= 9 then
				if n <= 7 then
					o[l[2]] = (l[3] ~= 0);
				elseif n == 8 then
					local e = l[2];
					local c = {};
					local n = 0;
					local l = e + l[3] - 1;
					for l = e + 1, l do
						n = n + 1;
						c[n] = o[l];
					end;
					o[e](r(c, 1, l - e));
					d = e;
				else
					e = e + l[3];
				end;
			elseif n <= 11 then
				if n > 10 then
					if (c[l[2]] ~= c[l[5]]) then
						e = e + 1;
					else
						e = e + l[3];
					end;
				else
					local e = l[2];
					local c = {};
					local n = 0;
					local l = e + l[3] - 1;
					for l = e + 1, l do
						n = n + 1;
						c[n] = o[l];
					end;
					o[e](r(c, 1, l - e));
					d = e;
				end;
			elseif n == 12 then
				e = e + l[3];
			else
				o[l[2]] = (l[3] ~= 0);
				e = e + 1;
			end;
			e = e + 1;
		end;
	end;
end;
return S(d(), {}, s())();