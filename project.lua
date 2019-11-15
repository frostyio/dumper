-- if previous version ran, then destroy --
if _G.Destroy then pcall(_G.Destroy) end

-- global variables --

local service = setmetatable({}, {__index = function(self, service) return game:GetService(service) end});

local user_input_service = service.UserInputService;
local run_service = service.RunService;
local teams = service.Teams;
local lighting = service.Lighting;
local players = service.Players;
local tween_service = service.TweenService;
local market_place_service = service.MarketplaceService;

local player = players.LocalPlayer;
local mouse = player:GetMouse();

local update_loop = {};
local drawing_objects = {};

-- ui objects --

local sg ;

local scale = 1.125;
local frame_size = 250;
local frame_size2 = 150;

local engine, drag_ui ;

local keybinds = {};
local is_hovering = false;

local properties = {
	["TextLabel"] = {"BackgroundTransparency", "TextTransparency"},
	["TextButton"] = {"BackgroundTransparency", "TextTransparency"},
	["TextBox"] = {"BackgroundTransparency", "TextTransparency"},

	["ImageLabel"] = {"BackgroundTransparency", "ImageTransparency"},
	["ImageButton"] = {"BackgroundTransparency", "ImageTransparency"},

	["Other"] = {"BackgroundTransparency"}
};

local blacklisted_keys = {
	[Enum.KeyCode.Backspace] = true, 
	[Enum.KeyCode.RightShift] = true
};

-- ui functions --

local create, copy, combine, rgb_to_hsv, hover;

do

	function create(class)
		return function(props)
			local obj = Instance.new(class);
			for k,v in next, props do
				obj[k] = v;
			end
			return obj;
		end
	end

	-- table addons --

	function copy(tbl)
		return setmetatable({}, {__index = tbl});
	end

	function combine(a, b)
		for k, v in next, b do
			if a[k] == nil then
				a[k] = v;
			end
		end
		return a;
	end

	-- used for color picker
	function rgb_to_hsv(r, g, b, a)
		r, g, b, a = r / 255, g / 255, b / 255, a / 255;
		local max, min = math.max(r, g, b), math.min(r, g, b);
		local h, s, v;
		v = max;

		local d = max - min;
		if max == 0 then s = 0 else s = d / max end;
			if max == min then
				h = 0; -- achromatic
			else
				if max == r then
					h = (g - b) / d ;
					if g < b then 
						h = h + 6 ;
					end
				elseif max == g then 
					h = (b - r) / d + 2;
				elseif max == b then
					h = (r - g) / d + 4;
			end
			h = h / 6;
		end

		return h, s, v, a;
	end

	-- used for button hover effect --

	function hover(frame)
		frame.InputBegan:Connect(function(input) 
			if input.UserInputType == Enum.UserInputType.MouseMovement then 
				frame.BackgroundColor3 = Color3.fromRGB(0,0,0);
				tween_service:Create(frame, TweenInfo.new(0.1),{BackgroundTransparency = 0.6}):Play() 
			end 
		end)
		frame.InputEnded:Connect(function(input) 
			if input.UserInputType == Enum.UserInputType.MouseMovement then 
				tween_service:Create(frame, TweenInfo.new(0.1),{BackgroundTransparency = 1}):Play()
			end 
		end)
	end

end

-- drag ui --

do
	local dragging, dragInput, dragStart, startPos, dragitem, drag_frame;

	-- update the selected frame w/ bounds --

	local function update(gui, input)
		local delta = input.Position - dragStart;
		local pos = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y);

		-- bounds --
		if drag_frame then
			local small_x = pos.X.Scale * gui.AbsoluteSize.X + pos.X.Offset;
			local small_y = pos.Y.Scale * gui.AbsoluteSize.Y + pos.Y.Offset;
				
			local far_x = small_x + gui.Size.X.Offset;
			local far_y = small_y + gui.Size.Y.Offset;
			
			local true_x = math.clamp(small_x, 0, drag_frame.AbsoluteSize.X - (far_x - small_x));
			local true_y = math.clamp(small_y, 0, drag_frame.AbsoluteSize.Y - (far_y - small_y));
			
			pos = UDim2.new(0, true_x, 0, true_y);
		end

		gui.Position = pos;
	end

	-- set up the frame --
	local function set_frame(item, moveframe, borderframe, func)
		moveframe = moveframe or item;
		-- started dragging --
		item.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true;
				dragStart = input.Position;
				startPos = moveframe.Position;
				dragitem = moveframe;
				drag_frame = borderframe;
				
				if func then 
					func(dragging);
				end
			
				-- stopped dragging --
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false;
						if func then 
							func(dragging); 
						end
					end
				end)

			end
		end)

		-- update when mouse moves --
		item.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input;
			end
		end)
	end

	user_input_service.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(dragitem, input);
		end
	end)

	drag_ui = set_frame;
end

-- main library start --

do
	local moving_frames = {};
	local color_frame_open;
	
	sg = create("ScreenGui"){
		Parent = game:GetService("CoreGui")
	};
	local frame = create("Frame"){
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = sg
	};
	
	-- moving backgrounds --

	local function proper_background(frame, size)
		local color = Color3.fromRGB(255, 255, 255);
		local fr = create("Frame"){
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ClipsDescendants = true,
			Visible = false,
			Parent = frame,
		};
		local image = create("ImageLabel"){
			BackgroundTransparency = 1,
			Size = size or UDim2.new(1, 0, 1, 0),
			SizeConstraint = "RelativeYY",
			ImageColor3 = color,
			Image = "rbxassetid://3884591443",
			ScaleType = "Tile",
			Parent = fr,
		};
		local image2 = create("ImageLabel"){
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ImageColor3 = color,
			Position = UDim2.new(0, 0, -1, 0),
			Image = "rbxassetid://3884591443",
			ScaleType = "Tile",
			Parent = image,
		};
		local image3 = create("ImageLabel"){
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(-1, 0, -1, 0),
			ImageColor3 = color,
			Image = "rbxassetid://3884591443",
			ScaleType = "Tile",
			Parent = image,
		};
		local image4 = create("ImageLabel"){
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(-1, 0, 0, 0),
			ImageColor3 = color,
			Image = "rbxassetid://3884591443",
			ScaleType = "Tile",
			Parent = image,
		};
		local as = frame.AbsoluteSize;
		if as.X > as.Y then
			image.SizeConstraint = "RelativeXX";
		else
			image.SizeConstraint = "RelativeYY";
		end
		
		table.insert(moving_frames, image);
	end

	-- option oop start --
	
	local new_options; 
	do
		new_options = {
			-- label / button --
			label = function(self, text, func)
				-- option ui creation --

				local frame = create("Frame"){
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20 * scale),
					ZIndex = 2,
					LayoutOrder = self.options_number,
					Parent = self.env.scroll_list
				};
				local label = create("TextLabel") {
					Size = UDim2.new(0.8, 0, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					Text = text == "$blank" and "" or ("[ %s ]"):format(text),
					TextSize = 17 * scale,
					TextScaled = false,
					TextWrapped = true,
					BackgroundTransparency = 1,
					Parent = frame,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = "SourceSansSemibold",
					ZIndex = 2,
				};

				-- functions --
								
                self.change_text = function(self, text)
                    if text == "$blank" then label.Text = "" return end;
					label.Text = ("[ %s ]"):format(text);
				end
				
				frame.InputBegan:Connect(function(input) 
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if func then func() end;
					end
				end)

				-- final setup & return --

				hover(frame);
				self:add_data(frame);
				
				return self;
			end,

			-- number slider --

			slider = function(self, text, current, min, max, func)

				-- frame creation --

				local frame = create("Frame"){
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 40 * scale),
					ZIndex = 2,
					LayoutOrder = self.options_number,
					Parent = self.env.scroll_list
				};
				local label = create("TextLabel"){
					Size = UDim2.new(0.8, 0, 0, 20),
					Position = UDim2.new(0.5, 0, 0, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					Text = ("%s [%.02f]"):format(text, current),
					TextSize = 17 * scale,
					TextScaled = false,
					TextWrapped = true,
					BackgroundTransparency = 1,
					Parent = frame,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = "SourceSans",
					TextXAlignment = "Left",
					ZIndex = 2,
				};
				local min_label = create("TextLabel"){
					Size = UDim2.new(0.161, 0, 0, 20 * scale),
					Position = UDim2.new(0.05, 0, 0, 25 * scale),
					AnchorPoint = Vector2.new(0, .5),
					Text = ("%d"):format(min),
					TextSize = 13 * scale,
					TextScaled = false,
					TextWrapped = true,
					BackgroundTransparency = 1,
					Parent = frame,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = "SourceSans",
					ZIndex = 2,
				};
				local max_label = create("TextLabel"){
					Size = UDim2.new(0.161, 0, 0, 20 * scale),
					Position = UDim2.new(0.8, 0, 0, 25 * scale),
					AnchorPoint = Vector2.new(0, .5),
					Text = ("%d"):format(max),
					TextSize = 13 * scale,
					TextScaled = false,
					TextWrapped = true,
					BackgroundTransparency = 1,
					Parent = frame,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = "SourceSans",
					ZIndex = 2,
				};
				local slider_frame = create("ImageLabel"){
					ImageColor3 = Color3.fromRGB(245, 185, 19),
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 25 * scale),
					Size = UDim2.new(0.6, 0, 0, 3 * scale),
					ZIndex = 2,
					Parent = frame,
					ScaleType = "Slice",
					SliceCenter = Rect.new(Vector2.new(12, 12), Vector2.new(12, 12)),
					Image = "rbxassetid://2851928567",
				};
				local slider = create("ImageLabel"){
					Size = UDim2.new(0.05, 0, 4, 0),
					Position = UDim2.new(current / max, 0, 0.5, 0),
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 2,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Parent = slider_frame,
					ScaleType = "Slice",
					SliceCenter = Rect.new(Vector2.new(6, 6), Vector2.new(6, 6)),
					Image = "rbxassetid://2851928567",
				};

				-- number slider functionality --
				
				local dragging, drag_input = false;
				
				-- switch the slider's position to the mouse's x --
				local function to_mouse()
					local x = mouse.X;
					local absolute_x = slider_frame.AbsolutePosition.X;
					local size = slider_frame.AbsoluteSize.X;

					x = math.clamp(x - absolute_x, 0, size) / size;
					slider.Position = UDim2.new(x, 0, 0.5, 0);
					x = x * max;
					local distance_from_min = min - x
					x = math.clamp(x + min, min, max);
					label.Text = ("%s [%.02f]"):format(text, x);

					-- call the changed function --
					if func then func(x) end
				end

				-- start frame input connections --
				
				frame.InputBegan:Connect(function(input) 
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true;
						to_mouse();
						
						input.Changed:Connect(function(s) 
							if input.UserInputState == Enum.UserInputState.End then
								dragging = false;
								drag_input = nil;
							end
						end)
					end
				end)

				frame.InputChanged:Connect(function(input) 
					if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
						drag_input = input;
					end
				end)

				user_input_service.InputChanged:Connect(function(input) 
					if input == drag_input and dragging then
						to_mouse();
					end
				end)

				-- final setup & return --
				
				
				self:add_data(frame);
				hover(frame);
				
				return self;
			end,


			-- color picker --

			color = function(self, text, c, func)

				-- frame creation --

				local f = frame;
				local frame = create("Frame"){
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20 * scale),
					ZIndex = 2,
					LayoutOrder = self.options_number,
					Parent = self.env.scroll_list
				};
				local label = create("TextLabel"){
					Size = UDim2.new(0.8, 0, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					Text = text or "",
					TextXAlignment = "Left",
					TextSize = 17 * scale,
					TextScaled = false,
					TextWrapped = true,
					BackgroundTransparency = 1,
					Parent = frame,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = "SourceSans",
					ZIndex = 2,
				};
				local image = create("ImageLabel"){
					BackgroundTransparency = 1,
					Position = UDim2.new(0.8, 0, .5, 0),
					Size = UDim2.new(0, 16 * scale, 0, 16 * scale),
					AnchorPoint = Vector2.new(0, 0.5),
					ZIndex = 2,
					ScaleType = "Fit",
					Image = "rbxassetid://3894286630",
					ImageColor3 = Color3.new(1, 0, 0),
					Parent = frame
				};
				
				local color_frame = create("Frame"){
					Parent = f,
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					Size = UDim2.new(0, 357 * scale, 0, 273 * scale),
					Position = UDim2.new(0.0, 300 * scale, 0.0, 100 * scale),
					BorderSizePixel = 0,
					Visible = false,
				}
				local preview = create("Frame"){
					Parent = color_frame,
					Position = UDim2.new(0.852, 0, 0.081, 0),
					Size = UDim2.new(0.1, 0, 0.647, 0),
					SizeConstraint = "RelativeXX",
					BackgroundColor3 = c or Color3.fromRGB(255, 255, 255),
					ZIndex = 2,
				}
				local mask = create("ImageLabel"){
					ZIndex = 2,
					Position = UDim2.new(0.05, 0, 0.073, 0),
					Size = UDim2.new(0.65, 0, 0.65, 0),
					SizeConstraint = "RelativeXX",
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					Parent = color_frame,
					Image = "rbxassetid://3894757147",
				}
				local selector_mask = create("Frame"){
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0.03, 0, 0.03, 0),
					BorderSizePixel = 0,
					SizeConstraint = "RelativeXX",
					ZIndex = 2,
					Parent = mask,
				}
				local hue = create("Frame"){
					BackgroundTransparency = 1,
					Position = UDim2.new(0.725, 0, 0.073, 0),
					Size = UDim2.new(0.075, 0, 0.65, 0),
					SizeConstraint = "RelativeXX",
					ZIndex = 2,
					Parent = color_frame
				}
				local hue_image = create("ImageLabel"){
					ZIndex = 3,
					Position = UDim2.new(0, 0, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					SizeConstraint = "RelativeXY",
					Rotation = 180,
					Parent = hue,
					Image = "rbxassetid://3894304885",
				}
				local selector = create("Frame"){
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0.01, 0),
					BorderSizePixel = 0,
					ZIndex = 4,
					Parent = hue,
				}
				local topbar = create("Frame"){
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0.09, 0),
					Parent = color_frame
				}

				-- color picker functionality --
				
				image.ImageColor3 = c;
				mask.ImageColor3 = Color3.fromHSV(1, 1, 1)
				
				local h, s, v = 0, 0, 0

				-- update everything --

				local function update_color()
					mask.ImageColor3 = Color3.fromHSV(h, 1, 1)
					preview.BackgroundColor3 = Color3.fromHSV(h, s, v)
					image.ImageColor3 = mask.ImageColor3
					if func then
						func(preview.BackgroundColor3)
					end
				end

				-- set color and selector positions from RGB --
				
				local function set_color(r,g,b,color)
					local hh, ss, vv = rgb_to_hsv(r, g, b, 0); -- hue, saturation (1 color, 0 white), value (1 brightess, 0 darkest)
					selector.Position = UDim2.new(0, 0, hh, 0);
					selector_mask.Position = UDim2.new(ss - (ss*2) + 1, 0, vv, 0);
					--
					mask.ImageColor3 = color;
					preview.BackgroundColor3 = color;
					image.ImageColor3 = color;

					h = hh;
				end

				-- hue selector functionality --
								
				do
					local current_input
					local dragging = false

					-- set selector to mouse's position
					
					local function set_to_mouse()
						selector.Position = UDim2.new(0, 0, 0, 
							math.clamp(mouse.Y - hue.AbsolutePosition.Y, 0, 
								hue.AbsoluteSize.Y))
						h = (selector.Position.Y.Offset / hue.AbsoluteSize.Y)
						update_color()
					end
					
					hue.InputBegan:Connect(function(input) 
						if input.UserInputType == Enum.UserInputType.MouseButton1 
							and color_frame.Visible then
							dragging = true
							set_to_mouse()
						end
					end)
					
					hue.InputChanged:Connect(function(input) 
						if not dragging then return end
						current_input = input
					end)
					
					user_input_service.InputChanged:Connect(function(input) 
						if input == current_input then
							set_to_mouse()
						end
					end)
					user_input_service.InputEnded:Connect(function(input) 
						if input.UserInputType == Enum.UserInputType.MouseButton1 
						then
							dragging = false
							current_input = nil
						end
					end)
					
				end

				-- mask selector & color change functionality --
				
				do	
					local current_input
					local dragging = false
					
					local function set_to_mouse()
						local y = mouse.Y
						local x = mouse.X
						selector_mask.Position = UDim2.new(0, 
							math.clamp(x - mask.AbsolutePosition.X, 0, 
								mask.AbsoluteSize.X), 0, 
							math.clamp(y - mask.AbsolutePosition.Y, 0, 
								mask.AbsoluteSize.Y))
						v = 1 - (selector_mask.Position.Y.Offset / 
							mask.AbsoluteSize.Y)
						s = 1 - (selector_mask.Position.X.Offset / 
							mask.AbsoluteSize.X)
				
						update_color();
						func(preview.BackgroundColor3);
					end

					-- mouse changed events --
					
					mask.InputBegan:Connect(function(input) 
						if input.UserInputType == Enum.UserInputType.MouseButton1 
						then
							dragging = true
							set_to_mouse()
						end
					end)
					
					mask.InputChanged:Connect(function(input) 
						if not dragging then return end
						current_input = input
					end)
					
					user_input_service.InputChanged:Connect(function(input) 
						if input == current_input then
							set_to_mouse()
						end
					end)
					user_input_service.InputEnded:Connect(function(input) 
						if input.UserInputType == Enum.UserInputType.MouseButton1 
						then
							dragging = false
							current_input = nil
						end
					end)

				end
				
				-- visibility functionality --

				local f = {}				
				f.hide = function(s)
					color_frame.Visible = false
					self.env.original_env.toggled = false
				end
				f.show = function(s)
					color_frame.Visible = true
					self.env.original_env.toggled = true
				end
				f.toggle = function(s)
					if color_frame_open ~= color_frame and color_frame_open~=nil then
						return;
					end
					color_frame.Visible = not color_frame.Visible
					self.env.original_env.toggled = color_frame.Visible
					color_frame_open = color_frame.Visible and color_frame or nil
				end

				-- on click show color picker --
				frame.InputBegan:Connect(function(input) 
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						f:toggle();
					end
				end)

				-- final setup --
				drag_ui(topbar, color_frame);
				proper_background(color_frame, UDim2.new(0, 300 * scale,0,300 * scale));
				hover(frame);
				set_color(c.R, c.G, c.B, c);
			end,

			-- button toggle --

			toggle = function(self, title, toggled, func)

				-- frame creation --

				local frame = create("Frame"){
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20 * scale),
					ZIndex = 2,
					LayoutOrder = self.options_number,
					Parent = self.env.scroll_list
				};
				local label = create("TextLabel"){
					Size = UDim2.new(0.8, 0, 1, 0),
					Position = UDim2.new(0.6, 0, 0, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					Text = title,
					TextSize = 17 * scale,
					TextScaled = false,
					TextXAlignment = "Left",
					TextWrapped = true,
					BackgroundTransparency = 1,
					Parent = frame,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = "SourceSans",
					ZIndex = 2,
				};
				local rounded = create("ImageLabel"){
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.075, 0, 0.55, 0),
					Size = UDim2.new(0.4, 0, 0.4, 0),
					ZIndex = 2,
					ImageColor3 = Color3.fromRGB(255, 84, 84),
					SizeConstraint = "RelativeYY",
					Image = "rbxassetid://2851925780",
					ScaleType = "Slice",
					SliceCenter = Rect.new(Vector2.new(15, 15),Vector2.new(15, 15)),
					Parent = frame
				};

				-- toggle functionality --
				
				local self = copy(self);
				
				self.enabled = false;
				self.tweening = false;
				self.enable = function(self)
					self.tweening = true;
					tween_service:Create(rounded, TweenInfo.new(0.5), {
					ImageColor3 = Color3.fromRGB(83, 255, 94)}):Play()
					self.enabled = true
					if func then func(self.enabled) end
					wait(.5)
					self.tweening = false
				end
				self.disable = function(self)
					self.tweening = true;
					tween_service:Create(rounded, TweenInfo.new(0.5), {
					ImageColor3 = Color3.fromRGB(255, 84, 84)}):Play()
					self.enabled = false
					if func then func(self.enabled) end
					wait(.5)
					self.tweening = false
				end
				self.toggle = function(self)
					if self.tweening then return end;
					if self.enabled then
						self:disable();
					else
						self:enable();
					end
				end
				
				if toggled then
					self:enable();
				end

				local current_keybind;
				frame.InputBegan:Connect(function(input) 
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						self:toggle();

					-- keybind functionality --

					elseif input.UserInputType == Enum.UserInputType.MouseButton2 then

						-- remove current keybind --

						if current_keybind then
							table.remove(keybinds, current_keybind);
						end
						label.Text = title .. " [...]";

						-- wait till key is pressed --

						local Keybind, Connection;
						Connection = user_input_service.InputBegan:Connect(function(input, gpe) 
							if gpe then return end;
							if blacklisted_keys[input.KeyCode] ~= true and input.UserInputType == Enum.UserInputType.Keyboard then
								Keybind = input;
								Connection:Disconnect();
							elseif blacklisted_keys[input.KeyCode] then
								Keybind = "Escape";
							end
						end);

						repeat wait(.2) until Keybind;

						-- set keybind

						if Keybind ~= "Escape" then
							current_keybind = #keybinds + 1;
							label.Text = ("%s [%s]"):format(title, Keybind.KeyCode.Name)
							table.insert( keybinds, current_keybind, {KeyCode = Keybind.KeyCode, func = function() self:toggle() end} );
						else
							label.Text = title;
						end
					end
				end)

				-- final setup & return --
				
				self:add_data(frame);
				hover(frame);
				
				return self;
			end,

			-- extension --

			extension = function(self, text)

				-- extension ui creation --

				local frame = create("Frame"){
					BackgroundTransparency = 0.25,
					BackgroundColor3 = Color3.fromRGB(10, 10, 10),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 20 * scale),
					ZIndex = 2,
					LayoutOrder = self.options_number,
					Parent = self.env.scroll_list,
					ClipsDescendants = true,
				};
				local label = create("TextLabel"){
					Size = UDim2.new(.7, 0, 0, 12 * scale),
					Position = UDim2.new(0.55, 0, 0, 3 * scale),
					AnchorPoint = Vector2.new(0.5, 0),
					Text = ("%s"):format(text),
					TextSize = 17 * scale,
					Font = "SourceSansSemibold",
					TextScaled = false,
					TextWrapped = true,
					BackgroundTransparency = 1,
					Parent = frame,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextXAlignment = "Left",
					ZIndex = 2,
				};
				local image = create("ImageLabel"){
					BackgroundTransparency = 1,
					Position = UDim2.new(0.1, 0, 0, 7 * scale),
					Size = UDim2.new(0, 7 * scale, 0, 7 * scale),
					ZIndex = 2,
					ScaleType = "Fit",
					Image = "rbxassetid://130424513",
					ImageColor3 = Color3.new(1, 1, 1),
					Parent = frame
				};
				
				local scroll_frame = create("ScrollingFrame"){
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 20 * scale),
					Size = UDim2.new(1, 0, 1, -25 * scale),
					ZIndex = 2,
					ScrollBarThickness = 1,
					Parent = frame,
					CanvasSize = UDim2.new(0, 0, 0, 0),
				}
				local list_layout = create("UIListLayout"){
					Parent = scroll_frame,
					SortOrder = "LayoutOrder",
				}

				-- extension functionality (very messy) --
				
				local f = {}
				f.showing = false;
				f.tweening = false;
				f.original_size = frame.Size;
				local first_self;

				-- extend extensions --
				
				f.show = function(self, a)
					if first_self == nil then first_self = self end
					self = first_self
					f.tweening = true;
					frame:TweenSize(f.original_size, 1, 1, 0.3, 1);
					f.showing = true;

					-- tween the frame to correct size --
					coroutine.wrap(function() 
						local start_time = tick()
						while tick() - start_time <= .3 do
							-- updating size --
							self.size = self:calculate_size();
							self.parent:update_size();

							-- updating scroll --

							local y = frame.AbsolutePosition + frame.AbsoluteSize;
							y = y.Y + self.size;
							self.env.scroll_list.CanvasPosition = Vector2.new(0, y);

							run_service.RenderStepped:Wait();
						end
					end)()

					wait(.3);
					f.tweening = false;
				end

				f.hide = function(self, b)
					f.tweening = true;
					if not b then f.original_size = frame.Size; end
					frame:TweenSize(UDim2.new(1, 0, 0, 20 * scale), 1, 1, 0.3, 1);
					f.showing = false;

					-- tween the frame to the correct size --
					coroutine.wrap(function() 
						local start_time = tick()
						while tick() - start_time <= .3 do
							-- updating size --
							self.size = self:calculate_size();
							self.parent:update_size();

							run_service.RenderStepped:Wait();
						end
					end)()

					wait(.3);
					f.tweening = false;
				end
				f.toggle = function(self)
					if f.tweening then return end;
					if f.showing then
						f.hide(self);
					else
						f.show(self);
					end
				end

				-- toggle --
				
				label.InputBegan:Connect(function(input) 
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						f.toggle(self);
					end
				end)

				-- setting up fake extension environment --
				
				local fake_self = copy(new_options);
				
				local options = combine(copy(new_options), fake_self);
				options.env = {};
				options.options_number = 0;
				options.options = {};
				options.parent = fake_self;
				options.size = 212;
				options.env.scroll_list = scroll_frame;
				options.env.original_env = self.env.original_env;
				options.is_extension = true;
				fake_self.f = f;
				
				fake_self.option_data = options;

				-- fake update size --

				fake_self.update_size = function(self)
					options.size = fake_self.calculate_size(options);
					if f.showing == false then
						frame.Size = UDim2.new(1, 0, 0, 20);
						return;
					end

					frame.Size = UDim2.new(0, 128 * scale, 0, math.clamp(options.size, 20 * scale, frame_size2 * scale));
					if options.size > (frame_size2 * scale) then
						scroll_frame.CanvasSize = UDim2.new(0, 0, 1, options.size - (frame_size2 * scale) - 20);
					else
						scroll_frame.CanvasSize = UDim2.new(0, 0, 0, 0);
					end
				end

				-- fake new --
				
				fake_self.new = function(s, ty, ...) 
					if ty == "extension" then
						return error("Cannot have an extension in an extension.", 0);
					end
					if ty ~= "slider" then
						f.original_size = f.original_size + UDim2.new(0,0,0,25 * scale);
					else
						f.original_size = f.original_size + UDim2.new(0,0,0,40 * scale);
					end
					return options:new(ty, ...);
				end;

				-- final setup & return --
				
				self:add_data(frame);
				
				return fake_self;
			end,

			-- dropdown (to be redone) --

			dropdown = function(self, text, func)

				-- frame creation --

				local frame = create("Frame"){
					BackgroundTransparency = 0.25,
					BackgroundColor3 = Color3.fromRGB(1, 28, 84),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 20 * scale),
					ZIndex = 2,
					LayoutOrder = self.options_number,
					Parent = self.env.scroll_list,
					ClipsDescendants = true,
				};
				local label = create("TextLabel"){
					Size = UDim2.new(.9, 0, 0, 12 * scale),
					Position = UDim2.new(0.2, 0, 0, 3 * scale),
					Text = ("%s"):format(text),
					TextSize = 17 * scale,
					TextScaled = false,
					TextWrapped = true,
					BackgroundTransparency = 1,
					Parent = frame,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = "SourceSans",
					TextXAlignment = "Left",
					ZIndex = 2,
					TextWrapped = false,
					Font = "SourceSansSemibold",
				};
				local image = create("ImageLabel"){
					BackgroundTransparency = 1,
					Position = UDim2.new(0.1, 0, 0, 7 * scale),
					Size = UDim2.new(0, 7 * scale, 0, 7 * scale),
					ZIndex = 2,
					ScaleType = "Fit",
					Image = "rbxassetid://130424513",
					ImageColor3 = Color3.new(1, 1, 1),
					Parent = frame
				};
				
				local scroll_frame = create("ScrollingFrame"){
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 20 * scale),
					Size = UDim2.new(1, 0, 1, -25 * scale),
					ZIndex = 2,
					ScrollBarThickness = 1,
					Parent = frame,
					CanvasSize = UDim2.new(0, 0, 0, 0),
				}
				local list_layout = create("UIListLayout"){
					Parent = scroll_frame,
					SortOrder = "LayoutOrder",
				}

				-- basically same as extension --
				-- not bothering to make pretty as this will be --
				-- removed and redone --
				
				local f = {};
				f.showing = false;
				f.tweening = false;
				f.original_size = frame.Size;
				
				local time = 0.02--.3
				
				f.show = function(self)
					f.tweening = true;
					frame:TweenSize(f.original_size, 1, 1, time, 1);
					f.showing = true;
					coroutine.wrap(function() 
						local start_time = tick();
						while tick() - start_time <= time do
							self.size = self:calculate_size();
							self.parent.update_size();
							local y = frame.AbsolutePosition + frame.AbsoluteSize;
							y = y.Y + self.size;
							self.env.scroll_list.CanvasPosition = Vector2.new(0, y);
							run_service.RenderStepped:Wait();
						end
					end)()
					wait(time);
					f.tweening = false;
				end
				f.hide = function(self)
					f.tweening = true;
					f.original_size = frame.Size;
					frame:TweenSize(UDim2.new(1, 0, 0, 20 * scale), 1, 1, time, 1);
					f.showing = false;
					coroutine.wrap(function() 
						local start_time = tick()
						while tick() - start_time <= time do
							self.size = self:calculate_size();
							self.parent:update_size();
							run_service.RenderStepped:Wait();
						end
					end)()
					wait(time);
					f.tweening = false;
				end
				f.toggle = function(self)
					if f.tweening then return end;
					if f.showing then
						f.hide(self);
					else
						f.show(self);
					end
				end
				
				label.InputBegan:Connect(function(input) 
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						f.toggle(self);
					end
				end)
				
				
				local fake_self = copy(new_options);
				
				local options = combine(copy(new_options), fake_self);
				options.env = {};
				options.options_number = 0;
				options.options = {};
				options.parent = fake_self;
				options.size = 212;
				options.env.scroll_list = scroll_frame;
				options.env.original_env = self.env.original_env;
				options.is_extension = true;
				
				fake_self.option_data = options;
				fake_self.update_size = function(self)
					options.size = fake_self.calculate_size(options);
					frame.Size = UDim2.new(0, 128 * scale, 0, math.clamp(options.size, 20 * scale, frame_size2 * scale));

					if options.size > (frame_size2 * scale) then
						scroll_frame.CanvasSize = UDim2.new(0, 0, 1, options.size - (frame_size2 * scale));
					else
						scroll_frame.CanvasSize = UDim2.new(0, 0, 0, 0);
					end
				end
				
				local current_enabled;
				
				fake_self.new = function(s, title, enabled) 
					f.original_size = f.original_size + UDim2.new(0,0,0,25 * scale)
					local a = f;
					local f = {};
					local frame = create("Frame"){
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 20 * scale),
						ZIndex = 2,
						Parent = scroll_frame
					};
					local l = create("TextLabel"){
						Size = UDim2.new(0.7, 0, 0, 12 * scale),
						Position = UDim2.new(0.55, 0, 0, 3 * scale),
						AnchorPoint = Vector2.new(0.5, 0),
						Text = ("%s"):format(title),
						TextSize = 17 * scale,
						TextScaled = false,
						TextWrapped = true,
						BackgroundTransparency = 1,
						Parent = frame,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Font = "SourceSans",
						TextXAlignment = "Left",
						ZIndex = 2,
					};
					local image = create("ImageLabel"){
						BackgroundTransparency = 1,
						Position = UDim2.new(0.8, 0, 0.5, 0),
						Size = UDim2.new(.9, 0, .9, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						Image = "rbxassetid://3899585657",
						ZIndex = 2,
						Parent = frame,
						SizeConstraint = "RelativeYY",
					};
					
					f.enabled = false;
					f.enable = function(self)
						f.enabled = true;
						image.Image = "rbxassetid://3899586131";
						if current_enabled ~= f and current_enabled then
							current_enabled:disable();
						end
						current_enabled = f;
						label.Text = ("%s [%s]"):format(text, title);
						if func then func(title, f.enabled) end;
					end
					f.disable = function(self)
						f.enabled = false;
						image.Image = "rbxassetid://3899585657";
						if current_enabled == f then current_enabled = nil end;
						if func then func(title, f.enabled) end;
					end
					f.toggle = function(self)
						if f.enabled then
							f:disable();
						else
							f:enable();
						end
					end
					frame.InputBegan:Connect(function(input) 
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							f:toggle();
						end
					end)
					
					if enabled then
						f:enable()
					end
					
					if not a.showing then
						frame.Size = UDim2.new(1, 0, 0, 20 * scale)
					end
					return f
				end;
				
				
				self:add_data(frame);
				
				return fake_self;
			end,

			-- option functions --

			-- calculate correct frame sizes --

			calculate_size = function(self)
				local size = 40 * scale; -- add for topbar + spacing + padding
				for _, frame in next, self.options do
					size = size + frame.AbsoluteSize.Y;
				end
				return size;
			end,

			-- adding option to table --

			add_data = function(self, obj)
				self.options_number = self.options_number + 1;
				table.insert(self.options, obj);
				self.size = self:calculate_size();
				self.parent:update_size();
				delay(1, function()  
					self.size = self:calculate_size();
					self.parent:update_size();
				end)
			end,

			-- updating frame size --

			update = function(self)
				self.size = self:calculate_size();
				self.parent:update_size();
			end,

			-- call function --
			new = function(self, class, ...)
				if not(self[class]) then
					return warn(("invalid class [%s]"):format(class));
				end
				return self[class](self, ...);
			end
		}

		-- allows for tab("toggle", "hello");
		new_options = setmetatable(new_options, {
			__call = function(self, ...) 
				return self.new(...);
			end
		})
	end

	-- new tab setup --
	
	local new_menu; 
	do 
		new_menu = {

			-- minimize and maximize functions --

			maximize = function(self)
				self.env.list_frame:TweenSize(UDim2.new(1,0,1,-29), 1, 1, 0.2, 1);
				self.minimized = false;
			end,
			minimize = function(self)
				self.env.list_frame:TweenSize(UDim2.new(1, 0, 0, 0), 1, 1, 0.2, 1);
				self.minimized = true;
			end,
			toggle = function(self)
				if self.minimized then
					self:maximize();
				elseif self.minimized == nil then
					self:maximize();
				else
					self:minimize();
				end
			end,

			-- hiding and showing tab functions --

			hide = function(self)
				self.hidden = true;
				self.transparencies = {};

				local frame = self.env.main_frame;
				for _, object in pairs(frame:GetDescendants()) do
					if object:IsA("GuiObject") then
						local data = {};
						for _, property in pairs(properties[object.ClassName] or properties["Other"]) do 
							data[property] = object[property];
							tween_service:Create(object, TweenInfo.new(0.2), {[property] = 1}):Play();
						end
						self.transparencies[object] = data;
					end
				end
			end,

			show = function(self)
				self.hidden = false;
				local frame = self.env.main_frame;
				for _, object in pairs(frame:GetDescendants()) do
					if object:IsA("GuiObject") and self.transparencies[object] then
						local data = self.transparencies[object];
						for property, value in pairs(data) do 
							tween_service:Create(object, TweenInfo.new(0.2), {[property] = value}):Play();
						end
					end
				end
			end,

			-- update frame size --

			update_size = function(self)
				self.env.main_frame.Size = UDim2.new(0, 128 * scale, 0, 
					math.clamp(self.option_data.size, 20 * scale, frame_size * scale) + 5);
				if self.option_data.size > frame_size * scale then
					self.env.scroll_list.CanvasSize = UDim2.new(0, 0, 1, 
						self.option_data.size - (frame_size * scale));
				else
					self.env.scroll_list.CanvasSize = UDim2.new(0, 0, 0, 0);
				end
			end,

			-- creation function --

			tab = function(self, title, visible, position)
				-- auto position --
				if not(position) then -- size calculations
					if self.env.last_pos then
						local last_pos = self.env.last_pos;
						local new_pos;
						local x = last_pos.X.Offset;
						local absolute_size = sg.AbsoluteSize.X;
						if absolute_size-(x+(140*scale)+(115*scale)) < 115*scale then
							new_pos = UDim2.new(0, 115 * scale, 0, (25 * scale) + (frame_size * scale))
						else
							new_pos = last_pos + UDim2.new(0, 140 * scale, 0, 0);
						end
						self.env.last_pos = new_pos;
						position = new_pos;
					else
						self.env.last_pos = UDim2.new(0, 115 * scale, 0, 25 * scale);
					end
				end

				-- environment --
				
				local f = {}
				for k,v in next, self.env do f[k] = v end
				local self = {}
				for k,v in next, new_menu do self[k] = v end
				self.env = f

				-- frame creation --
				
				local frame = create("Frame"){
					BackgroundTransparency = 1,
					Position = position or UDim2.new(0, 115 * scale, 0, 25 * scale),
					Size = UDim2.new(0, 128 * scale, 0, 212 * scale),
					Visible = visible,
					Parent = self.env.main_frame
				};
				local topbar = create("Frame"){
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22 * scale),
					Parent = frame,
					ZIndex = 3,
				};
				local title_label = create("TextLabel"){
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 2 * scale),
					Size = UDim2.new(1, 0, 1, 0),
					Text = title or "unnamed",
					TextSize = 17 * scale,
					TextScaled = false,
					TextWrapped = false,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					ZIndex = 2,
					Font = "SourceSansBold",
					Parent = topbar
				};
				local topbar_background = create("Frame"){
					BackgroundColor3 = Color3.fromRGB(32, 34, 35),
					Size = UDim2.new(1, 0, 0, 24 * scale),
					BorderSizePixel = 0,
					ZIndex = 0,
					Parent = topbar
				};
				
				local list_frame = create("Frame"){
					BackgroundColor3 = Color3.fromRGB(32, 34, 35),
					Position = UDim2.new(0, 0, 0, 26 * scale),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 0),
					ZIndex = 0,
					ClipsDescendants = true,
					Parent = frame,
				};
				local scrolling_list_frame = create("ScrollingFrame"){
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 5),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, -6),
					ZIndex = 2,
					ScrollBarThickness = 1,
					Parent = list_frame,
					CanvasSize = UDim2.new(0, 0, 1.05, 0),
				};
				local list_layout = create("UIListLayout"){
					Padding = UDim.new(0, 2),
					SortOrder = "LayoutOrder",
					Parent = scrolling_list_frame
				};

				-- setup --
				
				local dragging = false;
				
				proper_background(list_frame, UDim2.new(0, 200 * scale, 0, 200 * scale));
				proper_background(topbar, UDim2.new(0, 200 * scale, 0, 200 * scale));
				drag_ui(topbar, frame, self.env.main_frame, function(b) dragging = b; end);
				
				--
				
				self.env.main_frame = frame;
				self.env.list_frame = list_frame;
				self.env.scroll_list = scrolling_list_frame;
				
				-- events
				
				self.env.original_env.toggled = false
				
				topbar.InputBegan:Connect(function(input) 
					if input.UserInputType == Enum.UserInputType.MouseButton2 then
						if self.env.original_env.toggled == false then
							self.env.original_env.toggled = true;
							self:maximize();
						else
							self.env.original_env.toggled = false
							self:minimize();
						end
					end
				end)

				-- maximizing and minimizing
				
				frame.MouseEnter:Connect(function() 
					if self.env.original_env.toggled then return end;
					if not(self.minimized) then return end

					is_hovering = true;
					self:maximize();
				end)
				frame.MouseLeave:Connect(function() 
					if self.env.original_env.toggled then return end;
					if dragging then return end;
					if self.minimized then return end;

					is_hovering = false;
					self:minimize();
				end)
				
				-- self return
				
				local options = combine(copy(new_options), self);
				options.options_number = 0;
				options.options = {};
				options.parent = self;
				options.size = 212;
				options.original_env = self.env
				options.env.original_env = self.env
				self.option_data = options;
				
				self.new = function(self, ...) 
					return options:new(...);
				end;
				
				return self;
			end,
			new = function(self, class, ...)
				return self[class](self, ...);
			end
		}
		new_menu = setmetatable(new_menu, {
			__call = function(self, ...) 
				return self.new(...);
			end
		})
	end

	-- main engine function --
	
	engine = function(frame)
		local env, self = {}, {tabs = {}};
		
		self.last_pos = nil;
		
		env.main_frame = frame;
		self.env = env;
		self.env.original_env = self.env;
		self.new = function(self, ...) 
			local tab = combine(copy(new_menu), self):new(...);
			table.insert(self.tabs, tab);
			return tab;
		end;

		local Circle = Drawing and Drawing.new("Circle")
		if Circle then
			Circle.Visible = sg.Enabled 
			Circle.Color = Color3.fromRGB(255, 255, 255);
			Circle.Radius = 3;
			Circle.Filled = true;
		end

		self.hide = function() 
			for _, v in pairs(self.tabs) do v:hide() end wait(0.2) sg.Enabled = false 
		end;
		self.show = function() 
			sg.Enabled = true for _, v in pairs(self.tabs) do v:show() end 
		end;

		local showing = true;
		local behavior;

		table.insert(keybinds, {KeyCode = Enum.KeyCode.RightShift, func = function() 
			showing = not showing;
			behavior = showing and user_input_service.MouseBehavior or nil;
			if showing then self:show() else self:hide() end;
		end})

		table.insert(update_loop, function() 
			Circle.Position = Vector2.new(mouse.X, mouse.Y + 36);
			Circle.Visible = is_hovering;

			if behavior then
				user_input_service.MouseBehavior = Enum.MouseBehavior.Default;
			end
		end)
		
		return self, sg
	end
	
	-- moving frames function --

	coroutine.wrap(function()
		wait(.5)
		while script.Name ~= "Destroyed" do
			for _, frame in pairs(moving_frames) do
				frame.Position = UDim2.new(0, 0, 0, 0)
				frame:TweenPosition(
					UDim2.new(1, 0, 1, 0), 
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Linear, 
					3, 1
				)
			end
			wait(3)
		end
	end)()

	-- keybinds --

	user_input_service.InputBegan:Connect(function(input, gpe) 
		if gpe then return end;

		local keycodes = {};
		for k, v in pairs(keybinds) do
			if v.KeyCode == input.KeyCode then
				v.func();
			end
		end
	end)

	------------------------------------------------------
	
	------------------------------------------------------
	
	------------------------------------------------------
	
	local function get_team(client)
		if game.PlaceId == 3233893879 then -- bad business
			for _, obj in next, teams:GetDescendants() do
				if obj.Name == client.Name then
					return obj.Parent.Parent
				end
			end
		end
		
		return client.Team
	end
	local function get_character(client)
		if game.PlaceId == 3233893879 then -- bad business
			return workspace.Characters:FindFirstChild(client.Name)
		end
		return client.Character
	end
	
	local function get_humanoid(character)
		return character:FindFirstChildOfClass("Humanoid")
	end
	
	local function get_root_name()
		if game.PlaceId == 3233893879 then -- bad business
			return "Root"
		end
		return "HumanoidRootPart"
	end
	
	local function get_root(character)
		return character:FindFirstChild(get_root_name())
	end
	
	run_service.RenderStepped:Connect(function() 
		for i, func in pairs(update_loop) do
			func(i);
		end
	end)
	
	local eng, sg = engine(frame);
	
	local visuals, aimbot = {}, {};
	
	-- functions
	
	local function get_screen_size()
		return sg.AbsoluteSize;
	end

	sg.Enabled = false;
	
	-- start of visuals
	
	do
	
		local boxes = false;
		local tracers = false;
		local names = false;
		local show_team = true;
		local using_team_color = false;
		local fullbright = false;
		local transparency = 1;
		local team_color = Color3.fromRGB(43, 156, 255);
		local enemy_color = Color3.fromRGB(220, 25, 25);
		local limit_distance = false;
		
		local tab;
		
		function visuals.init()
			tab = eng:new("tab", "visuals", true);
		end
		function visuals.configure_esp(b, t, n)
			if not(tab) then visuals.init() end;

			b, t, n = b or true, t or true, n or true;
			
			tab:new("label", "esp");
			if b then
				tab:new("toggle", "boxes", false, function(b) boxes = b end);
			end
			if t then
				tab:new("toggle", "tracers", false, function(b) tracers = b end);
			end
			if n then
				tab:new("toggle", "names", false, function(b) names = b end);
			end
			local extension = tab:new("extension", "config");
			extension:new("toggle", "team colors", function(b) using_team_color = b end)
			extension:new("slider", "opacity", 0.5, 0, 1, function(n) transparency = n end)
			extension:new("color", "team color", team_color, function(c) team_color = c end);
			extension:new("color", "enemy color", enemy_color, function(c) enemy_color = c end);
		end
		function visuals.configure_misc(fb)
			if not(tab) then visuals.init() end;
			fb = fb or true;
			
			tab:new("label", "misc");
			if fb then
				local old_settings = {};
				local check_fors = {"Ambient", "Brightness", "FogEnd", "FogStart", "ClockTime"};
				tab:new("toggle", "fullbright", fullbright, function(b) 
					if b then
						fullbright = true;
						for _, check in pairs(check_fors) do
							old_settings[check] = lighting[check];
						end
					else
						fullbright = false;
						delay(.1, function() 
							for check, value in pairs(old_settings) do
								lighting[check] = value;
							end
						end)
					end
				end);
				
				table.insert(update_loop, function() 
					if fullbright then
						lighting.Ambient = Color3.fromRGB(0, 0, 0);
						lighting.Brightness = 3;
						lighting.FogEnd, lighting.FogStart = 10000, 0;
						lighting.TimeOfDay = 12;
					end
				end)
			end
		end
		function visuals.all()
			visuals.init();
			visuals.configure_esp();
			visuals.configure_misc();
		end
	
		local ESP = {};
		local CustomObjects = {};
		local CustomData = {};

		function visuals.new_esp_object(self, type, ...)
			local objects = {};
			local data = {
				objects = objects,
				color = Color3.fromRGB(90, 49, 13),
				transparency = 1,
				thickness = 3,
				destroyed = false,
				visible = true
			};

			local function destroy()
				data.destroyed = true;
				data.update = nil;
			end

			if type == "box" then
				local object, color, transparency, thickness = ...
				data.color, data.transparency = color or Color3.fromRGB(90, 49, 13), transparency or 1;
				data.thickness = thickness or 3;

				-- create the 12 line objects --
				for i = 1, 12 do
					objects[("Line%d"):format(i)] = {Type = "Line", From = Vector2.new(), To = Vector2.new()};
				end
				data.object = object;

				local function update()
					if script.Name == "Destroyed" then
						destroy();
					end

					local Camera = workspace.CurrentCamera
					if not(Camera) then return end
					if not(object and object:IsDescendantOf(workspace)) then
						destroy();
					end

					local function wtvp(...) return Camera:WorldToViewportPoint(...) end

					local cf = object.CFrame;
					local _, on_screen = Camera:WorldToScreenPoint(cf.p);
					local size = object.Size;
					local x, y, z = size.X, size.Y, size.Z;
					local v3 = CFrame.new;
					-- front
					local front_top_left, front_top_left_showing = wtvp((cf * v3(-(x / 2), y / 2, z / 2)).p);
					local front_top_right, front_top_right_showing = wtvp((cf * v3(x / 2, y / 2, z / 2)).p);
					local front_bottom_left, front_bottom_left_showing = wtvp((cf * v3(-(x / 2), -(y / 2), z / 2)).p);
					local front_bottom_right, front_bottom_right_showing = wtvp((cf * v3(x / 2, -(y / 2), z / 2)).p);
					front_top_left = Vector2.new(front_top_left.X, front_top_left.Y);
					front_top_right = Vector2.new(front_top_right.X, front_top_right.Y);
					front_bottom_left = Vector2.new(front_bottom_left.X, front_bottom_left.Y);
					front_bottom_right = Vector2.new(front_bottom_right.X, front_bottom_right.Y);
					-- back
					local back_top_left, back_top_left_showing = wtvp((cf * v3(-(x / 2), y / 2, -(z / 2))).p);
					local back_top_right, back_top_right_showing = wtvp((cf * v3(x / 2, y / 2, -(z / 2))).p);
					local back_bottom_left, back_bottom_left_showing = wtvp((cf * v3(-(x / 2), -(y / 2), -(z / 2))).p);
					local back_bottom_right, back_bottom_right_showing = wtvp((cf * v3(x / 2, -(y / 2), -(z / 2))).p);
					back_top_left = Vector2.new(back_top_left.X, back_top_left.Y);
					back_top_right = Vector2.new(back_top_right.X, back_top_right.Y);
					back_bottom_left = Vector2.new(back_bottom_left.X, back_bottom_left.Y);
					back_bottom_right = Vector2.new(back_bottom_right.X, back_bottom_right.Y);

					objects.Line1.From = front_top_left;
					objects.Line1.To = front_top_right;
					objects.Line1.Visible = front_top_right_showing;

					objects.Line2.From = front_top_right;
					objects.Line2.To = front_bottom_right;
					objects.Line2.Visible = front_bottom_right_showing;

					objects.Line3.From = front_bottom_right;
					objects.Line3.To = front_bottom_left;
					objects.Line3.Visible = front_bottom_left_showing;

					objects.Line4.From = front_bottom_left;
					objects.Line4.To = front_top_left;
					objects.Line4.Visible = front_top_left_showing;

					objects.Line5.From = back_top_left;
					objects.Line5.To = back_top_right;
					objects.Line5.Visible = back_top_right_showing;

					objects.Line6.From = back_top_right;
					objects.Line6.To = back_bottom_right;
					objects.Line6.Visible = back_bottom_right_showing;

					objects.Line7.From = back_bottom_right;
					objects.Line7.To = back_bottom_left;
					objects.Line7.Visible = back_bottom_left_showing;

					objects.Line8.From = back_bottom_left;
					objects.Line8.To = back_top_left;
					objects.Line8.Visible = back_top_left_showing;

					-- connections

					objects.Line9.From = back_bottom_left;
					objects.Line9.To = front_bottom_left;
					objects.Line9.Visible = front_bottom_left_showing;

					objects.Line10.From = back_bottom_right;
					objects.Line10.To = front_bottom_right;
					objects.Line10.Visible = front_bottom_right_showing;

					objects.Line11.From = back_top_left;
					objects.Line11.To = front_top_left;
					objects.Line11.Visible = front_top_left_showing;

					objects.Line12.From = front_top_right;
					objects.Line12.To = back_top_right;
					objects.Line12.Visible = back_bottom_right_showing;
				end

				data.update = update;
			end

			table.insert(CustomObjects, setmetatable({}, {__index = data, __newindex = data}));

			return {
				destroy = destroy,
				update = update, 
				visibility = function(b)
					data.visible = b;
				end
			};
		end
		
		local function UpdateESP(Data, Vec, Root, Client)
			local Camera = workspace.CurrentCamera;
			if not(Camera) then return end
			local Color = using_team_color and get_team(Client) and get_team(Client).TeamColor.Color or 
						(get_team(Client) == get_team(player) and team_color or enemy_color);
			if Data.NameLabel and names then
				Data.NameLabel.Position = Vec;
				Data.NameLabel.Visible = names;
				Data.NameLabel.Color = Color;
				Data.NameLabel.Transparency = transparency;
			end
		
			if Data.Line1 and Data.Line2 and Data.Line3 and Data.Line4 and boxes then
				local CF = Root.CFrame;
				local TopLeft = Camera:WorldToViewportPoint((CF * CFrame.new(2, 3, 0)).p);
				local TopRight = Camera:WorldToViewportPoint((CF * CFrame.new(-2, 3, 0)).p);
				local BottomLeft = Camera:WorldToViewportPoint((CF * CFrame.new(2, -3, 0)).p);
				local BottomRight = Camera:WorldToViewportPoint((CF * CFrame.new(-2, -3, 0)).p);
		
				local Line1, Line2, Line3, Line4 = Data.Line1, Data.Line2, Data.Line3, Data.Line4;
				Line1.Visible,Line2.Visible,Line3.Visible,Line4.Visible = true, true, true, true;
				Line1.Color = Color;
				Line2.Color = Color;
				Line3.Color = Color;
				Line4.Color = Color;
				Line1.Transparency = transparency;
				Line2.Transparency = transparency;
				Line3.Transparency = transparency;
				Line4.Transparency = transparency;
		
				Line1.From = Vector2.new(TopLeft.X, TopLeft.Y);
				Line1.To = Vector2.new(TopRight.X, TopRight.Y);
		
				Line2.From = Vector2.new(TopRight.X, TopRight.Y);
				Line2.To = Vector2.new(BottomRight.X, BottomRight.Y);
		
				Line3.From = Vector2.new(BottomRight.X, BottomRight.Y);
				Line3.To = Vector2.new(BottomLeft.X, BottomLeft.Y);
		
				Line4.From = Vector2.new(BottomLeft.X, BottomLeft.Y);
				Line4.To = Vector2.new(TopLeft.X, TopLeft.Y);
			end
			
			if Data.Tracer and tracers then
				local CF = Root.CFrame;
				local Viewport = Camera.ViewportSize;
				local To = Camera:WorldToViewportPoint(CF.p);
				Data.Tracer.From = Vector2.new(Viewport.X / 2, (Viewport.Y / 2) + (Viewport.Y / 4) );
				Data.Tracer.To = Vector2.new(To.X, To.Y);
				Data.Tracer.Visible = tracers;
				Data.Tracer.Color = Color;
				Data.Tracer.Transparency = transparency;
			end
		end
		
		local function Update()
			local Camera = workspace.CurrentCamera;
			if not(Camera) then return end;
		
			local Current = {};
			local MyTeam = get_team(player);
		
			for _, Client in next, players:GetPlayers() do
				local Character = get_character(Client);
				local Team = get_team(Client);
				if Character and Client ~= player and (MyTeam ~= Team and not show_team or show_team) then
					Current[Character] = true;
		
					-- Create ESP
					if ESP[Character] == nil then
						local Color = using_team_color and Client.Team and Client.Team.TeamColor.Color or Color3.fromRGB(255, 0, 0);
						
						local Data = {};
						local NameLabel = Drawing.new("Text");
						NameLabel.Text = Client.Name;
						NameLabel.Center = true;
						NameLabel.Color = Color;
						NameLabel.Size = 14.0;
						NameLabel.Visible = names;
						Data.NameLabel = NameLabel;
						
						local Line1 = Drawing.new("Line");
						Line1.Thickness = 1.6;
						Line1.Color = Color;
						Line1.Visible = boxes;
						local Line2 = Drawing.new("Line");
						Line2.Thickness = 1.6;
						Line2.Color = Color;
						Line2.Visible = boxes;
						local Line3 = Drawing.new("Line");
						Line3.Thickness = 1.6;
						Line3.Color = Color;
						Line3.Visible = boxes;
						local Line4 = Drawing.new("Line");
						Line4.Thickness = 1.6;
						Line4.Color = Color;
						Line4.Visible = boxes;
                        Data.Line1, Data.Line2, Data.Line3, Data.Line4 = Line1, Line2, Line3, Line4;
						
						local Tracer = Drawing.new("Line");
						Tracer.Thickness = 1.6;
						Tracer.Color = Color;
						Tracer.Visible = tracers;
                        Data.Tracer = Tracer;
                        
                        table.insert(drawing_objects, Tracer);
                        table.insert(drawing_objects, NameLabel);
                        table.insert(drawing_objects, Line1);
                        table.insert(drawing_objects, Line2);
                        table.insert(drawing_objects, Line3);
                        table.insert(drawing_objects, Line4);
		
						ESP[Character] = Data;
					else -- Update ESP
						local Root = get_root(Character);
						local Data = ESP[Character];
						if Root then
							local Vec3, OnScreen = Camera:WorldToScreenPoint(Root.Position);
							if Data and Data.Line1 ~= nil then
								Data.Line1.Visible,Data.Line2.Visible,
									Data.Line3.Visible,Data.Line4.Visible = boxes,boxes,boxes,boxes;
								Data.NameLabel.Visible = names;
							end
							if OnScreen then
								local Vec2 = Vector2.new(Vec3.X, Vec3.Y);
								if math.huge and limit_distance then
									if player:DistanceFromCharacter(Root.Position) < math.huge then
										UpdateESP(ESP[Character], Vec2, Root, Client);
									else
										Data.Line1.Visible,Data.Line2.Visible,
											Data.Line3.Visible,Data.Line4.Visible = false, false, false, false;
										Data.NameLabel.Visible = false;
										Data.Tracer.Visible = false;
									end
								else
									Data.Line1.Visible,Data.Line2.Visible,
										Data.Line3.Visible,Data.Line4.Visible = false, false, false, false;
									Data.NameLabel.Visible = false;
									Data.Tracer.Visible = false;
									UpdateESP(ESP[Character], Vec2, Root, Client);
								end
							else
								Data.Line1.Visible,Data.Line2.Visible,
									Data.Line3.Visible,Data.Line4.Visible = false, false, false, false;
								Data.NameLabel.Visible = false;
								Data.Tracer.Visible = false;
							end
						elseif Data then
							Data.Line1.Visible,Data.Line2.Visible,
								Data.Line3.Visible,Data.Line4.Visible = false, false, false, false;
							Data.NameLabel.Visible = false;
							Data.Tracer.Visible = false;
						end
					end
		
				end
			end
		
			for Char, Data in next, ESP do
				if Char:IsDescendantOf(workspace) == false or script.Name == "Destroyed" then
					Data.Line1:Remove();
					Data.Line2:Remove();
					Data.Line3:Remove();
					Data.Line4:Remove();
					Data.NameLabel:Remove();
					Data.Tracer:Remove();
					ESP[Char] = nil;
				end
			end

			for i, custom in pairs(CustomObjects) do
				if not custom.destroyed then
					if custom.update then custom:update() end

					local transparency = custom.transparency
					local color = custom.color
					local thickness = custom.thickness

					for _, render_object in pairs(custom.objects) do
						local data = CustomData[render_object] or Drawing.new(render_object.Type)
						CustomData[render_object] = data

						if custom.destroyed then
							data.Visible = false
							data:Remove()
						else
							data.Transparency = transparency
							data.Color = color
							data.Thickness = thickness
							for index, value in next, render_object do
								if index ~= "Type" then
									data[index] = value
								end
							end

							if render_object.Visible ~= nil and custom.visible ~= false then
								data.Visible = render_object.Visible 
							else 
								data.Visible = custom.visible 
							end
						end
					end

					if custom.destroyed then
						table.remove(CustomObjects, i)
					end
				else
					for _, render_object in pairs(custom.objects) do
						local data = CustomData[render_object]
						if data then data:Remove() CustomData[render_object] = nil end
					end
				end
			end
		
		end
		
		
        table.insert(update_loop, Drawing and Update or nil)
		
	end
	
	-- end of visuals

	-- start of aimbot
	
	do
		local function check_in_bounds(config, mx, my, x, y)
			local dfc_x, dfc_y = mx - (mx + x), my - (my + y) - 36
			local distance = math.sqrt((dfc_x ^ 2) + (dfc_y ^ 2))
			local v = get_screen_size()
			local radius = config.radius / 100
			local rx, ry = radius * v.X, radius * v.Y
			local max = math.sqrt((rx ^ 2) + (ry ^ 2)) / 2
			return max > distance
		end
		
		local function update_circle(config, circle)
			if script.Name == "Destroyed" then return end
			if not(circle) then return end;
			circle.Radius = get_screen_size().X * (config.radius / 100) / 2;
			circle.Visible = config.enabled;
			circle.Position = Vector2.new(mouse.X, mouse.Y + 36);
			circle.Transparency = config.transparency;

			config.current = config.current + config.add;
			if config.current > 360 then
				config.add = -0.5;
			elseif config.current <= 0 then
				config.add = 0.5;
			end
			circle.Color = Color3.fromHSV(config.current / 360, 1, 1);
			
			return circle;
		end
		
		local function make_circle(config)
			if not(Drawing) then return end;
			local circle = Drawing.new("Circle");
			circle.Filled = false;
			circle.Thickness = 3;
			circle.NumSides = 15;
            circle.Color = Color3.fromRGB(255, 176, 29);
			table.insert(drawing_objects, circle);
			config.add = 1;
			config.current = 0;
			
			return update_circle(config, circle);
		end
		
		function aimbot.main_aimbot(self, can_config, config)
			can_config = can_config or true;
			
			local config = config or {
				radius = 27,
				wall_collision = true,
				use_circle = true,
				max_distance = math.huge,
				sensitivity = 27,
				hit_part = "Head",
				transparency = 1,
				enabled = false,
				type = "camera",
				ffa = false,
			};
			
			local char_targets = {};
			local circle;
			local camera = workspace.CurrentCamera
			
			local function get_movement()
				local Character = get_character(player)
				if not( Character ) then return end
				local Root = get_root(Character)
				if not ( Root ) then return end
				local RootCF = workspace.CurrentCamera.CFrame
				
				local all_chars = {workspace:FindFirstChild("Dummy")}
				for _, player in next, players:GetPlayers() do
					if get_character(player) and player ~= player then
						local character = get_character(player)
						local h = character:FindFirstChildOfClass("Humanoid")
						if h then
							if h.Health > 0.5 then
								all_chars[player] = character
							end
						else
							all_chars[player] = character
						end
					end
				end
				
				local distance, closest, point, person = math.huge
				local hit_part;
				
				local x, y = mouse.X, mouse.Y
				
				for plr, char in next, all_chars do
					local random = get_root_name()--char_targets[char] or math.random(0,1)==0 and config.hit_part or get_root_name()
					if char_targets[char] == nil then char_targets[char] = random end
					local head = char:FindFirstChild(random)
					if head then
						local screen_point = camera:WorldToViewportPoint(head.Position)
								
						if screen_point.Z > 5 then
							
							local d_x, d_y = x - screen_point.X, y - screen_point.Y
							local d = math.sqrt(d_x ^ 2 + d_y ^ 2)
												
							local check = config.use_circle and check_in_bounds(config, x, y, d_x, d_y)
							check = (RootCF.p - head.CFrame.p).Magnitude <= math.huge -- max_distance
							if config.wall_collision then
								local ray = Ray.new(RootCF.p, (head.CFrame.p - RootCF.p).Unit * 900)
								local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Character}, false, true)
								if hit then
									if not hit:IsDescendantOf(char) then
										check = false
									end
								end
							end
							if config.ffa == false then
								local player = players:GetPlayerFromCharacter(char)
								if player and get_team(player) == get_team(player) then
									check = false
								end
							end
										
							if d < distance and check then
								closest, distance, point, person = char, d, screen_point, plr
								hit_part = head
							end
						end
					end
				end
					
				if point then
					local d_x, d_y = x - point.X, y - point.Y
					point = point - Vector3.new(0, 36, 0)
					local check = config.use_circle and check_in_bounds(config, x, y, d_x, d_y)
					if config.use_circle and not(check) then
						return false
					end
					local goto = Vector2.new(
						(point.X - mouse.X) * (config.sensitivity / 100),
						(point.Y - mouse.Y) * (config.sensitivity / 100)
					)
					return goto, closest, hit_part
				end
				
				return false
			end
			
			if Drawing then
				circle = make_circle(config);
			end
			
			local tab = self.tab;
			
			tab:new("toggle", "aimbot", config.enabled, function(b) config.enabled = b end);
			
			if can_config then
				local ext = tab:new("extension", "config");
				ext:new("slider", "sensitivity", config.sensitivity / 100, 0, 1, function(n) config.sensitivity = n * 100 end)
				ext:new("slider", "fov", config.radius / 100, 0, 1, function(n) config.radius = n * 100 end)
				ext:new("toggle", "collision", config.wall_collision, function(b) config.wall_collision = b end)
				ext:new("toggle", "in circle", config.use_circle, function(b) config.use_circle = b end)
                ext:new("toggle", "use mouse", true, function(n) config.type = n and "mouse" or "camera" end);
                ext:new("toggle", "ffa", false, function(b) config.ffa = b end);
				local dropdown = ext:new("dropdown", "target", function(n) config.hit_part = n end);
				dropdown:new("head", true);
				dropdown:new("torso");
			end
			
			
			local last_tween;
			table.insert(update_loop, function() 
				if config.enabled then
					update_circle(config, circle)
					if config.type == "camera" then
						local _, _, hitpart = get_movement()
						if hitpart then
							if last_tween then last_tween:Cancel() end
							last_tween = tween_service:Create(camera, TweenInfo.new(1 - (config.sensitivity / 100)), 
								{CFrame = CFrame.new(camera.CFrame.p, hitpart.CFrame.p)})
							last_tween:Play()
						end
					elseif config.type == "mouse" then
						local goto, char = get_movement()
						if goto then
							mousemoverel(goto.x, goto.y)
						end
					end
				elseif script.Name ~= "Destroyed" then
					circle.Visible = false
				end
				
				
			end)
		end
		
		function aimbot.init(main_aimbot)
			main_aimbot = main_aimbot or true;
			
			local self = {};
			
			self.tab = eng:new("tab", "aimbot", true);
			for k, v in pairs(aimbot) do self[k] = v end;
			
			if main_aimbot then
				self:main_aimbot();
			end
		end
	end
	
    -- end of aimbot
    
	spawn(visuals.all);
    spawn(aimbot.init);

    local game_name = market_place_service:GetProductInfo(game.PlaceId).Name;

    do 
		local function init()
			
			-- LOST GAME

            if game_name:match("Lost") then
                local PlayerGui = player.PlayerGui;

                local MainGui = PlayerGui.MainGui;
                local FullScreen = MainGui.Fullscreen;
                local StatusModifier = FullScreen.StatusModifier; -- StatusModifier

                local Jumpscript = PlayerGui.JumpCooldown;

                local Floating = false;
                local SpeedEnabled = false;
                local ContainerESP = false;
                local FloatPart;

                local function FastJump(boolean)
                    Jumpscript.Disabled = boolean;
                end
                local function InfStats(boolean)
                	StatusModifier.Disabled = boolean
                end
                local function NoDrown(boolean)
                	if get_character(player):FindFirstChild("UnderWaterOLD") then
                		get_character(player).UnderWaterOLD.Disabled = boolean
                	end
                    FullScreen.UnderWater.Disabled = boolean;
                end
                local function Float(boolean)
                    Floating = boolean;
                    if Floating then
                        if FloatPart then
                            FloatPart.Parent = get_character(player);
                        else
                            FloatPart = Instance.new('Part', pchar);
                            FloatPart.Transparency = 1;
                            FloatPart.Size = Vector3.new(6,1,6);
                            FloatPart.Anchored = true;
                            FloatPart.Material = "Grass";
                        end
                    else
                        FloatPart.Parent = nil;
                    end
                end
                local function Speed(boolean)
                    SpeedEnabled = boolean;
                end

                local Containers = workspace.Containers

                local container_esps = {}

                local colors = {
                	["MilitaryCrate"] = Color3.new(0, 0.13, 0.37),
                	["MedCrate"] = Color3.fromRGB(232, 0, 0),
                	["FoodCrate"] = Color3.fromRGB(31, 128, 29),
                	["EliteCrate"] = Color3.new(.47, .31, .66),
                	["Other"] = Color3.new(.90, .49, .13)
                }

                local function add(obj)
                	if container_esps[obj] then return end
                	local data = visuals:new_esp_object(
                		"box", 
                		obj:FindFirstChild("HitBox") or obj.PrimaryPart,
                		colors[obj.Name] or colors["Other"],
                		0.7,
                		1
                	);
                	data.visibility(ContainerESP);
                	container_esps[obj] = data
                end

                coroutine.wrap(function() 
                	while wait(1) do
                		for _, container in pairs(Containers:GetChildren()) do
                			local primary = container.PrimaryPart or container:FindFirstChild("HitBox")
                			if primary then
                				local distance = player:DistanceFromCharacter(primary.CFrame.p)
                				if distance < 600 then
                					if container.LootingInProgress.Value == false 
                						and #container.Properties.Inventory:GetChildren() > 0 then
                					add(container)
                				end
                				elseif container_esps[container] then
                					container_esps[container]:destroy()
                					container_esps[container] = nil
                				end
                			end
                		end
                	end
            	end)()


                local function ContainerESPF(b)
                	ContainerESP = b
                	for _, data in pairs(container_esps) do data.visibility(b) end
                end

                table.insert(update_loop, function() 
                    if Floating and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        FloatPart.Parent = player.Character
                        FloatPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.CFrame * Vector3.new(0, -3.5, 0))
                    end
                    if SpeedEnabled and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                        player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 18
                    else
                        player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 10.5
                    end
                end)

                local tab = eng:new("tab", "lost", true);
                tab:new("toggle", "fast jump", false, FastJump);
                tab:new("toggle", "inf stats", false, InfStats);
                tab:new("toggle", "no drown", false, NoDrown);
                tab:new("toggle", "no fall", false, Float);
                tab:new("toggle", "speed", false, Speed);
                tab:new("toggle", "container esp", false, ContainerESPF);
				tab:new("label", "$blank");
				
			-- big paintball --

			elseif game_name:match("BIG Paintball") then

				local silent_aim_b = false;
				local check_walls = true;
				local in_view = true;

				local tab = eng:new("tab", "paintball", true);
				tab:new("toggle", "silent aim", false, function(b) silent_aim_b = b end);

				local config = tab:new("extension", "config");
				config:new("toggle", "wall check", check_walls, function(b) check_walls = b end);
				config:new("toggle", "in view", in_view, function(b) in_view = b end);

				local MT = getrawmetatable(game);
				local OldNameCall = MT.__namecall;
				setreadonly(MT, false);
				local my_char, my_root_p;

				-- silent aim namecall --

				MT.__namecall = newcclosure(function(self, ...)
					local Method = getnamecallmethod();
					local Args = {...};
				
					if Method == "FindPartOnRayWithWhitelist" and silent_aim_b then
						local start = Args[1];
						local d = player.DistanceFromCharacter(player, start.Origin);
						if d < 2 then 
							if not my_char then return end;
							if not my_root then return end;
							local closest, distance = nil, math.huge;
							for k, v in next, players.GetPlayers(players) do
								local char = v.Character;
								if char then
									local root = char.FindFirstChild(char, "HumanoidRootPart");
									if root then
										local ray = Ray.new(my_root_p, (root.CFrame.p - my_root_p).Unit * 900);
										local hit = workspace.FindPartOnRayWithIgnoreList(workspace, ray, {my_char, workspace.__DEBRIS}, false, true);
										local d = player.DistanceFromCharacter(player, root.CFrame.p);

										local Camera = workspace.CurrentCamera;
										local _, on_screen = Camera.WorldToViewportPoint(Camera, root.CFrame.p)

										if d < distance and ((hit and hit.IsDescendantOf(hit, char) or hit == nil) 
											and check_walls or check_walls == false) then
											if (on_screen and in_view or in_view == false ) then
												if v.Team ~= player.Team or workspace.__VARIABLES.RoundType.Value == "FFA" then
													distance = d;
													closest = v;
												end
											end
										end
									end
								end
							end
							local plr = closest;
							if plr then
								local char = plr.Character;
								local root = char.WaitForChild(char, "HumanoidRootPart");
								return root, Vector3.new();
							end
						end
					end
				
					return OldNameCall(self, unpack(Args));
				end)

				-- get character 
				
				coroutine.wrap(function()
					while wait(.1) do
						my_char = player.Character;
						my_root = my_char:FindFirstChild("HumanoidRootPart");
					
						my_root_p = my_root.CFrame.p;
					end
				end)()

            end
        end
        spawn(init);
	end
	
	wait(.2);
	eng:hide();
	wait(.3);
	sg.Enabled = true;
	eng:show();

	engine = nil;
	eng = nil;
end

local function Destroy()
    sg:Destroy();
    update_loop = {};
    script.Name = "Destroyed";
    for k,v in pairs(drawing_objects) do
        v:Remove();
    end
    script:Destroy();
end
_G.Destroy = Destroy;