--[[
    Script: Foundation Hub (Modified)
    Original Author: @wicked
    Modification Author: AI Assistant
    Date Modified: 2024-05-16
    Description: Enhanced version of the Foundation Hub script with combined Auto Rooms + Auto Loot functionality,
                 entity pausing, and preservation of original features.
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
			BG:Destroy()
			BV:Destroy()

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

	local humanoid = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
	end

	pcall(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
end
local allTrackedESPs = {}

local function updateESPVisibility()
    for _, data in pairs(allTrackedESPs) do
        local shouldBeVisible = espCategories[data.Category]
        if shouldBeVisible then
            data.ESP:Show()
        else
            data.ESP:Hide()
        end
    end
end


local IsCaged = false


for _, Item in getgc(false) do
    if typeof(Item) == "function" and getinfo(Item).name == "minigameComplete" then
    warn("Found")
    CageDone = Item
        old = hookfunction(Item, function(...)
            
            IsCaged = false
            old(...)
        end)
    end
end

local Options = Library.Options
Options.MenuKeybind = "P"
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
	old = hookfunction(Library.Toggle, function()
    stateLib = not stateLib
	Library.ScreenGui.Enabled = stateLib
    old()
end)
task.spawn(function()
	while wait() do
getrenv()._G.lockMouse = not stateLib
end
end)
end

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("<b>LocalPlayer</b>")
local WSLoopEnabled = false
local WSLoopVal = 16
LeftGroupBox:AddToggle("WSEnable", {
	Text = "Enable Walkspeed",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		WSLoopEnabled = Value
	end,
})

LeftGroupBox:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
    Callback = function(Value)
		IsFlying = Value
        if Value then
            NOFLY()
		    wait()
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
end

--[[LeftGroupBox:AddToggle("AI", {
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
           
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, prompt in workspace.GeneratedRooms:GetDescendants() do
                    if prompt:IsA("ProximityPrompt") and prompt:IsDescendantOf(workspace.GeneratedRooms) then
                        local prompt_pos = prompt.Parent:IsA("Model") and prompt.Parent:GetPivot().Position or prompt.Parent.Position
                        if not (prompt:FindFirstAncestor("Toolshed_Hiding") or
                                prompt:FindFirstAncestor("Locker") or
                                prompt:FindFirstAncestor("OpenedSTORAGE") or
                                (prompt.Parent.Parent and prompt.Parent.Parent:FindFirstChild("OpenedSTORAGE"))) and
                                (prompt_pos - hrp.Position).Magnitude < prompt.MaxActivationDistance then
                            fireproximityprompt(prompt)
                        end
                    end
                end
           

        end
    end
end)
local JumpTog =LeftGroupBox:AddToggle("Jump", {
	Text = "Allow Jumping",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		if Players.LocalPlayer.Character then
            Players.LocalPlayer.Character:SetAttribute("AllowedToJump", Value)
        end
	end,
})
local Noclipping
local Clip = true
local RunService = game:GetService("RunService")
LeftGroupBox:AddToggle("Noclip", {
	Text = "Noclip",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		if Value == false then
            if Noclipping then
		        Noclipping:Disconnect()
	        end
            for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
		    	if child:IsA("BasePart") and child.CanCollide == false and child.Name ~= "Head" then
		    		child.CanCollide = true
		    	end
		    end
	        Clip = true
        else
            Clip = false
	        wait(0.1)
	        local function NoclipLoop()
		        if Clip == false and Players.LocalPlayer.Character ~= nil then
		    	    for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
		    		    if child:IsA("BasePart") and child.CanCollide == true then
		    			    child.CanCollide = false
		    		    end
		    	    end
		        end
	        end
	        Noclipping = RunService.Stepped:Connect(NoclipLoop)
        end

       
	end,
})

LeftGroupBox:AddSlider("WSSlider", {
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

LeftGroupBox:AddSlider("FSpeed", {
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
    while wait() do
        if WSLoopEnabled and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            Players.LocalPlayer.Character.Humanoid.WalkSpeed = WSLoopVal
        end
        if IsFlying and not FPLoop then
            for _, Obj in Players.LocalPlayer.Character:GetDescendants() do
                if Obj.Name == "Handle" then
                    Obj.Transparency = 1
                    pcall(function()
                        Obj.LocalTransparencyModifier = 1
                    end)
                end
            end
        end
    end
end)


local RightGroupBox = Tabs.Main:AddRightGroupbox("<b>Quick Buttons</b>")
RightGroupBox:AddButton({
	Text = "Lobby",
	Func = function()
		RepStorage.Events.PlayerActions.LeaveToLobby:FireServer()
	end,
	DoubleClick = true,

	Disabled = false,
	Visible = true,
})
RightGroupBox:AddButton({
	Text = "Play Again",
	Func = function()
		RepStorage.Events.PlayerActions.PlayAgain:FireServer()
	end,
	DoubleClick = true,

	Disabled = false,
	Visible = true,
})
RightGroupBox:AddButton({
	Text = "Reset",
	Func = function()
		RepStorage.Events.EntityEvents.DamageFromClient:FireServer({
            AttackedBy = "Legit Hub", 
            IsSet = true, 
            IgnoresHide = false, 
            Damage = 0
        })
	end,
	DoubleClick = true,

	Disabled = false,
	Visible = true,
})

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("<b>Prompts</b>")
local InstaRact = false
LeftGroupBox:AddToggle("InstantInteract", {
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
                end
            end
        elseif Value == true then
            for _, Prompt in workspace:GetDescendants() do
                if Prompt:IsA("ProximityPrompt") then
                    Prompt:SetAttribute("OrigHold", Prompt.HoldDuration)
                    Prompt.HoldDuration = 0
                end
            end
        end
	end,
})

workspace.DescendantAdded:Connect(function(Prompt)
    if Prompt:GetAttribute("Open") ~= nil and Prompt.Name ~= "Door" then
        Prompt:GetAttributeChangedSignal("Open"):Once(function()
            Prompt.Name = "OpenedSTORAGE"
        end)
    end
    if Prompt:IsA("ProximityPrompt") and InstaRact then
        Prompt:SetAttribute("OrigHold", Prompt.HoldDuration)
        Prompt.HoldDuration = 0
    end
end)
local PM = 1
local PR = false
LeftGroupBox:AddToggle("PromptReach", {
	Text = "Prompt Reach",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		PR = Value
        if Value == false then
            for _, Prompt in workspace:GetDescendants() do
                if Prompt:IsA("ProximityPrompt") and Prompt:GetAttribute("OrigHold") ~= nil then
                    Prompt.RequiresLineOfSight = Prompt:GetAttribute("OrigLOSReq")
                    Prompt.MaxActivationDistance = Prompt:GetAttribute("OrigMAD")
                end
            end
        elseif Value == true then
            for _, Prompt in workspace:GetDescendants() do
                if Prompt:IsA("ProximityPrompt") then
                   Prompt:SetAttribute("OrigLOSReq", Prompt.RequiresLineOfSight)
                    Prompt:SetAttribute("OrigMAD", Prompt.MaxActivationDistance)
                    Prompt.RequiresLineOfSight = false
                    Prompt.MaxActivationDistance = Prompt.MaxActivationDistance * PM
                end
            end
        end
	end,
})
LeftGroupBox:AddSlider("PM", {
	Text = "Prompt Reach Multiplier",
	Default = PM,
	Min = 1,
	Max = 1.4,
	Rounding = 1,
	Compact = true,

	Callback = function(Value)
		PM = Value
        if PR then
             for _, Prompt in workspace:GetDescendants() do
                if Prompt:IsA("ProximityPrompt") then
                   Prompt:SetAttribute("OrigLOSReq", Prompt.RequiresLineOfSight)
                    Prompt:SetAttribute("OrigMAD", Prompt.MaxActivationDistance)
                    Prompt.RequiresLineOfSight = false
                    Prompt.MaxActivationDistance = Prompt.MaxActivationDistance * PM
                end
            end
        end
	end,

	Disabled = false, 
	Visible = true, 
})
workspace.DescendantAdded:Connect(function(Prompt)
    if Prompt:IsA("ProximityPrompt") and PR then
        Prompt:SetAttribute("OrigLOSReq", Prompt.RequiresLineOfSight)
        Prompt:SetAttribute("OrigMAD", Prompt.MaxActivationDistance)
        Prompt.RequiresLineOfSight = false
        Prompt.MaxActivationDistance = Prompt.MaxActivationDistance * PM
    end
end)

-- =============================================================
-- NEW: Auto Rooms + Auto Loot Section
-- =============================================================
local AutoRoomsGroupBox = Tabs.Main:AddLeftGroupbox("<b>Auto-Rooms</b>") -- Changed from RightGroupBox to LeftGroupBox for space
local ARTargetReach = 205
local CollectionService = game:GetService("CollectionService")
local Rooms = workspace.GeneratedRooms
local ARGoing = false -- For original Auto Rooms button
local isAutoRoomsAndLootActive = false -- For the new combined feature
local isARAL_LootingSideRooms = false -- Side room toggle for the new feature
local FiredPrompts = {}
local DoggedRooms = {}
local CutFolder = Instance.new("Folder")
local ARCon -- Connection for the Auto Rooms loop
local isCurrentlyLooting = false -- Flag to prevent loop overlap
local hostileEntities = {"Rush", "Ambush", "Ram"} -- Entities that pause the process

-- NEW: Function to check for hostile entities
local function areHostileEntitiesPresent()
    for _, entityName in ipairs(hostileEntities) do
        if workspace:FindFirstChild(entityName, true) then -- Recursive search
            -- Optional: Add distance check if needed
            -- local entityModel = workspace:FindFirstChild(entityName, true)
            -- local playerChar = Players.LocalPlayer.Character
            -- if entityModel and playerChar and entityModel:FindFirstChild("HumanoidRootPart") and playerChar:FindFirstChild("HumanoidRootPart") then
            --     if (entityModel.HumanoidRootPart.Position - playerChar.HumanoidRootPart.Position).Magnitude < 50 then -- Example distance
            --         return true
            --     end
            -- end
            return true -- Found one
        end
    end
    return false -- None found
end

-- NEW: Reusable Auto Loot Function
local function autoLootRoom(roomModel, lootSideRoomsFlag, useFastModeFlag)
    if not roomModel or not roomModel:IsA("Model") then
        warn("AutoLootRoom: Invalid room model provided.")
        return
    end
    
    isCurrentlyLooting = true -- Set looting flag
    local lootStartTime = tick()
    Library:Notify("AR+L: Looting " .. roomModel.Name, 1)
    warn("--- AutoLootRoom Started for:", roomModel.Name, "---")
    if useFastModeFlag then warn("--- Using Fast Gold Loot ---") end
    if lootSideRoomsFlag then warn("--- Attempting Side Room Loot ---") end

    local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then Library:Notify("AR+L: Player character not found.", 3); warn("ERROR: Player character not found."); isCurrentlyLooting = false; return end

    local goldItemNames = {"Coin", "CoinStack", "GoldBar", "GoldBarAndDiamonds"}
    local itemsLootedCount = 0
    local partsToLootAfterOpening = {}
    local overallContainerIndex = 0

    -- Function to pause if hostile entities are present
    local function pauseForEntities(context)
        local paused = false
        while areHostileEntitiesPresent() do
            if not paused then
                 warn("    -- HOSTILE ENTITY DETECTED! Pausing", context, "...")
                 Library:Notify("AR+L: Hostile entity detected! Pausing loot...", 2)
                 paused = true
            end
            task.wait(0.5) -- Check every half second
        end
        if paused then
            warn("    -- Hostile entity gone. Resuming", context, ".")
            Library:Notify("AR+L: Resuming loot...", 1)
        end
    end

    -- Function to try looting an item via teleport loop (STANDARD METHOD for gold)
    local function tryFirePromptForItem_Teleport(itemPromptRef, itemModel, itemContextName)
         pauseForEntities("Teleport Loot for " .. itemContextName)
         if not (itemModel and itemModel.Parent) then return true end
         local originalCFrame = character.HumanoidRootPart.CFrame; local looted = false; local attempts = 0; local maxLoopTime = 7; local startTime = tick(); local firstAttempt = true
         while itemModel and itemModel.Parent and (tick() - startTime < maxLoopTime) do pauseForEntities("Teleport Loot Loop for " .. itemContextName); if firstAttempt then task.wait(0.1); firstAttempt = false end; local currentItemPrompt = itemModel:FindFirstChild("ItemPrompt"); if currentItemPrompt and currentItemPrompt:IsA("ProximityPrompt") and currentItemPrompt.Enabled then local promptParent = currentItemPrompt.Parent; if not promptParent then break end; local targetCFrame; if promptParent:IsA("Model") then targetCFrame = promptParent:GetPivot() elseif promptParent:IsA("BasePart") then targetCFrame = promptParent.CFrame end; if targetCFrame then character:PivotTo(targetCFrame); task.wait(0.05); pauseForEntities("Firing Prompt (Teleport) for " .. itemContextName); local success, err = pcall(fireproximityprompt, currentItemPrompt); task.wait(0.07); if not itemModel or not itemModel.Parent then looted = true; break end end end; attempts = attempts + 1; task.wait(0.1) end
         character:PivotTo(originalCFrame); if not itemModel or not itemModel.Parent then looted = true else looted = false; warn("    -- WARNING: Item", itemContextName, "still exists after TP loot attempts.") end; return looted
    end

    -- Function to trigger a container prompt reliably (teleport and fire ONCE or TWICE)
    local function triggerContainerPrompt_Reliable(prompt, containerPart, promptContextName)
        pauseForEntities("Reliable Trigger for " .. promptContextName)
        warn("    -- Triggering Container Prompt Reliably:", promptContextName)
        if not (containerPart and containerPart.Parent) then warn("      -- ERROR: Invalid container part."); return end; if not (prompt and prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Enabled) then warn("      -- ERROR: Invalid or disabled prompt."); return end; local originalCFrame = character.HumanoidRootPart.CFrame; local promptParent = prompt.Parent; local targetCFrame; if promptParent:IsA("Model") then targetCFrame = promptParent:GetPivot() elseif promptParent:IsA("BasePart") then targetCFrame = promptParent.CFrame elseif promptParent:IsA("Attachment") then targetCFrame = promptParent.WorldCFrame end; if not targetCFrame then warn("      -- ERROR: Could not get target CFrame."); character:PivotTo(originalCFrame); return end
        character:PivotTo(targetCFrame); task.wait(0.07); pauseForEntities("Firing Prompt (Reliable 1) for " .. promptContextName); local success1, err1 = pcall(fireproximityprompt, prompt); task.wait(0.08); if prompt and prompt.Parent and prompt.Enabled then pauseForEntities("Firing Prompt (Reliable 2) for " .. promptContextName); pcall(fireproximityprompt, prompt); task.wait(0.05) end; character:PivotTo(originalCFrame); warn("      -- Finished reliable trigger attempt for:", promptContextName)
    end

    -- MODIFIED: Function to find and loot gold (Handles Table structure correctly)
    local function findAndLootGold(itemContainer, containerContextName)
        pauseForEntities("Searching Gold in " .. containerContextName)
        if not itemContainer then warn("    -- ERROR: itemContainer is nil. Aborting loot."); return end

        local itemParentToSearch = itemContainer; local spawnFolder = nil
        spawnFolder = itemContainer:FindFirstChild("ItemSpawns") or itemContainer:FindFirstChild("SpawnAreas")
        if not spawnFolder and itemContainer.Name == "Outside_Container" then local baseOutline = itemContainer:FindFirstChild("BaseOutline"); if baseOutline then spawnFolder = baseOutline:FindFirstChild("ItemSpawns") or baseOutline:FindFirstChild("SpawnAreas") end end
        if spawnFolder then itemParentToSearch = spawnFolder end
        if not itemParentToSearch or not itemParentToSearch.Parent then warn("    -- ERROR: Invalid itemParentToSearch:", itemParentToSearch and itemParentToSearch:GetFullName() or "nil"); return end

        local potentialItems = itemParentToSearch:GetChildren(); if #potentialItems == 0 then return end

        for i, item in ipairs(potentialItems) do
            local itemModel = item; if not (itemModel and itemModel.Parent) then continue end
            if table.find(goldItemNames, itemModel.Name) then
                local itemPrompt = itemModel:FindFirstChild("ItemPrompt")
                if itemPrompt then
                    local lootedThisItem = false
                    if useFastModeFlag then
                        local fastAttempts = 0; local maxFastAttempts = 3
                        while fastAttempts < maxFastAttempts do pauseForEntities("Fast Loot Attempt for " .. itemModel.Name); if not (itemModel and itemModel.Parent) then lootedThisItem = true; break end; if not (itemPrompt and itemPrompt.Parent and itemPrompt.Enabled) then warn("      -- Gold Prompt became invalid during fast loot attempt."); break end; pcall(fireproximityprompt, itemPrompt); task.wait(0.05); fastAttempts = fastAttempts + 1 end
                        if not (itemModel and itemModel.Parent) then itemsLootedCount = itemsLootedCount + 1; lootedThisItem = true else warn("          -- FAILURE: Gold still exists after brief direct fire. Falling back to teleport.") end
                    end
                    if not lootedThisItem then if tryFirePromptForItem_Teleport(itemPrompt, itemModel, itemModel.Name .. " ItemPrompt in " .. containerContextName) then itemsLootedCount = itemsLootedCount + 1 else warn("          -- FAILED teleport loot for GOLD:", itemModel.Name) end end
                else warn("        -- ERROR: Could not find ItemPrompt inside gold item:", itemModel.Name) end
            end
        end
    end -- End of findAndLootGold function

    -- Phase 1: Check True State, Trigger if Needed, Identify Loot Locations
    warn("\n--- Starting Phase 1: Checking True State & Identifying Loot Locations ---")
    local function processItemForOpening(item)
        pauseForEntities("Processing Item " .. (item and item.Name or "nil"))
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

                local function checkAndTrigger(promptRef, innerModelRef, partForTrigger, context)
                    pauseForEntities("Checking/Triggering " .. context)
                    local promptOpenedAttr = promptRef and promptRef:GetAttribute("Opened"); local nameOK = innerModelRef and innerModelRef.Name == "OpenedSTORAGE"; local isTrulyOpen = (promptOpenedAttr == true and nameOK == true)
                    warn("      -- Check:", context, "Prompt Attr:", tostring(promptOpenedAttr), "Inner Name:", innerModelRef and innerModelRef.Name or "N/A", "Truly Open:", isTrulyOpen)
                    if not isTrulyOpen and promptRef then warn("        -- Marked for opening trigger."); triggerContainerPrompt_Reliable(promptRef, partForTrigger, context .. " Trigger #" .. modelIndex) elseif not promptRef then warn("      -- WARNING: No prompt found for", context) end
                end

                local innerModels = {}; for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name == "Container" or cChild.Name == "OpenedSTORAGE") then table.insert(innerModels, cChild) end end
                local innerModelRef = #innerModels > 0 and innerModels[1] or nil

                if containerModel.Name == "Drawer" then
                    for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name:find("Container", 1, true) or cChild.Name == "OpenedSTORAGE") and cChild.Name ~= "Outside_Container" then local currentInnerModel = cChild; local mainDrawer = currentInnerModel:FindFirstChild("MainDrawer"); if mainDrawer then local prompt = mainDrawer:FindFirstChild("ProxAttach", true):FindFirstChild("ProximityPrompt"); checkAndTrigger(prompt, currentInnerModel, mainDrawer, "Drawer." .. currentInnerModel.Name); table.insert(lootPartsToAdd, mainDrawer); else warn("    -- ERROR: No MainDrawer in", cChild:GetFullName()) end end end
                    local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer); end
                elseif containerModel.Name:find("LockerVariant") or containerModel.Name:find("CrowbarVariant") then
                     local basePart = innerModelRef and innerModelRef:FindFirstChild("Base"); if basePart then table.insert(lootPartsToAdd, basePart) else warn("    -- WARNING: Could not find Base part for Locker.") end
                     if containerModel.Name:find("LLV2") or containerModel.Name:find("Variant2") then local doorBottom = containerModel:FindFirstChild("DoorBottom"); local promptB = doorBottom and doorBottom:FindFirstChild("DoorBottom", true):FindFirstChild("ProximityPrompt"); local doorTop = containerModel:FindFirstChild("DoorTop"); local promptT = doorTop and doorTop:FindFirstChild("DoorTop", true):FindFirstChild("ProximityPrompt"); checkAndTrigger(promptB, innerModelRef, doorBottom, "LockerV2 Bottom Door"); checkAndTrigger(promptT, innerModelRef, doorTop, "LockerV2 Top Door")
                     else local door = containerModel:FindFirstChild("Door"); local promptD = door and door:FindFirstChild("ProximityPrompt"); checkAndTrigger(promptD, innerModelRef, door, "Locker Single Door") end
                elseif containerModel.Name == "Rolltop" then
                     local mainDrawerRef = innerModelRef and innerModelRef:FindFirstChild("MainDrawer"); if mainDrawerRef then local pA = mainDrawerRef:FindFirstChild("ProxAttach"); local promptR = pA and pA:FindFirstChild("ProximityPrompt"); checkAndTrigger(promptR, innerModelRef, mainDrawerRef, "Rolltop MainDrawer"); table.insert(lootPartsToAdd, mainDrawerRef) else warn("    -- WARNING: Could not find MainDrawer for Rolltop.") end
                     local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer) end
                elseif containerModel.Name == "ToolBox" then
                     local spawnAreasRef = nil; local toolBoxInnerModel = nil; for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name == "Container" or cChild.Name == "OpenedSTORAGE") then toolBoxInnerModel = cChild; break end end
                     if toolBoxInnerModel then local promptTB = containerModel:FindFirstChild("ProximityPrompt"); checkAndTrigger(promptTB, toolBoxInnerModel, toolBoxInnerModel, "ToolBox"); local baseRef = toolBoxInnerModel:FindFirstChild("Base"); if baseRef then spawnAreasRef = baseRef:FindFirstChild("SpawnAreas"); if spawnAreasRef then table.insert(lootPartsToAdd, spawnAreasRef) else warn("    -- WARNING: ToolBox Base found, but no SpawnAreas.") end else warn("    -- WARNING: ToolBox InnerContainer found, but no Base.") end else warn("    -- WARNING: Could not find InnerContainer for ToolBox.") end
                elseif containerModel.Name:find("Table") then
                     warn("  -- Handling Table Variant:", containerModel.Name); local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then warn("    -- Found Outside_Container. Adding to loot list."); table.insert(lootPartsToAdd, outsideContainer) else warn("    -- WARNING: No Outside_Container found for Table variant:", containerModel.Name) end
                end

                if #lootPartsToAdd > 0 then for _, part in ipairs(lootPartsToAdd) do if part and part.Parent then table.insert(partsToLootAfterOpening, part) else warn("      -- Skipping invalid loot part.") end end end

            elseif child.Name == "AddedAssets" and child:IsA("Folder") then processItemForOpening(child)
            elseif lootSideRoomsFlag and child.Name == "SideRoom" and child:IsA("Model") then processItemForOpening(child) -- Use the flag here
            end
            task.wait()
        end
    end

    warn("--- Starting Phase 1 Recursive Processing ---"); processItemForOpening(roomModel); warn("--- Finished Phase 1 Recursive Processing ---")
    warn("-- Phase 1 Summary: Identified", #partsToLootAfterOpening, "potential loot locations.")

    -- Intermediate Step: Global Wait (With entity check)
    local waitTime = 0.1 -- Minimal wait after opening, can be adjusted
    if waitTime > 0 and #partsToLootAfterOpening > 0 then warn("\n--- Performing short wait (", waitTime, "s) with entity check... ---"); pauseForEntities("Post-Open Wait"); task.wait(waitTime)
    elseif #partsToLootAfterOpening == 0 then warn("\n--- No open containers identified for looting. Skipping Loot Phase. ---")
    else warn("\n--- Proceeding directly to Loot Phase. ---") end

    -- Phase 2: Loot Gold from Identified Locations
    if #partsToLootAfterOpening > 0 then
        warn("\n--- Starting Phase 2: Looting Gold ---"); local uniquePartsLooted = {}
        for i, part in ipairs(partsToLootAfterOpening) do
            pauseForEntities("Looting Part #" .. i)
            if not (part and part.Parent) then warn("    -- Skipping part #", i, "as it no longer exists."); continue end
            if uniquePartsLooted[part] then continue end
            local contextName = part.Name; local parentModel = part:FindFirstAncestorWhichIsA("Model"); if parentModel then contextName = parentModel.Name .. " " .. contextName end
            findAndLootGold(part, contextName .. " #" .. i); uniquePartsLooted[part] = true
        end
        warn("--- Finished Phase 2: Looting Gold ---")
    end

    -- Final Notification
    local duration = tick() - lootStartTime
    warn("--- AutoLootRoom Finished for", roomModel.Name, "in", string.format("%.2f", duration), "seconds ---")
    Library:Notify("AR+L: Finished looting " .. roomModel.Name .. ". Looted " .. itemsLootedCount .. " gold items.", 3)
    isCurrentlyLooting = false -- Clear looting flag
end
-- =============================================================

AutoRoomsGroupBox:AddSlider("ARRoomReach", {
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

-- Original Auto Rooms Button
AutoRoomsGroupBox:AddButton({
	Text = "Start/Stop Auto Rooms ONLY",
	Func = function()
        ARGoing = not ARGoing
        isAutoRoomsAndLootActive = false -- Ensure combined mode is off
        if ARGoing then
            Library:Notify("Auto Rooms ONLY started")
            -- Start the loop (or ensure it runs if already created)
            if not ARCon or not ARCon.Connected then
                warn("Starting new ARCon for Auto Rooms ONLY")
                ARCon = RunService.Stepped:Connect(AutoRoomsLoop)
            end
            for _, scene in ClientMain.CLIENT.CutsceneHandler.Cutscenes:GetChildren() do
                scene.Parent = CutFolder
            end
        else
            Library:Notify("Auto Rooms ONLY stopped")
            -- Stop the loop only if combined mode is also off
            if not isAutoRoomsAndLootActive and ARCon and ARCon.Connected then
                 warn("Disconnecting ARCon from Auto Rooms ONLY button")
                 ARCon:Disconnect()
                 ARCon = nil
            end
            FiredPrompts = {}
            DoggedRooms = {}
            for _, scene in CutFolder:GetChildren() do
                scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes
            end
            RepStorage.Events.VoidEvent:FireServer()
        end
	end,

	Disabled = false,
	Visible = true,
})

-- NEW: Combined Auto Rooms + Auto Loot Toggle
AutoRoomsGroupBox:AddToggle("AutoRoomsAndLoot", {
    Text = "Enable Auto Rooms + Auto Loot",
    Default = false,
    Callback = function(Value)
        isAutoRoomsAndLootActive = Value
        ARGoing = false -- Ensure original mode is off
        if isAutoRoomsAndLootActive then
            Library:Notify("Auto Rooms + Auto Loot ENABLED")
            -- Start the loop (or ensure it runs if already created)
             if not ARCon or not ARCon.Connected then
                 warn("Starting new ARCon for Auto Rooms + Loot")
                 ARCon = RunService.Stepped:Connect(AutoRoomsLoop)
             end
            for _, scene in ClientMain.CLIENT.CutsceneHandler.Cutscenes:GetChildren() do
                scene.Parent = CutFolder
            end
        else
            Library:Notify("Auto Rooms + Auto Loot DISABLED")
            -- Stop the loop only if original mode is also off
            if not ARGoing and ARCon and ARCon.Connected then
                 warn("Disconnecting ARCon from Auto Rooms + Loot toggle")
                 ARCon:Disconnect()
                 ARCon = nil
            end
            FiredPrompts = {}
            DoggedRooms = {}
            for _, scene in CutFolder:GetChildren() do
                scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes
            end
            RepStorage.Events.VoidEvent:FireServer()
        end
    end
})

-- NEW: Side Room Toggle for Combined Feature
AutoRoomsGroupBox:AddToggle("ARAL_LootSideRooms", {
    Text = "Loot Side Rooms (AR+L Mode)",
    Default = false,
    Callback = function(Value)
        isARAL_LootingSideRooms = Value
    end,
    Disabled = false,
    Visible = true, -- Initially visible, might hide/show based on main toggle later if needed
})


AutoRoomsGroupBox:AddDropdown("RMUnify", {
	Values = { "Current Room", "Special Room"},
	Default = 1, 
	Multi = false, 

	Text = "Notifications",

	Searchable = false, 

	Disabled = false, 
	Visible = true, 
})

-- Combined Auto Rooms Loop Function
function AutoRoomsLoop()
    -- Pause if hostile entities are present AND combined mode is active
    local pausedForEntity = false
    while (ARGoing or isAutoRoomsAndLootActive) and areHostileEntitiesPresent() do
        if not pausedForEntity then
             Library:Notify("Hostile entity detected! Pausing Auto Rooms...", 2)
             warn("--- HOSTILE ENTITY DETECTED! Pausing Auto Rooms Loop ---")
             pausedForEntity = true
        end
        task.wait(0.5) -- Check frequently
    end
     if pausedForEntity then
         Library:Notify("Resuming Auto Rooms...", 1)
         warn("--- Hostile entity gone. Resuming Auto Rooms Loop ---")
     end

    -- Pause if currently looting in combined mode
    local pausedForLoot = false
    while isAutoRoomsAndLootActive and isCurrentlyLooting do
         if not pausedForLoot then
             warn("--- Waiting for AutoLootRoom to finish ---")
             pausedForLoot = true
         end
        task.wait(0.1) -- Wait for loot to finish
    end
     if pausedForLoot then
         warn("--- AutoLootRoom finished. Resuming Auto Rooms Loop ---")
     end

    -- Check if the process should continue
    if not ARGoing and not isAutoRoomsAndLootActive then
        if ARCon and ARCon.Connected then
            warn("ARCon: Both modes off, disconnecting.")
            ARCon:Disconnect()
            ARCon = nil
        end
        return
    end

    local Character = Players.LocalPlayer.Character
    if not Character then return end -- Need character

    local RoomNumbers = {}
    for _, Room in Rooms:GetChildren() do
        if Room:IsA("Model") and Room.Name:match("Room(%d+)") then
            CollectionService:RemoveTag(Room, "DarkRoom")
            local Number = tonumber(Room.Name:match("Room(%d+)"))
            if Number then table.insert(RoomNumbers, Number) end
        end
    end
    if #RoomNumbers == 0 then return end -- No rooms found yet

    table.sort(RoomNumbers) -- Sort ascending
    local LastRoomNumber = RoomNumbers[#RoomNumbers] -- Highest number is the latest room generated

    -- Check if target reached
    if LastRoomNumber >= ARTargetReach then
        Library:Notify("Target room " .. ARTargetReach .. " reached. Stopping.", 3)
        FiredPrompts = {}
        DoggedRooms = {}
        if ARCon and ARCon.Connected then ARCon:Disconnect(); ARCon = nil end
        ARGoing = false
        isAutoRoomsAndLootActive = false
        -- Manually update toggles if needed (optional)
        -- Toggles.AutoRoomsAndLoot:SetValue(false) 
        for _, scene in CutFolder:GetChildren() do scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes end
        task.wait(0.5)
        RepStorage.Events.VoidEvent:FireServer()
        return
    end

    local currentRoomName = "Room" .. tostring(LastRoomNumber)
    local currentRoom = Rooms:FindFirstChild(currentRoomName)
    local nextRoomName = "Room" .. tostring(LastRoomNumber + 1)
    local nextRoom = Rooms:FindFirstChild(nextRoomName)

    if not currentRoom then return end -- Current room doesn't exist?

    -- Notify about room progression
    if not table.find(DoggedRooms, currentRoom) then
        table.insert(DoggedRooms, currentRoom)
        local notifyMode = Options.RMUnify.Value
        if notifyMode == "Current Room" then
            Library:Notify("Auto Rooms: Reached " .. currentRoom.Name)
        elseif notifyMode == "Special Room" and currentRoom:GetAttribute("Chance") == 0 then
            Library:Notify("Auto Rooms: Special room '" .. currentRoom:GetAttribute("RawName") .. "' reached")
        end
    end

    -- Handle special rooms like 195
    if currentRoom.Name == "Room195" then
        RepStorage.Events.TheObservatory.BeatPuzzle:FireServer()
    end

    -- Find door/trigger elements in the *current* room
    local Door = currentRoom:FindFirstChild("Door") or currentRoom:FindFirstChild("DoorNormal")
    local Scriptable = currentRoom:FindFirstChild("Scriptable")
    local Hitbox = (Door and Door:FindFirstChild("Hitbox")) or (Scriptable and Scriptable:FindFirstChild("Trigger"))
    local Lever = currentRoom:FindFirstChild("CaveLever")
    local Prompt = Lever and Lever:FindFirstChild("ProximityPrompt")
    -- Elevator logic might need adjustment if it's part of the main path
    -- local Elevator = Scriptable and Scriptable:FindFirstChild("Elevator")
    -- local ElevatorControl = Elevator and Elevator:FindFirstChild("Control")
    -- local ElevatorPrompt = ElevatorControl and ElevatorControl.Button.ProximityPrompt

    -- Handle Levers first if present
    if Prompt and Prompt.Enabled and not FiredPrompts[Prompt] then
        warn("ARCon: Firing Lever Prompt in", currentRoom.Name)
        Character:PivotTo(Lever:GetPivot())
        fireproximityprompt(Prompt)
        FiredPrompts[Prompt] = true
        task.wait(0.2) -- Give lever time
        return -- Re-run loop to check state after lever
    end

    -- If the next room already exists, and we are in combined mode, loot it
    if nextRoom and isAutoRoomsAndLootActive and not table.find(DoggedRooms, nextRoom) then
         warn("ARCon: Next room", nextRoom.Name, "already exists. Triggering loot.")
         table.insert(DoggedRooms, nextRoom) -- Mark as processed for looting
         autoLootRoom(nextRoom, isARAL_LootingSideRooms, true) -- Loot with fast mode forced
         -- Loop will continue after loot finishes (due to isCurrentlyLooting check)
         return -- Let loop re-evaluate after looting
    end

    -- If there's a door hitbox and the next room *doesn't* exist yet, trigger the door
    if Hitbox and not nextRoom then
        warn("ARCon: Triggering Door Hitbox in", currentRoom.Name, "to generate", nextRoomName)
        local targetCFrame = currentRoom:GetPivot() * CFrame.new(0, 5, 15) -- Position near the expected door location
        Character:PivotTo(targetCFrame)
        task.wait(0.1)
        Hitbox.CFrame = targetCFrame -- Move hitbox to player to trigger
        Hitbox.Size = Vector3.new(10, 10, 10) -- Keep size reasonable
        task.wait(0.3) -- Wait a bit for the trigger potentially
        -- Don't reset size immediately, let the game handle it or reset later if needed
    end
end


-- =============================================================
-- Visuals Tab
-- =============================================================
local LeftGroupBoxVisuals = Tabs.Visuals:AddLeftGroupbox("<b>General</b>")
LeftGroupBoxVisuals:AddToggle("Fullbright", {
	Text = "Fullbright",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		if Value == true then
            Lighting.Brightness = 3
            Lighting.GlobalShadows = false
        elseif Value == false then
            Lighting.Brightness = 0
            Lighting.GlobalShadows = true
        end
	end,
})
local noFog = false
LeftGroupBoxVisuals:AddToggle("NoFog", {
	Text = "No-Fog",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
		if Value == true then
		noFog = true
            Lighting.Atmosphere.Density = 0
        elseif Value == false then
		noFog = false
            Lighting.Atmosphere.Density = 0.6
        end
	end,
})

task.spawn(function()
	while wait() do
		if noFog then
			 Lighting.Atmosphere.Density = 0
		else
			 Lighting.Atmosphere.Density = 0.6
		end
	end
end)

LeftGroupBoxVisuals:AddToggle("FP", {
	Text = "Third Person",

	Default = false,
	Disabled = false, 
	Visible = true, 

	Callback = function(Value)
        FPLoop = Value
		if Value == true then
            if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                ClientMain.Scripts.cameraMain.Enabled = false
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                Players.LocalPlayer.Character.Humanoid.AutoRotate = true
                Players.LocalPlayer.CameraMaxZoomDistance = 10
                Players.LocalPlayer.CameraMinZoomDistance = 10
            end
        elseif Value == false then
            if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                ClientMain.Scripts.cameraMain.Enabled = true
            end
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
    while wait() do
        if FPLoop and Players.LocalPlayer.Character then
            Players.LocalPlayer.Character.Head.Transparency = 0
            Players.LocalPlayer.Character.Head.LocalTransparencyModifier = 0
            for _, Obj in Players.LocalPlayer.Character:GetDescendants() do
                if Obj.Name == "face" or Obj.Name == "Handle" then
                    Obj.Transparency = 0
                    pcall(function()
                        Obj.LocalTransparencyModifier = 0
                    end)
                end
            end
        end
    end
end)
local NotifyEntities = {"Rush", "Screech", "Ram", "Ambush", "Hoardbats", "Eyes", "Stare", "Onslaught"}
local NotifyEntitiesInternal = {}
local RightGroupBoxVisuals = Tabs.Visuals:AddRightGroupbox("<b>Notifications</b>")
for _, Entity in NotifyEntities do
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


-- =============================================================
-- Exploits Tab
-- =============================================================
local LeftGroupBoxExploits = Tabs.Exploits:AddLeftGroupbox("<b>Exploits</b>") -- Renamed variable for clarity

-- Anti-Trigger Section (Moved to Right Groupbox for better layout)
local RightGroupBoxExploits_AntiTrigger = Tabs.Exploits:AddRightGroupbox("<b>Anti-Trigger</b>")
local AntiTrigger = {"Seek-Chase-Start", "Seek-Chase-Planks-Fall", "Seek-Chase-Obstruction", "Seek-Chase-Boat-Start", "Death-Trigger", "Seek-Last-Room-Start","Prison-Start", "Watcher-Chase-Start","Observatory-Door"}
local AntiTriggerInternal = {}

local function processTrigger(trigger)
    if not trigger or not trigger.Parent then return end -- Basic check
    
    local triggerName = trigger.Name
    local parentName = trigger.Parent.Name

    if triggerName == "Trigger" and trigger:FindFirstChild("Chase") then
        trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Start"]
    elseif triggerName == "Hitbox" and trigger.Parent:FindFirstChild("Planks") then
        trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Planks-Fall"]
    elseif triggerName == "EndSequenceHitbox" then
        trigger.CanTouch = not AntiTriggerInternal["Seek-Last-Room-Start"]
    elseif triggerName == "DeathPit" then
        trigger.CanTouch = not AntiTriggerInternal["Death-Trigger"]
    elseif triggerName == "Hitbox" and trigger.Parent:FindFirstChild("AnimatedShelf") then
        trigger.CanTouch = not AntiTriggerInternal["Watcher-Chase-Start"]
    elseif triggerName == "DoorTrigger" and trigger.Parent:FindFirstChild("BigDoor") then
        trigger.CanTouch = not AntiTriggerInternal["Observatory-Door"]
    elseif triggerName == "StartCutscene" and trigger.Parent:FindFirstChild("PivotWatcherCutscene") and trigger.Parent:FindFirstChild("GuidingLight") then
        trigger.CanTouch = not AntiTriggerInternal["Prison-Start"]
    elseif triggerName == "Cube" and parentName == "Piper" then
        trigger.CanTouch = not AntiTriggerInternal["Death-Trigger"]
    elseif triggerName == "Trigger" and trigger.Parent:FindFirstChild("ObstructionHolder") then
        trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Obstruction"]
    elseif triggerName == "Trigger" and trigger.Parent:FindFirstChild("2ndPivot") and trigger.Parent:FindFirstChild("Cutscene") then
        trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Boat-Start"]
    end
end

for _, Trigger in AntiTrigger do
    AntiTriggerInternal[Trigger] = false
    RightGroupBoxExploits_AntiTrigger:AddToggle("Anti" .. Trigger, {
	    Text = "Anti-" .. Trigger,
	    Default = false,
	    Disabled = false, 
	    Visible = true, 
	    Callback = function(Value)
		   AntiTriggerInternal[Trigger] = Value
           -- Re-process existing triggers when toggled
           task.spawn(function()
               for _, object in workspace:GetDescendants() do
                    if object:IsA("BasePart") then -- Only process parts that can be touched
                        processTrigger(object)
                    end
               end
           end)
	    end,
    })
end

workspace.DescendantAdded:Connect(function(object)
    if object:IsA("BasePart") then -- Only process parts that can be touched
        processTrigger(object)
    end
end)


-- ESP Section (Moved back to Visuals Tab)
local LeftGroupBoxVisuals_ESP = Tabs.Visuals:AddLeftGroupbox("<b>ESP</b>")
local ESPTracersEnabled: boolean = true
LeftGroupBoxVisuals_ESP:AddToggle("ESPTracers", {
	Text = "Tracers",

	Default = true,
	Disabled = false, 
	Visible = false, -- Keep hidden as per original script?

	Callback = function(Value)
		ESPTracersEnabled = Value
        -- Add logic here to update existing ESP tracers if library supports it
	end,
})
local ESPThings = {"Entity", "Objectives", "Doors", "HidingSpots", "Coins", "Containers"}
for _, Thing in ESPThings do
    LeftGroupBoxVisuals_ESP:AddToggle("ESP" .. Thing, {
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

-- Back to Exploits Tab - Left Groupbox
LeftGroupBoxExploits:AddButton({
	Text = "Skip Watcher 150",
	Func = function()
        if ClientMain and ClientMain.CLIENT.Values.CurrentRoom.Value and ClientMain.CLIENT.Values.CurrentRoom.Value.Name == "Room150" then
            RepStorage.Events.ThePrision.FinishedTerminal:FireServer()
        else
            Library:Notify("You must be in room 150!")
        end
	end,

	Disabled = false,
	Visible = true,
})

-- Define variables for the ORIGINAL Auto Loot Gold controls first
local originalLootWaitTime = 0.1 -- Default wait time for original button
local originalUseFastMode = false -- Default: Fast mode is disabled for original button
local originalLootSideRooms = false -- Default: Side rooms disabled for original button

-- Add the controls to the UI GroupBox for the ORIGINAL Auto Loot Gold
LeftGroupBoxExploits:AddToggle("OriginalLootSideRooms", {
    Text = "Attempt Loot Side Rooms (Manual)",
    Default = originalLootSideRooms,
    Callback = function(Value)
        originalLootSideRooms = Value
        print("-- DEBUG: Original Loot Side Rooms set to:", originalLootSideRooms)
    end,
    Disabled = false,
    Visible = true,
})

LeftGroupBoxExploits:AddToggle("OriginalUseFastModeToggle", {
    Text = "Use Fast Gold Loot (Manual - Risky)",
    Default = originalUseFastMode,
    Callback = function(Value)
        originalUseFastMode = Value
        print("-- DEBUG: Original Fast Gold Loot set to:", originalUseFastMode)
    end,
    Disabled = false,
    Visible = true,
})

LeftGroupBoxExploits:AddSlider("OriginalLootWaitSlider", {
    Text = "Loot Wait Time (Manual, s)",
    Default = originalLootWaitTime,
    Min = 0,
    Max = 1,
    Rounding = 1, -- 1 decimal place (0.1 increments)
    Compact = true,
    Callback = function(Value)
        originalLootWaitTime = Value -- Update the variable when slider changes
        print("-- DEBUG: Original Loot Wait Time set to:", originalLootWaitTime)
    end,
    Disabled = false,
    Visible = true,
})

local AutoLootVersion = "2.19-ARAL_Integration" -- Updated version number
LeftGroupBoxExploits:AddButton({
    Text = "Auto Loot Gold (Current Room - Manual)",
    Func = function()
        Library:Notify("Manual Auto Loot Gold Started (v" .. AutoLootVersion .. ")", 1)
        
        local player = Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then Library:Notify("Player character not found.", 3); return end
        if not ClientMain or not ClientMain.CLIENT or not ClientMain.CLIENT.Values or not ClientMain.CLIENT.Values.CurrentRoom or not ClientMain.CLIENT.Values.CurrentRoom.Value then Library:Notify("Cannot determine current room.", 3); return end
        local currentRoomModel = ClientMain.CLIENT.Values.CurrentRoom.Value
        if not currentRoomModel or not currentRoomModel:IsA("Model") then Library:Notify("Current room data is invalid.", 3); return end

        -- Call the reusable loot function with the ORIGINAL toggle values
        autoLootRoom(currentRoomModel, originalLootSideRooms, originalUseFastMode) 
        -- Note: The original wait slider isn't directly used by autoLootRoom anymore, 
        -- but the internal wait logic exists. We could pass originalLootWaitTime if needed.
    end,
    DoubleClick = false, Disabled = false, Visible = true,
})

LeftGroupBoxExploits:AddButton({
	Text = "+1 Revive (FE)",
	Func = function()
       if shared and shared.giveIt then
           shared.giveIt()
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

    table.sort(room_numbers, function(a, b) return a > b end) -- Sort descending to get highest first

    -- If only one room (e.g., Room1), there's no "latest" door to open yet in the sense of progression.
    -- The logic usually targets the door *in* the latest room to get to the *next* one.
    -- Let's return the model of the highest numbered room found.
    if #room_numbers > 0 then
        local latest_room_number = room_numbers[1]
        local latest_room_name = "Room" .. latest_room_number
        return rooms_folder:FindFirstChild(latest_room_name)
    end

    return nil
end

LeftGroupBoxExploits:AddButton({
	Text = "Open Current Room Door",
	Func = function()
        if ClientMain and ClientMain.CLIENT.Values.CurrentRoom.Value and ClientMain.CLIENT.Values.CurrentRoom.Value.Name:find("Room") then
            local Room = ClientMain.CLIENT.Values.CurrentRoom.Value
            local Door = Room:FindFirstChild("Door") or Room:FindFirstChild("DoorNormal")
            local Hitbox = Door and Door:FindFirstChild("Hitbox")
            local PlayerChar = Players.LocalPlayer.Character
            if Hitbox and PlayerChar and PlayerChar:FindFirstChild("HumanoidRootPart") then
                Hitbox.CFrame = PlayerChar.HumanoidRootPart.CFrame
                Library:Notify("Attempted to open door for " .. Room.Name, 1)
            else
                 Library:Notify("Could not find door hitbox or player.", 2)
            end
        else
            Library:Notify("You are not in a room!", 2)
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
            local PlayerChar = Players.LocalPlayer.Character
            if Hitbox and PlayerChar and PlayerChar:FindFirstChild("HumanoidRootPart") then
                Hitbox.CFrame = PlayerChar.HumanoidRootPart.CFrame
                 Library:Notify("Attempted to open door for " .. Room.Name, 1)
            else
                 Library:Notify("Could not find door hitbox or player for " .. Room.Name, 2)
            end
        else
             Library:Notify("Could not find the latest room.", 2)
        end
	end,

	Disabled = false,
	Visible = true,
})
LeftGroupBoxExploits:AddButton({
	Text = "Enable Observatory Lever",
	Func = function()
        if ClientMain and ClientMain.CLIENT.Values.CurrentRoom.Value and ClientMain.CLIENT.Values.CurrentRoom.Value.Name == "Room194" then
            local leverPrompt = ClientMain.CLIENT.Values.CurrentRoom.Value:FindFirstChild("CaveLever", true):FindFirstChild("ProximityPrompt")
            if leverPrompt then
                 leverPrompt.Enabled = true
                 Library:Notify("Observatory lever enabled.", 1)
            else
                 Library:Notify("Could not find observatory lever prompt.", 2)
            end
        else
            Library:Notify("You must be in the observatory (Room 194)!", 2)
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
	while task.wait(1) do -- Check less frequently
		if InfRev and shared and shared.giveIt then 
            pcall(shared.giveIt) -- Wrap in pcall just in case
        end
	end
end)
local SIP
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
                print("Attempting to invoke DropItem for target:", SIP.Name, "Tool:", tool.Name)
                local success, err = pcall(RepStorage.Events.PlayerActions.DropItem.InvokeServer, RepStorage.Events.PlayerActions.DropItem, tool)
                 if not success then
                     warn("DropItem Invoke Error:", err)
                     Library:Notify("Failed to invoke drop: " .. tostring(err), 3)
                     expectingDrop = false -- Reset flag on error
                 else
                     Library:Notify("Drop invoked for " .. tool.Name .. ". Waiting for drop...", 1)
                 end
            else
                 Library:Notify("Target has no tool equipped.", 2)
            end
        else
            Library:Notify("Invalid target selected.", 2)
        end
	end,

	Disabled = false,
	Visible = true,
})
workspace.DroppedItems.ChildAdded:Connect(function(item)
	if not expectingDrop then return end
    if item:IsA("Tool") then -- Check if it's actually a tool
        local pickupPrompt = item:FindFirstChild("Pickup", true)
        if pickupPrompt and pickupPrompt:IsA("ProximityPrompt") then
            Library:Notify("Detected dropped item: " .. item.Name .. ". Attempting pickup.", 1)
            task.wait(0.3) -- Short delay for prompt to maybe enable
            local success, err = pcall(fireproximityprompt, pickupPrompt)
            if success then
                Library:Notify("Stole item: " .. item.Name .. "!", 3)
            else
                warn("Pickup Error:", err)
                Library:Notify("Failed to pick up item: " .. tostring(err), 3)
            end
        else
             Library:Notify("Dropped item has no pickup prompt?", 2)
        end
    end
	expectingDrop = false -- Reset flag regardless of success
end)


local AutoCage = false
local DoConLoop = false
LeftGroupBoxExploits:AddToggle("AutoCage", {
	Text = "Auto Escape Watcher-cage",

	Default = true, -- Defaulting to true as per original script
	Disabled = false, 
	Visible = true, -- Make visible as it's a useful feature

	Callback = function(Value)
        AutoCage = Value -- Use AutoCage directly now
        -- The connection disabling logic is removed as the hook handles it
	end,
})

-- Hook the PlayerCaged event instead of disabling connections
local playerCagedEvent = RepStorage.Events.ThePrision.PlayerCaged
local originalPlayerCagedConnection = nil -- Store original if needed, but hook is better

local playerCagedHook
playerCagedHook = hookfunction(playerCagedEvent.Fire, function(self, ...) -- Hook Fire for client event
    if AutoCage then
        warn("AutoCage: Intercepted PlayerCaged event. Handling automatically.")
        task.spawn(function() -- Use task.spawn for delay
            task.wait(4) -- Wait 4 seconds as per original logic
            warn("AutoCage: Firing MinigameFinished.")
            RepStorage.Events.ThePrision.MinigameFinished:FireServer()
        end)
        -- Don't call the original function, effectively skipping the cage UI/logic
        return
    else
        -- If AutoCage is off, call the original function
        warn("AutoCage: Feature is off. Allowing PlayerCaged event.")
        return playerCagedHook(...) -- Call original using the hook object
    end
end)


task.spawn(function()
    while task.wait(0.2) do -- Check slightly less often
        if PartialGod then
            -- Use a less intrusive method if possible, maybe just prevent damage?
            -- Firing DamageFromClient constantly might cause issues.
            -- Let's comment this out for now unless absolutely necessary.
            -- RepStorage.Events.EntityEvents.DamageFromClient:FireServer({
            --     AttackedBy = "Blacklight", 
            --     IsSet = true, 
            --     IgnoresHide = false, 
            --     Damage = math.huge -- Setting damage to huge might be interpreted as healing? Or just kill you? Needs testing.
            -- })
            
            -- Alternative: Hook the damage function if possible, or just rely on InfRevives
            local playerChar = Players.LocalPlayer.Character
            if playerChar and playerChar:FindFirstChildOfClass("Humanoid") then
                 if playerChar.Humanoid.Health < playerChar.Humanoid.MaxHealth then
                      -- Maybe fire a specific healing event if one exists?
                      -- Or just let InfRevives handle it upon death.
                 end
            end
        end
    end
end)

-- Anti-Entity Section (Moved to Right Groupbox)
local RightGroupBoxExploits_AntiEntity = Tabs.Exploits:AddRightGroupbox("<b>Anti-Entity</b>")
local AntiEntity = {"Blacklight", "Screech", "Void", "Decoy", "Seek", "Watcher"} -- Added Watcher

for _, Entity in AntiEntity do
    AntiEntityInternal[Entity] = false
    RightGroupBoxExploits_AntiEntity:AddToggle("Anti" .. Entity, {
	    Text = "Anti-" .. Entity,

	    Default = false,
	    Disabled = false, 
	    Visible = true, 

	    Callback = function(Value)
            AntiEntityInternal[Entity] = Value -- Update the state

            -- Apply immediate effects based on entity and value
            if Entity == "Screech" then
                if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.ScreechActive then
                     ClientMain.CLIENT.Values.ScreechActive.Value = Value -- Directly control Screech state if possible
                end
            elseif Entity == "Decoy" then
                 task.spawn(function() -- Use task.spawn for potentially many objects
                     for _, Obj in workspace:GetDescendants() do
                         if Obj.Name == "AttackRange" and Obj.Parent and Obj.Parent.Name == "decoyLocker" then
                             Obj.CanTouch = not Value
                         end
                     end
                 end)
            elseif Entity == "Seek" then
                 task.spawn(function()
                     for _, Obj in workspace:GetDescendants() do
                         if Obj.Name == "Hitbox" and Obj.Parent and Obj.Parent.Name == "Seek" then
                             Obj.CanTouch = not Value
                         end
                     end
                 end)
             elseif Entity == "Watcher" then
                 task.spawn(function()
                     local watcherModel = workspace:FindFirstChild("WanderWatcher")
                     if watcherModel then
                         local pickupArea = watcherModel:FindFirstChild("PickupArea", true)
                         if pickupArea then
                             pickupArea.CanTouch = not Value
                         end
                     end
                 end)
             elseif Entity == "Blacklight" then
                  if workspace:FindFirstChild("GameInfo") and workspace.GameInfo:FindFirstChild("BlacklightDisabled") then
                       workspace.GameInfo.BlacklightDisabled.Value = Value
                  end
             elseif Entity == "Void" then
                  -- The hook handles Anti-Void
                  Library:Notify("Anti-Void is handled by a hook.", 1)
             end
	    end,
    })
end


-- Apply Anti-Entity effects to newly added objects
workspace.DescendantAdded:Connect(function(Obj)
    if AntiEntityInternal["Decoy"] and Obj.Name == "AttackRange" and Obj.Parent and Obj.Parent.Name == "decoyLocker" then
        Obj.CanTouch = false
    end
    if AntiEntityInternal["Seek"] and Obj.Name == "Hitbox" and Obj.Parent and Obj.Parent.Name == "Seek" then
        Obj.CanTouch = false
    end
     if AntiEntityInternal["Watcher"] and Obj.Name == "PickupArea" and Obj:FindFirstAncestor("WanderWatcher") then
         Obj.CanTouch = false
     end
end)

-- Continuous checks/effects for certain Anti-Entities
task.spawn(function()
    while task.wait(0.5) do -- Check periodically
        if AntiEntityInternal["Screech"] then
            if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.ScreechActive then
                 ClientMain.CLIENT.Values.ScreechActive.Value = true -- Keep forcing it true
            end
        end
	    -- Removed Watcher crouch spam as Anti-Watcher now disables pickup area
        -- if AntiEntityInternal["Watcher"] then
	    --    RepStorage:WaitForChild("Events"):WaitForChild("PlayerCrouching"):FireServer(true)
	    -- end
        if AntiEntityInternal["Blacklight"] then
             if workspace:FindFirstChild("GameInfo") and workspace.GameInfo:FindFirstChild("BlacklightDisabled") then
                  workspace.GameInfo.BlacklightDisabled.Value = true -- Keep forcing it true
             end
        end
    end
end)

-- Anti-Void Hook (Already present, ensure it uses the correct variable)
local voidModule = require(ClientMain.CLIENT.CurrentRoomDependency.Modules.Void)
local originalVoidPlayer = voidModule.VoidPlayer
local voidPlayerHook
voidPlayerHook = hookfunction(originalVoidPlayer, function(...)
    if AntiEntityInternal["Void"] then
        warn("Anti-Void: Blocking VoidPlayer call.")
        return -- Block the function call
    else
        return voidPlayerHook(...) -- Call original if anti-void is off
    end
end)


-- Entity Spawn Notifications (Already present)
workspace.ChildAdded:Connect(function(Object)
    if Object:IsA("Model") then -- Check if it's a model
        local name = Object.Name
        if NotifyEntitiesInternal[name] then
             Library:Notify(name .. ' has spawned')
        end
    end
end)

workspace.DescendantAdded:Connect(function(Object)
    if Object.Name == 'ScreechAHHHH' and NotifyEntitiesInternal["Screech"] then
        Library:Notify('Screech has spawned')
    end
end)

if workspace:FindFirstChild("GameInfo") then
    local gameInfo = workspace.GameInfo
    if gameInfo:FindFirstChild("HoardbatsActive") then
        gameInfo.HoardbatsActive:GetPropertyChangedSignal("Value"):Connect(function()
            if gameInfo.HoardbatsActive.Value == true and NotifyEntitiesInternal["Hoardbats"] then
                Library:Notify('Hoardbats Swarm has spawned')
            end
        end)
    end
    if gameInfo:FindFirstChild("LureActive") then
        gameInfo.LureActive:GetPropertyChangedSignal("Value"):Connect(function()
            if gameInfo.LureActive.Value == true and NotifyEntitiesInternal["Onslaught"]then
                Library:Notify('Onslaught has spawned')
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
MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library:OnUnload(function()
    print("Unloading Foundation Hub...")
    -- Disconnect connections
    if ARCon and ARCon.Connected then ARCon:Disconnect() end
    if Noclipping then Noclipping:Disconnect() end
    if flyKeyDown then flyKeyDown:Disconnect() end
	if flyKeyUp then flyKeyUp:Disconnect() end
    
    -- Unhook functions
    if playerCagedHook and typeof(playerCagedHook) == "function" then -- Check if it's the hook object
         pcall(playerCagedHook.Unhook) -- Use the Unhook method if available
    end
     if voidPlayerHook and typeof(voidPlayerHook) == "function" then
         pcall(voidPlayerHook.Unhook)
     end
     -- Unhook the library toggle hook if it exists (variable 'old' might be local)
     -- This requires careful handling of the 'old' variable scope or a dedicated unhook reference.

    -- Reset modified game states
    pcall(NOFLY)
    if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Reset walkspeed
        Players.LocalPlayer.Character:SetAttribute("AllowedToJump", true) -- Allow jumping
    end
     if Players.LocalPlayer.Character then
         for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
		    	if child:IsA("BasePart") and child.CanCollide == false and child.Name ~= "Head" then
		    		child.CanCollide = true -- Reset noclip
		    	end
		 end
     end
    Lighting.Brightness = 0; Lighting.GlobalShadows = true -- Reset fullbright
    Lighting.Atmosphere.Density = 0.6 -- Reset fog
    if ClientMain and ClientMain.Scripts and ClientMain.Scripts.cameraMain then ClientMain.Scripts.cameraMain.Enabled = true end -- Reset third person
    if workspace:FindFirstChild("GameInfo") and workspace.GameInfo:FindFirstChild("BlacklightDisabled") then workspace.GameInfo.BlacklightDisabled.Value = false end -- Reset anti-blacklight
    if ClientMain and ClientMain.CLIENT and ClientMain.CLIENT.Values and ClientMain.CLIENT.Values.ScreechActive then ClientMain.CLIENT.Values.ScreechActive.Value = false end -- Reset anti-screech

    -- Reset Anti-Triggers and Anti-Entities that modify CanTouch
     task.spawn(function()
         for _, object in workspace:GetDescendants() do
             if object:IsA("BasePart") then
                 -- Reset triggers based on original logic (always enable on unload)
                 local triggerName = object.Name; local parent = object.Parent; local parentName = parent and parent.Name
                 if (triggerName == "Trigger" and object:FindFirstChild("Chase")) or
                    (triggerName == "Hitbox" and parent and parent:FindFirstChild("Planks")) or
                    (triggerName == "EndSequenceHitbox") or
                    (triggerName == "DeathPit") or
                    (triggerName == "Hitbox" and parent and parent:FindFirstChild("AnimatedShelf")) or
                    (triggerName == "DoorTrigger" and parent and parent:FindFirstChild("BigDoor")) or
                    (triggerName == "StartCutscene" and parent and parent:FindFirstChild("PivotWatcherCutscene")) or
                    (triggerName == "Cube" and parentName == "Piper") or
                    (triggerName == "Trigger" and parent and parent:FindFirstChild("ObstructionHolder")) or
                    (triggerName == "Trigger" and parent and parent:FindFirstChild("2ndPivot")) or
                    (triggerName == "AttackRange" and parentName == "decoyLocker") or
                    (triggerName == "Hitbox" and parentName == "Seek") or
                    (triggerName == "PickupArea" and object:FindFirstAncestor("WanderWatcher")) then
                     object.CanTouch = true
                 end
             end
         end
     end)

    -- Clear shared functions if they were set by this script
    shared.giveIt = nil 
    
    print("Foundation Hub Unload Complete.")
end)


MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "P", NoUI = true, Text = "Menu keybind" }) -- Changed default to P as per original


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
-- ESP Library and Setup
-- =============================================================
local ESPLibrary = loadstring(game:HttpGet(
    'https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau'
))()

local colors = {
    Entity = Color3.fromRGB(255, 0, 0),
    Objectives = Color3.fromRGB(0, 255, 0),
    HidingSpots = BrickColor.new('Gray').Color,
    Doors = Color3.fromRGB(0, 0, 150),
    Coins = Color3.new(0.898039, 0.913725, 0.000000),
    Containers = BrickColor.new('Gray').Color,
}

local function addESP(part, name, category)
    if not part or not part.Parent then return nil end -- Check if part exists

    -- Basic debounce: Check if an ESP already exists for this part
    if part:FindFirstChild("MSESP_Highlight") or part:FindFirstChild("MSESP_Box") then
         -- warn("ESP already exists for:", part:GetFullName())
         return nil -- Don't add another one
    end

    local esp = ESPLibrary:Add({
        Name = name,
        Model = part, -- Use Model property which handles BaseParts and Models
        Color = colors[category] or Color3.fromRGB(255, 255, 255), -- Default color
        MaxDistance = math.huge,
        TextSize = 17,
        ESPType = 'Highlight', -- Use Highlight as default
        FillColor = colors[category] or Color3.fromRGB(255, 255, 255),
        OutlineColor = colors[category] or Color3.fromRGB(255, 255, 255),
        Tracer = {
            Enabled = ESPTracersEnabled, -- Use the toggle state
            Color = colors[category] or Color3.fromRGB(255, 255, 255),
        },
    })
    
    -- Add to tracking table
    table.insert(allTrackedESPs, {
        ESP = esp,
        Category = category,
        Instance = part, -- Keep track of the instance
    })

    -- Set initial visibility based on category toggle
    if not espCategories[category] then
        esp:Hide()
    end

    -- Cleanup connection when the part is destroyed
    local connection
    connection = part.Destroying:Connect(function()
        -- Find and remove from allTrackedESPs
        for i = #allTrackedESPs, 1, -1 do
            if allTrackedESPs[i].Instance == part then
                allTrackedESPs[i].ESP:Destroy() -- Destroy the ESP object itself
                table.remove(allTrackedESPs, i)
                break
            end
        end
        if connection then connection:Disconnect() end -- Disconnect self
    end)

    return esp
end

local roomSpecESPs = {} -- Table to hold ESPs specific to the current room

-- Function to clear room-specific ESPs
local function clearRoomESPs()
     -- warn("Clearing", #roomSpecESPs, "room-specific ESPs")
     for _, espData in ipairs(roomSpecESPs) do
         if espData and espData.ESP then
             espData.ESP:Destroy() -- Use ESP library's destroy method
         end
     end
     table.clear(roomSpecESPs)
end

-- Function to process objects within a specific room for ESP
local function processRoom(room)
    if not room or not room:IsA("Model") then return end
    -- warn("Processing room for ESP:", room.Name)
    
    clearRoomESPs() -- Clear previous room's ESPs first

    for _, object in room:GetDescendants() do
        task.spawn(function() -- Use task.spawn to avoid yielding the main thread too much
            if not object or not object.Parent then return end -- Check validity inside spawn

            local name = object.Name
            local parent = object.Parent
            local category = nil
            local espName = nil
            local targetPart = object -- Default target

            -- Hiding Spots & Decoys
            if espCategories.HidingSpots then
                if name == 'Locker' or name == 'Toolshed_Hiding' then category = 'HidingSpots'; espName = 'Hiding-Spot'
                elseif name == 'decoyLocker' then category = 'Entity'; espName = 'Decoy' -- Treat decoy as entity ESP
                end
            end

            -- Objectives
            if espCategories.Objectives then
                if name == 'OilCanister' then category = 'Objectives'; espName = 'Oil Can'
                elseif name == 'GasCanister' then category = 'Objectives'; espName = 'Gas Canister'
                elseif name == 'GeneratorPuzzle' then category = 'Objectives'; espName = 'Generator'
                elseif name == 'Terminal' then category = 'Objectives'; espName = 'Terminal'
                elseif name == 'Switch' and not object:FindFirstAncestor('Switch') and not object:FindFirstAncestor('Flashlight') then category = 'Objectives'; espName = 'Fuse'
                elseif name == 'GivingCoins' then category = 'Coins'; espName = 'Coins'; targetPart = parent -- Target the parent model for coins
                elseif name == 'Minigame' and object:FindFirstChild('Switches') then category = 'Objectives'; espName = 'Breaker Minigame'
                elseif name == 'ObservatoryKey' then category = 'Objectives'; espName = 'Key'
                elseif name == 'SignModel' then local sign = object:FindFirstChild('Sign'); if sign then targetPart = sign; category = 'Objectives'; espName = 'Directional Sign'; sign.Material = Enum.Material.Neon; sign.Color = Color3.fromRGB(255, 255, 255) end
                elseif name == 'Control' and parent.Name == 'Elevator' and parent.Parent:FindFirstChild('ElevatorHandler') then local sign = object:FindFirstChild('Sign'); if sign then sign.Material = Enum.Material.Neon end; category = 'Objectives'; espName = 'Exit Elevator'
                elseif name == 'OxygenTank' then category = 'Objectives'; espName = 'Oxygen Can'
                elseif (name == 'CaveLever' or name == 'Lever') and not object:FindFirstAncestor('GeneratorPuzzle') and not object:FindFirstAncestor('EndPanel') and not object:FindFirstAncestor('GeneratorDeco') then local order = object:GetAttribute('Order'); espName = 'Lever' .. (order and (' ' .. order) or ''); category = 'Objectives'
                end
            end
            
            -- Containers (Only mark parent model once)
            if espCategories.Containers then
                 if name == 'Container' and parent:IsA("Model") and not parent:HasTag("ContainerMarkedESP") then
                      parent:AddTag("ContainerMarkedESP")
                      category = 'Containers'; espName = 'Container'; targetPart = parent
                      -- Cleanup tag when parent is destroyed
                      local tagConn; tagConn = parent.Destroying:Connect(function() parent:RemoveTag("ContainerMarkedESP"); if tagConn then tagConn:Disconnect() end end)
                 end
            end

            -- Doors
            if espCategories.Doors then
                if (name == 'Door' and parent.Parent and parent.Parent.Name == 'GeneratedRooms') or name == 'Chunk_Watcher' then category = 'Doors'; espName = 'Door'
                end
            end

            -- Add ESP if category and name determined
            if category and espName then
                local newEsp = addESP(targetPart, espName, category)
                if newEsp then table.insert(roomSpecESPs, {ESP = newEsp, Instance = targetPart}) end -- Add to room-specific list
            end
        end)
    end
end

-- Function to handle CurrentRoom value changes
local function handleCurrentRoomUpdate(objectValue)
    if objectValue and objectValue:IsA("ObjectValue") then
        local currentRoomModel = objectValue.Value
        if currentRoomModel and currentRoomModel:IsA("Model") and currentRoomModel.Parent == Rooms then
            task.delay(0.5, function() -- Short delay for room contents to potentially load
                 processRoom(currentRoomModel)
            end)
        else
             clearRoomESPs() -- Clear ESPs if value is nil or not a valid room
        end
    else
         clearRoomESPs() -- Clear ESPs if the object itself is invalid
    end
end

-- Find the CurrentRoom ObjectValue and connect to its changes
local currentRoomValueObject = nil
local function findAndConnectCurrentRoom()
    if currentRoomValueObject then return end -- Already found

    local clientFolder = ClientMain and ClientMain:FindFirstChild("CLIENT")
    local valuesFolder = clientFolder and clientFolder:FindFirstChild("Values")
    currentRoomValueObject = valuesFolder and valuesFolder:FindFirstChild("CurrentRoom")

    if currentRoomValueObject and currentRoomValueObject:IsA("ObjectValue") then
        print("Found CurrentRoom ObjectValue at:", currentRoomValueObject:GetFullName())
        handleCurrentRoomUpdate(currentRoomValueObject) -- Initial processing
        currentRoomValueObject:GetPropertyChangedSignal("Value"):Connect(function()
            handleCurrentRoomUpdate(currentRoomValueObject) -- Process on change
        end)
    else
        warn("Could not find CurrentRoom ObjectValue. Room ESPs might not update automatically.")
    end
end

-- Try to find the CurrentRoom object initially and on relevant additions
findAndConnectCurrentRoom()
if not currentRoomValueObject then
     LocalPlayer.DescendantAdded:Connect(function(descendant)
         if descendant.Name == "CurrentRoom" and descendant:IsA("ObjectValue") then
             findAndConnectCurrentRoom() -- Try again if added later
         end
     end)
end


-- Function to process globally added objects (Entities mainly)
local function processGlobalObject(object)
    if not object or not object.Parent then return end
    if object:FindFirstAncestor('Game Configuration') then return end -- Ignore config stuff

    if espCategories.Entity then
        local name = object.Name
        local category = 'Entity'
        local espName = nil
        local targetPart = object

        if name == 'HoardbatClient' or name == "HoardBat" then espName = 'Hoardbat'
        elseif name == 'Eyes' and (not object.Parent or object.Parent.Name ~= 'Bob') then espName = 'Eyes' -- Added parent check
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
        end
    end
end

-- Process existing global objects and connect for new ones
workspace.DescendantAdded:Connect(processGlobalObject)
for _, object in workspace:GetDescendants() do
    task.spawn(processGlobalObject, object) -- Use task.spawn for initial scan
end

print("Foundation Hub PLus Plus Loaded and Initialized.")
