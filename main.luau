--[[
    Script modified based on user request to integrate Auto Loot with Auto Rooms.
    Key changes:
    1. Added "Auto Loot On Room Enter" toggle in Main -> Auto-Rooms.
    2. Added "Loot Side Rooms (Integrated)" toggle for the above feature.
    3. Modified Auto Rooms logic (ARCon) to:
        - Pause if Rush, Ambush, or Ram are detected.
        - Wait for room change after opening a door.
        - Trigger a new integrated loot function if the toggle is enabled.
        - Pause again if entities appear during/after looting.
    4. Created `executeIntegratedAutoLoot` function:
        - Takes room model and side room flag as arguments.
        - Always uses "fast" looting (direct fireproximityprompt).
        - Uses the integrated side room flag.
        - Includes entity checks to pause looting if needed.
    5. Added `entityIsPresent` helper function.
    6. Kept the original "Auto Loot Gold (Current Room)" button and its settings independent.
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
            local humanoid = character:FindFirstChildOfClass("Humanoid")
			while FLYING do
				task.wait()
                if not character or not root or not root.Parent or not humanoid or humanoid.Health <= 0 then FLYING = false break end -- Safety check

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

				if humanoid and not vfly then
					humanoid.PlatformStand = true
				end
			end

			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			if BG and BG.Parent then BG:Destroy() end
            if BV and BV.Parent then BV:Destroy() end

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
    if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
	end
    local root = getRoot(character)
    if root then
        local bg = root:FindFirstChild("BodyGyro")
        local bv = root:FindFirstChild("BodyVelocity")
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
    end

	pcall(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
end
local allTrackedESPs = {}

local function updateESPVisibility()
    for _, data in pairs(allTrackedESPs) do
        local shouldBeVisible = espCategories[data.Category]
        if data.ESP and data.ESP.Enabled ~= shouldBeVisible then -- Check if update is needed
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
    warn("Found CageDone function")
    CageDone = Item
        old = hookfunction(Item, function(...)
            
            IsCaged = false
            old(...)
        end)
    end
end

local Options = Library.Options
Options.MenuKeybind = "P" -- Changed default to P as RightShift is common
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
repeat task.wait() until Library and typeof(Library.Toggle) == "function"
if not game:GetService("UserInputService").TouchEnabled then
	old = hookfunction(Library.Toggle, function(...) -- Use ... to pass arguments
    stateLib = not stateLib
	Library.ScreenGui.Enabled = stateLib
    old(...) -- Call original function with arguments
end)
task.spawn(function()
	while task.wait() do -- Use task.wait()
        pcall(function() -- Wrap in pcall for safety
            getrenv()._G.lockMouse = not stateLib
        end)
    end
end)
end

local LeftGroupBoxMain = Tabs.Main:AddLeftGroupbox("<b>LocalPlayer</b>") -- Renamed to avoid conflict
local WSLoopEnabled = false
local WSLoopVal = 16
LeftGroupBoxMain:AddToggle("WSEnable", {
	Text = "Enable Walkspeed",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		WSLoopEnabled = Value
        if not Value and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
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
		    task.wait() -- Use task.wait()
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
    pcall(function() -- Wrap in pcall for safety
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

--[[LeftGroupBoxMain:AddToggle("AI", { -- Use unique name
    Text = "Auto Interact",
    Default = false,
    Callback = function(value)
        dai_enabled = value
        -- toggle_proximity_connections(not value) -- This might interfere with other scripts, commented out
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
           pcall(function() -- Wrap in pcall
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, prompt in workspace.GeneratedRooms:GetDescendants() do
                    if prompt:IsA("ProximityPrompt") and prompt:IsDescendantOf(workspace.GeneratedRooms) and prompt.Enabled then -- Check if enabled
                        local promptPart = prompt.Parent
                        local prompt_pos = nil
                        if promptPart:IsA("Model") and promptPart:FindFirstChild("PrimaryPart") then
                            prompt_pos = promptPart.PrimaryPart.Position
                        elseif promptPart:IsA("BasePart") then
                             prompt_pos = promptPart.Position
                        elseif promptPart:IsA("Attachment") then
                             prompt_pos = promptPart.WorldPosition
                        end

                        if prompt_pos and not (prompt:FindFirstAncestor("Toolshed_Hiding") or
                                prompt:FindFirstAncestor("Locker") or
                                prompt:FindFirstAncestor("OpenedSTORAGE") or
                                (prompt.Parent.Parent and prompt.Parent.Parent:FindFirstChild("OpenedSTORAGE"))) and
                                (prompt_pos - hrp.Position).Magnitude < prompt.MaxActivationDistance then
                            fireproximityprompt(prompt)
                            task.wait(0.05) -- Small delay after firing
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
        pcall(function()
		    if Players.LocalPlayer.Character then
                Players.LocalPlayer.Character:SetAttribute("AllowedToJump", Value)
            end
        end)
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
        pcall(function()
		    if Value == false then
                if Noclipping then
		            Noclipping:Disconnect()
                    Noclipping = nil -- Clear the connection variable
	            end
                if Players.LocalPlayer.Character then
                    for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
		        	    if child:IsA("BasePart") and child.CanCollide == false and child.Name ~= "Head" and child.Name ~= "HumanoidRootPart" then -- Avoid HRP
		        		    child.CanCollide = true
		        	    end
		            end
                end
	            Clip = true
            else
                Clip = false
	            task.wait(0.1) -- Use task.wait()
	            local function NoclipLoop()
                    pcall(function()
		                if Clip == false and Players.LocalPlayer.Character ~= nil then
		    	            for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
		    		            if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= "HumanoidRootPart" then -- Avoid HRP
		    			            child.CanCollide = false
		    		            end
		    	            end
		                end
                    end)
	            end
                if Noclipping then Noclipping:Disconnect() end -- Disconnect previous if any
	            Noclipping = RunService.Stepped:Connect(NoclipLoop)
            end
        end)
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
    while task.wait() do -- Use task.wait()
        pcall(function()
            if WSLoopEnabled and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                Players.LocalPlayer.Character.Humanoid.WalkSpeed = WSLoopVal
            end
            if IsFlying and not FPLoop then
                if Players.LocalPlayer.Character then
                    for _, Obj in Players.LocalPlayer.Character:GetDescendants() do
                        if Obj:IsA("BasePart") and Obj.Name == "Handle" then -- Check if BasePart
                            Obj.Transparency = 1
                            pcall(function()
                                Obj.LocalTransparencyModifier = 1
                            end)
                        end
                    end
                end
            end
        end)
    end
end)


local RightGroupBoxMain = Tabs.Main:AddRightGroupbox("<b>Quick Buttons</b>") -- Renamed
RightGroupBoxMain:AddButton({
	Text = "Lobby",
	Func = function()
        pcall(function() RepStorage.Events.PlayerActions.LeaveToLobby:FireServer() end)
	end,
	DoubleClick = false, -- Usually false for buttons

	Disabled = false,
	Visible = true,
})
RightGroupBoxMain:AddButton({
	Text = "Play Again",
	Func = function()
        pcall(function() RepStorage.Events.PlayerActions.PlayAgain:FireServer() end)
	end,
	DoubleClick = false,

	Disabled = false,
	Visible = true,
})
RightGroupBoxMain:AddButton({
	Text = "Reset",
	Func = function()
        pcall(function()
		    RepStorage.Events.EntityEvents.DamageFromClient:FireServer({
                AttackedBy = "Legit Hub Reset", -- Changed name slightly
                IsSet = true, 
                IgnoresHide = false, 
                Damage = math.huge -- Use math.huge for instant reset
            })
        end)
	end,
	DoubleClick = false,

	Disabled = false,
	Visible = true,
})

local LeftGroupBoxPrompts = Tabs.Main:AddLeftGroupbox("<b>Prompts</b>") -- Renamed
local InstaRact = false
LeftGroupBoxPrompts:AddToggle("InstantInteract", {
	Text = "Instant Interact",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
        pcall(function()
		    InstaRact = Value
            local prompts = workspace:GetDescendants()
            for _, Prompt in ipairs(prompts) do -- Use ipairs for arrays
                if Prompt:IsA("ProximityPrompt") then
                    if Value == false then
                        if Prompt:GetAttribute("OrigHold") ~= nil then
                            Prompt.HoldDuration = Prompt:GetAttribute("OrigHold")
                        end
                    else -- Value == true
                        if Prompt:GetAttribute("OrigHold") == nil then -- Set only if not already set
                             Prompt:SetAttribute("OrigHold", Prompt.HoldDuration)
                        end
                        Prompt.HoldDuration = 0
                    end
                end
            end
        end)
	end,
})

workspace.DescendantAdded:Connect(function(Prompt)
    pcall(function()
        if Prompt:IsA("ProximityPrompt") and InstaRact then
            if Prompt:GetAttribute("OrigHold") == nil then
                Prompt:SetAttribute("OrigHold", Prompt.HoldDuration)
            end
            Prompt.HoldDuration = 0
        end
        -- Separate logic for storage naming
        if Prompt:IsA("Model") and Prompt:GetAttribute("Open") ~= nil and Prompt.Name ~= "Door" then
            Prompt:GetAttributeChangedSignal("Open"):Once(function()
                if Prompt and Prompt.Parent then -- Check if still valid
                    Prompt.Name = "OpenedSTORAGE"
                end
            end)
        end
    end)
end)
local PM = 1
local PR = false
LeftGroupBoxPrompts:AddToggle("PromptReach", {
	Text = "Prompt Reach",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
        pcall(function()
		    PR = Value
            local prompts = workspace:GetDescendants()
            for _, Prompt in ipairs(prompts) do
                if Prompt:IsA("ProximityPrompt") then
                    if Value == false then
                        if Prompt:GetAttribute("OrigLOSReq") ~= nil then
                            Prompt.RequiresLineOfSight = Prompt:GetAttribute("OrigLOSReq")
                        end
                        if Prompt:GetAttribute("OrigMAD") ~= nil then
                            Prompt.MaxActivationDistance = Prompt:GetAttribute("OrigMAD")
                        end
                    else -- Value == true
                        if Prompt:GetAttribute("OrigLOSReq") == nil then
                            Prompt:SetAttribute("OrigLOSReq", Prompt.RequiresLineOfSight)
                        end
                        if Prompt:GetAttribute("OrigMAD") == nil then
                            Prompt:SetAttribute("OrigMAD", Prompt.MaxActivationDistance)
                        end
                        Prompt.RequiresLineOfSight = false
                        Prompt.MaxActivationDistance = (Prompt:GetAttribute("OrigMAD") or Prompt.MaxActivationDistance) * PM -- Use original if available
                    end
                end
            end
        end)
	end,
})
LeftGroupBoxPrompts:AddSlider("PM", {
	Text = "Prompt Reach Multiplier",
	Default = PM,
	Min = 1,
	Max = 5, -- Increased max slightly
	Rounding = 1, -- 1 decimal place
	Compact = true,

	Callback = function(Value)
        pcall(function()
		    PM = Value
            if PR then -- Only update if PromptReach is enabled
                 local prompts = workspace:GetDescendants()
                 for _, Prompt in ipairs(prompts) do
                    if Prompt:IsA("ProximityPrompt") then
                       if Prompt:GetAttribute("OrigLOSReq") == nil then Prompt:SetAttribute("OrigLOSReq", Prompt.RequiresLineOfSight) end
                       if Prompt:GetAttribute("OrigMAD") == nil then Prompt:SetAttribute("OrigMAD", Prompt.MaxActivationDistance) end
                       Prompt.RequiresLineOfSight = false
                       Prompt.MaxActivationDistance = (Prompt:GetAttribute("OrigMAD") or Prompt.MaxActivationDistance) * PM
                    end
                end
            end
        end)
	end,

	Disabled = false, 
	Visible = true, 
})
workspace.DescendantAdded:Connect(function(Prompt)
    pcall(function()
        if Prompt:IsA("ProximityPrompt") and PR then
            if Prompt:GetAttribute("OrigLOSReq") == nil then Prompt:SetAttribute("OrigLOSReq", Prompt.RequiresLineOfSight) end
            if Prompt:GetAttribute("OrigMAD") == nil then Prompt:SetAttribute("OrigMAD", Prompt.MaxActivationDistance) end
            Prompt.RequiresLineOfSight = false
            Prompt.MaxActivationDistance = (Prompt:GetAttribute("OrigMAD") or Prompt.MaxActivationDistance) * PM
        end
    end)
end)

-- =============================================================
-- Auto Rooms & Integrated Auto Loot Section
-- =============================================================
local RightGroupBoxAutoRooms = Tabs.Main:AddRightGroupbox("<b>Auto-Rooms</b>") -- Renamed
local ARTargetReach = 205
local AutoLootOnRoomEnterEnabled = false
local AutoLootSideRoomsIntegratedEnabled = false

-- Helper function to check for dangerous entities
local function entityIsPresent()
    return workspace:FindFirstChild("Rush", false) or workspace:FindFirstChild("Ambush", false) or workspace:FindFirstChild("Ram", false)
end

-- Helper function to get current room number
local function getCurrentRoomNumber()
    if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.CurrentRoom and ClientMain.CLIENT.Values.CurrentRoom.Value then
        local roomName = ClientMain.CLIENT.Values.CurrentRoom.Value.Name
        local num = tonumber(roomName:match("Room(%d+)"))
        return num or -1 -- Return -1 if not a standard room
    end
    return -1 -- Return -1 if unable to determine
end

-- Integrated Auto Loot Function (Modified from original button)
local function executeIntegratedAutoLoot(roomModel, lootSideRoomsFlag)
    local integratedLootVersion = "1.0-Integrated"
    Library:Notify("Integrated Loot Started (v" .. integratedLootVersion .. ") for " .. roomModel.Name, 1)
    warn("--- Integrated Auto Loot (v" .. integratedLootVersion .. ") Started for " .. roomModel.Name .. " ---")
    warn("--- Integrated Fast Gold Loot ALWAYS Enabled ---")
    if lootSideRoomsFlag then warn("--- Integrated Side Room Loot Enabled ---") end

    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then Library:Notify("Player character not found for integrated loot.", 3); warn("ERROR: Player character not found."); return end
    if not roomModel or not roomModel:IsA("Model") then Library:Notify("Invalid room model for integrated loot.", 3); warn("ERROR: Invalid room model."); return end

    local goldItemNames = {"Coin", "CoinStack", "GoldBar", "GoldBarAndDiamonds"}
    local itemsLootedCount = 0
    local partsToLootAfterOpening = {}
    local overallContainerIndex = 0
    local originalCFrame = character.HumanoidRootPart.CFrame -- Store original position

    -- Function to try looting an item via FAST MODE (direct fire) or TELEPORT fallback
    local function tryFirePromptForItem_Integrated(itemPromptRef, itemModel, itemContextName)
        if not (itemModel and itemModel.Parent) then return true end -- Already gone
        if not (itemPromptRef and itemPromptRef:IsA("ProximityPrompt") and itemPromptRef.Parent and itemPromptRef.Enabled) then return false end -- Invalid prompt

        local looted = false
        local fastAttempts = 0
        local maxFastAttempts = 3

        -- FAST MODE attempt first
        while fastAttempts < maxFastAttempts do
            if entityIsPresent() then warn("    -- Entity detected during fast loot, pausing..."); repeat task.wait(0.5) until not entityIsPresent(); warn("    -- Entity gone, resuming fast loot.") end
            if not (itemModel and itemModel.Parent) then looted = true; break end
            if not (itemPromptRef and itemPromptRef.Parent and itemPromptRef.Enabled) then warn("      -- Gold Prompt became invalid during fast loot attempt."); break end
            pcall(fireproximityprompt, itemPromptRef)
            task.wait(0.05)
            fastAttempts = fastAttempts + 1
        end

        if not (itemModel and itemModel.Parent) then
            looted = true
            -- warn("      -- SUCCESS: Looted", itemContextName, "via fast mode.")
        else
            warn("      -- FAILURE: Gold still exists after fast fire. Falling back to teleport.")
            -- TELEPORT MODE fallback (similar to original)
            local tpAttempts = 0; local maxLoopTime = 5; local startTime = tick(); local firstAttempt = true
            while itemModel and itemModel.Parent and (tick() - startTime < maxLoopTime) do
                 if entityIsPresent() then warn("    -- Entity detected during TP loot, pausing..."); character:PivotTo(originalCFrame); repeat task.wait(0.5) until not entityIsPresent(); warn("    -- Entity gone, resuming TP loot.") end
                 if firstAttempt then task.wait(0.1); firstAttempt = false end
                 local currentItemPrompt = itemModel:FindFirstChild("ItemPrompt")
                 if currentItemPrompt and currentItemPrompt:IsA("ProximityPrompt") and currentItemPrompt.Enabled then
                     local promptParent = currentItemPrompt.Parent
                     if not promptParent then break end
                     local targetCFrame
                     if promptParent:IsA("Model") then targetCFrame = promptParent:GetPivot() elseif promptParent:IsA("BasePart") then targetCFrame = promptParent.CFrame end
                     if targetCFrame then
                         character:PivotTo(targetCFrame)
                         task.wait(0.05)
                         local success, err = pcall(fireproximityprompt, currentItemPrompt)
                         task.wait(0.07)
                         if not itemModel or not itemModel.Parent then looted = true; break end
                     end
                 end
                 tpAttempts = tpAttempts + 1
                 task.wait(0.1)
            end
            if not itemModel or not itemModel.Parent then looted = true else warn("    -- WARNING: Item", itemContextName, "still exists after TP loot attempts.") end
        end

        character:PivotTo(originalCFrame) -- Return to original position
        return looted
    end

    -- Function to trigger a container prompt reliably (teleport and fire ONCE or TWICE)
    local function triggerContainerPrompt_Reliable_Integrated(prompt, containerPart, promptContextName)
        warn("    -- Triggering Container Prompt Reliably:", promptContextName)
        if not (containerPart and containerPart.Parent) then warn("      -- ERROR: Invalid container part."); return end
        if not (prompt and prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Enabled) then warn("      -- ERROR: Invalid or disabled prompt."); return end

        local promptParent = prompt.Parent
        local targetCFrame
        if promptParent:IsA("Model") then targetCFrame = promptParent:GetPivot() elseif promptParent:IsA("BasePart") then targetCFrame = promptParent.CFrame elseif promptParent:IsA("Attachment") then targetCFrame = promptParent.WorldCFrame end
        if not targetCFrame then warn("      -- ERROR: Could not get target CFrame."); return end

        character:PivotTo(targetCFrame)
        task.wait(0.07)
        if entityIsPresent() then warn("    -- Entity detected before container trigger, pausing..."); character:PivotTo(originalCFrame); repeat task.wait(0.5) until not entityIsPresent(); warn("    -- Entity gone, resuming trigger."); character:PivotTo(targetCFrame); task.wait(0.07) end
        local success1, err1 = pcall(fireproximityprompt, prompt)
        task.wait(0.08)
        if prompt and prompt.Parent and prompt.Enabled then -- Check again before second fire
            if entityIsPresent() then warn("    -- Entity detected before 2nd container trigger, pausing..."); character:PivotTo(originalCFrame); repeat task.wait(0.5) until not entityIsPresent(); warn("    -- Entity gone, resuming 2nd trigger."); character:PivotTo(targetCFrame); task.wait(0.07) end
            pcall(fireproximityprompt, prompt)
            task.wait(0.05)
        end
        character:PivotTo(originalCFrame)
        warn("      -- Finished reliable trigger attempt for:", promptContextName)
    end

    -- MODIFIED: Function to find and loot gold (Handles Table structure correctly, uses integrated loot function)
    local function findAndLootGold_Integrated(itemContainer, containerContextName)
        -- warn("  -- [Loot Phase] findAndLootGold_Integrated called for:", containerContextName, "Part:", itemContainer and itemContainer:GetFullName() or "nil")
        if not itemContainer then warn("    -- ERROR: itemContainer is nil. Aborting loot."); return end
        if entityIsPresent() then warn("    -- Entity detected at start of findAndLootGold, pausing..."); repeat task.wait(0.5) until not entityIsPresent(); warn("    -- Entity gone, resuming findAndLootGold.") end

        local itemParentToSearch = itemContainer
        local spawnFolder = nil
        spawnFolder = itemContainer:FindFirstChild("ItemSpawns") or itemContainer:FindFirstChild("SpawnAreas")
        if not spawnFolder and itemContainer.Name == "Outside_Container" then
             local baseOutline = itemContainer:FindFirstChild("BaseOutline")
             if baseOutline then spawnFolder = baseOutline:FindFirstChild("ItemSpawns") or baseOutline:FindFirstChild("SpawnAreas") end
        end
        if spawnFolder then itemParentToSearch = spawnFolder end
        if not itemParentToSearch or not itemParentToSearch.Parent then warn("    -- ERROR: Invalid itemParentToSearch:", itemParentToSearch and itemParentToSearch:GetFullName() or "nil"); return end

        local potentialItems = itemParentToSearch:GetChildren()
        if #potentialItems == 0 then return end

        for i, item in ipairs(potentialItems) do
            local itemModel = item; if not (itemModel and itemModel.Parent) then continue end
            if entityIsPresent() then warn("    -- Entity detected during item loop, pausing..."); repeat task.wait(0.5) until not entityIsPresent(); warn("    -- Entity gone, resuming item loop.") end

            if table.find(goldItemNames, itemModel.Name) then
                local itemPrompt = itemModel:FindFirstChild("ItemPrompt")
                if itemPrompt then
                    if tryFirePromptForItem_Integrated(itemPrompt, itemModel, itemModel.Name .. " ItemPrompt in " .. containerContextName) then
                        itemsLootedCount = itemsLootedCount + 1
                    else
                        warn("          -- FAILED integrated loot for GOLD:", itemModel.Name)
                    end
                else warn("        -- ERROR: Could not find ItemPrompt inside gold item:", itemModel.Name) end
            end
            task.wait() -- Small yield within the loop
        end
    end

    -- Phase 1: Check True State, Trigger if Needed, Identify Loot Locations
    warn("\n--- Starting Integrated Phase 1: Checking True State & Identifying Loot Locations ---")
    local function processItemForOpening_Integrated(item)
        if not item or not item.Parent then return end
        if entityIsPresent() then warn("    -- Entity detected during container processing, pausing..."); repeat task.wait(0.5) until not entityIsPresent(); warn("    -- Entity gone, resuming container processing.") end

        local children = item:GetChildren()
        for _, child in ipairs(children) do
            if not child or not child.Parent then continue end
            local isKnownContainer = child:IsA("Model") and (child.Name:find("LockerVariant") or child.Name:find("CrowbarVariant") or child.Name == "Drawer" or child.Name:find("Table") or child.Name == "Rolltop" or child.Name == "ToolBox")

            if isKnownContainer then
                overallContainerIndex = overallContainerIndex + 1
                local containerModel = child; local modelIndex = overallContainerIndex
                warn("-- [Open Phase] Processing Container:", containerModel.Name, "#", modelIndex)
                local containerChildren = containerModel:GetChildren(); local lootPartsToAdd = {}

                local function checkAndTrigger_Integrated(promptRef, innerModelRef, partForTrigger, context)
                    local promptOpenedAttr = promptRef and promptRef:GetAttribute("Opened"); local nameOK = innerModelRef and innerModelRef.Name == "OpenedSTORAGE"; local isTrulyOpen = (promptOpenedAttr == true and nameOK == true)
                    warn("      -- Check:", context, "Prompt Attr:", tostring(promptOpenedAttr), "Inner Name:", innerModelRef and innerModelRef.Name or "N/A", "Truly Open:", isTrulyOpen)
                    if not isTrulyOpen and promptRef then warn("        -- Marked for opening trigger."); triggerContainerPrompt_Reliable_Integrated(promptRef, partForTrigger, context .. " Trigger #" .. modelIndex) elseif not promptRef then warn("      -- WARNING: No prompt found for", context) end
                end

                local innerModels = {}
                for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name == "Container" or cChild.Name == "OpenedSTORAGE") then table.insert(innerModels, cChild) end end
                local innerModelRef = #innerModels > 0 and innerModels[1] or nil

                -- Handle specific container types (using _Integrated functions)
                if containerModel.Name == "Drawer" then
                    for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name:find("Container", 1, true) or cChild.Name == "OpenedSTORAGE") and cChild.Name ~= "Outside_Container" then local currentInnerModel = cChild; local mainDrawer = currentInnerModel:FindFirstChild("MainDrawer"); if mainDrawer then local prompt = mainDrawer:FindFirstChild("ProxAttach", true):FindFirstChild("ProximityPrompt"); checkAndTrigger_Integrated(prompt, currentInnerModel, mainDrawer, "Drawer." .. currentInnerModel.Name); table.insert(lootPartsToAdd, mainDrawer); else warn("    -- ERROR: No MainDrawer in", cChild:GetFullName()) end end end
                    local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer); end
                elseif containerModel.Name:find("LockerVariant") or containerModel.Name:find("CrowbarVariant") then
                     local basePart = innerModelRef and innerModelRef:FindFirstChild("Base"); if basePart then table.insert(lootPartsToAdd, basePart) else warn("    -- WARNING: Could not find Base part for Locker.") end
                     if containerModel.Name:find("LLV2") or containerModel.Name:find("Variant2") then local doorBottom = containerModel:FindFirstChild("DoorBottom"); local promptB = doorBottom and doorBottom:FindFirstChild("DoorBottom", true):FindFirstChild("ProximityPrompt"); local doorTop = containerModel:FindFirstChild("DoorTop"); local promptT = doorTop and doorTop:FindFirstChild("DoorTop", true):FindFirstChild("ProximityPrompt"); checkAndTrigger_Integrated(promptB, innerModelRef, doorBottom, "LockerV2 Bottom Door"); checkAndTrigger_Integrated(promptT, innerModelRef, doorTop, "LockerV2 Top Door")
                     else local door = containerModel:FindFirstChild("Door"); local promptD = door and door:FindFirstChild("ProximityPrompt"); checkAndTrigger_Integrated(promptD, innerModelRef, door, "Locker Single Door") end
                elseif containerModel.Name == "Rolltop" then
                     local mainDrawerRef = innerModelRef and innerModelRef:FindFirstChild("MainDrawer"); if mainDrawerRef then local pA = mainDrawerRef:FindFirstChild("ProxAttach"); local promptR = pA and pA:FindFirstChild("ProximityPrompt"); checkAndTrigger_Integrated(promptR, innerModelRef, mainDrawerRef, "Rolltop MainDrawer"); table.insert(lootPartsToAdd, mainDrawerRef) else warn("    -- WARNING: Could not find MainDrawer for Rolltop.") end
                     local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer) end
                elseif containerModel.Name == "ToolBox" then
                     local toolBoxInnerModel = nil; for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name == "Container" or cChild.Name == "OpenedSTORAGE") then toolBoxInnerModel = cChild; break end end
                     if toolBoxInnerModel then local promptTB = containerModel:FindFirstChild("ProximityPrompt"); checkAndTrigger_Integrated(promptTB, toolBoxInnerModel, toolBoxInnerModel, "ToolBox"); local baseRef = toolBoxInnerModel:FindFirstChild("Base"); if baseRef then local spawnAreasRef = baseRef:FindFirstChild("SpawnAreas"); if spawnAreasRef then table.insert(lootPartsToAdd, spawnAreasRef) else warn("    -- WARNING: ToolBox Base found, but no SpawnAreas.") end else warn("    -- WARNING: ToolBox InnerContainer found, but no Base.") end else warn("    -- WARNING: Could not find InnerContainer for ToolBox.") end
                elseif containerModel.Name:find("Table") then
                     local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer) else warn("    -- WARNING: No Outside_Container found for Table variant:", containerModel.Name) end
                end

                if #lootPartsToAdd > 0 then
                    for _, part in ipairs(lootPartsToAdd) do if part and part.Parent then table.insert(partsToLootAfterOpening, part) else warn("      -- Skipping invalid loot part.") end end
                end

            elseif child.Name == "AddedAssets" and child:IsA("Folder") then processItemForOpening_Integrated(child)
            elseif lootSideRoomsFlag and child.Name == "SideRoom" and child:IsA("Model") then processItemForOpening_Integrated(child) -- Use the flag here
            end
            task.wait()
        end
    end

    processItemForOpening_Integrated(roomModel)
    warn("--- Finished Integrated Phase 1 ---")
    warn("-- Phase 1 Summary: Identified", #partsToLootAfterOpening, "potential loot locations.")

    -- Phase 2: Loot Gold from Identified Locations
    if #partsToLootAfterOpening > 0 then
        warn("\n--- Starting Integrated Phase 2: Looting Gold ---"); local uniquePartsLooted = {}
        for i, part in ipairs(partsToLootAfterOpening) do
            if not (part and part.Parent) then warn("    -- Skipping part #", i, "as it no longer exists."); continue end
            if uniquePartsLooted[part] then continue end
            if entityIsPresent() then warn("    -- Entity detected before looting part, pausing..."); repeat task.wait(0.5) until not entityIsPresent(); warn("    -- Entity gone, resuming loot.") end

            local contextName = part.Name; local parentModel = part:FindFirstAncestorWhichIsA("Model"); if parentModel then contextName = parentModel.Name .. " " .. contextName end
            findAndLootGold_Integrated(part, contextName .. " #" .. i); uniquePartsLooted[part] = true
            task.wait() -- Yield between looting parts
        end
        warn("--- Finished Integrated Phase 2: Looting Gold ---")
    end

    -- Final Notification
    warn("--- Integrated Auto Loot Finished for " .. roomModel.Name .. " ---")
    Library:Notify("Integrated Loot Finished (v" .. integratedLootVersion .. "). Looted " .. itemsLootedCount .. " gold items in " .. roomModel.Name .. ".", 3)
    character:PivotTo(originalCFrame) -- Ensure player returns to original spot
end
-- End of executeIntegratedAutoLoot function


RightGroupBoxAutoRooms:AddSlider("ARRoomReach", {
	Text = "Room to Reach",
	Default = ARTargetReach,
	Min = 102,
	Max = 205,
	Rounding = 0,
	Compact = true,

	Callback = function(Value)
		ARTargetReach = Value -- Update the target reach variable
	end,

	Disabled = false, 
	Visible = true, 
})

RightGroupBoxAutoRooms:AddToggle("AutoLootOnRoomEnter", {
    Text = "Auto Loot On Room Enter",
    Default = false,
    Callback = function(Value)
        AutoLootOnRoomEnterEnabled = Value
    end,
    Disabled = false,
    Visible = true,
})

RightGroupBoxAutoRooms:AddToggle("AutoLootSideRoomsIntegrated", {
    Text = "Loot Side Rooms (Integrated)",
    Default = false,
    Callback = function(Value)
        AutoLootSideRoomsIntegratedEnabled = Value
    end,
    Disabled = false,
    Visible = true,
})


local CollectionService = game:GetService("CollectionService")
local Rooms = workspace.GeneratedRooms
local ARGoing = false
local FiredPrompts = {}
local DoggedRooms = {}
local CutFolder = Instance.new("Folder")
CutFolder.Name = "TempCutsceneStorage_FoundationHub"
CutFolder.Parent = CoreGui -- Store somewhere safe

local ARCon -- Connection variable for the Stepped loop

RightGroupBoxAutoRooms:AddButton({
	Text = "Start/Stop Auto Rooms", -- Clarified button text
	Func = function()
        ARGoing = not ARGoing
        if ARGoing then
            -- Move cutscenes
            pcall(function()
                if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.CutsceneHandler and ClientMain.CLIENT.CutsceneHandler.Cutscenes then
                    for _, scene in ClientMain.CLIENT.CutsceneHandler.Cutscenes:GetChildren() do
                        scene.Parent = CutFolder
                    end
                else
                    warn("Could not find Cutscene folder to disable.")
                end
            end)
            Library:Notify("Auto rooms started")
            FiredPrompts = {} -- Reset state
            DoggedRooms = {}

            ARCon = RunService.Stepped:Connect(function()
                if not ARGoing then -- Check if should stop
                    if ARCon then ARCon:Disconnect(); ARCon = nil end
                    return
                end

                -- Check for entities and pause
                if entityIsPresent() then
                    Library:Notify("Entity detected, pausing Auto Rooms...", 1)
                    warn("Entity detected, pausing Auto Rooms...")
                    -- Wait until entity is gone, but also check if ARGoing was turned off
                    while entityIsPresent() and ARGoing do
                        task.wait(0.5)
                    end
                    if not ARGoing then return end -- Stop if disabled during pause
                    Library:Notify("Entity gone, resuming Auto Rooms.", 1)
                    warn("Entity gone, resuming Auto Rooms.")
                end

                local Character = Players.LocalPlayer.Character
                if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end -- Need character

                local RoomNumbers = {}
                local currentRoomNum = getCurrentRoomNumber() -- Get current room number once

                for _, Room in Rooms:GetChildren() do
                    pcall(function() CollectionService:RemoveTag(Room, "DarkRoom") end) -- Safely remove tag
                    local Number = tonumber(Room.Name:gsub("Room", ""))
                    if Number then table.insert(RoomNumbers, Number) end
                end
                if #RoomNumbers == 0 then return end -- No rooms found

                table.sort(RoomNumbers) -- Sort ascending
                local LastRoomNumber = RoomNumbers[#RoomNumbers] -- Highest number is the latest room *being generated* or *just entered*

                -- Check if target reached
                if currentRoomNum >= ARTargetReach then
                    Library:Notify("Target room " .. ARTargetReach .. " reached. Stopping Auto Rooms.")
                    ARGoing = false -- Set flag to stop
                    -- Move cutscenes back
                    pcall(function()
                        if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.CutsceneHandler and ClientMain.CLIENT.CutsceneHandler.Cutscenes then
                             for _, scene in CutFolder:GetChildren() do
                                scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes
                            end
                        end
                    end)
                    RepStorage.Events.VoidEvent:FireServer() -- Fire void event if needed
                    if ARCon then ARCon:Disconnect(); ARCon = nil end -- Disconnect immediately
                    return
                end

                -- Find the *next* room's door/trigger based on the *current* room
                local currentRoomModel = Rooms:FindFirstChild("Room" .. tostring(currentRoomNum))
                if not currentRoomModel then return end -- Can't find current room model

                -- Notify about entering a new room
                if not table.find(DoggedRooms, currentRoomModel) then
                    table.insert(DoggedRooms, currentRoomModel)
                    local notifyMode = Options.RMUnify.Value
                    if notifyMode == "Current Room" then
                        Library:Notify("Auto Rooms: Entered Room " .. currentRoomNum)
                    elseif notifyMode == "Special Room" and currentRoomModel:GetAttribute("Chance") == 0 then
                        Library:Notify("Auto Rooms: Entered Special room '" .. currentRoomModel:GetAttribute("RawName") .. "' (Room " .. currentRoomNum .. ")")
                    end
                end

                -- Handle special room logic (Observatory, etc.)
                if currentRoomNum == 195 then
                    pcall(function() RepStorage.Events.TheObservatory.BeatPuzzle:FireServer() end)
                end

                -- Find the door/trigger *in the current room* to open the *next* room
                local Door = currentRoomModel:FindFirstChild("Door") or currentRoomModel:FindFirstChild("DoorNormal")
                local Scriptable = currentRoomModel:FindFirstChild("Scriptable")
                local Hitbox = (Door and Door:FindFirstChild("Hitbox")) or (Scriptable and Scriptable:FindFirstChild("Trigger"))
                local Lever = currentRoomModel:FindFirstChild("CaveLever")
                local Prompt = Lever and Lever:FindFirstChild("ProximityPrompt")
                -- Elevator logic might need adjustment if it's the exit mechanism
                local Elevator = Scriptable and Scriptable:FindFirstChild("Elevator")
                local ElevatorControl = Elevator and Elevator:FindFirstChild("Control")
                local ElevatorPrompt = ElevatorControl and ElevatorControl:FindFirstChild("Button", true):FindFirstChild("ProximityPrompt")

                local triggeredSomething = false
                local hrp = Character.HumanoidRootPart

                -- Prioritize Lever if present and not fired
                if Prompt and Prompt.Enabled and not FiredPrompts[Prompt] then
                    warn("Attempting to fire Lever Prompt in Room " .. currentRoomNum)
                    Character:PivotTo(Lever:GetPivot() * CFrame.new(0, 0, -3)) -- Move slightly in front
                    task.wait(0.1)
                    fireproximityprompt(Prompt)
                    FiredPrompts[Prompt] = true
                    triggeredSomething = true
                    task.wait(0.2) -- Wait a bit after firing lever
                -- Prioritize Elevator if present and not fired
                elseif ElevatorPrompt and ElevatorPrompt.Enabled and not FiredPrompts[ElevatorPrompt] then
                     warn("Attempting to fire Elevator Prompt in Room " .. currentRoomNum)
                     Character:PivotTo(ElevatorControl.Button:GetPivot() * CFrame.new(0,0,-3))
                     task.wait(0.1)
                     fireproximityprompt(ElevatorPrompt)
                     FiredPrompts[ElevatorPrompt] = true
                     triggeredSomething = true
                     task.wait(0.2)
                -- Otherwise, use Hitbox if available
                elseif Hitbox then
                    warn("Attempting to trigger Hitbox in Room " .. currentRoomNum)
                    local targetCFrame = currentRoomModel:GetPivot() * CFrame.new(0, 5, 0) -- Target slightly above floor
                    -- Teleport close first, then resize hitbox
                    Character:PivotTo(targetCFrame)
                    task.wait(0.05)
                    Hitbox.CFrame = hrp.CFrame -- Move hitbox to player
                    Hitbox.Size = Vector3.new(10, 10, 10) -- Make it reasonably large
                    Hitbox.Transparency = 0.5; Hitbox.BrickColor = BrickColor.Red(); Hitbox.CanCollide = false -- Debug visual
                    triggeredSomething = true
                    task.wait(0.1) -- Wait for trigger registration
                    Hitbox.Size = Vector3.new(1, 1, 1) -- Shrink back (optional)
                    Hitbox.Transparency = 1
                else
                    warn("No door/lever/hitbox/elevator found to proceed from Room " .. currentRoomNum)
                    -- Potentially stop ARGoing here if stuck?
                    -- ARGoing = false
                    -- Library:Notify("Auto rooms stopped: Could not find exit mechanism.", 3)
                    -- return
                end

                -- If we triggered something, wait for the room to change and then potentially loot
                if triggeredSomething then
                    warn("Waiting for room change from " .. currentRoomNum)
                    local waitStartTime = tick()
                    local roomChanged = false
                    repeat
                        task.wait(0.1)
                        if entityIsPresent() then -- Check for entities during wait
                             Library:Notify("Entity detected while waiting for room change, pausing...", 1)
                             warn("Entity detected while waiting for room change, pausing...")
                             while entityIsPresent() and ARGoing do task.wait(0.5) end
                             if not ARGoing then return end
                             Library:Notify("Entity gone, resuming wait.", 1)
                             warn("Entity gone, resuming wait.")
                             waitStartTime = tick() -- Reset timeout timer after entity pause
                        end
                        roomChanged = (getCurrentRoomNumber() > currentRoomNum)
                    until roomChanged or (tick() - waitStartTime > 5) or not ARGoing -- 5 second timeout or stopped

                    if not ARGoing then return end -- Stop if disabled during wait

                    if roomChanged then
                        local newRoomNum = getCurrentRoomNumber()
                        local newRoomModel = Rooms:FindFirstChild("Room" .. tostring(newRoomNum))
                        warn("Room changed to " .. newRoomNum)

                        -- Check for entities AGAIN before looting
                        if entityIsPresent() then
                             Library:Notify("Entity detected just before looting, pausing...", 1)
                             warn("Entity detected just before looting, pausing...")
                             while entityIsPresent() and ARGoing do task.wait(0.5) end
                             if not ARGoing then return end
                             Library:Notify("Entity gone, proceeding to loot.", 1)
                             warn("Entity gone, proceeding to loot.")
                        end

                        -- Execute integrated loot if enabled
                        if AutoLootOnRoomEnterEnabled and newRoomModel then
                            executeIntegratedAutoLoot(newRoomModel, AutoLootSideRoomsIntegratedEnabled)
                            -- Check for entities AGAIN after looting
                            if entityIsPresent() then
                                 Library:Notify("Entity detected after looting, pausing...", 1)
                                 warn("Entity detected after looting, pausing...")
                                 while entityIsPresent() and ARGoing do task.wait(0.5) end
                                 if not ARGoing then return end
                                 Library:Notify("Entity gone, resuming Auto Rooms.", 1)
                                 warn("Entity gone, resuming Auto Rooms.")
                            end
                        end
                    else
                        warn("Room did not change after 5 seconds or trigger.")
                        -- Maybe retry trigger or stop?
                    end
                end
            end) -- End of RunService.Stepped connection

        else -- ARGoing turned off
            Library:Notify("Auto rooms stopped")
            FiredPrompts = {}
            DoggedRooms = {}
            if ARCon then ARCon:Disconnect(); ARCon = nil end -- Disconnect the loop
            ARGoing = false -- Ensure flag is false
            -- Move cutscenes back
            pcall(function()
                 if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.CutsceneHandler and ClientMain.CLIENT.CutsceneHandler.Cutscenes then
                    for _, scene in CutFolder:GetChildren() do
                        scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes
                    end
                 end
            end)
            RepStorage.Events.VoidEvent:FireServer() -- Fire void event if needed
        end
	end,

	Disabled = false,
	Visible = true,
})

RightGroupBoxAutoRooms:AddDropdown("RMUnify", {
	Values = { "Current Room", "Special Room"},
	Default = 1, 
	Multi = false, 

	Text = "Notifications",

	Searchable = false, 

	Disabled = false, 
	Visible = true, 
})


local LeftGroupBoxVisuals = Tabs.Visuals:AddLeftGroupbox("<b>General</b>") -- Renamed
LeftGroupBoxVisuals:AddToggle("Fullbright", {
	Text = "Fullbright",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
        pcall(function()
		    if Value == true then
                Lighting.Brightness = 3
                Lighting.GlobalShadows = false
                Lighting.ClockTime = 14 -- Day time
                Lighting.FogEnd = 100000 -- Remove fog
            else
                Lighting.Brightness = 0 -- Reset to default (adjust if needed)
                Lighting.GlobalShadows = true
                Lighting.ClockTime = 4 -- Night time (adjust if needed)
                Lighting.FogEnd = 500 -- Reset fog (adjust if needed)
            end
        end)
	end,
})
local noFog = false
LeftGroupBoxVisuals:AddToggle("NoFog", {
	Text = "No-Fog",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
        pcall(function()
		    noFog = Value
            if Value == true then
		        if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = 0 end
                Lighting.FogEnd = 100000
            else
		        if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = 0.6 end -- Reset (adjust if needed)
                Lighting.FogEnd = 500 -- Reset (adjust if needed)
            end
        end)
	end,
})

task.spawn(function()
	while task.wait(1) do -- Check less frequently
        pcall(function()
		    if noFog then
			    if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = 0 end
                Lighting.FogEnd = 100000
		    -- else -- Let the toggle callback handle resetting
			--    if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = 0.6 end
            --    Lighting.FogEnd = 500
		    end
        end)
	end
end)

LeftGroupBoxVisuals:AddToggle("FP", {
	Text = "Third Person",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
        pcall(function()
            FPLoop = Value
		    if Value == true then
                if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    if ClientMain and ClientMain.Scripts and ClientMain.Scripts.cameraMain then ClientMain.Scripts.cameraMain.Enabled = false end
                    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                    Players.LocalPlayer.Character.Humanoid.AutoRotate = true
                    Players.LocalPlayer.CameraMaxZoomDistance = 10
                    Players.LocalPlayer.CameraMinZoomDistance = 10
                end
            else -- Value == false
                if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                     if ClientMain and ClientMain.Scripts and ClientMain.Scripts.cameraMain then ClientMain.Scripts.cameraMain.Enabled = true end
                     Players.LocalPlayer.CameraMaxZoomDistance = 400 -- Reset zoom
                     Players.LocalPlayer.CameraMinZoomDistance = 0.5
                end
            end
        end)
	end,
}):AddKeyPicker("KeyPicker", {
	Default = "V", 
	SyncToggleState = true,

	Mode = "Toggle", 

	Text = "Third Person", 
	NoUI = false, 
})

task.spawn(function()
    while task.wait() do -- Use task.wait()
        pcall(function()
            if FPLoop and Players.LocalPlayer.Character then
                local head = Players.LocalPlayer.Character:FindFirstChild("Head")
                if head then
                    head.Transparency = 0
                    head.LocalTransparencyModifier = 0
                end
                for _, Obj in Players.LocalPlayer.Character:GetDescendants() do
                    if Obj:IsA("BasePart") and (Obj.Name == "Handle" or Obj.Name == "face") then -- Check BasePart
                        Obj.Transparency = 0
                        pcall(function() Obj.LocalTransparencyModifier = 0 end)
                    elseif Obj:IsA("Decal") and Obj.Name == "face" then -- Handle Decal face
                         Obj.Transparency = 0
                    end
                end
            end
        end)
    end
end)
local NotifyEntities = {"Rush", "Screech", "Ram", "Ambush", "Hoardbats", "Eyes", "Stare", "Onslaught"}
local NotifyEntitiesInternal = {}
local RightGroupBoxVisuals = Tabs.Visuals:AddRightGroupbox("<b>Notifications</b>") -- Renamed
for _, Entity in ipairs(NotifyEntities) do -- Use ipairs
    NotifyEntitiesInternal[Entity] = false
    RightGroupBoxVisuals:AddToggle("Notify" .. Entity, {
	    Text = "Notify " .. Entity,

	    Default = false,
	    Disabled = false, 
	    Visible = true, 

	    Callback = function(Value)
		   NotifyEntitiesInternal[Entity] = Value
	    end,
    })
end




local LeftGroupBoxAntiTrigger = Tabs.Exploits:AddRightGroupbox("<b>Anti-Trigger</b>") -- Renamed
local AntiTrigger = {"Seek-Chase-Start", "Seek-Chase-Planks-Fall", "Seek-Chase-Obstruction", "Seek-Chase-Boat-Start", "Death-Trigger", "Seek-Last-Room-Start","Prison-Start", "Watcher-Chase-Start","Observatory-Door"}
local AntiTriggerInternal = {}

local function processTrigger(trigger)
    if not trigger or not trigger.Parent then return end -- Basic check
    pcall(function()
        local triggerName = trigger.Name
        local parent = trigger.Parent
        local parentName = parent.Name

        if triggerName == "Trigger" and parent:FindFirstChild("Chase") then
            trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Start"]
        elseif triggerName == "Hitbox" and parent:FindFirstChild("Planks") then
            trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Planks-Fall"]
        elseif triggerName == "EndSequenceHitbox" then
            trigger.CanTouch = not AntiTriggerInternal["Seek-Last-Room-Start"]
        elseif triggerName == "DeathPit" or (triggerName == "Cube" and parentName == "Piper") then
            trigger.CanTouch = not AntiTriggerInternal["Death-Trigger"]
        elseif triggerName == "Hitbox" and parent:FindFirstChild("AnimatedShelf") then
            trigger.CanTouch = not AntiTriggerInternal["Watcher-Chase-Start"]
        elseif triggerName == "DoorTrigger" and parent:FindFirstChild("BigDoor") then
            trigger.CanTouch = not AntiTriggerInternal["Observatory-Door"]
        elseif triggerName == "StartCutscene" and parent:FindFirstChild("PivotWatcherCutscene") and parent:FindFirstChild("GuidingLight") then
            trigger.CanTouch = not AntiTriggerInternal["Prison-Start"]
        elseif triggerName == "Trigger" and parent:FindFirstChild("ObstructionHolder") then
            trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Obstruction"]
        elseif triggerName == "Trigger" and parent:FindFirstChild("2ndPivot") and parent:FindFirstChild("Cutscene") then
            trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Boat-Start"]
        end
    end)
end

for _, Trigger in ipairs(AntiTrigger) do -- Use ipairs
    AntiTriggerInternal[Trigger] = false
    LeftGroupBoxAntiTrigger:AddToggle("Anti" .. Trigger, {
	    Text = "Anti-" .. Trigger,

	    Default = false,
	    Disabled = false, 
	    Visible = true, 

	    Callback = function(Value)
           pcall(function()
		       AntiTriggerInternal[Trigger] = Value
               -- Re-process all relevant objects in workspace when a toggle changes
               for _, object in workspace:GetDescendants() do
                    processTrigger(object)
               end
           end)
	    end,
    })
end

workspace.DescendantAdded:Connect(function(object)
    processTrigger(object) -- Process newly added objects
end)






local LeftGroupBoxESP = Tabs.Visuals:AddLeftGroupbox("<b>ESP</b>") -- Renamed
local ESPTracersEnabled: boolean = true
LeftGroupBoxESP:AddToggle("ESPTracers", {
	Text = "Tracers",

	Default = true,
	Disabled = false, 
	Visible = true, -- Made visible as it's a standard ESP option

	Callback = function(Value)
		ESPTracersEnabled = Value
        -- Update existing ESPs if library supports it
        for _, data in pairs(allTrackedESPs) do
            if data.ESP and data.ESP.Tracer then
                 data.ESP.Tracer.Enabled = Value
            end
        end
	end,
})
local ESPThings = {"Entity", "Objectives", "Doors", "HidingSpots", "Coins", "Containers"}
for _, Thing in ipairs(ESPThings) do -- Use ipairs
    LeftGroupBoxESP:AddToggle("ESP" .. Thing, {
	    Text = "ESP " .. Thing,

	    Default = false,
	    Disabled = false, 
	    Visible = true, 

	    Callback = function(Value)
           pcall(function()
		       espCategories[Thing] = Value
               updateESPVisibility() -- Update visibility when category is toggled
           end)
	    end,
    })
end
local LeftGroupBoxExploits = Tabs.Exploits:AddLeftGroupbox("<b>Exploits</b>") -- Renamed
LeftGroupBoxExploits:AddButton({
	Text = "Skip Watcher 150",
	Func = function()
        pcall(function()
            if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.CurrentRoom and ClientMain.CLIENT.Values.CurrentRoom.Value and ClientMain.CLIENT.Values.CurrentRoom.Value.Name == "Room150" then
                RepStorage.Events.ThePrision.FinishedTerminal:FireServer()
                Library:Notify("Fired FinishedTerminal event.", 1)
            else
                Library:Notify("You must be in room 150!", 2)
            end
        end)
	end,

	Disabled = false,
	Visible = true,
})

-- Define variables for the controls first (Original Auto Loot Button)
local lootWaitTime = 0.1 -- Default wait time
local useFastMode = false -- Default: Fast mode (Optimized Gold Loot) is disabled
local lootSideRooms = false -- Default: only check AddedAssets / direct models explicitly handled

-- Add the controls to the UI GroupBox (Original Auto Loot Button)
LeftGroupBoxExploits:AddToggle("LootSideRooms", {
    Text = "Attempt Loot Side Rooms (Button)", -- Clarified Text
    Default = lootSideRooms,
    Callback = function(Value)
        lootSideRooms = Value
        print("-- DEBUG: Button Loot Side Rooms set to:", lootSideRooms)
    end,
    Disabled = false,
    Visible = true,
})

LeftGroupBoxExploits:AddToggle("UseFastModeToggle", {
    Text = "Use Fast Gold Loot (Button - Risky)", -- Clarified Text
    Default = useFastMode,
    Callback = function(Value)
        useFastMode = Value
        print("-- DEBUG: Button Fast Gold Loot set to:", useFastMode)
    end,
    Disabled = false,
    Visible = true,
})

LeftGroupBoxExploits:AddSlider("LootWaitSlider", {
    Text = "Loot Wait Time (Button - s)", -- Clarified Text
    Default = lootWaitTime,
    Min = 0,
    Max = 1,
    Rounding = 1, -- 1 decimal place (0.1 increments)
    Compact = true,
    Callback = function(Value)
        lootWaitTime = Value -- Update the variable when slider changes
        print("-- DEBUG: Button Loot Wait Time set to:", lootWaitTime)
    end,
    Disabled = false,
    Visible = true,
})
local AutoLootVersion = "2.19-IntegratedFix" -- Updated version number
LeftGroupBoxExploits:AddButton({
    Text = "Auto Loot Gold (Current Room Button)", -- Clarified Text
    Func = function()
        -- This is the ORIGINAL Auto Loot function, triggered by the button.
        -- It uses the global lootSideRooms, useFastMode, and lootWaitTime variables.
        Library:Notify("Button Auto Loot Gold Started (v" .. AutoLootVersion .. ")", 1)
        warn("--- Button Auto Loot Gold (v" .. AutoLootVersion .. ") Started ---")
        if useFastMode then warn("--- Button Fast Gold Loot Enabled ---") end

        local player = Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then Library:Notify("Player character not found.", 3); warn("ERROR: Player character not found."); return end
        if not ClientMain or not ClientMain.CLIENT or not ClientMain.CLIENT.Values or not ClientMain.CLIENT.Values.CurrentRoom or not ClientMain.CLIENT.Values.CurrentRoom.Value then Library:Notify("Cannot determine current room.", 3); warn("ERROR: Cannot determine current room."); return end
        local currentRoomModel = ClientMain.CLIENT.Values.CurrentRoom.Value
        if not currentRoomModel or not currentRoomModel:IsA("Model") then Library:Notify("Current room data is invalid.", 3); warn("ERROR: Current room data is invalid."); return end
        warn("Current Room Model:", currentRoomModel:GetFullName())

        local goldItemNames = {"Coin", "CoinStack", "GoldBar", "GoldBarAndDiamonds"}
        local itemsLootedCount = 0
        local partsToLootAfterOpening = {}
        local overallContainerIndex = 0
        local originalCFrame = character.HumanoidRootPart.CFrame -- Store original position

        -- Function to try looting an item via teleport loop (STANDARD METHOD for gold) - FOR BUTTON
        local function tryFirePromptForItem_Teleport_Button(itemPromptRef, itemModel, itemContextName)
             if not (itemModel and itemModel.Parent) then return true end
             local looted = false; local attempts = 0; local maxLoopTime = 7; local startTime = tick(); local firstAttempt = true
             while itemModel and itemModel.Parent and (tick() - startTime < maxLoopTime) do if firstAttempt then task.wait(0.1); firstAttempt = false end; local currentItemPrompt = itemModel:FindFirstChild("ItemPrompt"); if currentItemPrompt and currentItemPrompt:IsA("ProximityPrompt") and currentItemPrompt.Enabled then local promptParent = currentItemPrompt.Parent; if not promptParent then break end; local targetCFrame; if promptParent:IsA("Model") then targetCFrame = promptParent:GetPivot() elseif promptParent:IsA("BasePart") then targetCFrame = promptParent.CFrame end; if targetCFrame then character:PivotTo(targetCFrame); task.wait(0.05); local success, err = pcall(fireproximityprompt, currentItemPrompt); task.wait(0.07); if not itemModel or not itemModel.Parent then looted = true; break end end end; attempts = attempts + 1; task.wait(0.1) end
             if not itemModel or not itemModel.Parent then looted = true else looted = false; warn("    -- WARNING: Item", itemContextName, "still exists after TP loot attempts.") end; return looted
        end

        -- Function to trigger a container prompt reliably (teleport and fire ONCE or TWICE) - FOR BUTTON
        local function triggerContainerPrompt_Reliable_Button(prompt, containerPart, promptContextName)
            warn("    -- Triggering Container Prompt Reliably:", promptContextName)
            if not (containerPart and containerPart.Parent) then warn("      -- ERROR: Invalid container part."); return end; if not (prompt and prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Enabled) then warn("      -- ERROR: Invalid or disabled prompt."); return end; local promptParent = prompt.Parent; local targetCFrame; if promptParent:IsA("Model") then targetCFrame = promptParent:GetPivot() elseif promptParent:IsA("BasePart") then targetCFrame = promptParent.CFrame elseif promptParent:IsA("Attachment") then targetCFrame = promptParent.WorldCFrame end; if not targetCFrame then warn("      -- ERROR: Could not get target CFrame."); character:PivotTo(originalCFrame); return end
            character:PivotTo(targetCFrame); task.wait(0.07); local success1, err1 = pcall(fireproximityprompt, prompt); task.wait(0.08); if prompt and prompt.Parent and prompt.Enabled then pcall(fireproximityprompt, prompt); task.wait(0.05) end; character:PivotTo(originalCFrame); warn("      -- Finished reliable trigger attempt for:", promptContextName)
        end


        -- MODIFIED: Function to find and loot gold (Handles Table structure correctly) - FOR BUTTON
        local function findAndLootGold_Button(itemContainer, containerContextName)
            -- warn("  -- [Loot Phase] findAndLootGold_Button called for:", containerContextName, "Part:", itemContainer and itemContainer:GetFullName() or "nil")
            if not itemContainer then warn("    -- ERROR: itemContainer is nil. Aborting loot."); return end

            local itemParentToSearch = itemContainer
            local spawnFolder = nil
            spawnFolder = itemContainer:FindFirstChild("ItemSpawns") or itemContainer:FindFirstChild("SpawnAreas")
            if not spawnFolder and itemContainer.Name == "Outside_Container" then
                 local baseOutline = itemContainer:FindFirstChild("BaseOutline")
                 if baseOutline then spawnFolder = baseOutline:FindFirstChild("ItemSpawns") or baseOutline:FindFirstChild("SpawnAreas") end
            end
            if spawnFolder then itemParentToSearch = spawnFolder end
            if not itemParentToSearch or not itemParentToSearch.Parent then warn("    -- ERROR: Invalid itemParentToSearch:", itemParentToSearch and itemParentToSearch:GetFullName() or "nil"); return end

            local potentialItems = itemParentToSearch:GetChildren()
            if #potentialItems == 0 then return end

            for i, item in ipairs(potentialItems) do
                local itemModel = item; if not (itemModel and itemModel.Parent) then continue end
                if table.find(goldItemNames, itemModel.Name) then
                    local itemPrompt = itemModel:FindFirstChild("ItemPrompt")
                    if itemPrompt then
                        local lootedThisItem = false
                        if useFastMode then -- Use the button's fast mode toggle
                            local fastAttempts = 0; local maxFastAttempts = 3
                            while fastAttempts < maxFastAttempts do if not (itemModel and itemModel.Parent) then lootedThisItem = true; break end; if not (itemPrompt and itemPrompt.Parent and itemPrompt.Enabled) then warn("      -- Gold Prompt became invalid during fast loot attempt."); break end; pcall(fireproximityprompt, itemPrompt); task.wait(0.05); fastAttempts = fastAttempts + 1 end
                            if not (itemModel and itemModel.Parent) then itemsLootedCount = itemsLootedCount + 1; lootedThisItem = true else warn("          -- FAILURE: Gold still exists after brief direct fire. Falling back to teleport.") end
                        end
                        if not lootedThisItem then if tryFirePromptForItem_Teleport_Button(itemPrompt, itemModel, itemModel.Name .. " ItemPrompt in " .. containerContextName) then itemsLootedCount = itemsLootedCount + 1 else warn("          -- FAILED teleport loot for GOLD:", itemModel.Name) end end
                    else warn("        -- ERROR: Could not find ItemPrompt inside gold item:", itemModel.Name) end
                end
            end
        end -- End of findAndLootGold_Button function

        -- Phase 1: Check True State, Trigger if Needed, Identify Loot Locations - FOR BUTTON
        warn("\n--- Starting Button Phase 1: Checking True State & Identifying Loot Locations ---")
        local function processItemForOpening_Button(item)
            if not item or not item.Parent then return end
            local children = item:GetChildren()
            for _, child in ipairs(children) do
                if not child or not child.Parent then continue end
                local isKnownContainer = child:IsA("Model") and (child.Name:find("LockerVariant") or child.Name:find("CrowbarVariant") or child.Name == "Drawer" or child.Name:find("Table") or child.Name == "Rolltop" or child.Name == "ToolBox")

                if isKnownContainer then
                    overallContainerIndex = overallContainerIndex + 1
                    local containerModel = child; local modelIndex = overallContainerIndex
                    warn("-- [Open Phase] Processing Container:", containerModel.Name, "#", modelIndex)
                    local containerChildren = containerModel:GetChildren(); local lootPartsToAdd = {}

                    local function checkAndTrigger_Button(promptRef, innerModelRef, partForTrigger, context)
                        local promptOpenedAttr = promptRef and promptRef:GetAttribute("Opened"); local nameOK = innerModelRef and innerModelRef.Name == "OpenedSTORAGE"; local isTrulyOpen = (promptOpenedAttr == true and nameOK == true)
                        warn("      -- Check:", context, "Prompt Attr:", tostring(promptOpenedAttr), "Inner Name:", innerModelRef and innerModelRef.Name or "N/A", "Truly Open:", isTrulyOpen)
                        if not isTrulyOpen and promptRef then warn("        -- Marked for opening trigger."); triggerContainerPrompt_Reliable_Button(promptRef, partForTrigger, context .. " Trigger #" .. modelIndex) elseif not promptRef then warn("      -- WARNING: No prompt found for", context) end
                    end

                    local innerModels = {}
                    for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name == "Container" or cChild.Name == "OpenedSTORAGE") then table.insert(innerModels, cChild) end end
                    local innerModelRef = #innerModels > 0 and innerModels[1] or nil

                    -- Handle specific container types (using _Button functions)
                    if containerModel.Name == "Drawer" then
                        for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name:find("Container", 1, true) or cChild.Name == "OpenedSTORAGE") and cChild.Name ~= "Outside_Container" then local currentInnerModel = cChild; local mainDrawer = currentInnerModel:FindFirstChild("MainDrawer"); if mainDrawer then local prompt = mainDrawer:FindFirstChild("ProxAttach", true):FindFirstChild("ProximityPrompt"); checkAndTrigger_Button(prompt, currentInnerModel, mainDrawer, "Drawer." .. currentInnerModel.Name); table.insert(lootPartsToAdd, mainDrawer); else warn("    -- ERROR: No MainDrawer in", cChild:GetFullName()) end end end
                        local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer); end
                    elseif containerModel.Name:find("LockerVariant") or containerModel.Name:find("CrowbarVariant") then
                         local basePart = innerModelRef and innerModelRef:FindFirstChild("Base"); if basePart then table.insert(lootPartsToAdd, basePart) else warn("    -- WARNING: Could not find Base part for Locker.") end
                         if containerModel.Name:find("LLV2") or containerModel.Name:find("Variant2") then local doorBottom = containerModel:FindFirstChild("DoorBottom"); local promptB = doorBottom and doorBottom:FindFirstChild("DoorBottom", true):FindFirstChild("ProximityPrompt"); local doorTop = containerModel:FindFirstChild("DoorTop"); local promptT = doorTop and doorTop:FindFirstChild("DoorTop", true):FindFirstChild("ProximityPrompt"); checkAndTrigger_Button(promptB, innerModelRef, doorBottom, "LockerV2 Bottom Door"); checkAndTrigger_Button(promptT, innerModelRef, doorTop, "LockerV2 Top Door")
                         else local door = containerModel:FindFirstChild("Door"); local promptD = door and door:FindFirstChild("ProximityPrompt"); checkAndTrigger_Button(promptD, innerModelRef, door, "Locker Single Door") end
                    elseif containerModel.Name == "Rolltop" then
                         local mainDrawerRef = innerModelRef and innerModelRef:FindFirstChild("MainDrawer"); if mainDrawerRef then local pA = mainDrawerRef:FindFirstChild("ProxAttach"); local promptR = pA and pA:FindFirstChild("ProximityPrompt"); checkAndTrigger_Button(promptR, innerModelRef, mainDrawerRef, "Rolltop MainDrawer"); table.insert(lootPartsToAdd, mainDrawerRef) else warn("    -- WARNING: Could not find MainDrawer for Rolltop.") end
                         local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer) end
                    elseif containerModel.Name == "ToolBox" then
                         local toolBoxInnerModel = nil; for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name == "Container" or cChild.Name == "OpenedSTORAGE") then toolBoxInnerModel = cChild; break end end
                         if toolBoxInnerModel then local promptTB = containerModel:FindFirstChild("ProximityPrompt"); checkAndTrigger_Button(promptTB, toolBoxInnerModel, toolBoxInnerModel, "ToolBox"); local baseRef = toolBoxInnerModel:FindFirstChild("Base"); if baseRef then local spawnAreasRef = baseRef:FindFirstChild("SpawnAreas"); if spawnAreasRef then table.insert(lootPartsToAdd, spawnAreasRef) else warn("    -- WARNING: ToolBox Base found, but no SpawnAreas.") end else warn("    -- WARNING: ToolBox InnerContainer found, but no Base.") end else warn("    -- WARNING: Could not find InnerContainer for ToolBox.") end
                    elseif containerModel.Name:find("Table") then
                         local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer) else warn("    -- WARNING: No Outside_Container found for Table variant:", containerModel.Name) end
                    end

                    if #lootPartsToAdd > 0 then
                        for _, part in ipairs(lootPartsToAdd) do if part and part.Parent then table.insert(partsToLootAfterOpening, part) else warn("      -- Skipping invalid loot part.") end end
                    end

                elseif child.Name == "AddedAssets" and child:IsA("Folder") then processItemForOpening_Button(child)
                elseif lootSideRooms and child.Name == "SideRoom" and child:IsA("Model") then processItemForOpening_Button(child) -- Use the button's side room toggle
                end
                task.wait()
            end
        end

        processItemForOpening_Button(currentRoomModel)
        warn("--- Finished Button Phase 1 ---")
        warn("-- Phase 1 Summary: Identified", #partsToLootAfterOpening, "potential loot locations.")

        -- Intermediate Step: Global Wait - FOR BUTTON
        if lootWaitTime > 0 and #partsToLootAfterOpening > 0 then warn("\n--- Performing button global wait for", lootWaitTime, "seconds... ---"); task.wait(lootWaitTime)
        elseif #partsToLootAfterOpening == 0 then warn("\n--- No open containers identified for button looting. Skipping wait and Loot Phase. ---")
        else warn("\n--- Button loot wait time is 0. Proceeding directly to Loot Phase. ---") end

        -- Phase 2: Loot Gold from Identified Locations - FOR BUTTON
        if #partsToLootAfterOpening > 0 then
            warn("\n--- Starting Button Phase 2: Looting Gold ---"); local uniquePartsLooted = {}
            for i, part in ipairs(partsToLootAfterOpening) do
                if not (part and part.Parent) then warn("    -- Skipping part #", i, "as it no longer exists."); continue end
                if uniquePartsLooted[part] then continue end
                local contextName = part.Name; local parentModel = part:FindFirstAncestorWhichIsA("Model"); if parentModel then contextName = parentModel.Name .. " " .. contextName end
                findAndLootGold_Button(part, contextName .. " #" .. i); uniquePartsLooted[part] = true
            end
            warn("--- Finished Button Phase 2: Looting Gold ---")
        end

        -- Final Notification - FOR BUTTON
        warn("--- Button Auto Loot Gold Finished ---")
        Library:Notify("Button Auto Loot Gold Finished (v" .. AutoLootVersion .. "). Looted " .. itemsLootedCount .. " gold items.", 3)
        character:PivotTo(originalCFrame) -- Return player

    end,
    DoubleClick = false, Disabled = false, Visible = true,
})

LeftGroupBoxExploits:AddButton({
	Text = "+1 Revive (FE)",
	Func = function()
       pcall(function() if shared and shared.giveIt then shared.giveIt() else warn("Revive function not available.") end end)
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
    if #room_numbers == 0 then return nil end -- Handle no rooms found

    table.sort(room_numbers, function(a, b) return a > b end) -- Sort descending

    --[[
    If the player is IN Room 10, the highest number might be 11 (if it just generated).
    We usually want the door IN Room 10. So we might need the second highest number,
    or more reliably, use the ClientMain.CLIENT.Values.CurrentRoom.Value.
    This function might be less reliable than using the CurrentRoom value.
    Returning the model for the highest number found for now.
    ]]
    local latest_room_number = room_numbers[1]
    local latest_room_name = "Room" .. latest_room_number

    return rooms_folder:FindFirstChild(latest_room_name)
end

LeftGroupBoxExploits:AddButton({
	Text = "Open Current Room Door",
	Func = function()
        pcall(function()
            if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.CurrentRoom and ClientMain.CLIENT.Values.CurrentRoom.Value and ClientMain.CLIENT.Values.CurrentRoom.Value.Name:find("Room") then
                local Room = ClientMain.CLIENT.Values.CurrentRoom.Value
	            local Door = Room:FindFirstChild("Door") or Room:FindFirstChild("DoorNormal")
                local Hitbox = Door and Door:FindFirstChild("Hitbox")
                if Hitbox and Players.LocalPlayer.Character and Players.LocalPlayer.Character.HumanoidRootPart then
		            Hitbox.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    Hitbox.Size = Vector3.new(10,10,10) -- Make sure size is adequate
                    Library:Notify("Moved hitbox for " .. Room.Name, 1)
                    task.wait(0.1)
                    Hitbox.Size = Vector3.new(1,1,1) -- Reset size
	            else
                    Library:Notify("Could not find Door/Hitbox in " .. Room.Name, 2)
                end
            else
                Library:Notify("You are not in a room or room data unavailable!", 2)
            end
        end)
	end,

	Disabled = false,
	Visible = true,
})
LeftGroupBoxExploits:AddButton({
	Text = "Open Latest Room Door", -- This might open the door *after* the one you want
	Func = function()
        pcall(function()
            local Room = get_latest_room()
            if Room then
        	    local Door = Room:FindFirstChild("Door") or Room:FindFirstChild("DoorNormal")
                local Hitbox = Door and Door:FindFirstChild("Hitbox")
                if Hitbox and Players.LocalPlayer.Character and Players.LocalPlayer.Character.HumanoidRootPart then
		            Hitbox.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    Hitbox.Size = Vector3.new(10,10,10)
                    Library:Notify("Moved hitbox for latest room: " .. Room.Name, 1)
                    task.wait(0.1)
                    Hitbox.Size = Vector3.new(1,1,1)
	            else
                    Library:Notify("Could not find Door/Hitbox in latest room: " .. Room.Name, 2)
                end
            else
                 Library:Notify("Could not find the latest room.", 2)
            end
        end)
	end,

	Disabled = false,
	Visible = true,
})
LeftGroupBoxExploits:AddButton({
	Text = "Enable Observatory Lever",
	Func = function()
        pcall(function()
            if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.CurrentRoom and ClientMain.CLIENT.Values.CurrentRoom.Value and ClientMain.CLIENT.Values.CurrentRoom.Value.Name == "Room194" then
                local lever = ClientMain.CLIENT.Values.CurrentRoom.Value:FindFirstChild("CaveLever", true)
                if lever and lever:FindFirstChild("ProximityPrompt") then
                    lever.ProximityPrompt.Enabled = true
                    Library:Notify("Observatory lever enabled!", 1)
                else
                     Library:Notify("Could not find observatory lever/prompt!", 2)
                end
            else
                Library:Notify("You must be in the observatory (Room 194)!", 2)
            end
        end)
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
		if InfRev then pcall(function() if shared and shared.giveIt then shared.giveIt() end end) end
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
        pcall(function()
            if SIP and SIP.Character then
                local tool = SIP.Character:FindFirstChildWhichIsA("Tool")
                if tool then
		            expectingDrop = true
		            print("Requesting item drop from " .. SIP.Name)
		            RepStorage.Events.PlayerActions.DropItem:InvokeServer(tool) -- Use InvokeServer if it's a RemoteFunction
                    Library:Notify("Attempting to steal " .. tool.Name .. " from " .. SIP.Name, 1)
                else
                    Library:Notify(SIP.Name .. " is not holding an item.", 2)
                end
	        else
                Library:Notify("Select a valid player target first!", 2)
            end
        end)
	end,

	Disabled = false,
	Visible = true,
})
workspace:WaitForChild("DroppedItems").ChildAdded:Connect(function(item)
    pcall(function()
	    if not expectingDrop then return end
        if not item or not item.Parent then return end -- Check item validity
        local pickupPrompt = item:FindFirstChild("Pickup", true)
        if pickupPrompt and pickupPrompt:IsA("ProximityPrompt") then
            task.wait(0.3) -- Slightly longer wait
	        fireproximityprompt(pickupPrompt)
	        Library:Notify("Stole item: " .. item.Name, 3)
	        expectingDrop = false -- Reset flag
        else
            warn("Could not find pickup prompt for dropped item: " .. item.Name)
            task.wait(0.5) -- Wait a bit longer before resetting if prompt not found immediately
            expectingDrop = false -- Reset flag anyway
        end
    end)
end)


local AutoCage = true -- Default to true as requested
local DoConLoop = true -- Keep connections disabled by default if AutoCage is true

LeftGroupBoxExploits:AddToggle("AutoCage", {
	Text = "Auto Escape Watcher-cage",

	Default = AutoCage, -- Use variable
	Disabled = false, 
	Visible = true, -- Make visible as it's a useful feature

	Callback = function(Value)
        pcall(function()
            AutoCage = Value -- Update state variable
            DoConLoop = Value -- Link connection disabling to this toggle

            local connections = {}
            if RepStorage.Events:FindFirstChild("ThePrision") and RepStorage.Events.ThePrision:FindFirstChild("PlayerCaged") then
                 connections = getconnections(RepStorage.Events.ThePrision.PlayerCaged.OnClientEvent)
            end

            if Value then -- If AutoCage is ON, disable connections
                for _, Connection in ipairs(connections) do
                    Connection:Disable()
                end
                warn("Watcher cage event connections DISABLED.")
            else -- If AutoCage is OFF, enable connections
                for _, Connection in ipairs(connections) do
                    Connection:Enable()
                end
                 warn("Watcher cage event connections ENABLED.")
            end
        end)
	end,
})

-- Initial setup based on default AutoCage value
task.spawn(function()
    task.wait(2) -- Wait for events to potentially load
    pcall(function()
         local connections = {}
         if RepStorage.Events:FindFirstChild("ThePrision") and RepStorage.Events.ThePrision:FindFirstChild("PlayerCaged") then
              connections = getconnections(RepStorage.Events.ThePrision.PlayerCaged.OnClientEvent)
         end
         if AutoCage then -- If default is true
             for _, Connection in ipairs(connections) do Connection:Disable() end
             warn("Initial setup: Watcher cage event connections DISABLED.")
         else
             for _, Connection in ipairs(connections) do Connection:Enable() end
             warn("Initial setup: Watcher cage event connections ENABLED.")
         end
    end)
end)


--[[ This loop seems redundant now that the callback handles the connections
task.spawn(function()
    while task.wait(5) do -- Check periodically
        pcall(function()
            local connections = {}
            if RepStorage.Events:FindFirstChild("ThePrision") and RepStorage.Events.ThePrision:FindFirstChild("PlayerCaged") then
                 connections = getconnections(RepStorage.Events.ThePrision.PlayerCaged.OnClientEvent)
            end
            if DoConLoop then -- If AutoCage is ON
                for _, Connection in ipairs(connections) do if Connection.Enabled then Connection:Disable() end end
            else
                for _, Connection in ipairs(connections) do if not Connection.Enabled then Connection:Enable() end end
            end
        end)
    end
end)
]]

if RepStorage.Events:FindFirstChild("ThePrision") and RepStorage.Events.ThePrision:FindFirstChild("PlayerCaged") then
    RepStorage.Events.ThePrision.PlayerCaged.OnClientEvent:Connect(function()
        if not AutoCage then return end -- Only run if enabled
        pcall(function()
            Library:Notify("Watcher cage detected! Escaping...", 1)
            task.wait(4) -- Wait for minigame to potentially start
            RepStorage.Events.ThePrision.MinigameFinished:FireServer()
            Library:Notify("Fired MinigameFinished event.", 1)
        end)
    end)
else
    warn("Could not find Watcher cage events (ThePrision.PlayerCaged). AutoCage might not work.")
end

task.spawn(function()
    while task.wait(0.1) do -- Heal more frequently if needed
        if PartialGod then
            pcall(function()
                RepStorage.Events.EntityEvents.DamageFromClient:FireServer({
                    AttackedBy = "FoundationHub Heal", -- Unique name
                    IsSet = true, 
                    IgnoresHide = false, 
                    Damage = -math.huge -- Negative damage to heal
                })
            end)
        end
    end
end)
local RightGroupBoxAntiEntity = Tabs.Exploits:AddRightGroupbox("<b>Anti-Entity</b>") -- Renamed
local AntiEntity = {"Blacklight", "Screech", "Void", "Decoy", "Seek", "Watcher"} -- Added Watcher

for _, Entity in ipairs(AntiEntity) do -- Use ipairs
    AntiEntityInternal[Entity] = false
    RightGroupBoxAntiEntity:AddToggle("Anti" .. Entity, {
	    Text = "Anti-" .. Entity,

	    Default = false,
	    Disabled = false, 
	    Visible = true, 

	    Callback = function(Value)
           pcall(function()
                AntiEntityInternal[Entity] = Value -- Update internal state first

                if Entity == "Screech" then
                    if Value == false and ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.ScreechActive then
                        ClientMain.CLIENT.Values.ScreechActive.Value = false -- Attempt to reset screech state
                    end
                    -- Note: Forcing ScreechActive.Value = true might not prevent damage, only the visual/audio effect.
                elseif Entity == "Decoy" then
                    for _, Obj in workspace:GetDescendants() do
                        if Obj.Name == "AttackRange" and Obj.Parent and Obj.Parent.Name == "Decoy" then
                            Obj.CanTouch = not Value
                        end
                    end
                elseif Entity == "Seek" then
                    for _, Obj in workspace:GetDescendants() do
                        if Obj.Name == "Hitbox" and Obj.Parent and Obj.Parent.Name == "Seek" then
                            Obj.CanTouch = not Value
                        end
                    end
                elseif Entity == "Watcher" then
                     -- Handled in the WanderWatcher loop below
                     local wanderWatcher = workspace:FindFirstChild("WanderWatcher")
                     if wanderWatcher then
                          local pickupArea = wanderWatcher:FindFirstChild("PickupArea", true)
                          if pickupArea then pickupArea.CanTouch = not Value end
                     end
                end
		   end)
	    end,
    })
end



workspace.DescendantAdded:Connect(function(Obj)
    pcall(function()
        if not Obj or not Obj.Parent then return end
        local objName = Obj.Name
        local parentName = Obj.Parent.Name

        if objName == "AttackRange" and parentName == "Decoy" and AntiEntityInternal["Decoy"] then
            Obj.CanTouch = false
        end
        if objName == "Hitbox" and parentName == "Seek" and AntiEntityInternal["Seek"] then
            Obj.CanTouch = false
        end
        if objName == "WanderWatcher" then -- Handle newly added Watcher
             local pickupArea = Obj:FindFirstChild("PickupArea", true)
             if pickupArea then pickupArea.CanTouch = not AntiEntityInternal["Watcher"] end
        end
    end)
end)

task.spawn(function()
    while task.wait(0.5) do -- Check less frequently
        pcall(function()
            -- This might only affect visuals/audio, not prevent damage if player looks.
            if AntiEntityInternal["Screech"] and ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.ScreechActive then
                ClientMain.CLIENT.Values.ScreechActive.Value = true
            end
	        -- Anti-Watcher crouch spam (might be detected)
            -- if AntiEntityInternal["Watcher"] then
	        --    RepStorage:WaitForChild("Events"):WaitForChild("PlayerCrouching"):FireServer(true)
            -- end
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do -- Check less frequently
        pcall(function()
            local wanderWatcher = workspace:FindFirstChild("WanderWatcher")
            if wanderWatcher then
                local pickupArea = wanderWatcher:FindFirstChild("PickupArea", true)
                if pickupArea then
                    pickupArea.CanTouch = not AntiEntityInternal["Watcher"]
                end
            end
        end)
    end
end)

-- Hook Void function
pcall(function()
    local voidModule = require(ClientMain.CLIENT.CurrentRoomDependency.Modules.Void)
    local oldVoidPlayer = voidModule.VoidPlayer
    voidModule.VoidPlayer = function(...)
        if AntiEntityInternal["Void"] then
            warn("Anti-Void: Blocked VoidPlayer call")
            return -- Block the function call
        else
            return oldVoidPlayer(...) -- Call original function
        end
    end
    warn("Successfully hooked VoidPlayer function.")
end)


task.spawn(function()
    while task.wait(1) do -- Check less frequently
        pcall(function()
            if workspace.GameInfo:FindFirstChild("BlacklightDisabled") then
                 workspace.GameInfo.BlacklightDisabled.Value = AntiEntityInternal["Blacklight"]
            end
        end)
    end
end)

  
workspace.ChildAdded:Connect(function(Object)
    pcall(function()
        if not Object or not Object.Parent then return end
        local name = Object.Name
        if NotifyEntitiesInternal[name] then -- Check if notification is enabled for this entity name
            Library:Notify(name .. ' has spawned')
        end
    end)
end)

workspace.DescendantAdded:Connect(function(Object)
     pcall(function()
        if not Object or not Object.Parent then return end
        if Object.Name == 'ScreechAHHHH' and NotifyEntitiesInternal["Screech"] then
            Library:Notify('Screech has spawned')
        end
    end)
end)

if workspace.GameInfo:FindFirstChild("HoardbatsActive") then
    workspace.GameInfo.HoardbatsActive:GetPropertyChangedSignal("Value"):Connect(function()
        pcall(function()
            if workspace.GameInfo.HoardbatsActive.Value == true and NotifyEntitiesInternal["Hoardbats"] then
                Library:Notify('Hoardbats Swarm has spawned')
            end
        end)
    end)
else warn("Could not find GameInfo.HoardbatsActive") end

if workspace.GameInfo:FindFirstChild("LureActive") then
    workspace.GameInfo.LureActive:GetPropertyChangedSignal("Value"):Connect(function()
        pcall(function()
            if workspace.GameInfo.LureActive.Value == true and NotifyEntitiesInternal["Onslaught"]then
                Library:Notify('Onslaught has spawned')
            end
        end)
    end)
else warn("Could not find GameInfo.LureActive") end

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
	Default = true, -- Defaulting to true as it was before
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
        pcall(function()
		    Value = Value:gsub("%%", "")
		    local DPI = tonumber(Value) / 100 -- Convert percentage to scale factor
		    Library:SetDPIScale(DPI)
        end)
	end,
})
MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library:OnUnload(function()
    print("Unloading Foundation Hub...")
    -- Stop ongoing processes
    ARGoing = false
    if ARCon then ARCon:Disconnect(); ARCon = nil end
    NOFLY()
    Clip = true -- Disable noclip
    if Noclipping then Noclipping:Disconnect(); Noclipping = nil end

    -- Reset modified game states
    pcall(function()
        if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
             Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
             Players.LocalPlayer.Character:SetAttribute("AllowedToJump", true) -- Allow jumping on unload
        end
        Lighting.Brightness = 0; Lighting.GlobalShadows = true; Lighting.ClockTime = 4; Lighting.FogEnd = 500
        if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = 0.6 end
        if workspace.GameInfo:FindFirstChild("BlacklightDisabled") then workspace.GameInfo.BlacklightDisabled.Value = false end
        if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.ScreechActive then ClientMain.CLIENT.Values.ScreechActive.Value = false end
        -- Reset camera
        if ClientMain and ClientMain.Scripts and ClientMain.Scripts.cameraMain then ClientMain.Scripts.cameraMain.Enabled = true end
        Players.LocalPlayer.CameraMaxZoomDistance = 400; Players.LocalPlayer.CameraMinZoomDistance = 0.5
        -- Reset prompts
        InstaRact = false; PR = false
        local prompts = workspace:GetDescendants()
        for _, Prompt in ipairs(prompts) do
             if Prompt:IsA("ProximityPrompt") then
                 if Prompt:GetAttribute("OrigHold") ~= nil then Prompt.HoldDuration = Prompt:GetAttribute("OrigHold") end
                 if Prompt:GetAttribute("OrigLOSReq") ~= nil then Prompt.RequiresLineOfSight = Prompt:GetAttribute("OrigLOSReq") end
                 if Prompt:GetAttribute("OrigMAD") ~= nil then Prompt.MaxActivationDistance = Prompt:GetAttribute("OrigMAD") end
             end
        end
        -- Reset Anti-Triggers/Entities
        for triggerName, _ in pairs(AntiTriggerInternal) do AntiTriggerInternal[triggerName] = false end
        for entityName, _ in pairs(AntiEntityInternal) do AntiEntityInternal[entityName] = false end
        for _, object in workspace:GetDescendants() do processTrigger(object) end -- Re-enable triggers
        for _, Obj in workspace:GetDescendants() do -- Re-enable entity hitboxes
             if Obj.Name == "AttackRange" and Obj.Parent and Obj.Parent.Name == "Decoy" then Obj.CanTouch = true end
             if Obj.Name == "Hitbox" and Obj.Parent and Obj.Parent.Name == "Seek" then Obj.CanTouch = true end
             local wanderWatcher = workspace:FindFirstChild("WanderWatcher"); if wanderWatcher then local pa = wanderWatcher:FindFirstChild("PickupArea", true); if pa then pa.CanTouch = true end end
        end
        -- Move cutscenes back
        if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.CutsceneHandler and ClientMain.CLIENT.CutsceneHandler.Cutscenes then
             for _, scene in CutFolder:GetChildren() do scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes end
        end
        CutFolder:Destroy()
        -- Unhook functions
        -- Note: Unhooking requires storing the original function reference, which wasn't done for all hooks.
        -- Attempt to unhook VoidPlayer if possible (requires storing 'oldVoidPlayer' globally or upvalue)
        -- if oldVoidPlayer and typeof(oldVoidPlayer) == "function" and ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.CurrentRoomDependency and ClientMain.CLIENT.CurrentRoomDependency.Modules then
        --    pcall(function() require(ClientMain.CLIENT.CurrentRoomDependency.Modules.Void).VoidPlayer = oldVoidPlayer end)
        -- end
    end)
    shared.giveIt = nil -- Clear shared function
    -- Toggles["FP"]:SetValue(false) -- Resetting toggles might not be necessary if UI is destroyed

    -- Destroy ESP elements
    ESPLibrary:RemoveAll()
    table.clear(allTrackedESPs)
    table.clear(roomSpecESPs)

    print("Foundation Hub Unload Complete.")
end)


MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = Options.MenuKeybind, NoUI = true, Text = "Menu keybind" }) -- Use Options value


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
-- ESP Setup Section
-- =============================================================
local ESPLibrary = loadstring(game:HttpGet(
    'https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau'
))()
ESPLibrary.DefaultTracerSetting = ESPTracersEnabled -- Set default based on toggle


local colors = {
    Entity = Color3.fromRGB(255, 0, 0),
    Objectives = Color3.fromRGB(0, 255, 0),
    HidingSpots = BrickColor.new('Medium stone grey').Color, -- Changed color slightly
    Doors = Color3.fromRGB(0, 100, 255), -- Changed color slightly
    Coins = Color3.fromRGB(255, 215, 0), -- Gold color
    Containers = BrickColor.new('Brown').Color, -- Changed color
}

local function addESP(part, name, category)
    if not part or not part.Parent then return nil end -- Check validity
    if not espCategories[category] then return nil end -- Don't add if category is disabled

    local esp = ESPLibrary:Add({
        Name = name,
        PrimaryPart = part:IsA("BasePart") and part or part:FindFirstChildWhichIsA("BasePart"), -- Find a primary part if model
        Color = colors[category],
        MaxDistance = math.huge,
        TextSize = 17,
        ESPType = 'Highlight', -- Highlight looks better usually
        FillColor = colors[category],
        OutlineColor = colors[category],
        Tracer = {
            Enabled = ESPTracersEnabled, -- Use the toggle state
            Color = colors[category],
        },
        RenderInNil = false, -- Don't render if PrimaryPart is nil
    })
    esp:Update({Enabled = true}) -- Ensure it's enabled initially if category is true

    local data = { ESP = esp, Category = category }
    table.insert(allTrackedESPs, data)

    -- Return the data structure for potential later use
    return data
end

local roomSpecESPs = {} -- Store ESP data structures {ESP=esp, Category=category}

local function processRoom(room)
    if not room or not room:IsA("Model") then return end
    -- Clear previous ESPs for this specific room type if needed (or manage globally)

    for _, object in room:GetDescendants() do
        task.spawn(function() -- Use task.spawn for concurrency
            pcall(function() -- Wrap ESP logic in pcall
                if not object or not object.Parent then return end -- Check inside task too

                local name = object.Name
                local parent = object.Parent
                local category = nil
                local espName = nil
                local targetPart = object

                -- Hiding Spots & Decoys
                if name == 'Locker' or name == 'Toolshed_Hiding' then category = 'HidingSpots'; espName = 'Hiding Spot'
                elseif name == 'decoyLocker' then category = 'Entity'; espName = 'Decoy'

                -- Objectives
                elseif name == 'OilCanister' then category = 'Objectives'; espName = 'Oil Can'
                elseif name == 'GasCanister' then category = 'Objectives'; espName = 'Gas Canister'
                elseif name == 'GeneratorPuzzle' then category = 'Objectives'; espName = 'Generator'
                elseif name == 'Terminal' then category = 'Objectives'; espName = 'Terminal'
                elseif name == 'Switch' and not object:FindFirstAncestor('Switch') and not object:FindFirstAncestor('Flashlight') then category = 'Objectives'; espName = 'Fuse'
                elseif name == 'GivingCoins' then category = 'Coins'; espName = 'Coins'; targetPart = object.Parent -- ESP on the parent model
                elseif name == 'Container' and parent and not parent:HasTag("ContainerMarked") then
                    parent:AddTag("ContainerMarked")
                    category = 'Containers'; espName = 'Container'; targetPart = parent -- ESP on the parent model
                elseif name == 'Minigame' and object:FindFirstChild('Switches') then category = 'Objectives'; espName = 'Breaker Minigame'
                elseif name == 'ObservatoryKey' then category = 'Objectives'; espName = 'Key'
                elseif name == 'SignModel' then
                    local sign = object:FindFirstChild('Sign')
                    if sign then targetPart = sign; category = 'Objectives'; espName = 'Directional Sign'; sign.Material = Enum.Material.Neon; sign.Color = Color3.fromRGB(255, 255, 255) end
                elseif name == 'Control' and parent.Name == 'Elevator' and parent.Parent:FindFirstChild('ElevatorHandler') then
                    targetPart = object; category = 'Objectives'; espName = 'Exit Elevator'; local sign = object:FindFirstChild('Sign'); if sign then sign.Material = Enum.Material.Neon end
                elseif name == 'OxygenTank' then category = 'Objectives'; espName = 'Oxygen Can'
                elseif (name == 'CaveLever' or name == 'Lever') and not object:FindFirstAncestor('GeneratorPuzzle') and not object:FindFirstAncestor('EndPanel') and not object:FindFirstAncestor('GeneratorDeco') then
                    local order = object:GetAttribute('Order')
                    category = 'Objectives'; espName = 'Lever' .. (order and (' ' .. order) or '')
                
                -- Doors
                elseif (name == 'Door' and parent and parent.Parent and parent.Parent.Name == 'GeneratedRooms') or name == 'Chunk_Watcher' then
                    category = 'Doors'; espName = 'Door'
                end

                -- Add ESP if category determined
                if category and espName then
                    local espData = addESP(targetPart, espName, category)
                    if espData then table.insert(roomSpecESPs, espData) end -- Store the data structure
                end
            end)
        end)
    end
end

local function clearRoomSpecificESPs()
     for i = #roomSpecESPs, 1, -1 do
         local data = roomSpecESPs[i]
         if data.ESP then data.ESP:Remove() end -- Use ESP library's remove function
         table.remove(roomSpecESPs, i)
     end
     -- Also remove ContainerMarked tags
     for _, obj in workspace.GeneratedRooms:GetDescendants() do
         if obj:IsA("Model") and obj:HasTag("ContainerMarked") then
             obj:RemoveTag("ContainerMarked")
         end
     end
end

local function doProcVal(object)
    pcall(function()
        local foundRoom = object.Value
        if foundRoom and foundRoom:IsA("Model") then
            clearRoomSpecificESPs() -- Clear ESPs from the previous room
            processRoom(foundRoom) -- Process the new room
            updateESPVisibility() -- Ensure new ESPs match category toggles
        else
            clearRoomSpecificESPs() -- Clear if room value is nil or invalid
        end
    end)
end

local function processLocalPlayerDescendant(object)
    pcall(function()
        if object.Name == 'CurrentRoom' and object:IsA('ObjectValue') then
            print('Found CurrentRoom value object at ' .. object:GetFullName())
            task.delay(1, function() doProcVal(object) end) -- Initial processing
            
            object:GetPropertyChangedSignal('Value'):Connect(function() doProcVal(object) end) -- Connect to changes
        end
    end)
end

-- Find existing CurrentRoom value object
pcall(function()
    local currentRoomVal = LocalPlayer:FindFirstChild("CurrentRoom", true) -- Search recursively
    if currentRoomVal and currentRoomVal:IsA("ObjectValue") then
         processLocalPlayerDescendant(currentRoomVal)
    else
        -- If not found immediately, connect to DescendantAdded
        LocalPlayer.DescendantAdded:Connect(processLocalPlayerDescendant)
        warn("CurrentRoom value not found immediately, waiting for it to be added.")
    end
end)


local function processObject(object)
    if not object or not object.Parent then return end
    if object:FindFirstAncestor('Game Configuration') then return end

    pcall(function() -- Wrap in pcall
        local name = object.Name
        local parentName = object.Parent.Name
        local category = 'Entity' -- Default to Entity for these checks
        local espName = nil
        local targetPart = object

        if name == 'HoardbatClient' or name == "HoardBat" then espName = 'Hoardbat'
        elseif name == 'Eyes' and parentName ~= 'Bob' then espName = 'Eyes'
        elseif name == 'Stare' then espName = 'Stare'
        elseif name == 'Ram' then espName = 'Ram'
        elseif name == 'Ambush' then espName = 'Ambush'
        elseif name == 'Rush' then espName = 'Rush'
        elseif name == 'FigureRig' then espName = 'Figure'
        elseif name == 'WanderWatcher' then espName = 'Watcher'
        elseif name == 'Seek' then espName = 'Seek'
        end

        if espName then
            addESP(targetPart, espName, category)
            updateESPVisibility() -- Update visibility after adding
        end
    end)
end

-- Initial scan of workspace
task.spawn(function()
    for _, object in workspace:GetDescendants() do
        processObject(object)
        task.wait() -- Yield during initial scan
    end
    updateESPVisibility() -- Final visibility update after scan
end)

-- Connect to future additions
workspace.DescendantAdded:Connect(processObject)

-- Initial Load Notification
Library:Notify("Foundation Hub Loaded!", 5)
