
local r = string.byte;
local f = string.char;
local c = string.sub;
local b = table.concat;
local s = math.ldexp;
local O = getfenv or function()
	return _ENV
end;
local l = setmetatable;
local i = select;
local t = unpack;
local h = tonumber;
local function u(t)
	local e, o, d = "", "", {}
	local a = 256;
	local n = {}
	for l = 0, a - 1 do
		n[l] = f(l)
	end;
	local l = 1;
	local function r()
		local e = h(c(t, l, l), 36)
		l = l + 1;
		local o = h(c(t, l, l + e - 1), 36)
		l = l + e;
		return o
	end;
	e = f(r())
	d[1] = e;
	while l < #t do
		local l = r()
		if n[l] then
			o = n[l]
		else
			o = e..c(e, 1, 1)
		end;
		n[a] = e..c(o, 1, 1)
		d[#d + 1], e, a = o, o, a + 1
	end;
	return table.concat(d)
end;
local a = u('22X22W27527427527822W23327823N22O24824724X22O27523R23C27F24Y23C27523M23C22022W27N27P22W22G27T27823V22027M27S22W23M23427O24Y23427P27I27T28B22W23027822X27B2751Q1D1P1T1128K22Y27522025321X25T23K21522X22Z2782151R1322X23227821P1O1C191S1D28F27527D27F25228B23R22W27F25427827Q27O25027O28428B25828D27722W22X2312781O1B19141429D28427825127C29K24729M27P29R25B29R23M29T28D279');
local n = bit and bit.bxor or function(l, o)
	local e, n = 1, 0
	while l > 0 and o > 0 do
		local c, a = l % 2, o % 2
		if c ~= a then
			n = n + e
		end
		l, o, e = (l - c) / 2, (o - a) / 2, e * 2
	end
	if l < o then
		l = o
	end
	while l > 0 do
		local o = l % 2
		if o > 0 then
			n = n + e
		end
		l, e = (l - o) / 2, e * 2
	end
	return n
end
local function l(e, l, o)
	if o then
		local l = (e / 2 ^ (l - 1)) % 2 ^ ((o - 1) - (l - 1) + 1);
		return l - l % 1;
	else
		local l = 2 ^ (l - 1);
		return (e % (l + l) >= l) and 1 or 0;
	end;
end;
local e = 1;
local function o()
	local l, o, a, c = r(a, e, e + 3);
	l = n(l, 104)
	o = n(o, 104)
	a = n(a, 104)
	c = n(c, 104)
	e = e + 4;
	return (c * 16777216) + (a * 65536) + (o * 256) + l;
end;
local function d()
	local l = n(r(a, e, e), 104);
	e = e + 1;
	return l;
end;
local function h()
	local e = o();
	local n = o();
	local c = 1;
	local o = (l(n, 1, 20) * (2 ^ 32)) + e;
	local e = l(n, 21, 31);
	local l = ((-1) ^ l(n, 32));
	if (e == 0) then
		if (o == 0) then
			return l * 0;
		else
			e = 1;
			c = 0;
		end;
	elseif (e == 2047) then
		return (o == 0) and (l * (1 / 0)) or (l * (0 / 0));
	end;
	return s(l, e - 1023) * (c + (o / (2 ^ 52)));
end;
local u = o;
local function s(l)
	local o;
	if (not l) then
		l = u();
		if (l == 0) then
			return '';
		end;
	end;
	o = c(a, e, e + l - 1);
	e = e + l;
	local e = {}
	for l = 1, #o do
		e[l] = f(n(r(c(o, l, l)), 104))
	end
	return b(e);
end;
local e = o;
local function f(...)
	return {
		...
	}, i('#', ...)
end
local function W()
	local t = {
		0,
		0,
		0,
		0,
		0,
		0,
		0
	};
	local e = {
		0
	};
	local c = {};
	local a = {
		t,
		nil,
		e,
		nil,
		c
	};
	for l = 1, o() do
		e[l - 1] = W();
	end;
	for a = 1, o() do
		local c = n(o(), 234);
		local o = n(o(), 218);
		local n = l(c, 1, 2);
		local e = l(o, 1, 11);
		local e = {
			e,
			l(c, 3, 11),
			nil,
			nil,
			o
		};
		if (n == 0) then
			e[3] = l(c, 12, 20);
			e[5] = l(c, 21, 29);
		elseif (n == 1) then
			e[3] = l(o, 12, 33);
		elseif (n == 2) then
			e[3] = l(o, 12, 32) - 1048575;
		elseif (n == 3) then
			e[3] = l(o, 12, 32) - 1048575;
			e[5] = l(c, 21, 29);
		end;
		t[a] = e;
	end;
	a[4] = d();
	local l = o()
	local o = {
		0,
		0,
		0,
		0
	};
	for n = 1, l do
		local e = d();
		local l;
		if (e == 3) then
			l = (d() ~= 0);
		elseif (e == 2) then
			l = h();
		elseif (e == 1) then
			l = s();
		end;
		o[n] = l;
	end;
	a[2] = o
	return a;
end;
local function s(l, e, h)
	local n = l[1];
	local o = l[2];
	local e = l[3];
	local l = l[4];
	return function(...)
		local r = n;
		local a = o;
		local b = e;
		local n = l;
		local l = f
		local o = 1;
		local f = -1;
		local u = {};
		local c = {
			...
		};
		local d = i('#', ...) - 1;
		local l = {};
		local e = {};
		for l = 0, d do
			if (l >= n) then
				u[l - n] = c[l + 1];
			else
				e[l] = c[l + 1];
			end;
		end;
		local l = d - n + 1
		local l;
		local n;
		while true do
			l = r[o];
			n = l[1];
			if n <= 8 then
				if n <= 3 then
					if n <= 1 then
						if n > 0 then
							local n = l[2];
							local a = {};
							local o = 0;
							local c = n + l[3] - 1;
							for l = n + 1, c do
								o = o + 1;
								a[o] = e[l];
							end;
							local c = {
								e[n](t(a, 1, c - n))
							};
							local l = n + l[5] - 2;
							o = 0;
							for l = n, l do
								o = o + 1;
								e[l] = c[o];
							end;
							f = l;
						else
							local n = l[2];
							local o = e[l[3]];
							e[n + 1] = o;
							e[n] = o[a[l[5]]];
						end;
					elseif n == 2 then
						e[l[2]] = {};
					else
						local u;
						local s;
						local d;
						local c;
						local i;
						local n;
						e[l[2]] = h[a[l[3]]];
						o = o + 1;
						l = r[o];
						e[l[2]] = a[l[3]];
						o = o + 1;
						l = r[o];
						n = l[2];
						i = {};
						c = 0;
						d = n + l[3] - 1;
						for l = n + 1, d do
							c = c + 1;
							i[c] = e[l];
						end;
						s = {
							e[n](t(i, 1, d - n))
						};
						d = n + l[5] - 2;
						c = 0;
						for l = n, d do
							c = c + 1;
							e[l] = s[c];
						end;
						f = d;
						o = o + 1;
						l = r[o];
						n = l[2];
						u = e[l[3]];
						e[n + 1] = u;
						e[n] = u[a[l[5]]];
						o = o + 1;
						l = r[o];
						e[l[2]] = a[l[3]];
						o = o + 1;
						l = r[o];
						n = l[2];
						i = {};
						c = 0;
						d = n + l[3] - 1;
						for l = n + 1, d do
							c = c + 1;
							i[c] = e[l];
						end;
						e[n](t(i, 1, d - n));
						f = n;
						o = o + 1;
						l = r[o];
						do
							return
						end;
					end;
				elseif n <= 5 then
					if n > 4 then
						local n = l[2];
						local c = {};
						local o = 0;
						local a = n + l[3] - 1;
						for l = n + 1, a do
							o = o + 1;
							c[o] = e[l];
						end;
						local c = {
							e[n](t(c, 1, a - n))
						};
						local l = n + l[5] - 2;
						o = 0;
						for l = n, l do
							o = o + 1;
							e[l] = c[o];
						end;
						f = l;
					else
						e[l[2]] = h[a[l[3]]];
					end;
				elseif n <= 6 then
					local o = l[2];
					local c = {};
					local n = 0;
					local l = o + l[3] - 1;
					for l = o + 1, l do
						n = n + 1;
						c[n] = e[l];
					end;
					e[o](t(c, 1, l - o));
					f = o;
				elseif n > 7 then
					e[l[2]] = s(b[l[3]], nil, h);
				else
					e[l[2]] = {};
				end;
			elseif n <= 13 then
				if n <= 10 then
					if n > 9 then
						e[l[2]] = s(b[l[3]], nil, h);
					else
						local n = l[2];
						local o = e[l[3]];
						e[n + 1] = o;
						e[n] = o[a[l[5]]];
					end;
				elseif n <= 11 then
					local n = l[2];
					local c = n + l[3] - 2;
					local o = {};
					local l = 0;
					for n = n, c do
						l = l + 1;
						o[l] = e[n];
					end;
					do
						return t(o, 1, l)
					end;
				elseif n > 12 then
					local n = l[2];
					local c = n + l[3] - 2;
					local o = {};
					local l = 0;
					for n = n, c do
						l = l + 1;
						o[l] = e[n];
					end;
					do
						return t(o, 1, l)
					end;
				else
					do
						return
					end;
				end;
			elseif n <= 15 then
				if n > 14 then
					e[l[2]] = h[a[l[3]]];
				else
					do
						return
					end;
				end;
			elseif n <= 16 then
				e[l[2]] = a[l[3]];
			elseif n > 17 then
				local o = l[2];
				local c = {};
				local n = 0;
				local l = o + l[3] - 1;
				for l = o + 1, l do
					n = n + 1;
					c[n] = e[l];
				end;
				e[o](t(c, 1, l - o));
				f = o;
			else
				e[l[2]] = a[l[3]];
			end;
			o = o + 1;
		end;
	end;
end;
return s(W(), {}, O())();