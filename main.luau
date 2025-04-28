--[[
    Script: Foundation Hub (Modified)
    Original Author: @wicked (based on footer)
    Modification Request: Combine Auto Rooms with Auto Loot Gold, add entity pausing.
    Modifier: AI Assistant
    Date: 2024-07-27
]]

local Repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
if not firetouchinterest or not hookfunction or not fireproximityprompt then
    game:GetService("Players").LocalPlayer:Kick("So sorry, your executor is not supported ):")
end
loadstring(game:HttpGet('https://raw.githubusercontent.com/gigimoose23/LegitHub/refs/heads/main/reviveInf.luau'))()
local Library = loadstring(game:HttpGet(Repo .. "Library.lua"))()
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()
local RepStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ClientMain = Players.LocalPlayer.PlayerGui:WaitForChild("NotBrokenUI").CLIENT_MAIN
Players.LocalPlayer.PlayerGui.DescendantAdded:Connect(function(Object)
    if Object.Name == "CLIENT_MAIN" and Object:IsA("LocalScript") then
        ClientMain = Object
    end
end)
local AntiEntityInternal = {}
local FPLoop = false
local CageDone
local FlySpeed
local IsFlying = false
local espCategories = {
    Entity = false,
    Objectives = false,
    HidingSpots = false,
    Doors = false,
    Coins = false,
    Containers = false,
}
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()


local FLYING = false
local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1

local flyKeyDown, flyKeyUp

local function getRoot(char)
	return char:FindFirstChild("HumanoidRootPart")
end
local TargetSpeed = 10
local SPEED = 0
function sFLY(vfly)
	repeat task.wait() until LocalPlayer and LocalPlayer.Character and getRoot(LocalPlayer.Character) and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

	if flyKeyDown then flyKeyDown:Disconnect() end
	if flyKeyUp then flyKeyUp:Disconnect() end

	local character = LocalPlayer.Character
	local root = getRoot(character)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	

	local function FLY()
		FLYING = true

		local BG = Instance.new("BodyGyro")
		BG.P = 9e4
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = root.CFrame
		BG.Parent = root

		local BV = Instance.new("BodyVelocity")
		BV.Velocity = Vector3.zero
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		BV.Parent = root

		task.spawn(function()
			while FLYING do
				task.wait()

				local camCF = workspace.CurrentCamera.CFrame
				local moveVec = (camCF.LookVector * (CONTROL.F + CONTROL.B)) +
					((camCF * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.Q + CONTROL.E) * 0.2, 0)).Position - camCF.Position)

				if moveVec.Magnitude > 0 then
					SPEED = TargetSpeed
					BV.Velocity = moveVec.Unit * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R, Q = CONTROL.Q, E = CONTROL.E}
				else
					SPEED = 0
					BV.Velocity = Vector3.zero
				end

				BG.CFrame = camCF

				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid and not vfly then
					humanoid.PlatformStand = true
				end
			end

			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			if BG and BG.Parent then BG:Destroy() end
			if BV and BV.Parent then BV:Destroy() end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.PlatformStand = false
			end
		end)
	end

	flyKeyDown = mouse.KeyDown:Connect(function(key)
		key = key:lower()
		local speed = vfly and vehicleflyspeed or iyflyspeed

		if key == "w" then
			CONTROL.F = speed
		elseif key == "s" then
			CONTROL.B = -speed
		elseif key == "a" then
			CONTROL.L = -speed
		elseif key == "d" then
			CONTROL.R = speed
		elseif QEfly and key == "e" then
			CONTROL.Q = speed * 2
		elseif QEfly and key == "q" then
			CONTROL.E = -speed * 2
		end

		pcall(function()
			workspace.CurrentCamera.CameraType = Enum.CameraType.Track
		end)
	end)

	flyKeyUp = mouse.KeyUp:Connect(function(key)
		key = key:lower()

		if key == "w" then
			CONTROL.F = 0
		elseif key == "s" then
			CONTROL.B = 0
		elseif key == "a" then
			CONTROL.L = 0
		elseif key == "d" then
			CONTROL.R = 0
		elseif key == "e" then
			CONTROL.Q = 0
		elseif key == "q" then
			CONTROL.E = 0
		end
	end)

	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown then flyKeyDown:Disconnect() end
	if flyKeyUp then flyKeyUp:Disconnect() end

	local character = Players.LocalPlayer.Character
	if character then
		local root = getRoot(character)
		if root then
			local bg = root:FindFirstChild("BodyGyro")
			local bv = root:FindFirstChild("BodyVelocity")
			if bg then bg:Destroy() end
			if bv then bv:Destroy() end
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
		end
	end

	pcall(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
end
local allTrackedESPs = {}

local function updateESPVisibility()
    for _, data in pairs(allTrackedESPs) do
        local shouldBeVisible = espCategories[data.Category]
        if data.ESP and data.ESP.Visible ~= shouldBeVisible then
             if shouldBeVisible then
                data.ESP:Show()
            else
                data.ESP:Hide()
            end
        end
    end
end


local IsCaged = false


for _, Item in getgc(false) do
    if typeof(Item) == "function" and getinfo(Item).name == "minigameComplete" then
    warn("Found minigameComplete")
    CageDone = Item
        old = hookfunction(Item, function(...)
            
            IsCaged = false
            old(...)
        end)
    end
end

local Options = Library.Options
Options.MenuKeybind = "P" -- Default keybind, can be changed in UI Settings
local Toggles = Library.Toggles

Library.ForceCheckbox = false 
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	

	Title = "Foundation Hub",
	Footer = "made by @wicked",
	Icon = 117293507901367,
	NotifySide = "Right",
	ShowCustomCursor = false

})

local Tabs = {
	Main = Window:AddTab("Main", "user"),
    Visuals = Window:AddTab("Visuals", "camera"),
	Exploits = Window:AddTab("Exploits", "shield-alert"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}
local stateLib = true
repeat wait() until Library and typeof(Library.Toggle) == "function"
if not game:GetService("UserInputService").TouchEnabled then
	local oldToggleFunc = Library.Toggle
	hookfunction(Library.Toggle, function()
        stateLib = not stateLib
        if Library.ScreenGui then Library.ScreenGui.Enabled = stateLib end
        oldToggleFunc()
    end)
    task.spawn(function()
        while task.wait() do
            pcall(function() getrenv()._G.lockMouse = not stateLib end)
        end
    end)
end

local LeftGroupBoxMain = Tabs.Main:AddLeftGroupbox("<b>LocalPlayer</b>")
local WSLoopEnabled = false
local WSLoopVal = 16
LeftGroupBoxMain:AddToggle("WSEnable", {
	Text = "Enable Walkspeed",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		WSLoopEnabled = Value
        if not Value and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
             Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Reset to default
        end
	end,
})

LeftGroupBoxMain:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
    Callback = function(Value)
		IsFlying = Value
        if Value then
            NOFLY()
		    task.wait()
		    sFLY()
        else
            NOFLY()
        end
	end,
}):AddKeyPicker("FlyKey", {
    Mode = "Toggle",
    Default = "F",
    Text = "Fly",
    SyncToggleState = true
})
local dai_enabled = false

local function toggle_proximity_connections(enabled)
    pcall(function()
        for _, prompt in workspace.GeneratedRooms:GetDescendants() do
            if prompt:IsA("ProximityPrompt") then
                for _, con in getconnections(prompt.Triggered) do
                    if enabled then
                        con:Enable()
                    else
                        con:Disable()
                    end
                end
            end
        end
    end)
end

--[[LeftGroupBoxMain:AddToggle("AI", {
    Text = "Auto Interact",
    Default = false,
    Callback = function(value)
        dai_enabled = value
        toggle_proximity_connections(not value)
    end,
}):AddKeyPicker("AIKey", {
    Mode = "Toggle",
    Default = "R",
    Text = "Auto Interact",
    SyncToggleState = true
})]]
local player = Players.LocalPlayer
task.spawn(function()
    while task.wait(0.1) do
        if dai_enabled then
            pcall(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, prompt in workspace.GeneratedRooms:GetDescendants() do
                    if prompt:IsA("ProximityPrompt") and prompt:IsDescendantOf(workspace.GeneratedRooms) and prompt.Enabled then
                        local prompt_pos = nil
                        if prompt.Parent:IsA("Model") then
                            prompt_pos = prompt.Parent:GetPivot().Position
                        elseif prompt.Parent:IsA("BasePart") then
                             prompt_pos = prompt.Parent.Position
                        elseif prompt.Parent:IsA("Attachment") then
                             prompt_pos = prompt.Parent.WorldPosition
                        end

                        if prompt_pos and not (prompt:FindFirstAncestor("Toolshed_Hiding") or
                                prompt:FindFirstAncestor("Locker") or
                                prompt:FindFirstAncestor("OpenedSTORAGE") or
                                (prompt.Parent.Parent and prompt.Parent.Parent:FindFirstChild("OpenedSTORAGE"))) and
                                (prompt_pos - hrp.Position).Magnitude < prompt.MaxActivationDistance then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end)
        end
    end
end)
local JumpTog =LeftGroupBoxMain:AddToggle("Jump", {
	Text = "Allow Jumping",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		if Players.LocalPlayer.Character then
            pcall(function() Players.LocalPlayer.Character:SetAttribute("AllowedToJump", Value) end)
        end
	end,
})
local Noclipping
local Clip = true
local RunService = game:GetService("RunService")
LeftGroupBoxMain:AddToggle("Noclip", {
	Text = "Noclip",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		if Value == false then
            if Noclipping then
		        Noclipping:Disconnect()
                Noclipping = nil
	        end
            if Players.LocalPlayer.Character then
                for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
		        	if child:IsA("BasePart") and child.CanCollide == false and child.Name ~= "Head" and child.Name ~= "HumanoidRootPart" then
		        		pcall(function() child.CanCollide = true end)
		        	end
		        end
            end
	        Clip = true
        else
            Clip = false
	        task.wait(0.1)
	        local function NoclipLoop()
		        if Clip == false and Players.LocalPlayer.Character ~= nil then
		    	    for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
		    		    if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= "HumanoidRootPart" then
		    			    pcall(function() child.CanCollide = false end)
		    		    end
		    	    end
		        end
	        end
            if Noclipping then Noclipping:Disconnect() end
	        Noclipping = RunService.Stepped:Connect(NoclipLoop)
        end
	end,
})

LeftGroupBoxMain:AddSlider("WSSlider", {
	Text = "WalkSpeed",
	Default = WSLoopVal,
	Min = 5,
	Max = 100,
	Rounding = 1,
	Compact = true,

	Callback = function(Value)
		WSLoopVal = Value
	end,

	Disabled = false, 
	Visible = true, 
})

LeftGroupBoxMain:AddSlider("FSpeed", {
	Text = "Fly Speed",
	Default = 16,
	Min = 10,
	Max = 300,
	Rounding = 1,
	Compact = true,

	Callback = function(Value)
		TargetSpeed = Value
	end,

	Disabled = false, 
	Visible = true, 
})
task.spawn(function()
    while task.wait(0.1) do
        if WSLoopEnabled and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            Players.LocalPlayer.Character.Humanoid.WalkSpeed = WSLoopVal
        end
        if IsFlying and not FPLoop then
             if Players.LocalPlayer.Character then
                for _, Obj in Players.LocalPlayer.Character:GetDescendants() do
                    if Obj:IsA("BasePart") and Obj.Name == "Handle" then
                        pcall(function()
                            Obj.Transparency = 1
                            Obj.LocalTransparencyModifier = 1
                        end)
                    end
                end
            end
        end
    end
end)


local RightGroupBoxMainQuick = Tabs.Main:AddRightGroupbox("<b>Quick Buttons</b>")
RightGroupBoxMainQuick:AddButton({
	Text = "Lobby",
	Func = function()
		RepStorage.Events.PlayerActions.LeaveToLobby:FireServer()
	end,
	DoubleClick = true,

	Disabled = false,
	Visible = true,
})
RightGroupBoxMainQuick:AddButton({
	Text = "Play Again",
	Func = function()
		RepStorage.Events.PlayerActions.PlayAgain:FireServer()
	end,
	DoubleClick = true,

	Disabled = false,
	Visible = true,
})
RightGroupBoxMainQuick:AddButton({
	Text = "Reset",
	Func = function()
		RepStorage.Events.EntityEvents.DamageFromClient:FireServer({
            AttackedBy = "Legit Hub", 
            IsSet = true, 
            IgnoresHide = false, 
            Damage = 0 -- Setting damage to 0 might not reset, usually need high damage. Let's try math.huge
        })
        -- Let's try a high damage value instead
         RepStorage.Events.EntityEvents.DamageFromClient:FireServer({
            AttackedBy = "Legit Hub Reset", 
            IsSet = true, 
            IgnoresHide = true, -- Ignore hide just in case
            Damage = math.huge
        })
	end,
	DoubleClick = true,

	Disabled = false,
	Visible = true,
})

local LeftGroupBoxMainPrompts = Tabs.Main:AddLeftGroupbox("<b>Prompts</b>")
local InstaRact = false
LeftGroupBoxMainPrompts:AddToggle("InstantInteract", {
	Text = "Instant Interact",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		InstaRact = Value
        if Value == false then
            for _, Prompt in workspace:GetDescendants() do
                if Prompt:IsA("ProximityPrompt") and Prompt:GetAttribute("OrigHold") ~= nil then
                    Prompt.HoldDuration = Prompt:GetAttribute("OrigHold")
                    Prompt:SetAttribute("OrigHold", nil) -- Clear attribute
                end
            end
        elseif Value == true then
            for _, Prompt in workspace:GetDescendants() do
                if Prompt:IsA("ProximityPrompt") then
                    if Prompt:GetAttribute("OrigHold") == nil then -- Only set if not already set
                        Prompt:SetAttribute("OrigHold", Prompt.HoldDuration)
                    end
                    Prompt.HoldDuration = 0
                end
            end
        end
	end,
})

workspace.DescendantAdded:Connect(function(Prompt)
    if Prompt:IsA("ProximityPrompt") and InstaRact then
        if Prompt:GetAttribute("OrigHold") == nil then
             Prompt:SetAttribute("OrigHold", Prompt.HoldDuration)
        end
        Prompt.HoldDuration = 0
    end
    -- Keep the OpenedSTORAGE logic
    if Prompt:IsA("Model") and Prompt:GetAttribute("Open") ~= nil and Prompt.Name ~= "Door" then
        Prompt:GetAttributeChangedSignal("Open"):Once(function()
            if Prompt:GetAttribute("Open") == true then
                 Prompt.Name = "OpenedSTORAGE"
            end
        end)
         -- Check initial state too
        if Prompt:GetAttribute("Open") == true then
             Prompt.Name = "OpenedSTORAGE"
        end
    end
end)
local PM = 1
local PR = false
LeftGroupBoxMainPrompts:AddToggle("PromptReach", {
	Text = "Prompt Reach",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		PR = Value
        if Value == false then
            for _, Prompt in workspace:GetDescendants() do
                if Prompt:IsA("ProximityPrompt") then
                    local origLOS = Prompt:GetAttribute("OrigLOSReq")
                    local origMAD = Prompt:GetAttribute("OrigMAD")
                    if origLOS ~= nil then Prompt.RequiresLineOfSight = origLOS end
                    if origMAD ~= nil then Prompt.MaxActivationDistance = origMAD end
                    Prompt:SetAttribute("OrigLOSReq", nil) -- Clear attributes
                    Prompt:SetAttribute("OrigMAD", nil)
                end
            end
        elseif Value == true then
            for _, Prompt in workspace:GetDescendants() do
                if Prompt:IsA("ProximityPrompt") then
                   if Prompt:GetAttribute("OrigLOSReq") == nil then Prompt:SetAttribute("OrigLOSReq", Prompt.RequiresLineOfSight) end
                   if Prompt:GetAttribute("OrigMAD") == nil then Prompt:SetAttribute("OrigMAD", Prompt.MaxActivationDistance) end
                    Prompt.RequiresLineOfSight = false
                    Prompt.MaxActivationDistance = Prompt:GetAttribute("OrigMAD") * PM -- Use original * multiplier
                end
            end
        end
	end,
})
LeftGroupBoxMainPrompts:AddSlider("PM", {
	Text = "Prompt Reach Multiplier",
	Default = PM,
	Min = 1,
	Max = 5, -- Increased max based on user likely wanting more reach
	Rounding = 1,
	Compact = true,

	Callback = function(Value)
		PM = Value
        if PR then
             for _, Prompt in workspace:GetDescendants() do
                if Prompt:IsA("ProximityPrompt") then
                   local origMAD = Prompt:GetAttribute("OrigMAD")
                   if origMAD == nil then -- If attribute not set yet, set it first
                        Prompt:SetAttribute("OrigMAD", Prompt.MaxActivationDistance)
                        origMAD = Prompt.MaxActivationDistance
                   end
                   Prompt.RequiresLineOfSight = false
                   Prompt.MaxActivationDistance = origMAD * PM -- Apply multiplier to original value
                end
            end
        end
	end,

	Disabled = false, 
	Visible = true, 
})
workspace.DescendantAdded:Connect(function(Prompt)
    if Prompt:IsA("ProximityPrompt") and PR then
        if Prompt:GetAttribute("OrigLOSReq") == nil then Prompt:SetAttribute("OrigLOSReq", Prompt.RequiresLineOfSight) end
        if Prompt:GetAttribute("OrigMAD") == nil then Prompt:SetAttribute("OrigMAD", Prompt.MaxActivationDistance) end
        Prompt.RequiresLineOfSight = false
        Prompt.MaxActivationDistance = Prompt:GetAttribute("OrigMAD") * PM
    end
end)

-- =============================================================
-- Auto Rooms & Combined Auto Rooms/Loot Logic
-- =============================================================
local AutoRoomsGroupBox = Tabs.Main:AddRightGroupbox("<b>Auto-Rooms</b>") -- Changed from Left to Right as per original script structure
local ARTargetReach = 205
local ARGoing = false -- For original Auto Rooms button
local CombinedAutoRoomsLootEnabled = false -- For the new combined feature
local CombinedFeatureLootSideRoomsEnabled = false -- Side room toggle for combined feature
local AutoProcessPausedByEntity = false -- Global pause state
local IsAutoLootingRoom = false -- Tracks if loot function is active
local ARCon -- Connection for the auto rooms loop
local FiredPrompts = {}
local DoggedRooms = {}
local CutFolder = Instance.new("Folder")
CutFolder.Name = "CutsceneBackup"
CutFolder.Parent = LocalPlayer.PlayerGui -- Store it somewhere safe

local CollectionService = game:GetService("CollectionService")
local Rooms = workspace.GeneratedRooms

-- Function to check for dangerous entities
local function CheckForDangerousEntities()
    return workspace:FindFirstChild("Rush") or workspace:FindFirstChild("Ambush") or workspace:FindFirstChild("Ram")
end

-- Entity Pausing Loop
task.spawn(function()
    while task.wait(0.25) do
        if ARGoing or CombinedAutoRoomsLootEnabled then -- Only check if an auto feature is active
            if CheckForDangerousEntities() then
                if not AutoProcessPausedByEntity then
                    warn("Dangerous entity detected! Pausing Auto Rooms/Loot.")
                    Library:Notify("Entity detected! Pausing...", 2)
                    AutoProcessPausedByEntity = true
                end
            else
                if AutoProcessPausedByEntity then
                    warn("Dangerous entity gone. Resuming Auto Rooms/Loot.")
                    Library:Notify("Entity gone. Resuming...", 1)
                    AutoProcessPausedByEntity = false
                end
            end
        else
            -- Ensure pause is off if no auto feature is running
            if AutoProcessPausedByEntity then
                 AutoProcessPausedByEntity = false
            end
        end
    end
end)

-- Function to wait while paused
local function WaitIfPaused()
    while AutoProcessPausedByEntity do
        task.wait(0.5)
    end
end

-- Refactored Auto Loot Gold Function
local AutoLootVersion = "2.19-CombinedFeature"
local function ExecuteAutoLootGold(targetRoomModel, forceFastMode, lootSideRooms, waitTimeOverride)
    Library:Notify("Auto Loot Gold Started (v" .. AutoLootVersion .. ")", 1)
    warn("--- Auto Loot Gold (v" .. AutoLootVersion .. ") Started ---")
    if forceFastMode then warn("--- Fast Gold Loot Enabled (Forced) ---") end

    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then Library:Notify("Player character not found.", 3); warn("ERROR: Player character not found."); return false end

    -- Use provided room model
    local currentRoomModel = targetRoomModel
    if not currentRoomModel or not currentRoomModel:IsA("Model") then Library:Notify("Target room data is invalid.", 3); warn("ERROR: Target room data is invalid."); return false end
    warn("Target Room Model:", currentRoomModel:GetFullName())

    local goldItemNames = {"Coin", "CoinStack", "GoldBar", "GoldBarAndDiamonds"}
    local itemsLootedCount = 0
    local partsToLootAfterOpening = {}
    local overallContainerIndex = 0
    local lootWaitTime = waitTimeOverride -- Use the provided wait time

    -- Function to try looting an item via teleport loop (STANDARD METHOD for gold)
    local function tryFirePromptForItem_Teleport(itemPromptRef, itemModel, itemContextName)
         WaitIfPaused() -- Check pause before starting
         if not (itemModel and itemModel.Parent) then return true end
         local originalCFrame = character.HumanoidRootPart.CFrame; local looted = false; local attempts = 0; local maxLoopTime = 7; local startTime = tick(); local firstAttempt = true
         while itemModel and itemModel.Parent and (tick() - startTime < maxLoopTime) do
             WaitIfPaused() -- Check pause inside loop
             if firstAttempt then task.wait(0.1); firstAttempt = false end;
             local currentItemPrompt = itemModel:FindFirstChild("ItemPrompt");
             if currentItemPrompt and currentItemPrompt:IsA("ProximityPrompt") and currentItemPrompt.Enabled then
                 local promptParent = currentItemPrompt.Parent; if not promptParent then break end;
                 local targetCFrame;
                 if promptParent:IsA("Model") then targetCFrame = promptParent:GetPivot()
                 elseif promptParent:IsA("BasePart") then targetCFrame = promptParent.CFrame
                 elseif promptParent:IsA("Attachment") then targetCFrame = promptParent.WorldCFrame end;

                 if targetCFrame then
                     character:PivotTo(targetCFrame); task.wait(0.05);
                     WaitIfPaused() -- Check pause before firing
                     local success, err = pcall(fireproximityprompt, currentItemPrompt); task.wait(0.07);
                     if not itemModel or not itemModel.Parent then looted = true; break end
                 end
             end;
             attempts = attempts + 1; task.wait(0.1)
         end
         character:PivotTo(originalCFrame);
         if not itemModel or not itemModel.Parent then looted = true else looted = false; warn("    -- WARNING: Item", itemContextName, "still exists after TP loot attempts.") end;
         return looted
    end

    -- Function to trigger a container prompt reliably (teleport and fire ONCE or TWICE)
    local function triggerContainerPrompt_Reliable(prompt, containerPart, promptContextName)
        WaitIfPaused() -- Check pause before starting
        warn("    -- Triggering Container Prompt Reliably:", promptContextName)
        if not (containerPart and containerPart.Parent) then warn("      -- ERROR: Invalid container part."); return end;
        if not (prompt and prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Enabled) then warn("      -- ERROR: Invalid or disabled prompt."); return end;
        local originalCFrame = character.HumanoidRootPart.CFrame; local promptParent = prompt.Parent;
        local targetCFrame;
        if promptParent:IsA("Model") then targetCFrame = promptParent:GetPivot()
        elseif promptParent:IsA("BasePart") then targetCFrame = promptParent.CFrame
        elseif promptParent:IsA("Attachment") then targetCFrame = promptParent.WorldCFrame end;
        if not targetCFrame then warn("      -- ERROR: Could not get target CFrame."); character:PivotTo(originalCFrame); return end

        character:PivotTo(targetCFrame); task.wait(0.07);
        WaitIfPaused() -- Check pause before firing
        local success1, err1 = pcall(fireproximityprompt, prompt); task.wait(0.08);
        if prompt and prompt.Parent and prompt.Enabled then
             WaitIfPaused() -- Check pause before second fire
             pcall(fireproximityprompt, prompt); task.wait(0.05)
        end;
        character:PivotTo(originalCFrame); warn("      -- Finished reliable trigger attempt for:", promptContextName)
    end

    -- MODIFIED: Function to find and loot gold (Handles Table structure correctly)
    local function findAndLootGold(itemContainer, containerContextName)
        WaitIfPaused() -- Check pause at function start
        if not itemContainer then warn("    -- ERROR: itemContainer is nil. Aborting loot."); return end

        local itemParentToSearch = itemContainer
        local spawnFolder = nil

        spawnFolder = itemContainer:FindFirstChild("ItemSpawns") or itemContainer:FindFirstChild("SpawnAreas")

        if not spawnFolder and itemContainer.Name == "Outside_Container" then
             local baseOutline = itemContainer:FindFirstChild("BaseOutline")
             if baseOutline then
                  spawnFolder = baseOutline:FindFirstChild("ItemSpawns") or baseOutline:FindFirstChild("SpawnAreas")
             end
        end

        if spawnFolder then itemParentToSearch = spawnFolder end

        if not itemParentToSearch or not itemParentToSearch.Parent then warn("    -- ERROR: Invalid itemParentToSearch:", itemParentToSearch and itemParentToSearch:GetFullName() or "nil"); return end

        local potentialItems = itemParentToSearch:GetChildren();
        if #potentialItems == 0 then return end

        for i, item in ipairs(potentialItems) do
            WaitIfPaused() -- Check pause inside loop
            local itemModel = item; if not (itemModel and itemModel.Parent) then continue end
            if table.find(goldItemNames, itemModel.Name) then
                local itemPrompt = itemModel:FindFirstChild("ItemPrompt")
                if itemPrompt and itemPrompt:IsA("ProximityPrompt") then
                    local lootedThisItem = false
                    if forceFastMode then
                        local fastAttempts = 0; local maxFastAttempts = 3
                        while fastAttempts < maxFastAttempts do
                            WaitIfPaused() -- Check pause in fast loop
                            if not (itemModel and itemModel.Parent) then lootedThisItem = true; break end;
                            if not (itemPrompt and itemPrompt.Parent and itemPrompt.Enabled) then warn("      -- Gold Prompt became invalid during fast loot attempt."); break end;
                            pcall(fireproximityprompt, itemPrompt); task.wait(0.05); fastAttempts = fastAttempts + 1
                        end
                        if not (itemModel and itemModel.Parent) then itemsLootedCount = itemsLootedCount + 1; lootedThisItem = true else warn("          -- FAILURE: Gold still exists after brief direct fire. Falling back to teleport.") end
                    end
                    if not lootedThisItem then
                        if tryFirePromptForItem_Teleport(itemPrompt, itemModel, itemModel.Name .. " ItemPrompt in " .. containerContextName) then
                            itemsLootedCount = itemsLootedCount + 1
                        else
                            warn("          -- FAILED teleport loot for GOLD:", itemModel.Name)
                        end
                    end
                else warn("        -- ERROR: Could not find ItemPrompt inside gold item:", itemModel.Name) end
            end
        end
    end -- End of findAndLootGold function

    -- =============================================================
    -- Phase 1: Check True State, Trigger if Needed, Identify Loot Locations
    -- =============================================================
    warn("\n--- Starting Phase 1: Checking True State & Identifying Loot Locations ---")

    local function processItemForOpening(item)
        WaitIfPaused() -- Check pause at start
        if not item or not item.Parent then return end
        local children = item:GetChildren()
        for _, child in ipairs(children) do
            WaitIfPaused() -- Check pause in loop
            if not child or not child.Parent then continue end
            local isKnownContainer = child:IsA("Model") and (child.Name:find("LockerVariant") or child.Name:find("CrowbarVariant") or child.Name == "Drawer" or child.Name:find("Table") or child.Name == "Rolltop" or child.Name == "ToolBox")

            if isKnownContainer then
                overallContainerIndex = overallContainerIndex + 1
                local containerModel = child; local modelIndex = overallContainerIndex
                warn("-- [Open Phase] Processing Container:", containerModel.Name, "#", modelIndex)
                local containerChildren = containerModel:GetChildren(); local lootPartsToAdd = {}

                local function checkAndTrigger(promptRef, innerModelRef, partForTrigger, context)
                    WaitIfPaused() -- Check pause before check/trigger
                    local promptOpenedAttr = promptRef and promptRef:GetAttribute("Opened"); local nameOK = innerModelRef and innerModelRef.Name == "OpenedSTORAGE"; local isTrulyOpen = (promptOpenedAttr == true and nameOK == true)
                    warn("      -- Check:", context, "Prompt Attr:", tostring(promptOpenedAttr), "Inner Name:", innerModelRef and innerModelRef.Name or "N/A", "Truly Open:", isTrulyOpen)
                    if not isTrulyOpen and promptRef then warn("        -- Marked for opening trigger."); triggerContainerPrompt_Reliable(promptRef, partForTrigger, context .. " Trigger #" .. modelIndex) elseif not promptRef then warn("      -- WARNING: No prompt found for", context) end
                end

                local innerModels = {}
                for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name == "Container" or cChild.Name == "OpenedSTORAGE") then table.insert(innerModels, cChild) end end
                local innerModelRef = #innerModels > 0 and innerModels[1] or nil

                -- Handle Drawer
                if containerModel.Name == "Drawer" then
                    for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name:find("Container", 1, true) or cChild.Name == "OpenedSTORAGE") and cChild.Name ~= "Outside_Container" then local currentInnerModel = cChild; local mainDrawer = currentInnerModel:FindFirstChild("MainDrawer"); if mainDrawer then local proxAttach = mainDrawer:FindFirstChild("ProxAttach", true); local prompt = proxAttach and proxAttach:FindFirstChild("ProximityPrompt"); checkAndTrigger(prompt, currentInnerModel, mainDrawer, "Drawer." .. currentInnerModel.Name); table.insert(lootPartsToAdd, mainDrawer); else warn("    -- ERROR: No MainDrawer in", cChild:GetFullName()) end end end
                    local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer); end

                -- Handle Lockers/Crowbars
                elseif containerModel.Name:find("LockerVariant") or containerModel.Name:find("CrowbarVariant") then
                     local basePart = innerModelRef and innerModelRef:FindFirstChild("Base"); if basePart then table.insert(lootPartsToAdd, basePart) else warn("    -- WARNING: Could not find Base part for Locker.") end
                     if containerModel.Name:find("LLV2") or containerModel.Name:find("Variant2") then local doorBottom = containerModel:FindFirstChild("DoorBottom"); local promptB = doorBottom and doorBottom:FindFirstChild("DoorBottom", true) and doorBottom.DoorBottom:FindFirstChild("ProximityPrompt"); local doorTop = containerModel:FindFirstChild("DoorTop"); local promptT = doorTop and doorTop:FindFirstChild("DoorTop", true) and doorTop.DoorTop:FindFirstChild("ProximityPrompt"); checkAndTrigger(promptB, innerModelRef, doorBottom, "LockerV2 Bottom Door"); checkAndTrigger(promptT, innerModelRef, doorTop, "LockerV2 Top Door")
                     else local door = containerModel:FindFirstChild("Door"); local promptD = door and door:FindFirstChild("ProximityPrompt"); checkAndTrigger(promptD, innerModelRef, door, "Locker Single Door") end

                -- Handle Rolltop
                elseif containerModel.Name == "Rolltop" then
                     local mainDrawerRef = innerModelRef and innerModelRef:FindFirstChild("MainDrawer"); if mainDrawerRef then local pA = mainDrawerRef:FindFirstChild("ProxAttach"); local promptR = pA and pA:FindFirstChild("ProximityPrompt"); checkAndTrigger(promptR, innerModelRef, mainDrawerRef, "Rolltop MainDrawer"); table.insert(lootPartsToAdd, mainDrawerRef) else warn("    -- WARNING: Could not find MainDrawer for Rolltop.") end
                     local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer) end

                -- Handle ToolBox
                elseif containerModel.Name == "ToolBox" then
                     local spawnAreasRef = nil; local toolBoxInnerModel = nil
                     for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name == "Container" or cChild.Name == "OpenedSTORAGE") then toolBoxInnerModel = cChild; break end end
                     if toolBoxInnerModel then
                          local promptTB = containerModel:FindFirstChild("ProximityPrompt"); checkAndTrigger(promptTB, toolBoxInnerModel, toolBoxInnerModel, "ToolBox")
                          local baseRef = toolBoxInnerModel:FindFirstChild("Base"); if baseRef then spawnAreasRef = baseRef:FindFirstChild("SpawnAreas"); if spawnAreasRef then table.insert(lootPartsToAdd, spawnAreasRef) else warn("    -- WARNING: ToolBox Base found, but no SpawnAreas.") end else warn("    -- WARNING: ToolBox InnerContainer found, but no Base.") end
                     else warn("    -- WARNING: Could not find InnerContainer for ToolBox.") end

                -- Handle ALL Table variants
                elseif containerModel.Name:find("Table") then
                     local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer) else warn("    -- WARNING: No Outside_Container found for Table variant:", containerModel.Name) end
                end

                if #lootPartsToAdd > 0 then
                    for _, part in ipairs(lootPartsToAdd) do
                        if part and part.Parent then table.insert(partsToLootAfterOpening, part) else warn("      -- Skipping invalid loot part.") end
                    end
                end

            elseif child.Name == "AddedAssets" and child:IsA("Folder") then processItemForOpening(child)
            elseif lootSideRooms and child.Name == "SideRoom" and child:IsA("Model") then processItemForOpening(child)
            end
            task.wait() -- Minimal yield
        end
    end

    warn("--- Starting Phase 1 Recursive Processing ---"); processItemForOpening(currentRoomModel); warn("--- Finished Phase 1 Recursive Processing ---")
    warn("-- Phase 1 Summary: Identified", #partsToLootAfterOpening, "potential loot locations.")

    if lootWaitTime > 0 and #partsToLootAfterOpening > 0 then warn("\n--- Performing global wait for", lootWaitTime, "seconds... ---"); task.wait(lootWaitTime)
    elseif #partsToLootAfterOpening == 0 then warn("\n--- No open containers identified for looting. Skipping wait and Loot Phase. ---")
    else warn("\n--- Loot wait time is 0. Proceeding directly to Loot Phase. ---") end

    if #partsToLootAfterOpening > 0 then
        warn("\n--- Starting Phase 2: Looting Gold ---"); local uniquePartsLooted = {}
        for i, part in ipairs(partsToLootAfterOpening) do
            WaitIfPaused() -- Check pause before looting each part
            if not (part and part.Parent) then warn("    -- Skipping part #", i, "as it no longer exists."); continue end
            if uniquePartsLooted[part] then continue end
            local contextName = part.Name; local parentModel = part:FindFirstAncestorWhichIsA("Model"); if parentModel then contextName = parentModel.Name .. " " .. contextName end
            findAndLootGold(part, contextName .. " #" .. i); uniquePartsLooted[part] = true
        end
        warn("--- Finished Phase 2: Looting Gold ---")
    end

    warn("--- Auto Loot Gold Finished ---")
    Library:Notify("Auto Loot Gold Finished (v" .. AutoLootVersion .. "). Looted " .. itemsLootedCount .. " gold items.", 3)
    return true -- Indicate success
end -- End of ExecuteAutoLootGold

-- Auto Rooms Loop Function
local function StartAutoRoomsLoop(isCombined)
    if ARCon then ARCon:Disconnect(); ARCon = nil end -- Disconnect previous if any

    FiredPrompts = {}
    DoggedRooms = {}
    -- Move cutscenes
    for _, scene in ClientMain.CLIENT.CutsceneHandler.Cutscenes:GetChildren() do
        scene.Parent = CutFolder
    end

    ARCon = RunService.Stepped:Connect(function()
        -- Check if the feature was disabled externally
        if (isCombined and not CombinedAutoRoomsLootEnabled) or (not isCombined and not ARGoing) then
             if ARCon then ARCon:Disconnect(); ARCon = nil end
             -- Move cutscenes back
             for _, scene in CutFolder:GetChildren() do
                scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes
             end
             Library:Notify("Auto rooms stopped.", 1)
             warn("Auto rooms loop stopped externally.")
             RepStorage.Events.VoidEvent:FireServer() -- Fire void event on stop
             IsAutoLootingRoom = false -- Ensure loot flag is reset
             AutoProcessPausedByEntity = false -- Ensure pause flag is reset
             return
        end

        -- Wait if paused by entity or if currently looting (in combined mode)
        while AutoProcessPausedByEntity or (isCombined and IsAutoLootingRoom) do
            task.wait(0.5)
            -- Re-check if the feature was disabled during the pause
            if (isCombined and not CombinedAutoRoomsLootEnabled) or (not isCombined and not ARGoing) then
                 if ARCon then ARCon:Disconnect(); ARCon = nil end
                 for _, scene in CutFolder:GetChildren() do scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes end
                 Library:Notify("Auto rooms stopped.", 1)
                 warn("Auto rooms loop stopped during pause.")
                 RepStorage.Events.VoidEvent:FireServer()
                 IsAutoLootingRoom = false
                 AutoProcessPausedByEntity = false
                 return
            end
        end

        local Character = Players.LocalPlayer.Character
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end -- Need character

        local RoomNumbers = {}
        local currentRoomNumber = -1
        local currentRoomModel = nil
        if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.CurrentRoom then
            currentRoomModel = ClientMain.CLIENT.Values.CurrentRoom.Value
            if currentRoomModel then
                local numStr = currentRoomModel.Name:match("Room(%d+)")
                if numStr then currentRoomNumber = tonumber(numStr) end
            end
        end

        for _, Room in Rooms:GetChildren() do
            CollectionService:RemoveTag(Room, "DarkRoom") -- Keep fullbright consistent
            local NumberStr = Room.Name:match("Room(%d+)")
            if NumberStr then
                table.insert(RoomNumbers, tonumber(NumberStr))
            end
        end
        if #RoomNumbers == 0 then return end -- No rooms generated yet

        table.sort(RoomNumbers)
        local LastRoomNumber = RoomNumbers[#RoomNumbers]
        local TargetRoomNumber = Options.ARRoomReach.Value

        -- Check completion condition
        if LastRoomNumber >= TargetRoomNumber then
            if ARCon then ARCon:Disconnect(); ARCon = nil end
            ARGoing = false
            CombinedAutoRoomsLootEnabled = false
            Toggles.AutoRoomsCombinedToggle:SetValue(false) -- Update UI toggle
            Toggles.AutoRoomsStartStop:SetText("Start") -- Update button text
            Library:Notify("Target room " .. TargetRoomNumber .. " reached. Auto rooms done.", 3)
            warn("Target room reached. Auto rooms done.")
            FiredPrompts = {}
            DoggedRooms = {}
            for _, scene in CutFolder:GetChildren() do scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes end
            RepStorage.Events.VoidEvent:FireServer()
            IsAutoLootingRoom = false
            AutoProcessPausedByEntity = false
            return
        end

        local nextRoomNumber = currentRoomNumber + 1
        local nextRoomModel = Rooms:FindFirstChild("Room" .. tostring(nextRoomNumber))

        if not nextRoomModel then
             warn("Waiting for next room model: Room" .. nextRoomNumber)
             return -- Wait for the next room model to exist
        end

        -- Notify about new room
        if not table.find(DoggedRooms, nextRoomModel) then
            table.insert(DoggedRooms, nextRoomModel)
            local roomName = nextRoomModel.Name
            local rawName = nextRoomModel:GetAttribute("RawName") or "Unknown"
            local chance = nextRoomModel:GetAttribute("Chance")
            local notifyMsg = "Auto Rooms: Entered " .. roomName
            if Options.RMUnify.Value == "Special Room" and chance == 0 then
                notifyMsg = notifyMsg .. " (Special: " .. rawName .. ")"
                Library:Notify(notifyMsg, 2)
            elseif Options.RMUnify.Value == "Current Room" then
                 Library:Notify(notifyMsg, 1)
            end
            warn(notifyMsg)

             -- *** COMBINED FEATURE: Trigger Auto Loot Here ***
            if isCombined then
                IsAutoLootingRoom = true -- Set flag before starting loot
                warn("Combined Mode: Starting Auto Loot for", roomName)
                Library:Notify("Auto Looting " .. roomName .. "...", 1)
                -- Execute loot: Force fast mode, use specific side room toggle, 0 wait time
                local success = ExecuteAutoLootGold(nextRoomModel, true, CombinedFeatureLootSideRoomsEnabled, 0)
                if success then
                    warn("Combined Mode: Auto Loot finished for", roomName)
                    Library:Notify("Finished looting " .. roomName, 1)
                else
                     warn("Combined Mode: Auto Loot failed for", roomName)
                     Library:Notify("Auto Loot failed for " .. roomName, 2)
                end
                IsAutoLootingRoom = false -- Clear flag after loot finishes/fails
                WaitIfPaused() -- Check pause again immediately after looting finishes
            end
        end

        -- Handle specific room logic (Observatory, etc.)
        if nextRoomModel.Name == "Room195" then
            RepStorage.Events.TheObservatory.BeatPuzzle:FireServer()
        end

        -- Find door/trigger for the *next* room to open it
        local Door = nextRoomModel:FindFirstChild("Door") or nextRoomModel:FindFirstChild("DoorNormal")
        local Scriptable = nextRoomModel:FindFirstChild("Scriptable")
        local Hitbox = (Door and Door:FindFirstChild("Hitbox")) or (Scriptable and Scriptable:FindFirstChild("Trigger"))
        local Lever = nextRoomModel:FindFirstChild("CaveLever")
        local Prompt = Lever and Lever:FindFirstChild("ProximityPrompt", true)
        -- Elevator logic might need adjustment if it's the *exit* of the current room, not entrance of next
        -- Let's assume standard door/hitbox/lever for now

        -- Handle Lever first if present
        if Prompt and Prompt.Enabled and not FiredPrompts[Prompt] then
            warn("Attempting to fire lever prompt in", nextRoomModel.Name)
            local success = pcall(function()
                 Character:PivotTo(Lever:GetPivot() * CFrame.new(0, -3, 5)) -- Move slightly in front
                 task.wait(0.1)
                 fireproximityprompt(Prompt)
            end)
            if success then
                FiredPrompts[Prompt] = true
                warn("Lever prompt fired for", nextRoomModel.Name)
                task.wait(0.5) -- Wait a bit after lever
            else
                 warn("Failed to fire lever prompt for", nextRoomModel.Name)
            end
            return -- Process one action per step
        end

        -- Handle Door Hitbox if no lever was processed
        if Hitbox and not (Prompt and Prompt.Enabled and not FiredPrompts[Prompt]) then
            warn("Attempting to trigger hitbox for", nextRoomModel.Name)
            local targetCFrame = Character.HumanoidRootPart.CFrame -- Default to current pos
             -- Try to get a CFrame inside the *current* room near the exit towards the next room
            if currentRoomModel then
                 local currentExit = currentRoomModel:FindFirstChild("Exit")
                 if currentExit then targetCFrame = currentExit.WorldCFrame * CFrame.new(0,0,-5) -- Stand 5 studs back from exit pivot
                 else targetCFrame = currentRoomModel:GetPivot() * CFrame.new(0, 5, 10) end -- Fallback CFrame
            end

            local success = pcall(function()
                Character:PivotTo(targetCFrame)
                task.wait(0.1)
                -- Make hitbox huge temporarily to ensure trigger
                local originalSize = Hitbox.Size
                local originalCF = Hitbox.CFrame
                Hitbox.Size = Vector3.new(50, 50, 50)
                Hitbox.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3) -- Place hitbox in front of player
                task.wait(0.2) -- Allow physics to update
                -- Restore hitbox
                Hitbox.Size = originalSize
                Hitbox.CFrame = originalCF
            end)
             if success then
                 warn("Hitbox triggered for", nextRoomModel.Name)
                 task.wait(0.5) -- Wait after triggering hitbox
             else
                 warn("Failed to trigger hitbox for", nextRoomModel.Name)
             end
             return -- Process one action per step
        end

        -- If neither lever nor hitbox found/triggered, log it
        if not (Prompt and Prompt.Enabled and not FiredPrompts[Prompt]) and not Hitbox then
            warn("No actionable door/lever/hitbox found for", nextRoomModel.Name)
            task.wait(1) -- Wait longer if stuck
        end

    end) -- End of RunService.Stepped connection
end -- End of StartAutoRoomsLoop

-- UI Elements for Auto Rooms
AutoRoomsGroupBox:AddSlider("ARRoomReach", {
	Text = "Room to Reach",
	Default = ARTargetReach,
	Min = 1, -- Start from 1
	Max = 205,
	Rounding = 0,
	Compact = true,

	Callback = function(Value)
		ARTargetReach = Value -- Update the target dynamically
        Options.ARRoomReach.Value = Value -- Ensure Options table is updated if used elsewhere
	end,

	Disabled = false, 
	Visible = true, 
})

-- Original Auto Rooms Button
AutoRoomsGroupBox:AddButton("AutoRoomsStartStop", { -- Give it an index for Toggles
	Text = "Start Auto Rooms",
	Func = function(self)
        if CombinedAutoRoomsLootEnabled then
            Library:Notify("Disable 'Auto Rooms + Loot' first!", 2)
            return
        end
        ARGoing = not ARGoing
        if ARGoing then
            self:SetText("Stop Auto Rooms")
            Library:Notify("Auto rooms started (Standard)", 1)
            warn("Standard Auto Rooms Started")
            StartAutoRoomsLoop(false) -- Start loop in standard mode
        else
            self:SetText("Start Auto Rooms")
            Library:Notify("Auto rooms stopping...", 1)
            warn("Standard Auto Rooms Stopping...")
            -- Loop will stop itself by detecting ARGoing is false
        end
	end,
	Disabled = false,
	Visible = true,
})

AutoRoomsGroupBox:AddDivider() -- Separate combined feature

-- Combined Auto Rooms + Loot Toggle
AutoRoomsGroupBox:AddToggle("AutoRoomsCombinedToggle", { -- Give it an index for Toggles
    Text = "Enable Auto Rooms + Loot",
    Default = false,
    Callback = function(Value)
        if Value and ARGoing then
             Library:Notify("Disable standard 'Auto Rooms' first!", 2)
             Toggles.AutoRoomsCombinedToggle:SetValue(false) -- Revert toggle
             return
        end
        CombinedAutoRoomsLootEnabled = Value
        if Value then
            Library:Notify("Auto Rooms + Loot Enabled", 1)
            warn("Combined Auto Rooms + Loot Enabled")
            StartAutoRoomsLoop(true) -- Start loop in combined mode
        else
            Library:Notify("Auto Rooms + Loot Disabled", 1)
            warn("Combined Auto Rooms + Loot Disabled")
             -- Loop will stop itself by detecting CombinedAutoRoomsLootEnabled is false
        end
    end,
    Disabled = false,
    Visible = true,
})

-- Side Room Toggle for Combined Feature
AutoRoomsGroupBox:AddToggle("CombinedLootSideRoomsToggle", { -- Give it an index for Toggles
    Text = "Loot Side Rooms (Combined Mode)",
    Default = false,
    Callback = function(Value)
        CombinedFeatureLootSideRoomsEnabled = Value
        warn("Combined Mode - Loot Side Rooms set to:", Value)
    end,
    Disabled = false,
    Visible = true,
})


AutoRoomsGroupBox:AddDropdown("RMUnify", {
	Values = { "Current Room", "Special Room"},
	Default = 1, 
	Multi = false, 

	Text = "Room Notifications",

	Searchable = false, 

	Disabled = false, 
	Visible = true, 
})


-- =============================================================
-- Visuals Tab
-- =============================================================
local LeftGroupBoxVisualsGeneral = Tabs.Visuals:AddLeftGroupbox("<b>General</b>")
LeftGroupBoxVisualsGeneral:AddToggle("Fullbright", {
	Text = "Fullbright",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		if Value == true then
            Lighting.Brightness = 3
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(180, 180, 180)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        elseif Value == false then
            Lighting.Brightness = 0
            Lighting.GlobalShadows = true
             Lighting.Ambient = Color3.fromRGB(0, 0, 0) -- Reset to default (approx)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128) -- Reset to default (approx)
        end
	end,
})
local noFog = false
local defaultFogDensity = 0.6 -- Store default
LeftGroupBoxVisualsGeneral:AddToggle("NoFog", {
	Text = "No-Fog",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		noFog = Value
		if Value == true then
            if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = 0 end
        elseif Value == false then
            if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = defaultFogDensity end
        end
	end,
})

-- Store default fog density if Atmosphere exists
if Lighting:FindFirstChild("Atmosphere") then
    defaultFogDensity = Lighting.Atmosphere.Density
end

-- Ensure fog stays off if toggled
task.spawn(function()
	while task.wait(1) do -- Check less frequently
		if noFog then
			 if Lighting:FindFirstChild("Atmosphere") and Lighting.Atmosphere.Density ~= 0 then Lighting.Atmosphere.Density = 0 end
		-- else -- Don't force it back on, only handle turning it off
		--	 if Lighting:FindFirstChild("Atmosphere") and Lighting.Atmosphere.Density ~= defaultFogDensity then Lighting.Atmosphere.Density = defaultFogDensity end
		end
	end
end)

LeftGroupBoxVisualsGeneral:AddToggle("FP", {
	Text = "Third Person",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
        FPLoop = Value
		if Value == true then
            if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                pcall(function() ClientMain.Scripts.cameraMain.Enabled = false end)
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                Players.LocalPlayer.Character.Humanoid.AutoRotate = true
                Players.LocalPlayer.CameraMaxZoomDistance = 10
                Players.LocalPlayer.CameraMinZoomDistance = 10
            end
        elseif Value == false then
             pcall(function() ClientMain.Scripts.cameraMain.Enabled = true end)
             -- Reset zoom? Maybe not necessary if cameraMain handles it.
             Players.LocalPlayer.CameraMaxZoomDistance = 400 -- Reset default max zoom
             Players.LocalPlayer.CameraMinZoomDistance = 0.5 -- Reset default min zoom
        end
	end,
}):AddKeyPicker("KeyPicker", {
	Default = "V", 
	SyncToggleState = true,

	Mode = "Toggle", 

	Text = "Third Person", 
	NoUI = false, 
})

task.spawn(function()
    while task.wait(0.1) do
        if FPLoop and Players.LocalPlayer.Character then
            pcall(function()
                Players.LocalPlayer.Character.Head.Transparency = 0
                Players.LocalPlayer.Character.Head.LocalTransparencyModifier = 0
                for _, Obj in Players.LocalPlayer.Character:GetDescendants() do
                    if Obj:IsA("BasePart") and (Obj.Name == "Handle" or Obj.Name == "face") then
                        Obj.Transparency = 0
                        Obj.LocalTransparencyModifier = 0
                    elseif Obj:IsA("Decal") and Obj.Name == "face" then
                         Obj.Transparency = 0
                    end
                end
            end)
        end
    end
end)
local NotifyEntities = {"Rush", "Screech", "Ram", "Ambush", "Hoardbats", "Eyes", "Stare", "Onslaught"}
local NotifyEntitiesInternal = {}
local RightGroupBoxVisualsNotifs = Tabs.Visuals:AddRightGroupbox("<b>Notifications</b>")
for _, Entity in ipairs(NotifyEntities) do
    NotifyEntitiesInternal[Entity] = false
    RightGroupBoxVisualsNotifs:AddToggle("Notify" .. Entity, {
	    Text = "Notify " .. Entity,

	    Default = false,
	    Disabled = false, 
	    Visible = true, 

	    Callback = function(Value)
		   NotifyEntitiesInternal[Entity] = Value
	    end,
    })
end




local LeftGroupBoxExploitsAntiTrigger = Tabs.Exploits:AddRightGroupbox("<b>Anti-Trigger</b>") -- Moved to Right as per original
local AntiTrigger = {"Seek-Chase-Start", "Seek-Chase-Planks-Fall", "Seek-Chase-Obstruction", "Seek-Chase-Boat-Start", "Death-Trigger", "Seek-Last-Room-Start","Prison-Start", "Watcher-Chase-Start","Observatory-Door"}
local AntiTriggerInternal = {}

local function processTrigger(trigger)
    if not trigger or not trigger.Parent then return end -- Basic sanity check

    local triggerName = trigger.Name
    local parentName = trigger.Parent.Name

    if triggerName == "Trigger" and trigger:FindFirstChild("Chase") then
        trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Start"]
    elseif triggerName == "Hitbox" and trigger.Parent:FindFirstChild("Planks") then
        trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Planks-Fall"]
    elseif triggerName == "EndSequenceHitbox" then
        trigger.CanTouch = not AntiTriggerInternal["Seek-Last-Room-Start"]
    elseif triggerName == "DeathPit" or (triggerName == "Cube" and parentName == "Piper") then
        trigger.CanTouch = not AntiTriggerInternal["Death-Trigger"]
    elseif triggerName == "Hitbox" and trigger.Parent:FindFirstChild("AnimatedShelf") then
        trigger.CanTouch = not AntiTriggerInternal["Watcher-Chase-Start"]
    elseif triggerName == "DoorTrigger" and trigger.Parent:FindFirstChild("BigDoor") then
        trigger.CanTouch = not AntiTriggerInternal["Observatory-Door"]
    elseif triggerName == "StartCutscene" and trigger.Parent:FindFirstChild("PivotWatcherCutscene") and trigger.Parent:FindFirstChild("GuidingLight") then
        trigger.CanTouch = not AntiTriggerInternal["Prison-Start"]
    elseif triggerName == "Trigger" and trigger.Parent:FindFirstChild("ObstructionHolder") then
        trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Obstruction"]
    elseif triggerName == "Trigger" and trigger.Parent:FindFirstChild("2ndPivot") and trigger.Parent:FindFirstChild("Cutscene") then
        trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Boat-Start"]
    end
end

for _, TriggerName in ipairs(AntiTrigger) do
    AntiTriggerInternal[TriggerName] = false
    LeftGroupBoxExploitsAntiTrigger:AddToggle("Anti" .. TriggerName, {
	    Text = "Anti-" .. TriggerName,

	    Default = false,
	    Disabled = false, 
	    Visible = true, 

	    Callback = function(Value)
		   AntiTriggerInternal[TriggerName] = Value
           -- Re-process existing triggers when toggled
           task.spawn(function()
               for _, object in workspace:GetDescendants() do
                    processTrigger(object)
               end
           end)
	    end,
    })
end

workspace.DescendantAdded:Connect(function(object)
    processTrigger(object)
end)






local LeftGroupBoxVisualsESP = Tabs.Visuals:AddLeftGroupbox("<b>ESP</b>")
local ESPTracersEnabled: boolean = true
--[[ LeftGroupBoxVisualsESP:AddToggle("ESPTracers", { -- Keep commented out if not needed
	Text = "Tracers",
	Default = true,
	Disabled = false, 
	Visible = false, -- Hidden as per original
	Callback = function(Value)
		ESPTracersEnabled = Value
        -- Need ESP library integration to update tracers globally here
	end,
})]]
local ESPThings = {"Entity", "Objectives", "Doors", "HidingSpots", "Coins", "Containers"}
for _, Thing in ipairs(ESPThings) do
    LeftGroupBoxVisualsESP:AddToggle("ESP" .. Thing, {
	    Text = "ESP " .. Thing,

	    Default = false,
	    Disabled = false, 
	    Visible = true, 

	    Callback = function(Value)
		   espCategories[Thing] = Value
           updateESPVisibility()
	    end,
    })
end

-- =============================================================
-- Exploits Tab
-- =============================================================
local LeftGroupBoxExploits = Tabs.Exploits:AddLeftGroupbox("<b>Exploits</b>")

LeftGroupBoxExploits:AddButton({
	Text = "Skip Watcher 150",
	Func = function()
        if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.CurrentRoom and ClientMain.CLIENT.Values.CurrentRoom.Value and ClientMain.CLIENT.Values.CurrentRoom.Value.Name == "Room150" then
            RepStorage.Events.ThePrision.FinishedTerminal:FireServer()
            Library:Notify("Fired FinishedTerminal event.", 1)
        else
            Library:Notify("You must be in room 150!", 2)
        end
	end,

	Disabled = false,
	Visible = true,
})

-- Define variables for the controls first
local manualLootWaitTime = 0.1 -- Default wait time for manual loot
local manualUseFastMode = false -- Default: Fast mode for manual loot
local manualLootSideRooms = false -- Default: Side rooms for manual loot

-- Add the controls to the UI GroupBox
LeftGroupBoxExploits:AddToggle("ManualLootSideRooms", {
    Text = "Attempt Loot Side Rooms (Manual)",
    Default = manualLootSideRooms,
    Callback = function(Value)
        manualLootSideRooms = Value
        print("-- DEBUG: Manual Loot Side Rooms set to:", manualLootSideRooms)
    end,
    Disabled = false,
    Visible = true,
})

LeftGroupBoxExploits:AddToggle("ManualUseFastModeToggle", {
    Text = "Use Fast Gold Loot (Manual - No TP First - Risky)",
    Default = manualUseFastMode,
    Callback = function(Value)
        manualUseFastMode = Value
        print("-- DEBUG: Manual Fast Gold Loot set to:", manualUseFastMode)
    end,
    Disabled = false,
    Visible = true,
})

LeftGroupBoxExploits:AddSlider("ManualLootWaitSlider", {
    Text = "Manual Loot Wait Time (s)",
    Default = manualLootWaitTime,
    Min = 0,
    Max = 1,
    Rounding = 1, -- 1 decimal place (0.1 increments)
    Compact = true,
    Callback = function(Value)
        manualLootWaitTime = Value -- Update the variable when slider changes
        print("-- DEBUG: Manual Loot Wait Time set to:", manualLootWaitTime)
    end,
    Disabled = false,
    Visible = true,
})

-- Manual Auto Loot Button (Uses the refactored function)
LeftGroupBoxExploits:AddButton({
    Text = "Auto Loot Gold (Current Room - Manual)",
    Func = function()
        local currentRoomModel = nil
        if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.CurrentRoom then
            currentRoomModel = ClientMain.CLIENT.Values.CurrentRoom.Value
        end

        if not currentRoomModel then
            Library:Notify("Cannot determine current room.", 3)
            warn("ERROR: Cannot determine current room for manual loot.")
            return
        end

        -- Call the refactored function with values from the manual UI toggles/slider
        ExecuteAutoLootGold(currentRoomModel, manualUseFastMode, manualLootSideRooms, manualLootWaitTime)
    end,
    DoubleClick = false, Disabled = false, Visible = true,
})

LeftGroupBoxExploits:AddButton({
	Text = "+1 Revive (FE)",
	Func = function()
       if shared and shared.giveIt then
           shared.giveIt()
           Library:Notify("Attempted to give revive.", 1)
       else
            Library:Notify("Revive function not available.", 2)
       end
	end,

	Disabled = false,
	Visible = true,
})
local function get_latest_room()
    local rooms_folder = workspace:FindFirstChild("GeneratedRooms")
    if not rooms_folder then return nil end

    local room_numbers = {}

    for _, child in ipairs(rooms_folder:GetChildren()) do
        if child:IsA("Model") then
            local num = tonumber(child.Name:match("Room(%d+)"))
            if num then
                table.insert(room_numbers, num)
            end
        end
    end
    if #room_numbers == 0 then return nil end

    table.sort(room_numbers, function(a, b) return a > b end) -- Sort descending

    -- If only one room (e.g., Room0), return that. If multiple, return the second highest (latest fully generated).
    local latest_room_number = room_numbers[1] -- Default to highest number
    if #room_numbers > 1 then
        latest_room_number = room_numbers[2] -- Use second highest if available
    end

    local latest_room_name = "Room" .. latest_room_number
    return rooms_folder:FindFirstChild(latest_room_name)
end

LeftGroupBoxExploits:AddButton({
	Text = "Open Current Room Door",
	Func = function()
        local currentRoomModel = nil
        if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.CurrentRoom then
            currentRoomModel = ClientMain.CLIENT.Values.CurrentRoom.Value
        end

        if currentRoomModel and currentRoomModel.Name:find("Room") then
            local Room = currentRoomModel
            local Door = Room:FindFirstChild("Door") or Room:FindFirstChild("DoorNormal")
            local Hitbox = Door and Door:FindFirstChild("Hitbox")
            if Hitbox and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = Players.LocalPlayer.Character.HumanoidRootPart
                local originalSize = Hitbox.Size
                local originalCF = Hitbox.CFrame
                Hitbox.Size = Vector3.new(50, 50, 50)
                Hitbox.CFrame = hrp.CFrame * CFrame.new(0,0,-3)
                task.wait(0.2)
                Hitbox.Size = originalSize
                Hitbox.CFrame = originalCF
                Library:Notify("Attempted to open current room door.", 1)
            elseif Door then
                 Library:Notify("Could not find hitbox for current room door.", 2)
            else
                 Library:Notify("Could not find door in current room.", 2)
            end
        else
            Library:Notify("You are not in a room or room unknown!", 2)
        end
	end,

	Disabled = false,
	Visible = true,
})
LeftGroupBoxExploits:AddButton({
	Text = "Open Latest Room Door",
	Func = function()
        local Room = get_latest_room()
        if Room then
            local Door = Room:FindFirstChild("Door") or Room:FindFirstChild("DoorNormal")
            local Hitbox = Door and Door:FindFirstChild("Hitbox")
            if Hitbox and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = Players.LocalPlayer.Character.HumanoidRootPart
                local originalSize = Hitbox.Size
                local originalCF = Hitbox.CFrame
                Hitbox.Size = Vector3.new(50, 50, 50)
                Hitbox.CFrame = hrp.CFrame * CFrame.new(0,0,-3)
                task.wait(0.2)
                Hitbox.Size = originalSize
                Hitbox.CFrame = originalCF
                Library:Notify("Attempted to open latest room door ("..Room.Name..").", 1)
            elseif Door then
                 Library:Notify("Could not find hitbox for latest room door ("..Room.Name..").", 2)
            else
                 Library:Notify("Could not find door in latest room ("..Room.Name..").", 2)
            end
        else
            Library:Notify("Could not determine the latest room.", 2)
        end
	end,

	Disabled = false,
	Visible = true,
})
LeftGroupBoxExploits:AddButton({
	Text = "Enable Observatory Lever",
	Func = function()
         local obsRoom = workspace.GeneratedRooms:FindFirstChild("Room194")
         if obsRoom then
            local lever = obsRoom:FindFirstChild("CaveLever", true)
            if lever and lever:FindFirstChild("ProximityPrompt") then
                lever.ProximityPrompt.Enabled = true
                Library:Notify("Observatory lever enabled!", 1)
            else
                 Library:Notify("Observatory lever or prompt not found!", 2)
            end
        else
            Library:Notify("Observatory room (194) not found!", 2)
        end
	end,

	Disabled = false,
	Visible = true,
})
local PartialGod = false
LeftGroupBoxExploits:AddToggle("PartialGod", {
	Text = "Infinite Healing",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		PartialGod = Value
	end,
})

local InfRev = false
LeftGroupBoxExploits:AddToggle("InfRev", {
	Text = "Infinite Revives",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		InfRev = Value
	end,
})
task.spawn(function()
	while task.wait(1) do -- Check less often
		if InfRev then
            if shared and shared.giveIt then
                 pcall(shared.giveIt)
            end
        end
	end
end)
local SIP -- Steal Item Player
LeftGroupBoxExploits:AddDropdown("StealItemsPicker", {
	SpecialType = "Player",
	ExcludeLocalPlayer = true, 
	Text = "Steal Item Target",

	Callback = function(Value)
		SIP = Value
	end,
})
local expectingDrop = false
LeftGroupBoxExploits:AddButton({
	Text = "Steal target's equipped item",
	Func = function()
        if SIP and SIP.Character then
            local tool = SIP.Character:FindFirstChildWhichIsA("Tool")
            if tool then
		        expectingDrop = true
                warn("Attempting to invoke DropItem for target:", SIP.Name, "Tool:", tool.Name)
		        local success, err = pcall(RepStorage.Events.PlayerActions.DropItem.InvokeServer, RepStorage.Events.PlayerActions.DropItem, tool)
                if not success then
                    warn("DropItem InvokeServer failed:", err)
                    Library:Notify("Failed to invoke drop: " .. tostring(err), 2)
                    expectingDrop = false -- Reset flag on failure
                else
                     Library:Notify("Drop invoked for " .. tool.Name, 1)
                end
            else
                 Library:Notify("Target has no tool equipped!", 2)
            end
	    else
            Library:Notify("Select a valid target player first!", 2)
        end
	end,

	Disabled = false,
	Visible = true,
})
workspace.DroppedItems.ChildAdded:Connect(function(item)
	if not expectingDrop then return end
    if item:IsA("Tool") then -- Ensure it's a tool
        warn("Detected dropped item:", item.Name)
        task.wait(0.5) -- Wait for pickup prompt to appear
        local pickupPrompt = item:FindFirstChild("Pickup", true)
        if pickupPrompt and pickupPrompt:IsA("ProximityPrompt") then
            warn("Attempting to fire pickup prompt for:", item.Name)
	        local success, err = pcall(fireproximityprompt, pickupPrompt)
            if success then
	            Library:Notify("Stole item: " .. item.Name, 3)
            else
                 warn("Failed to fire pickup prompt:", err)
                 Library:Notify("Failed to pick up stolen item.", 2)
            end
        else
             warn("Could not find pickup prompt for dropped item:", item.Name)
             Library:Notify("Could not find pickup for stolen item.", 2)
        end
	    expectingDrop = false -- Reset flag after attempt
    end
end)


local AutoCage = true -- Defaulted to true as per original script, but callback logic was inverted
local DoConLoop = true -- Sync with AutoCage default
local cageEventConnectionDisabled = false

-- Function to manage the connection state
local function UpdateCageConnectionState()
     local connectionDisabled = not AutoCage -- Disable connection if AutoCage is TRUE
     if connectionDisabled ~= cageEventConnectionDisabled then -- Only act if state needs changing
         local connections = getconnections(RepStorage.Events.ThePrision.PlayerCaged.OnClientEvent)
         warn("Updating PlayerCaged connections. AutoCage:", AutoCage, "Target State (Disabled):", connectionDisabled, "Found Connections:", #connections)
         for _, Connection in ipairs(connections) do
             if connectionDisabled then
                 Connection:Disable()
             else
                 Connection:Enable()
             end
         end
         cageEventConnectionDisabled = connectionDisabled
         warn("PlayerCaged connection state updated. Disabled:", cageEventConnectionDisabled)
     end
end

LeftGroupBoxExploits:AddToggle("AutoCage", {
	Text = "Auto Escape Watcher-cage",
	Default = AutoCage, -- Use variable default
	Disabled = false, 
	Visible = true, -- Made visible as it's a useful feature

	Callback = function(Value)
        AutoCage = Value
        UpdateCageConnectionState() -- Update connection state immediately
	end,
})

-- Initial state update
task.wait(2) -- Wait a bit for events to register
UpdateCageConnectionState()

-- Removed the redundant task.spawn loop for DoConLoop

RepStorage.Events.ThePrision.PlayerCaged.OnClientEvent:Connect(function()
    warn("PlayerCaged event received. AutoCage enabled:", AutoCage)
    if not AutoCage then return end
    Library:Notify("Watcher cage detected! Escaping...", 1)
    task.wait(4) -- Keep the delay
    warn("Firing MinigameFinished...")
    RepStorage.Events.ThePrision.MinigameFinished:FireServer()
    Library:Notify("Escaped Watcher cage!", 3)
end)

task.spawn(function()
    while task.wait(0.2) do -- Check more frequently for responsiveness
        if PartialGod then
            pcall(function()
                RepStorage.Events.EntityEvents.DamageFromClient:FireServer({
                    AttackedBy = "Blacklight", -- Keep original attacker name?
                    IsSet = true, 
                    IgnoresHide = false, -- Should probably be true to ensure healing
                    Damage = -math.huge -- Use negative huge damage for healing
                })
            end)
        end
    end
end)
local RightGroupBoxExploitsAntiEntity = Tabs.Exploits:AddRightGroupbox("<b>Anti-Entity</b>")
local AntiEntity = {"Blacklight", "Screech", "Void", "Decoy", "Seek", "Watcher"} -- Added Watcher based on later code

-- Initialize AntiEntityInternal properly
for _, EntityName in ipairs(AntiEntity) do
    AntiEntityInternal[EntityName] = false
end

local function UpdateAntiEntityState(Entity, Value)
     AntiEntityInternal[Entity] = Value
     warn("Anti-" .. Entity .. " set to: " .. tostring(Value))

     -- Apply immediate effects
     if Entity == "Screech" then
         if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.ScreechActive then
             ClientMain.CLIENT.Values.ScreechActive.Value = Value -- Force screech state
         end
     elseif Entity == "Decoy" then
         task.spawn(function() -- Use task.spawn for potentially many objects
             for _, Obj in workspace:GetDescendants() do
                 if Obj.Name == "AttackRange" then
                     pcall(function() Obj.CanTouch = not Value end)
                 end
             end
         end)
     elseif Entity == "Seek" then
          task.spawn(function()
             for _, Obj in workspace:GetDescendants() do
                 if Obj.Name == "Hitbox" and Obj.Parent and Obj.Parent.Name == "Seek" then
                     pcall(function() Obj.CanTouch = not Value end)
                 end
             end
         end)
     elseif Entity == "Watcher" then
          task.spawn(function()
              local wanderWatcher = workspace:FindFirstChild("WanderWatcher")
              if wanderWatcher then
                  local pickupArea = wanderWatcher:FindFirstChild("PickupArea", true)
                  if pickupArea then
                      pcall(function() pickupArea.CanTouch = not Value end)
                  end
              end
          end)
     elseif Entity == "Blacklight" then
          if workspace:FindFirstChild("GameInfo") and workspace.GameInfo:FindFirstChild("BlacklightDisabled") then
               workspace.GameInfo.BlacklightDisabled.Value = Value
          end
     end
end

for _, EntityName in ipairs(AntiEntity) do
    RightGroupBoxExploitsAntiEntity:AddToggle("Anti" .. EntityName, {
	    Text = "Anti-" .. EntityName,
	    Default = false,
	    Disabled = false, 
	    Visible = true, 
	    Callback = function(Value)
           UpdateAntiEntityState(EntityName, Value)
	    end,
    })
end



workspace.DescendantAdded:Connect(function(Obj)
    if Obj.Name == "AttackRange" and AntiEntityInternal["Decoy"] then
        pcall(function() Obj.CanTouch = false end)
    end
    if Obj.Name == "Hitbox" and Obj.Parent and Obj.Parent.Name == "Seek" and AntiEntityInternal["Seek"] then
        pcall(function() Obj.CanTouch = false end)
    end
     if Obj.Name == "WanderWatcher" and AntiEntityInternal["Watcher"] then
         local pickupArea = Obj:FindFirstChild("PickupArea", true)
         if pickupArea then
             pcall(function() pickupArea.CanTouch = false end)
         end
     end
end)

-- Persistent state loops for Screech, Watcher Crouch, Blacklight
task.spawn(function()
    while task.wait(0.5) do
        if AntiEntityInternal["Screech"] then
             if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.ScreechActive and not ClientMain.CLIENT.Values.ScreechActive.Value then
                 ClientMain.CLIENT.Values.ScreechActive.Value = true -- Keep forcing it true
             end
        end
	    if AntiEntityInternal["Watcher"] then
            pcall(function() RepStorage:WaitForChild("Events"):WaitForChild("PlayerCrouching"):FireServer(true) end)
	    end
         if AntiEntityInternal["Blacklight"] then
             if workspace:FindFirstChild("GameInfo") and workspace.GameInfo:FindFirstChild("BlacklightDisabled") and not workspace.GameInfo.BlacklightDisabled.Value then
                 workspace.GameInfo.BlacklightDisabled.Value = true -- Keep forcing it true
             end
         end
    end
end)

-- Anti-Void Hook
local voidModule = ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.CurrentRoomDependency and ClientMain.CLIENT.CurrentRoomDependency.Modules and ClientMain.CLIENT.CurrentRoomDependency.Modules.Void
if voidModule then
    local oldVoidPlayer = require(voidModule).VoidPlayer
    hookfunction(require(voidModule).VoidPlayer, function(...)
        if AntiEntityInternal["Void"] then
            warn("Anti-Void blocked VoidPlayer call")
            return
        else
            return oldVoidPlayer(...)
        end
    end)
    warn("Anti-Void hook applied.")
else
    warn("Could not find Void module for Anti-Void hook.")
end

-- Entity Spawn Notifications
workspace.ChildAdded:Connect(function(Object)
    local name = Object.Name
    if NotifyEntitiesInternal[name] then Library:Notify(name .. ' has spawned', 2) end
end)

workspace.DescendantAdded:Connect(function(Object)
    if Object.Name == 'ScreechAHHHH' and NotifyEntitiesInternal["Screech"] then
        Library:Notify('Screech has spawned', 2)
    end
end)

if workspace:FindFirstChild("GameInfo") then
    if workspace.GameInfo:FindFirstChild("HoardbatsActive") then
        workspace.GameInfo.HoardbatsActive:GetPropertyChangedSignal("Value"):Connect(function()
            if workspace.GameInfo.HoardbatsActive.Value == true and NotifyEntitiesInternal["Hoardbats"] then
                Library:Notify('Hoardbats Swarm has spawned', 2)
            end
        end)
    end
    if workspace.GameInfo:FindFirstChild("LureActive") then
        workspace.GameInfo.LureActive:GetPropertyChangedSignal("Value"):Connect(function()
            if workspace.GameInfo.LureActive.Value == true and NotifyEntitiesInternal["Onslaught"]then
                Library:Notify('Onslaught has spawned', 2)
            end
        end)
    end
end

-- =============================================================
-- UI Settings Tab
-- =============================================================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = false, -- Changed default to false as requested
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

		Library:SetDPIScale(DPI / 100) -- Library likely expects a scale factor (e.g., 1.0, 1.5)
	end,
})
MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library:OnUnload(function()
    warn("Unloading Foundation Hub...")
    -- Disconnect connections
    if ARCon then ARCon:Disconnect(); ARCon = nil end
    if Noclipping then Noclipping:Disconnect(); Noclipping = nil end
    NOFLY() -- Stop flying

    -- Reset modified game states
    if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Reset walkspeed
        pcall(function() Players.LocalPlayer.Character:SetAttribute("AllowedToJump", true) end) -- Allow jumping
    end
     if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = defaultFogDensity end -- Reset fog
    Lighting.Brightness = 0; Lighting.GlobalShadows = true; Lighting.Ambient = Color3.fromRGB(0,0,0); Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128) -- Reset lighting

    -- Reset toggles (optional, but good practice)
    for _, toggle in pairs(Toggles) do
        if toggle and toggle.Type == "Toggle" and toggle.Value then
             pcall(toggle.Callback, false) -- Call callback with false
             toggle:SetValue(false, true) -- Set value without invoking callback again
        end
    end
    -- Restore cutscenes
    for _, scene in CutFolder:GetChildren() do
        scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes
    end
    CutFolder:Destroy()

    -- Restore hooked functions (if hooks stored) - Requires more setup during hooking
    -- Restore prox prompt states
    InstaRact = false; Toggles.InstantInteract:SetValue(false, true); Toggles.InstantInteract.Callback(false)
    PR = false; Toggles.PromptReach:SetValue(false, true); Toggles.PromptReach.Callback(false)

    -- Restore cage connection
    AutoCage = false; UpdateCageConnectionState()

    -- Clear shared functions if set by this script
    shared.giveIt = nil

    warn("Foundation Hub Unloaded.")
end)


MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "P", NoUI = true, Text = "Menu keybind" }) -- Changed default to P


Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)



SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("LegitHub")
SaveManager:SetFolder("LegitHub/foundation")
SaveManager:SetSubFolder("game")



ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
SaveManager:BuildConfigSection(Tabs["UI Settings"])

-- =============================================================
-- ESP Setup (Requires MSESP Library)
-- =============================================================
local ESPLibrary = loadstring(game:HttpGet(
    'https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau'
))()

if not ESPLibrary then
    warn("Failed to load MSESP Library!")
    Library:Notify("ESP Library failed to load!", 3)
    -- Define dummy functions to prevent errors later
    ESPLibrary = { Add = function() return { Hide=function() end, Show=function() end, Destroy=function() end } end }
end


local colors = {
    Entity = Color3.fromRGB(255, 0, 0),
    Objectives = Color3.fromRGB(0, 255, 0),
    HidingSpots = BrickColor.new('Medium stone grey').Color, -- Changed color slightly
    Doors = Color3.fromRGB(0, 0, 150),
    Coins = Color3.new(0.898039, 0.913725, 0.000000),
    Containers = BrickColor.new('Dark stone grey').Color, -- Changed color slightly
}

local function addESP(part, name, category)
    if not part or not part.Parent then return nil end -- Sanity check

    local esp = ESPLibrary:Add({
        Name = name,
        PrimaryPart = part:IsA("Model") and part.PrimaryPart or (part:IsA("BasePart") and part or nil), -- Try to get a PrimaryPart or use the part itself
        Model = part:IsA("Model") and part or nil, -- Pass model only if it's a model
        Color = colors[category] or Color3.fromRGB(255,255,255),
        MaxDistance = math.huge,
        TextSize = 17,
        ESPType = 'Highlight', -- Highlight seems less intrusive
        FillColor = colors[category] or Color3.fromRGB(255,255,255),
        OutlineColor = colors[category] or Color3.fromRGB(255,255,255),
        Tracer = {
            Enabled = ESPTracersEnabled, -- Use the variable
            Color = colors[category] or Color3.fromRGB(255,255,255),
        },
        Enabled = espCategories[category] -- Initial visibility based on category toggle
    })

    if esp then
        local espData = { ESP = esp, Category = category }
        table.insert(allTrackedESPs, espData)

        -- Cleanup connection when part is destroyed
        part.Destroying:Connect(function()
            esp:Destroy()
            for i, data in ipairs(allTrackedESPs) do
                if data == espData then
                    table.remove(allTrackedESPs, i)
                    break
                end
            end
        end)
    else
        warn("Failed to create ESP for:", name, "Part:", part:GetFullName())
    end

    return esp
end

local roomSpecESPs = {} -- Store ESP objects specific to the current room

local function processRoomForESP(room)
    if not room or not room:IsA("Model") then return end
    -- Clear previous room's ESPs first
    for _, espData in ipairs(roomSpecESPs) do
        if espData and espData.ESP then espData.ESP:Destroy() end
    end
    table.clear(roomSpecESPs)
    warn("Processing room for ESP:", room.Name)

    local descendants = room:GetDescendants()
    task.spawn(function() -- Process descendants in a separate thread
        for _, object in ipairs(descendants) do
            if not object or not object.Parent then continue end -- Check validity

            local esp = nil
            -- Hiding Spots & Decoys
            if object.Name == 'Locker' or object.Name == 'Toolshed_Hiding' then esp = addESP(object, 'Hiding-Spot', 'HidingSpots')
            elseif object.Name == 'decoyLocker' then esp = addESP(object, 'Decoy', 'Entity')
            -- Objectives
            elseif object.Name == 'OilCanister' then esp = addESP(object, 'Oil Can', 'Objectives')
            elseif object.Name == 'GasCanister' then esp = addESP(object, 'Gas Canister', 'Objectives')
            elseif object.Name == 'GeneratorPuzzle' then esp = addESP(object, 'Generator', 'Objectives')
            elseif object.Name == 'Terminal' then esp = addESP(object, 'Terminal', 'Objectives')
            elseif object.Name == 'Switch' and not object:FindFirstAncestor('Switch') and not object:FindFirstAncestor('Flashlight') then esp = addESP(object, 'Fuse', 'Objectives')
            elseif object.Name == 'GivingCoins' then esp = addESP(object.Parent, 'Coins', 'Coins') -- ESP on parent model
            elseif object.Name == 'Container' and object.Parent and not object.Parent:HasTag("ContainerMarked") then object.Parent:AddTag("ContainerMarked"); esp = addESP(object.Parent, 'Container', 'Containers')
            elseif object.Name == 'Minigame' and object:FindFirstChild('Switches') then esp = addESP(object, 'Breaker Minigame', 'Objectives')
            elseif object.Name == 'ObservatoryKey' then esp = addESP(object, 'Key', 'Objectives')
            elseif object.Name == 'SignModel' then local sign = object:FindFirstChild('Sign'); if sign then esp = addESP(sign, 'Directional Sign', 'Objectives'); pcall(function() sign.Material = Enum.Material.Neon; sign.Color = Color3.fromRGB(255, 255, 255) end) end
            elseif object.Name == 'Control' and object.Parent and object.Parent.Name == 'Elevator' and object.Parent.Parent and object.Parent.Parent:FindFirstChild('ElevatorHandler') then local sign = object:FindFirstChild('Sign'); esp = addESP(object, 'Exit Elevator', 'Objectives'); if sign then pcall(function() sign.Material = Enum.Material.Neon end) end
            elseif object.Name == 'OxygenTank' then esp = addESP(object, 'Oxygen Can', 'Objectives')
            elseif (object.Name == 'CaveLever' or object.Name == 'Lever') and not object:FindFirstAncestor('GeneratorPuzzle') and not object:FindFirstAncestor('EndPanel') and not object:FindFirstAncestor('GeneratorDeco') then local order = object:GetAttribute('Order'); esp = addESP(object, 'Lever' .. (order and (' ' .. order) or ''), 'Objectives')
            -- Doors
            elseif (object.Name == 'Door' and object.Parent and object.Parent.Parent and object.Parent.Parent.Name == 'GeneratedRooms') or object.Name == 'Chunk_Watcher' then esp = addESP(object, 'Door', 'Doors')
            end

            if esp then table.insert(roomSpecESPs, {ESP = esp, Category = esp.Category}) end -- Store the created ESP
            task.wait() -- Yield slightly between objects
        end
        warn("Finished processing ESP for room:", room.Name, "Added", #roomSpecESPs, "ESPs.")
        updateESPVisibility() -- Update visibility after processing
    end)
end

-- Listen for CurrentRoom changes
local currentRoomValueObject = nil
local function findCurrentRoomValue()
    if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values then
        currentRoomValueObject = ClientMain.CLIENT.Values:FindFirstChild("CurrentRoom")
        if currentRoomValueObject and currentRoomValueObject:IsA("ObjectValue") then
             warn("Found CurrentRoom ObjectValue: " .. currentRoomValueObject:GetFullName())
             -- Process initial room
             task.delay(1, function() if currentRoomValueObject.Value then processRoomForESP(currentRoomValueObject.Value) end end)
             -- Connect to changes
             currentRoomValueObject:GetPropertyChangedSignal("Value"):Connect(function()
                 warn("CurrentRoom changed to:", currentRoomValueObject.Value and currentRoomValueObject.Value.Name or "nil")
                 if currentRoomValueObject.Value then
                     processRoomForESP(currentRoomValueObject.Value)
                 else -- Clear ESPs if value becomes nil (e.g., leaving game)
                      for _, espData in ipairs(roomSpecESPs) do if espData and espData.ESP then espData.ESP:Destroy() end end
                      table.clear(roomSpecESPs)
                 end
             end)
             return true -- Found
        end
    end
    return false -- Not found yet
end

-- Try to find the CurrentRoom value object initially and retry if needed
if not findCurrentRoomValue() then
    local findAttempts = 0
    while not currentRoomValueObject and findAttempts < 10 do
        findAttempts = findAttempts + 1
        warn("Retrying to find CurrentRoom ObjectValue (Attempt " .. findAttempts .. ")")
        task.wait(2)
        if findCurrentRoomValue() then break end
    end
    if not currentRoomValueObject then warn("Failed to find CurrentRoom ObjectValue after multiple attempts.") end
end


-- Process global entities added to workspace
local function processGlobalObject(object)
    if not object or not object.Parent then return end
    if object:FindFirstAncestor('Game Configuration') then return end -- Ignore config stuff

    local esp = nil
    local name = object.Name
    if name == 'HoardbatClient' or name == "HoardBat" then esp = addESP(object, 'Hoardbat', 'Entity')
    elseif name == 'Eyes' and (not object.Parent or object.Parent.Name ~= 'Bob') then esp = addESP(object, 'Eyes', 'Entity') -- Avoid Bob's eyes if needed
    elseif name == 'Stare' then esp = addESP(object, 'Stare', 'Entity')
    elseif name == 'Ram' then esp = addESP(object, 'Ram', 'Entity')
    elseif name == 'Ambush' then esp = addESP(object, 'Ambush', 'Entity')
    elseif name == 'Rush' then esp = addESP(object, 'Rush', 'Entity')
    elseif name == 'FigureRig' then esp = addESP(object, 'Figure', 'Entity')
    elseif name == 'WanderWatcher' then esp = addESP(object, 'Watcher', 'Entity')
    elseif name == 'Seek' then esp = addESP(object, 'Seek', 'Entity')
    end
    -- No need to store global ESPs separately unless specific cleanup is needed
    if esp then updateESPVisibility() end -- Update visibility if a new global ESP was added
end

workspace.DescendantAdded:Connect(processGlobalObject)
task.spawn(function() -- Process existing global objects
    for _, object in workspace:GetDescendants() do
        processGlobalObject(object)
        task.wait()
    end
    warn("Initial global ESP processing complete.")
    updateESPVisibility() -- Final visibility update
end)

warn("Foundation Hub Loaded Successfully.")
Library:Notify("Foundation Hub Plus Loaded!", 3)
