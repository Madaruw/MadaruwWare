-- example script by https://github.com/mstudio45/LinoriaLib/blob/main/Example.lua and modified by deivid
-- You can suggest changes with a pull request or something

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false -- Forces AddToggle to AddCheckbox
Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)

local Window = Library:CreateWindow({
	Title = "madaruw",
	Footer = "Nurummm",
	Icon = 76965209085182,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

-- Sadece Key System tabı oluştur
local Tabs = {
	Key = Window:AddKeyTab("Key System"),
}

-- Key System tab
Tabs.Key:AddLabel({
	Text = "Enter Key",
	DoesWrap = true,
	Size = 16,
})

Tabs.Key:AddKeyBox("Nur", function(Success, ReceivedKey)
	print("Expected Key: Nur - Received Key:", ReceivedKey, "| Success:", Success)
	if Success then
		Library:Notify({
			Title = "Başarılı!",
			Description = "Doğru anahtar girildi.",
			Time = 3,
		})
		
		-- Main ve UI Settings tablarını oluştur
		Tabs.Main = Window:AddTab("Main", "user")
		Tabs["UI Settings"] = Window:AddTab("UI Settings", "settings")
		
		-- Initialize services and variables AFTER UI is created
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local RunService = game:GetService("RunService")
		local Camera = workspace.CurrentCamera
		local Mouse = LocalPlayer:GetMouse()
		local UserInputService = game:GetService("UserInputService")
		local TweenService = game:GetService("TweenService")
		
		-- Initialize aimbot globals
		_G.AimbotEnabled = false
		_G.AimbotFOV = 50
		_G.ShowFOV = false
		_G.AimbotTarget = nil
		_G.AimbotTargetPart = "Head"
		_G.AimbotSmoothing = 5
		_G.AimbotPrediction = 0.1
		_G.CameraShake = 0
		_G.ChamsEnabled = false
		_G.ChamsMaterial = "Wireframe"
		_G.RainbowChams = false
		_G.FlingActive = false
		_G.CurrentFlingThrust = nil
		
		-- Main tab içeriği
		local AimbotGroup = Tabs.Main:AddLeftGroupbox("Aimbot", "crosshair") -- crosshair icon
		AimbotGroup:AddToggle("AimbotToggle", {
			Text = "Enable Aimbot",
			Tooltip = "Normal Aimbot'u aç/kapat (görsel hareket)",
			Default = false,
			Callback = function(Value)
				_G.AimbotEnabled = Value
				print("[cb] Aimbot changed to:", Value)
			end,
		})
		AimbotGroup:AddSlider("AimbotFOV", {
			Text = "Aimbot FOV",
			Default = 50,
			Min = 1,
			Max = 360,
			Rounding = 0,
			Callback = function(Value)
				_G.AimbotFOV = Value
				print("[cb] Aimbot FOV changed! New value:", Value)
			end,
			Tooltip = "Aimbot'un FOV'u (görüş açısı)",
		})
		AimbotGroup:AddToggle("ShowFOVToggle", {
			Text = "Show FOV Circle",
			Tooltip = "FOV dairesini göster/gizle",
			Default = false,
			Callback = function(Value)
				_G.ShowFOV = Value
				print("[cb] Show FOV changed to:", Value)
			end,
		})
		AimbotGroup:AddDropdown("AimbotTarget", {
			Values = { "Head", "Body", "Closest Part" },
			Default = 1,
			Text = "Target Part",
			Tooltip = "Hangi vücut parçasını hedefleyeceğini seç",
			Callback = function(Value)
				_G.AimbotTargetPart = Value
				print("[cb] Aimbot target changed to:", Value)
			end,
		})
		AimbotGroup:AddSlider("AimbotSmoothing", {
			Text = "Smoothing",
			Default = 5,
			Min = 1,
			Max = 20,
			Rounding = 1,
			Callback = function(Value)
				_G.AimbotSmoothing = Value
				print("[cb] Aimbot smoothing changed to:", Value)
			end,
			Tooltip = "Aimbot yumuşaklığı (düşük = hızlı, yüksek = yavaş)",
		})
		AimbotGroup:AddSlider("Prediction", {
			Text = "Prediction",
			Default = 0.1,
			Min = 0,
			Max = 1,
			Rounding = 2,
			Callback = function(Value)
				_G.AimbotPrediction = Value
				print("[cb] Aimbot prediction changed to:", Value)
			end,
			Tooltip = "Hedef tahmin değeri (hareket eden hedefler için)",
		})
		AimbotGroup:AddSlider("CameraShake", {
			Text = "Camera Shake",
			Default = 0,
			Min = 0,
			Max = 5,
			Rounding = 1,
			Callback = function(Value)
				_G.CameraShake = Value
				print("[cb] Camera shake changed to:", Value)
			end,
			Tooltip = "Kamera sallama efekti (gerçekçilik için)",
		})
		AimbotGroup:AddLabel("Aimbot Keybind"):AddKeyPicker("AimbotKeybind", {
			Default = "MB2", -- Right mouse button
			Mode = "Hold", -- Hold to aim
			Text = "Aimbot Key",
			NoUI = false,
			Callback = function(Value)
				print("[cb] Aimbot keybind pressed:", Value)
			end,
			ChangedCallback = function(New)
				print("[cb] Aimbot keybind changed to:", New)
			end,
		})

		-- Visuals groupbox
		local VisualsGroup = Tabs.Main:AddRightGroupbox("Visuals", "eye")
		VisualsGroup:AddToggle("ESPEnabled", {
			Text = "Enable ESP",
			Tooltip = "ESP'yi aç/kapat",
			Default = false,
	Callback = function(Value)
				_G.ESPEnabled = Value
	end,
})
		VisualsGroup:AddToggle("ShowBox", {
			Text = "Show Box",
			Tooltip = "Kutu çizgisi göster/gizle",
			Default = false,
	Callback = function(Value)
				_G.ShowBox = Value
	end,
})
		VisualsGroup:AddToggle("ShowNames", {
			Text = "Show Names",
			Tooltip = "İsimleri göster/gizle",
			Default = false,
	Callback = function(Value)
				_G.ShowNames = Value
	end,
})
		VisualsGroup:AddToggle("ShowHealth", {
			Text = "Show Health",
			Tooltip = "Can barını göster/gizle",
			Default = false,
	Callback = function(Value)
				_G.ShowHealth = Value
	end,
})
		VisualsGroup:AddToggle("ShowDistance", {
			Text = "Show Distance",
			Tooltip = "Mesafeyi göster/gizle",
			Default = false,
	Callback = function(Value)
				_G.ShowDistance = Value
	end,
})
		VisualsGroup:AddToggle("ShowBone", {
			Text = "Show Bone",
			Tooltip = "Kemik çizgilerini göster/gizle",
			Default = false,
	Callback = function(Value)
				_G.ShowBone = Value
	end,
})
		VisualsGroup:AddToggle("TeamCheck", {
			Text = "Team Check",
			Tooltip = "Takım arkadaşlarını gizle/göster",
			Default = false,
	Callback = function(Value)
				_G.TeamCheck = Value
	end,
})
		VisualsGroup:AddToggle("ChamsEnabled", {
			Text = "Enable Chams",
			Tooltip = "Chams'ı aç/kapat",
			Default = false,
			Callback = function(Value)
				_G.ChamsEnabled = Value
			end,
		})
		VisualsGroup:AddDropdown("ChamsMaterial", {
			Values = { "Wireframe", "Flat", "Neon" },
			Default = 1,
			Text = "Chams Material",
			Tooltip = "Chams materyalini seç",
			Callback = function(Value)
				_G.ChamsMaterial = Value
			end,
		})
		VisualsGroup:AddToggle("RainbowChams", {
			Text = "Rainbow Chams",
			Tooltip = "Gökkuşağı renk efekti",
			Default = false,
			Callback = function(Value)
				_G.RainbowChams = Value
			end,
		})

		-- ESP fonksiyonu (Drawing API ile Show Box ve Show Bone)
		if not _G.ESPDrawings then _G.ESPDrawings = {} end
		for _, v in pairs(_G.ESPDrawings) do pcall(function() v:Remove() end) end
		_G.ESPDrawings = {}
		if not _G.ESPConnections then _G.ESPConnections = {} end
		for _, conn in ipairs(_G.ESPConnections) do pcall(function() conn:Disconnect() end) end
		_G.ESPConnections = {}
		
		local function IsOnTeam(player)
			if not _G.TeamCheck then return false end
			return player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
		end
		
		local function GetBonePairs(character)
			-- Support both R6 and R15 body types
			local humanoid = character:FindFirstChild("Humanoid")
			if not humanoid then return {} end
			
			local rigType = humanoid.RigType
			local bones = {}
			
			if rigType == Enum.HumanoidRigType.R15 then
				-- R15 bone connections
				bones = {
					{"Head", "UpperTorso"},
					{"UpperTorso", "LowerTorso"},
					{"UpperTorso", "LeftUpperArm"},
					{"UpperTorso", "RightUpperArm"},
					{"LeftUpperArm", "LeftLowerArm"},
					{"LeftLowerArm", "LeftHand"},
					{"RightUpperArm", "RightLowerArm"},
					{"RightLowerArm", "RightHand"},
					{"LowerTorso", "LeftUpperLeg"},
					{"LowerTorso", "RightUpperLeg"},
					{"LeftUpperLeg", "LeftLowerLeg"},
					{"LeftLowerLeg", "LeftFoot"},
					{"RightUpperLeg", "RightLowerLeg"},
					{"RightLowerLeg", "RightFoot"},
				}
			else
				-- R6 bone connections
				bones = {
					{"Head", "Torso"},
					{"Torso", "Left Arm"},
					{"Torso", "Right Arm"},
					{"Torso", "Left Leg"},
					{"Torso", "Right Leg"},
				}
			end
			return bones
		end
		
		local function ClearESP(player)
			-- Clear GUI elements
			for _, v in ipairs({"ESPName","ESPHealth","ESPDist"}) do
				if player.Character then
					local obj = player.Character:FindFirstChild(v)
					if obj then pcall(function() obj:Destroy() end) end
				end
			end
			
			-- Clear Drawing API elements
			if _G.ESPDrawings[player] then
				if _G.ESPDrawings[player].Box then
					pcall(function() _G.ESPDrawings[player].Box:Remove() end)
					_G.ESPDrawings[player].Box = nil
				end
				if _G.ESPDrawings[player].Bones then
					for _, l in pairs(_G.ESPDrawings[player].Bones) do
						if l then pcall(function() l:Remove() end) end
					end
					_G.ESPDrawings[player].Bones = nil
				end
				if _G.ESPDrawings[player].Chams then
					for _, cham in pairs(_G.ESPDrawings[player].Chams) do
						if cham then pcall(function() cham:Destroy() end) end
					end
					_G.ESPDrawings[player].Chams = nil
				end
				_G.ESPDrawings[player] = nil
			end
		end
		
		-- Add player leaving detection
		local function OnPlayerLeaving(player)
			ClearESP(player)
		end
		
		-- Connect player leaving event
		Players.PlayerRemoving:Connect(OnPlayerLeaving)
		
		local function GetRainbowColor()
			local time = tick() * 2 -- Speed of color change
			return Color3.fromHSV(time % 1, 1, 1)
		end
		
		-- Completely fixed chams system - reliable and shows all players
		local chamUpdateRate = 0.1 -- Balanced update rate
		local lastChamUpdate = 0
		
		local function ApplyChams(character)
			if not _G.ChamsEnabled then return end
			
			local player = Players:GetPlayerFromCharacter(character)
			if not player then return end
			
			if not _G.ESPDrawings[player] then _G.ESPDrawings[player] = {} end
			if not _G.ESPDrawings[player].Chams then _G.ESPDrawings[player].Chams = {} end
			
			-- Get rainbow color or default magenta
			local chamColor = _G.RainbowChams and GetRainbowColor() or Color3.fromRGB(255, 0, 255)
			
			-- Use single character highlight for better performance and reliability
			if not _G.ESPDrawings[player].Chams.MainHighlight then
				local highlight = Instance.new("Highlight")
				highlight.Parent = character
				highlight.Adornee = character
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Name = "MainChamHighlight"
				_G.ESPDrawings[player].Chams.MainHighlight = highlight
			end
			
			-- Update existing highlight
			local highlight = _G.ESPDrawings[player].Chams.MainHighlight
			if highlight and highlight.Parent then
				highlight.FillColor = chamColor
				highlight.OutlineColor = chamColor
				
				-- Apply material-specific settings
				if _G.ChamsMaterial == "Wireframe" then
					highlight.FillTransparency = 1
					highlight.OutlineTransparency = 0
				elseif _G.ChamsMaterial == "Flat" then
					highlight.FillTransparency = 0.5
					highlight.OutlineTransparency = 0.8
				elseif _G.ChamsMaterial == "Neon" then
					highlight.FillTransparency = 0.2
					highlight.OutlineTransparency = 0
				end
			end
		end
		
		local function RemoveChams(player)
			if _G.ESPDrawings[player] and _G.ESPDrawings[player].Chams then
				if _G.ESPDrawings[player].Chams.MainHighlight then
					pcall(function() _G.ESPDrawings[player].Chams.MainHighlight:Destroy() end)
				end
				_G.ESPDrawings[player].Chams = {}
			end
		end
		
		-- Force update all chams for consistency - called every few seconds
		local function UpdateAllChams()
			if not _G.ChamsEnabled then return end
			
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					-- Ensure chams exist for all players
					ApplyChams(player.Character)
				end
			end
		end
		
		local function DrawESP()
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					local char = player.Character
					if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
						ClearESP(player)
						continue
					end
					if _G.TeamCheck and IsOnTeam(player) then
						ClearESP(player)
						continue
					end
					local hrp = char.HumanoidRootPart
					local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
					
					-- Apply chams regardless of screen visibility
					if _G.ChamsEnabled then
						-- Update chams more frequently for rainbow effect
						local currentTime = tick()
						if currentTime - lastChamUpdate >= chamUpdateRate then
							ApplyChams(char)
							lastChamUpdate = currentTime
						end
					else
						RemoveChams(player)
					end
					
					if onScreen and _G.ESPEnabled then
						if not _G.ESPDrawings[player] then _G.ESPDrawings[player] = {} end
						-- Show Box (kenar çizgisi, Drawing API ile)
						if _G.ShowBox then
							if not _G.ESPDrawings[player].Box then
								local box = Drawing.new("Square")
								box.Thickness = 2
								box.Color = Color3.fromRGB(80, 200, 255)
								box.Filled = false
								box.Transparency = 1
								_G.ESPDrawings[player].Box = box
							end
							-- Calculate proper box size based on character
							local head = char:FindFirstChild("Head")
							local rootPart = char:FindFirstChild("HumanoidRootPart")
							if head and rootPart then
								local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, head.Size.Y/2, 0))
								local rootPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, rootPart.Size.Y/2, 0))
								local height = math.abs(headPos.Y - rootPos.Y)
								local width = height * 0.6
								_G.ESPDrawings[player].Box.Visible = true
								_G.ESPDrawings[player].Box.Position = Vector2.new(pos.X - width/2, headPos.Y)
								_G.ESPDrawings[player].Box.Size = Vector2.new(width, height)
							end
						else
							if _G.ESPDrawings[player].Box then
								_G.ESPDrawings[player].Box.Visible = false
							end
						end
						-- Show Bone (tüm kemikler, Drawing API ile)
						if _G.ShowBone then
							if not _G.ESPDrawings[player].Bones then _G.ESPDrawings[player].Bones = {} end
							local bonePairs = GetBonePairs(char)
							for i, pair in ipairs(bonePairs) do
								local p1, p2 = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
								if p1 and p2 then
									if not _G.ESPDrawings[player].Bones[i] then
										local line = Drawing.new("Line")
										line.Thickness = 2
										line.Color = Color3.fromRGB(255,0,255)
										line.Transparency = 1
										_G.ESPDrawings[player].Bones[i] = line
									end
									local p1s = Camera:WorldToViewportPoint(p1.Position)
									local p2s = Camera:WorldToViewportPoint(p2.Position)
									if p1s.Z > 0 and p2s.Z > 0 then
										_G.ESPDrawings[player].Bones[i].Visible = true
										_G.ESPDrawings[player].Bones[i].From = Vector2.new(p1s.X, p1s.Y)
										_G.ESPDrawings[player].Bones[i].To = Vector2.new(p2s.X, p2s.Y)
									else
										_G.ESPDrawings[player].Bones[i].Visible = false
									end
								else
									if _G.ESPDrawings[player].Bones[i] then
										_G.ESPDrawings[player].Bones[i].Visible = false
									end
								end
							end
						else
							if _G.ESPDrawings[player].Bones then
								for _, l in pairs(_G.ESPDrawings[player].Bones) do
									if l then l.Visible = false end
								end
							end
						end
						-- Show Names (isim üstte, büyük ve outline)
						if _G.ShowNames then
							local nameGui = char:FindFirstChild("ESPName")
							if not nameGui then
								local name = Instance.new("BillboardGui", char)
								name.Name = "ESPName"
								name.Size = UDim2.new(4,0,1,0)
								name.AlwaysOnTop = true
								name.StudsOffsetWorldSpace = Vector3.new(0,3,0)
								local label = Instance.new("TextLabel", name)
								label.Size = UDim2.new(1,0,1,0)
								label.BackgroundTransparency = 1
								label.Text = player.Name
								label.TextColor3 = Color3.fromRGB(255,255,255)
								label.TextStrokeTransparency = 0.1
								label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
								label.Font = Enum.Font.SourceSansBold
								label.TextSize = 17
								label.TextScaled = true
							end
						else
							local obj = char:FindFirstChild("ESPName")
							if obj then pcall(function() obj:Destroy() end) end
						end
						-- Show Health (sola) - Update health value
						if _G.ShowHealth then
							local healthGui = char:FindFirstChild("ESPHealth")
							if not healthGui then
								local health = Instance.new("BillboardGui", char)
								health.Name = "ESPHealth"
								health.Size = UDim2.new(2,0,1,0)
								health.AlwaysOnTop = true
								health.StudsOffsetWorldSpace = Vector3.new(-2,1,0)
								local label = Instance.new("TextLabel", health)
								label.Size = UDim2.new(1,0,1,0)
								label.BackgroundTransparency = 1
								label.TextColor3 = Color3.fromRGB(0,255,0)
								label.TextStrokeTransparency = 0.5
								label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
								label.Font = Enum.Font.SourceSansBold
								label.TextSize = 14
								label.TextScaled = true
							else
								-- Update health value
								local label = healthGui:FindFirstChild("TextLabel")
								if label then
									local currentHealth = math.floor(char.Humanoid.Health)
									local maxHealth = math.floor(char.Humanoid.MaxHealth)
									label.Text = currentHealth .. "/" .. maxHealth
									-- Color based on health percentage
									local healthPercent = currentHealth / maxHealth
									if healthPercent > 0.6 then
										label.TextColor3 = Color3.fromRGB(0,255,0)
									elseif healthPercent > 0.3 then
										label.TextColor3 = Color3.fromRGB(255,255,0)
									else
										label.TextColor3 = Color3.fromRGB(255,0,0)
									end
								end
							end
						else
							local obj = char:FindFirstChild("ESPHealth")
							if obj then pcall(function() obj:Destroy() end) end
						end
						-- Show Distance (sağ alta) - Update distance value
						if _G.ShowDistance then
							local distGui = char:FindFirstChild("ESPDist")
							if not distGui then
								local dist = Instance.new("BillboardGui", char)
								dist.Name = "ESPDist"
								dist.Size = UDim2.new(2,0,1,0)
								dist.AlwaysOnTop = true
								dist.StudsOffsetWorldSpace = Vector3.new(2,-2,0)
								local label = Instance.new("TextLabel", dist)
								label.Size = UDim2.new(1,0,1,0)
								label.BackgroundTransparency = 1
								label.TextColor3 = Color3.fromRGB(255,255,0)
								label.TextStrokeTransparency = 0.5
								label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
								label.Font = Enum.Font.SourceSansBold
								label.TextSize = 14
								label.TextScaled = true
							else
								-- Update distance value
								local label = distGui:FindFirstChild("TextLabel")
								if label then
									local distance = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
									label.Text = distance .. "m"
								end
							end
						else
							local obj = char:FindFirstChild("ESPDist")
							if obj then pcall(function() obj:Destroy() end) end
						end
					else
						ClearESP(player)
					end
				end
			end
		end
		table.insert(_G.ESPConnections, RunService.RenderStepped:Connect(DrawESP))
		
		-- FOV Circle
		local FOVCircle = Drawing.new("Circle")
		FOVCircle.Color = Color3.fromRGB(255, 255, 255)
		FOVCircle.Thickness = 2
		FOVCircle.Transparency = 0.5
		FOVCircle.Filled = false
		FOVCircle.Visible = false
		
		local function UpdateFOVCircle()
			if _G.ShowFOV then
				FOVCircle.Visible = true
				local screenSize = Camera.ViewportSize
				FOVCircle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
				FOVCircle.Radius = _G.AimbotFOV
			else
				FOVCircle.Visible = false
			end
		end
		
		-- Cache for performance optimization
		local targetCache = {}
		local lastCacheUpdate = 0
		local cacheUpdateInterval = 0.1 -- Reduced for better responsiveness
		
		local function UpdateTargetCache()
			pcall(function()
				local currentTime = tick()
				if currentTime - lastCacheUpdate < cacheUpdateInterval then
					return
				end
				lastCacheUpdate = currentTime
				
				targetCache = {}
				
				-- First check all players
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character then
						local char = player.Character
						local humanoid = char:FindFirstChild("Humanoid")
						local head = char:FindFirstChild("Head")
						local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
						local hrp = char:FindFirstChild("HumanoidRootPart")
						
						if humanoid and head and humanoid.Health > 0 and head.Position then
							if not (_G.TeamCheck and IsOnTeam(player)) then
								table.insert(targetCache, {
									character = char,
									head = head,
									torso = torso,
									hrp = hrp,
									isPlayer = player
								})
							end
						end
					end
				end
				
				-- Then check for NPCs/bots in common MM2 aim trainer locations
				local commonParents = {workspace}
				
				-- Safely check for common NPC containers
				pcall(function()
					local npcs = workspace:FindFirstChild("NPCs")
					if npcs then table.insert(commonParents, npcs) end
				end)
				pcall(function()
					local bots = workspace:FindFirstChild("Bots")
					if bots then table.insert(commonParents, bots) end
				end)
				pcall(function()
					local targets = workspace:FindFirstChild("Targets")
					if targets then table.insert(commonParents, targets) end
				end)
				
				for _, parent in ipairs(commonParents) do
					if parent then
						pcall(function()
							for _, obj in ipairs(parent:GetChildren()) do
								if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
									local humanoid = obj:FindFirstChild("Humanoid")
									local head = obj:FindFirstChild("Head")
									local torso = obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
									local hrp = obj:FindFirstChild("HumanoidRootPart")
									
									if humanoid and head and humanoid.Health > 0 and head.Position and obj.Name ~= LocalPlayer.Name then
										-- Check if it's not already a player character
										local isPlayerChar = false
										for _, player in ipairs(Players:GetPlayers()) do
											if player.Character == obj then
												isPlayerChar = true
												break
											end
										end
										
										if not isPlayerChar then
											table.insert(targetCache, {
												character = obj,
												head = head,
												torso = torso,
												hrp = hrp,
												isPlayer = false
											})
										end
									end
								end
							end
						end)
					end
				end
			end)
		end
		
		local function GetTargetPart(target)
			if _G.AimbotTargetPart == "Head" then
				return target.head
			elseif _G.AimbotTargetPart == "Body" then
				return target.torso or target.hrp
			elseif _G.AimbotTargetPart == "Closest Part" then
				-- Find closest part to camera
				local closestPart = nil
				local closestDistance = math.huge
				local parts = {target.head, target.torso, target.hrp}
				
				for _, part in ipairs(parts) do
					if part and part.Position then
						local distance = (part.Position - Camera.CFrame.Position).Magnitude
						if distance < closestDistance then
							closestDistance = distance
							closestPart = part
						end
					end
				end
				return closestPart
			end
			return target.head -- Default fallback
		end
		
		local function GetClosestPlayerInFOV()
			if not _G.AimbotEnabled then return nil end
			
			local success, result = pcall(function()
				UpdateTargetCache()
				
				local closestTarget = nil
				local shortestDistance = math.huge
				local screenCenter = Camera.ViewportSize / 2
				
				for _, target in ipairs(targetCache) do
					local targetPart = GetTargetPart(target)
					local char = target.character
					
					if targetPart and targetPart.Parent and targetPart.Position and char:FindFirstChild("Humanoid") then
						local humanoid = char:FindFirstChild("Humanoid")
						if humanoid.Health > 0 then
							-- Safe WorldToViewportPoint call
							local partPosSuccess, partPos, onScreen = pcall(function()
								return Camera:WorldToViewportPoint(targetPart.Position)
							end)
							
							if partPosSuccess and onScreen and partPos.Z > 0 then
								local screenPos = Vector2.new(partPos.X, partPos.Y)
								local distance = (screenPos - screenCenter).Magnitude
								
								if distance <= _G.AimbotFOV and distance < shortestDistance then
									-- Quick visibility check (optional for performance)
									local raycastSuccess, raycastResult = pcall(function()
										local raycastParams = RaycastParams.new()
										raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
										raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
										
										return workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 300, raycastParams)
									end)
									
									if not raycastSuccess or not raycastResult or raycastResult.Instance:IsDescendantOf(char) then
										closestTarget = {target = target.isPlayer or char, part = targetPart}
										shortestDistance = distance
									end
								end
							end
						end
					end
				end
				
				return closestTarget
			end)
			
			if success then
				return result
			else
				return nil
			end
		end
		
		-- Normal Aimbot System with Visual Camera Movement
		local currentTarget = nil
		local lastShakeTime = 0
		local shakeOffset = Vector3.new(0, 0, 0)
		local lastTargetPosition = nil
		local targetVelocity = Vector3.new(0, 0, 0)
		
		local function ApplyPrediction(targetPart)
			if not targetPart or not targetPart.Parent then return targetPart.Position end
			
			local character = targetPart.Parent
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			
			if humanoidRootPart and _G.AimbotPrediction > 0 then
				-- Calculate velocity more accurately
				local currentPosition = targetPart.Position
				if lastTargetPosition then
					targetVelocity = (currentPosition - lastTargetPosition) * 60 -- 60 FPS assumption
				end
				lastTargetPosition = currentPosition
				
				-- Apply stronger prediction
				local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
				local bulletSpeed = 2000 -- Increased bullet speed assumption
				local timeToTarget = distance / bulletSpeed
				
				-- Much stronger prediction multiplier
				local predictionMultiplier = _G.AimbotPrediction * 10 -- Make prediction 10x stronger
				local predictedPosition = targetPart.Position + (targetVelocity * timeToTarget * predictionMultiplier)
				
				return predictedPosition
			end
			
			return targetPart.Position
		end
		
		local function ApplyCameraShake()
			if _G.CameraShake > 0 then
				-- Update shake every frame for smoothness
				local intensity = _G.CameraShake * 2 -- Make shake 2x stronger
				
				-- Create smooth shake using sine waves
				local time = tick() * 10 -- Speed up shake frequency
				shakeOffset = Vector3.new(
					math.sin(time * 1.5) * intensity * 0.5,
					math.cos(time * 2.1) * intensity * 0.3,
					math.sin(time * 1.8) * intensity * 0.2
				)
				
				-- Add random jitter for more realistic shake
				local randomIntensity = intensity * 0.3
				shakeOffset = shakeOffset + Vector3.new(
					(math.random() - 0.5) * randomIntensity,
					(math.random() - 0.5) * randomIntensity,
					(math.random() - 0.5) * randomIntensity
				)
			else
				shakeOffset = Vector3.new(0, 0, 0)
			end
		end
		
		local function AimAtTarget()
			if not _G.AimbotEnabled then
				currentTarget = nil
				return
			end
			
			-- Check if keybind is pressed
			local keybindPressed = Options.AimbotKeybind:GetState()
			if not keybindPressed then
				currentTarget = nil
				return
			end
			
			local success, targetData = pcall(GetClosestPlayerInFOV)
			if success and targetData and targetData.part then
				currentTarget = targetData
				local targetPart = targetData.part
				
				-- Apply prediction
				local predictedPosition = ApplyPrediction(targetPart)
				
				-- Apply camera shake
				ApplyCameraShake()
				local finalPosition = predictedPosition + shakeOffset
				
				-- Calculate the direction to look at
				local direction = (finalPosition - Camera.CFrame.Position).Unit
				local newCFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + direction)
				
				-- Apply smoothing - Fixed formula
				local currentCFrame = Camera.CFrame
				local smoothingSpeed = (21 - _G.AimbotSmoothing) / 20 -- Invert and normalize (1=slow, 20=fast)
				local lerpedCFrame = currentCFrame:Lerp(newCFrame, smoothingSpeed)
				
				-- Set the camera CFrame
				Camera.CFrame = lerpedCFrame
				
				_G.AimbotTarget = targetData.target
			else
				currentTarget = nil
				_G.AimbotTarget = nil
				-- Reset prediction tracking when no target
				lastTargetPosition = nil
				targetVelocity = Vector3.new(0, 0, 0)
			end
		end
		
		-- Update FOV circle and run aimbot
		table.insert(_G.ESPConnections, RunService.RenderStepped:Connect(function()
			UpdateFOVCircle()
			AimAtTarget()
		end))
		
		-- Trolling groupbox with improved aggressive fling
		local TrollingGroup = Tabs.Main:AddLeftGroupbox("Trolling", "zap")
		
		-- Player finder function
		local function findPlayers(searchString)
			local foundPlayers = {}
			local strl = searchString:lower()
			for _, player in ipairs(Players:GetPlayers()) do
				if strl == "all" or strl == "everyone" then
					table.insert(foundPlayers, player)
				elseif strl == "others" and player ~= LocalPlayer then
					table.insert(foundPlayers, player)
				elseif strl == "me" and player == LocalPlayer then
					table.insert(foundPlayers, player)
				elseif player.Name:lower():sub(1, #searchString) == strl then
					table.insert(foundPlayers, player)
				end
			end
			return foundPlayers
		end
		
		-- AGGRESSIVE Fling function
		local function aggressiveFling(target)
			local char = LocalPlayer.Character
			if not (char and target and target.Character) then return end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			
			-- Add BodyThrust
			local thr = Instance.new("BodyThrust")
			thr.Name = "FlingThrust"
			thr.Force = Vector3.new(9999, 9999, 9999)
			thr.Location = hrp.Position
			thr.Parent = hrp
			_G.CurrentFlingThrust = thr
			_G.FlingActive = true

			spawn(function()
				repeat
					if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and _G.FlingActive then
						hrp.CFrame = target.Character.HumanoidRootPart.CFrame
						thr.Location = target.Character.HumanoidRootPart.Position
					end
					RunService.Heartbeat:Wait()
				until not target.Character:FindFirstChild("Head") or not _G.FlingActive
				
				-- Clean up
				_G.FlingActive = false
				if thr and thr.Parent then
					thr:Destroy()
				end
				_G.CurrentFlingThrust = nil
			end)
		end
		
		TrollingGroup:AddInput("FlingTarget", {
			Default = "",
			Numeric = false,
			Text = "Target Username",
			Tooltip = "Fling edilecek oyuncunun kullanıcı adını gir (all, others, me veya isim)",
			Placeholder = "Username...",
			Callback = function(Value)
				_G.FlingTargetName = Value
			end,
		})
		
		TrollingGroup:AddButton({
			Text = "💥 Fling Hard!",
			Func = function()
				if _G.FlingActive then
					Library:Notify({
						Title = "Fling Already Active!",
						Description = "Stop current fling first",
						Time = 3,
					})
					return
				end
				
				if _G.FlingTargetName and _G.FlingTargetName ~= "" then
					local targets = findPlayers(_G.FlingTargetName)
					if #targets > 0 then
						Library:Notify({
							Title = "🚀 Fling Started!",
							Description = "Aggressively flinging " .. targets[1].Name,
							Time = 3,
						})
						aggressiveFling(targets[1])
					else
						Library:Notify({
							Title = "❌ Player Not Found!",
							Description = "No player found with that name",
							Time = 3,
						})
					end
				else
					Library:Notify({
						Title = "No Target!",
						Description = "Please enter a username first",
						Time = 3,
					})
				end
			end,
			Tooltip = "Agresif fling - Çok güçlü!",
		})
		
		TrollingGroup:AddButton({
			Text = "Stop Fling",
			Func = function()
				if _G.FlingActive then
					_G.FlingActive = false
					if _G.CurrentFlingThrust and _G.CurrentFlingThrust.Parent then
						_G.CurrentFlingThrust:Destroy()
					end
					_G.CurrentFlingThrust = nil
					
					Library:Notify({
						Title = "Fling Stopped!",
						Description = "Fling process manually stopped",
						Time = 2,
					})
				else
					Library:Notify({
						Title = "No Active Fling!",
						Description = "No fling process to stop",
						Time = 2,
					})
				end
			end,
			Tooltip = "Aktif fling işlemini durdur",
		})
		
		-- Improved bang functionality based on proper command structure
		TrollingGroup:AddInput("BangTarget", {
			Default = "",
			Numeric = false,
			Text = "Bang Target",
			Tooltip = "Bang edilecek oyuncunun kullanıcı adını gir",
			Placeholder = "Username...",
			Callback = function(Value)
				_G.BangTargetName = Value
			end,
		})
		
		TrollingGroup:AddSlider("BangSpeed", {
			Text = "Bang Speed",
			Default = 3,
			Min = 1,
			Max = 10,
			Rounding = 1,
			Callback = function(Value)
				_G.BangSpeed = Value
			end,
			Tooltip = "Bang hızını ayarla",
		})
		
		-- Helper function to check if player is R15
		local function isR15(player)
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				return player.Character.Humanoid.RigType == Enum.HumanoidRigType.R15
			end
			return false
		end
		
		-- Helper function to get torso
		local function getTorso(character)
			return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		end
		
		-- Helper function to get root
		local function getRoot(character)
			return character:FindFirstChild("HumanoidRootPart")
		end
		
		TrollingGroup:AddButton({
			Text = "Start Bang",
			Func = function()
				-- Stop any existing bang first
				if _G.BangActive then
					_G.BangActive = false
					if _G.BangDied then _G.BangDied:Disconnect() end
					if _G.BangAnim then _G.BangAnim:Stop() end
					if _G.BangAnimObj then _G.BangAnimObj:Destroy() end
					if _G.BangLoop then _G.BangLoop:Disconnect() end
				end
				
				if _G.BangTargetName and _G.BangTargetName ~= "" then
					-- Find target player
					local function findPlayer(name)
						local found = {}
						local strl = name:lower()
						for _, player in pairs(Players:GetPlayers()) do
							if player.Name:lower():sub(1, #name) == strl then
								table.insert(found, player)
							end
						end
						return found
					end
					
					local targetPlayers = findPlayer(_G.BangTargetName)
					if targetPlayers[1] then
						local targetPlayer = targetPlayers[1]
						
						if targetPlayer.Character and LocalPlayer.Character then
							local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
							if humanoid then
								_G.BangActive = true
								
								-- Create proper animation based on rig type
								_G.BangAnimObj = Instance.new("Animation")
								_G.BangAnimObj.AnimationId = not isR15(LocalPlayer) and "rbxassetid://148840371" or "rbxassetid://5918726674"
								_G.BangAnim = humanoid:LoadAnimation(_G.BangAnimObj)
								_G.BangAnim:Play(0.1, 1, 1)
								_G.BangAnim:AdjustSpeed(_G.BangSpeed or 3)
								
								-- Handle death
								_G.BangDied = humanoid.Died:Connect(function()
									_G.BangAnim:Stop()
									_G.BangAnimObj:Destroy()
									_G.BangDied:Disconnect()
									if _G.BangLoop then _G.BangLoop:Disconnect() end
									_G.BangActive = false
								end)
								
								-- Bang loop
								local bangOffset = CFrame.new(0, 0, 1.1)
								_G.BangLoop = RunService.Stepped:Connect(function()
									pcall(function()
										if _G.BangActive and targetPlayer.Character then
											local otherRoot = getTorso(targetPlayer.Character)
											local myRoot = getRoot(LocalPlayer.Character)
											if otherRoot and myRoot then
												myRoot.CFrame = otherRoot.CFrame * bangOffset
											end
										end
									end)
								end)
								
								Library:Notify({
									Title = "Bang Started!",
									Description = "Banging " .. targetPlayer.Name,
									Time = 3,
								})
							end
						else
							Library:Notify({
								Title = "Bang Failed!",
								Description = "Character not found",
								Time = 3,
							})
						end
					else
						Library:Notify({
							Title = "Player Not Found!",
							Description = "No player found with that name",
							Time = 3,
						})
					end
				else
					Library:Notify({
						Title = "No Target!",
						Description = "Please enter a username first",
						Time = 3,
					})
				end
			end,
			Tooltip = "Girilen kullanıcı adındaki oyuncuya bang yap",
		})
		
		TrollingGroup:AddButton({
			Text = "Stop Bang",
			Func = function()
				if _G.BangActive then
					_G.BangActive = false
					if _G.BangDied then _G.BangDied:Disconnect() end
					if _G.BangAnim then _G.BangAnim:Stop() end
					if _G.BangAnimObj then _G.BangAnimObj:Destroy() end
					if _G.BangLoop then _G.BangLoop:Disconnect() end
					
					Library:Notify({
						Title = "Bang Stopped!",
						Description = "Bang process stopped",
						Time = 2,
					})
				else
					Library:Notify({
						Title = "No Active Bang!",
						Description = "No bang process to stop",
						Time = 2,
					})
				end
			end,
			Tooltip = "Aktif bang işlemini durdur",
		})
		
		-- Player Enhancements groupbox
		local PlayerGroup = Tabs.Main:AddRightGroupbox("Player", "user")
		PlayerGroup:AddSlider("SpeedBoost", {
			Text = "Speed Boost",
			Default = 16,
			Min = 16,
			Max = 100,
			Rounding = 0,
			Callback = function(Value)
				_G.SpeedBoost = Value
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
					LocalPlayer.Character.Humanoid.WalkSpeed = Value
				end
			end,
			Tooltip = "Yürüme hızını artır",
		})
		PlayerGroup:AddSlider("JumpBoost", {
			Text = "Jump Boost",
			Default = 50,
			Min = 50,
			Max = 200,
			Rounding = 0,
			Callback = function(Value)
				_G.JumpBoost = Value
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
					LocalPlayer.Character.Humanoid.JumpPower = Value
				end
			end,
			Tooltip = "Zıplama gücünü artır",
		})
		PlayerGroup:AddToggle("Noclip", {
			Text = "Noclip",
			Tooltip = "Duvarlardan geç",
			Default = false,
			Callback = function(Value)
				_G.Noclip = Value
			end,
		})
		
		-- Teleport functionality
		_G.PlayerList = {}
		_G.SelectedPlayer = nil
		
		local function RefreshPlayerList()
			_G.PlayerList = {}
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(_G.PlayerList, player.Name)
				end
			end
			return _G.PlayerList
		end
		
		-- Initial player list
		RefreshPlayerList()
		
		PlayerGroup:AddDropdown("PlayerSelect", {
			Values = _G.PlayerList,
			Default = 1,
			Text = "Select Player",
			Tooltip = "Teleport edilecek oyuncuyu seç",
			Callback = function(Value)
				_G.SelectedPlayer = Value
			end,
		})
		
		PlayerGroup:AddButton({
			Text = "Refresh List",
			Func = function()
				local newList = RefreshPlayerList()
				Options.PlayerSelect:SetValues(newList)
				Options.PlayerSelect:SetValue(newList[1] or "")
				
				Library:Notify({
					Title = "Player List Refreshed!",
					Description = "Found " .. #newList .. " players",
					Time = 2,
				})
			end,
			Tooltip = "Oyuncu listesini yenile",
		})
		
		PlayerGroup:AddButton({
			Text = "Teleport to Player",
			Func = function()
				if not _G.SelectedPlayer or _G.SelectedPlayer == "" then
					Library:Notify({
						Title = "No Player Selected!",
						Description = "Please select a player first",
						Time = 3,
					})
					return
				end
				
				-- Find the selected player
				local targetPlayer = nil
				for _, player in pairs(Players:GetPlayers()) do
					if player.Name == _G.SelectedPlayer then
						targetPlayer = player
						break
					end
				end
				
				if not targetPlayer then
					Library:Notify({
						Title = "Player Not Found!",
						Description = "Selected player is no longer in the game",
						Time = 3,
					})
					return
				end
				
				if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
					Library:Notify({
						Title = "Teleport Failed!",
						Description = "Target player's character not found",
						Time = 3,
					})
					return
				end
				
				if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					Library:Notify({
						Title = "Teleport Failed!",
						Description = "Your character not found",
						Time = 3,
					})
					return
				end
				
				-- Perform teleport
				local targetPosition = targetPlayer.Character.HumanoidRootPart.CFrame
				LocalPlayer.Character.HumanoidRootPart.CFrame = targetPosition + Vector3.new(0, 0, -5) -- Teleport slightly behind
				
				Library:Notify({
					Title = "Teleported!",
					Description = "Teleported to " .. targetPlayer.Name,
					Time = 2,
				})
			end,
			Tooltip = "Seçilen oyuncuya ışınlan",
		})
		
		-- Spin bot functionality
		PlayerGroup:AddToggle("SpinBot", {
			Text = "Spin Bot",
			Tooltip = "Sürekli döndür",
			Default = false,
			Callback = function(Value)
				_G.SpinBot = Value
			end,
		})
		
		PlayerGroup:AddSlider("SpinSpeed", {
			Text = "Spin Speed",
			Default = 10,
			Min = 1,
			Max = 50,
			Rounding = 0,
			Callback = function(Value)
				_G.SpinSpeed = Value
			end,
			Tooltip = "Dönme hızını ayarla",
		})
		
		-- Initialize player enhancement globals
		_G.SpeedBoost = 16
		_G.JumpBoost = 50
		_G.Noclip = false
		_G.FlingTargetName = ""
		_G.SpinBot = false
		_G.SpinSpeed = 10
		_G.SpinConnection = nil
		_G.BangTargetName = ""
		_G.BangActive = false
		_G.BangAnimTrack = nil
		_G.OriginalWalkSpeed = 16
		
		-- Fixed spin bot functionality
		local spinAngle = 0
		local function HandleSpinBot()
			if _G.SpinBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = LocalPlayer.Character.HumanoidRootPart
				
				-- Increment spin angle based on speed (more responsive)
				spinAngle = spinAngle + (_G.SpinSpeed * 2)
				if spinAngle >= 360 then
					spinAngle = 0
				end
				
				-- Create new CFrame with only Y rotation to prevent flinging
				local currentPos = hrp.Position
				local newCFrame = CFrame.new(currentPos) * CFrame.Angles(0, math.rad(spinAngle), 0)
				
				-- Apply rotation smoothly
				hrp.CFrame = newCFrame
			end
		end
		
		-- Noclip functionality
		local function HandleNoclip()
			if _G.Noclip and LocalPlayer.Character then
				for _, part in pairs(LocalPlayer.Character:GetChildren()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			elseif LocalPlayer.Character then
				for _, part in pairs(LocalPlayer.Character:GetChildren()) do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						part.CanCollide = true
					end
				end
			end
		end
		
		-- Combined function for better performance
		local function HandlePlayerEnhancements()
			HandleNoclip()
			HandleSpinBot()
		end
		
		-- Connect player enhancements to renderstepped
		table.insert(_G.ESPConnections, RunService.RenderStepped:Connect(HandlePlayerEnhancements))
		
		-- Auto-apply speed and jump when character spawns
		local function OnCharacterAdded(character)
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.WalkSpeed = _G.SpeedBoost
			humanoid.JumpPower = _G.JumpBoost
		end
		
		-- Connect to current and future characters
		if LocalPlayer.Character then
			OnCharacterAdded(LocalPlayer.Character)
		end
		LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
		
		-- UI Settings tab içeriği
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Text = "Notification Side",
	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "DPI Scale",
	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)
		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)
		Library.ToggleKeybind = Options.MenuKeybind
		
		-- Addons setup
		ThemeManager:SetLibrary(Library)
		SaveManager:SetLibrary(Library)
		SaveManager:IgnoreThemeSettings()
		SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
		ThemeManager:SetFolder("MyScriptHub")
		SaveManager:SetFolder("MyScriptHub/specific-game")
		SaveManager:SetSubFolder("specific-place")
		SaveManager:BuildConfigSection(Tabs["UI Settings"])
		ThemeManager:ApplyToTab(Tabs["UI Settings"])
		
		-- Load saved settings
		SaveManager:LoadAutoloadConfig()
		
		-- Restore ESP and Aimbot settings from saved config
		spawn(function()
			wait(1) -- Wait for UI to fully load
			if Toggles.ESPEnabled then
				_G.ESPEnabled = Toggles.ESPEnabled.Value
			end
			if Toggles.ShowBox then
				_G.ShowBox = Toggles.ShowBox.Value
			end
			if Toggles.ShowNames then
				_G.ShowNames = Toggles.ShowNames.Value
			end
			if Toggles.ShowHealth then
				_G.ShowHealth = Toggles.ShowHealth.Value
			end
			if Toggles.ShowDistance then
				_G.ShowDistance = Toggles.ShowDistance.Value
			end
			if Toggles.ShowBone then
				_G.ShowBone = Toggles.ShowBone.Value
			end
			if Toggles.TeamCheck then
				_G.TeamCheck = Toggles.TeamCheck.Value
			end
			if Toggles.ChamsEnabled then
				_G.ChamsEnabled = Toggles.ChamsEnabled.Value
			end
			if Options.ChamsMaterial then
				_G.ChamsMaterial = Options.ChamsMaterial.Value
			end
			if Toggles.RainbowChams then
				_G.RainbowChams = Toggles.RainbowChams.Value
			end
			if Toggles.AimbotToggle then
				_G.AimbotEnabled = Toggles.AimbotToggle.Value
			end
			if Options.AimbotFOV then
				_G.AimbotFOV = Options.AimbotFOV.Value
			end
			if Toggles.ShowFOVToggle then
				_G.ShowFOV = Toggles.ShowFOVToggle.Value
			end
			if Options.AimbotTarget then
				_G.AimbotTargetPart = Options.AimbotTarget.Value
			end
			if Options.AimbotSmoothing then
				_G.AimbotSmoothing = Options.AimbotSmoothing.Value
			end
			if Options.Prediction then
				_G.AimbotPrediction = Options.Prediction.Value
			end
			if Options.CameraShake then
				_G.CameraShake = Options.CameraShake.Value
			end
			if Options.SpeedBoost then
				_G.SpeedBoost = Options.SpeedBoost.Value
			end
			if Options.JumpBoost then
				_G.JumpBoost = Options.JumpBoost.Value
			end
			if Toggles.Noclip then
				_G.Noclip = Toggles.Noclip.Value
			end
		end)
		
		-- Main tabına geç
		Window:SetTab(Tabs.Main)
	else
		Library:Notify({
			Title = "Hatalı Anahtar!",
			Description = "Yanlış anahtar girdiniz. Lütfen tekrar deneyin.",
			Time = 3,
		})
	end
end)

Library:OnUnload(function()
	print("Unloaded!")
	
	-- Clean up ESP drawings
	if _G.ESPDrawings then
		for player, drawings in pairs(_G.ESPDrawings) do
			if drawings.Box then
				pcall(function() drawings.Box:Remove() end)
			end
			if drawings.Bones then
				for _, bone in pairs(drawings.Bones) do
					pcall(function() bone:Remove() end)
				end
			end
		end
		_G.ESPDrawings = {}
	end
	
	-- Clean up FOV circle
	if FOVCircle then
		pcall(function() FOVCircle:Remove() end)
	end
	
	-- Disconnect all connections
	if _G.ESPConnections then
		for _, conn in ipairs(_G.ESPConnections) do
			pcall(function() conn:Disconnect() end)
		end
		_G.ESPConnections = {}
	end
	
	-- Clean up ESP GUI elements
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		if player.Character then
			for _, guiName in ipairs({"ESPName", "ESPHealth", "ESPDist"}) do
				local gui = player.Character:FindFirstChild(guiName)
				if gui then
					pcall(function() gui:Destroy() end)
				end
			end
		end
	end
	
	-- Reset global variables
	_G.ESPEnabled = false
	_G.ShowBox = false
	_G.ShowNames = false
	_G.ShowHealth = false
	_G.ShowDistance = false
	_G.ShowBone = false
	_G.TeamCheck = false
	_G.ChamsEnabled = false
	_G.ChamsMaterial = "Wireframe"
	_G.RainbowChams = false
	_G.AimbotEnabled = false
	_G.AimbotFOV = 50
	_G.ShowFOV = false
	_G.AimbotTarget = nil
	_G.AimbotTargetPart = "Head"
	_G.AimbotSmoothing = 5
	_G.AimbotPrediction = 0.1
	_G.CameraShake = 0
	_G.SpeedBoost = 16
	_G.JumpBoost = 50
	_G.Noclip = false
	_G.FlingTargetName = ""
	_G.SpinBot = false
	_G.SpinSpeed = 10
	_G.BangTargetName = ""
	_G.BangActive = false
	_G.BangSpeed = 3
	_G.BangAnimObj = nil
	_G.BangAnim = nil
	_G.BangDied = nil
	_G.BangLoop = nil
	_G.OriginalWalkSpeed = 16
end)
