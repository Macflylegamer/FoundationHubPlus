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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
RightGroupBox:AddButton({
Text = "Play Again",
Func = function()
RepStorage.Events.PlayerActions.PlayAgain:FireServer()
end,
DoubleClick = true,

Disabled = false,
Visible = true,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
workspace.DescendantAdded:Connect(function(Prompt)
if Prompt:IsA("ProximityPrompt") and PR then
Prompt:SetAttribute("OrigLOSReq", Prompt.RequiresLineOfSight)
Prompt:SetAttribute("OrigMAD", Prompt.MaxActivationDistance)
Prompt.RequiresLineOfSight = false
Prompt.MaxActivationDistance = Prompt.MaxActivationDistance * PM
end
end)
local RightGroupBox = Tabs.Main:AddLeftGroupbox("<b>Auto-Rooms</b>")
local ARTargetReach = 205
RightGroupBox:AddSlider("ARRoomReach", {
Text = "Room to Reach",
Default = ARTargetReach,
Min = 102,
Max = 205,
Rounding = 0,
Compact = true,

Callback = function(Value)
	
end,

Disabled = false, 
Visible = true,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
local CollectionService = game:GetService("CollectionService")
local Rooms = workspace.GeneratedRooms
local ARGoing = false
local FiredPrompts = {}
local DoggedRooms = {}
local CutFolder = Instance.new("Folder")
local ARCon
RightGroupBox:AddButton({
Text = "Start/Stop",
Func = function()
ARGoing = not ARGoing
if ARGoing then
for _, scene in ClientMain.CLIENT.CutsceneHandler.Cutscenes:GetChildren() do
scene.Parent = CutFolder
end
Library:Notify("Auto rooms started")

ARCon = RunService.Stepped:Connect(function()
local Character = Players.LocalPlayer.Character
local RoomNumbers = {}

for _, Room in Rooms:GetChildren() do
    CollectionService:RemoveTag(Room, "DarkRoom")

    local Number = Room.Name:gsub("Room", "")
    table.insert(RoomNumbers, tonumber(Number))
end

local LastRoom = math.max(unpack(RoomNumbers)) - 1
local foundRoom = Rooms:FindFirstChild("Room" .. tostring(LastRoom + 1))

if not table.find(DoggedRooms, foundRoom) then
    table.insert(DoggedRooms, foundRoom)
    if ARGoing and Options.RMUnify.Value == "Current Room" then
        Library:Notify("Auto Rooms: Room " .. foundRoom.Name:split("Room")[2])
    end
    if ARGoing and Options.RMUnify.Value == "Special Room" and foundRoom:GetAttribute("Chance") == 0 then
        Library:Notify("Auto Rooms: Special room '" .. foundRoom:GetAttribute("RawName") .. "' reached")
    end
end
if not Character then return end

for _, Room in Rooms:GetChildren() do
    if Room.Name == "Room195" then
        RepStorage.Events.TheObservatory.BeatPuzzle:FireServer()
    end
    

    local Door = Room:FindFirstChild("Door") or Room:FindFirstChild("DoorNormal")
    local Scriptable = Room:FindFirstChild("Scriptable")
    local Hitbox = (Door and Door:FindFirstChild("Hitbox")) or (Scriptable and Scriptable:FindFirstChild("Trigger"))
    local Lever = Room:FindFirstChild("CaveLever")
    local Prompt = Lever and Lever.ProximityPrompt
    local Elevator = Scriptable and Scriptable:FindFirstChild("Elevator")
    local ElevatorControl = Elevator and Elevator:FindFirstChild("Control")
    local ElevatorPrompt = ElevatorControl and ElevatorControl.Button.ProximityPrompt


    if LastRoom ==Options.ARRoomReach.Value - 1 then
        FiredPrompts = {}
        DoggedRooms = {}
        ARCon = ARCon and ARCon:Disconnect()
        ARGoing = false
for _, scene in CutFolder:GetChildren() do
            scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes
        end
        Library:Notify("Auto rooms done")
        task.wait(0.5)
        RepStorage.Events.VoidEvent:FireServer()
    end

    if not ARCon then break end

    if Prompt and not FiredPrompts[Prompt] then
        while Prompt.Enabled do
            Character:PivotTo(Lever:GetPivot())
            fireproximityprompt(Prompt)
            FiredPrompts[Prompt] = true
            task.wait()
        end
    end

    if not Hitbox then continue end

    local _LastRoom = Rooms:FindFirstChild(`Room{LastRoom}`)
    local _CFrame = _LastRoom:GetPivot() * CFrame.new(0, 150, 0)
    Character:PivotTo(_CFrame)

    Hitbox.CFrame = _CFrame
    Hitbox.Size = Vector3.new(2048, 2048, 2048)
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end)

else
        for _, scene in CutFolder:GetChildren() do
            scene.Parent = ClientMain.CLIENT.CutsceneHandler.Cutscenes
        end
        Library:Notify("Auto rooms stopped")
        FiredPrompts = {}
        DoggedRooms = {}
        ARCon = ARCon and ARCon:Disconnect()
        ARGoing = false
        RepStorage.Events.VoidEvent:FireServer()
    end
end,

Disabled = false,
Visible = true,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})

RightGroupBox:AddDropdown("RMUnify", {
Values = { "Current Room", "Special Room"},
Default = 1,
Multi = false,

Text = "Notifications",

Searchable = false, 

Disabled = false, 
Visible = true,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})

local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox("<b>General</b>")
LeftGroupBox:AddToggle("Fullbright", {
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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
local noFog = false
LeftGroupBox:AddToggle("NoFog", {
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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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

LeftGroupBox:AddToggle("FP", {
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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

}):AddKeyPicker("KeyPicker", {
Default = "V",
SyncToggleState = true,

Mode = "Toggle", 

Text = "Third Person", 
NoUI = false,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
local RightGroupBox = Tabs.Visuals:AddRightGroupbox("<b>Notifications</b>")
for _, Entity in NotifyEntities do
NotifyEntitiesInternal[Entity] = false
RightGroupBox:AddToggle("Notify" .. Entity, {
Text = "Notify " .. Entity,

Default = false,
    Disabled = false, 
    Visible = true, 

    Callback = function(Value)
	   NotifyEntitiesInternal[Entity] = Value
    end,
})
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end

local LeftGroupBox = Tabs.Exploits:AddRightGroupbox("<b>Anti-Trigger</b>")
local AntiTrigger = {"Seek-Chase-Start", "Seek-Chase-Planks-Fall", "Seek-Chase-Obstruction", "Seek-Chase-Boat-Start", "Death-Trigger", "Seek-Last-Room-Start","Prison-Start", "Watcher-Chase-Start","Observatory-Door"}
local AntiTriggerInternal = {}

local function processTrigger(trigger)
if trigger.Name == "Trigger" and trigger:FindFirstChild("Chase") then
trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Start"]
end
if trigger.Name == "Hitbox" and trigger.Parent:FindFirstChild("Planks") then
trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Planks-Fall"]
end
if trigger.Name == "EndSequenceHitbox" then
trigger.CanTouch = not AntiTriggerInternal["Seek-Last-Room-Start"]
end
if trigger.Name == "DeathPit" then
trigger.CanTouch = not AntiTriggerInternal["Death-Trigger"]
end
if trigger.Name == "Hitbox" and trigger.Parent:FindFirstChild("AnimatedShelf") then
trigger.CanTouch = not AntiTriggerInternal["Watcher-Chase-Start"]
end
if trigger.Name == "DoorTrigger" and trigger.Parent:FindFirstChild("BigDoor") then
trigger.CanTouch = not AntiTriggerInternal["Observatory-Door"]
end
if trigger.Name == "StartCutscene" and trigger.Parent:FindFirstChild("PivotWatcherCutscene") and trigger.Parent:FindFirstChild("GuidingLight") then
trigger.CanTouch = not AntiTriggerInternal["Prison-Start"]
end
if trigger.Name == "Cube" and trigger.Parent.Name == "Piper" then
trigger.CanTouch = not AntiTriggerInternal["Death-Trigger"]
end
if trigger.Name == "Trigger" and trigger.Parent:FindFirstChild("ObstructionHolder") then
trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Obstruction"]
end
if trigger.Name == "Trigger" and trigger.Parent:FindFirstChild("2ndPivot") and trigger.Parent:FindFirstChild("Cutscene") then
trigger.CanTouch = not AntiTriggerInternal["Seek-Chase-Boat-Start"]
end
end

for _, Trigger in AntiTrigger do
AntiTriggerInternal[Trigger] = false
LeftGroupBox:AddToggle("Anti" .. Trigger, {
Text = "Anti-" .. Trigger,

Default = false,
    Disabled = false, 
    Visible = true, 

    Callback = function(Value)
	   AntiTriggerInternal[Trigger] = Value
       for _, object in workspace:GetDescendants() do
            processTrigger(object)
       end
    end,
})
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end

workspace.DescendantAdded:Connect(function(object)
processTrigger(object)
end)

local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox("<b>ESP</b>")
local ESPTracersEnabled: boolean = true
LeftGroupBox:AddToggle("ESPTracers", {
Text = "Tracers",

Default = true,
Disabled = false, 
Visible = false, 

Callback = function(Value)
	ESPTracersEnabled = Value
end,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
local ESPThings = {"Entity", "Objectives", "Doors", "HidingSpots", "Coins", "Containers"}
for _, Thing in ESPThings do
LeftGroupBox:AddToggle("ESP" .. Thing, {
Text = "ESP " .. Thing,

Default = false,
    Disabled = false, 
    Visible = true, 

    Callback = function(Value)
	   espCategories[Thing] = Value
       updateESPVisibility()
    end,
})
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end
local LeftGroupBox = Tabs.Exploits:AddLeftGroupbox("<b>Exploits</b>")
LeftGroupBox:AddButton({
Text = "Skip Watcher 150",
Func = function()
if ClientMain and ClientMain.CLIENT.Values.CurrentRoom.Value.Name == "Room150" then
RepStorage.Events.ThePrision.FinishedTerminal:FireServer()
else
Library:Notify("You must be in room 150!")
end
end,

Disabled = false,
Visible = true,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})

-- Define variables for the controls first
local lootWaitTime = 0.1 -- Default wait time
local useFastMode = false -- Default: Fast mode (Optimized Gold Loot) is disabled
local lootSideRooms = false -- Default: only check AddedAssets / direct models explicitly handled

-- Add the controls to the UI GroupBox
LeftGroupBox:AddToggle("LootSideRooms", {
Text = "Attempt Loot Side Rooms (Experimental)",
Default = lootSideRooms,
Callback = function(Value)
lootSideRooms = Value
print("-- DEBUG: Loot Side Rooms set to:", lootSideRooms)
end,
Disabled = false,
Visible = true,
})

LeftGroupBox:AddToggle("UseFastModeToggle", {
Text = "Use Fast Gold Loot (No TP First - Risky)",
Default = useFastMode,
Callback = function(Value)
useFastMode = Value
print("-- DEBUG: Fast Gold Loot (No TP First) set to:", useFastMode)
end,
Disabled = false,
Visible = true,
})

LeftGroupBox:AddSlider("LootWaitSlider", {
Text = "Loot Wait Time (s)",
Default = lootWaitTime,
Min = 0,
Max = 1,
Rounding = 1, -- 1 decimal place (0.1 increments)
Compact = true,
Callback = function(Value)
lootWaitTime = Value -- Update the variable when slider changes
print("-- DEBUG: Loot Wait Time set to:", lootWaitTime)
end,
Disabled = false,
Visible = true,
})
local AutoLootVersion = "2.18-TableToolBoxFix" -- Updated version number
LeftGroupBox:AddButton({
Text = "Auto Loot Gold (Current Room)",
Func = function()
Library:Notify("Auto Loot Gold Started (v" .. AutoLootVersion .. ")", 1)
warn("--- Auto Loot Gold (v" .. AutoLootVersion .. ") Started ---")
if useFastMode then warn("--- Fast Gold Loot Enabled ---") end

local player = Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then Library:Notify("Player character not found.", 3); warn("ERROR: Player character not found."); return end
    if not ClientMain or not ClientMain.CLIENT or not ClientMain.CLIENT.Values or not ClientMain.CLIENT.Values.CurrentRoom or not ClientMain.CLIENT.Values.CurrentRoom.Value then Library:Notify("Cannot determine current room.", 3); warn("ERROR: Cannot determine current room."); return end
    local currentRoomModel = ClientMain.CLIENT.Values.CurrentRoom.Value
    if not currentRoomModel or not currentRoomModel:IsA("Model") then Library:Notify("Current room data is invalid.", 3); warn("ERROR: Current room data is invalid."); return end
    -- warn("Current Room Model:", currentRoomModel:GetFullName())

    local goldItemNames = {"Coin", "CoinStack", "GoldBar", "GoldBarAndDiamonds"}
    local itemsLootedCount = 0
    local partsToLootAfterOpening = {}
    local overallContainerIndex = 0

    -- Function to try looting an item via teleport loop (STANDARD METHOD for gold)
    local function tryFirePromptForItem_Teleport(itemPromptRef, itemModel, itemContextName)
         -- [...] (Function unchanged)
         if not (itemModel and itemModel.Parent) then return true end
         local originalCFrame = character.HumanoidRootPart.CFrame; local looted = false; local attempts = 0; local maxLoopTime = 7; local startTime = tick(); local firstAttempt = true
         while itemModel and itemModel.Parent and (tick() - startTime < maxLoopTime) do if firstAttempt then task.wait(0.1); firstAttempt = false end; local currentItemPrompt = itemModel:FindFirstChild("ItemPrompt"); if currentItemPrompt and currentItemPrompt:IsA("ProximityPrompt") and currentItemPrompt.Enabled then local promptParent = currentItemPrompt.Parent; if not promptParent then break end; local targetCFrame; if promptParent:IsA("Model") then targetCFrame = promptParent:GetPivot() elseif promptParent:IsA("BasePart") then targetCFrame = promptParent.CFrame end; if targetCFrame then character:PivotTo(targetCFrame); task.wait(0.05); local success, err = pcall(fireproximityprompt, currentItemPrompt); task.wait(0.07); if not itemModel or not itemModel.Parent then looted = true; break end end end; attempts = attempts + 1; task.wait(0.1) end
         character:PivotTo(originalCFrame); if not itemModel or not itemModel.Parent then looted = true else looted = false; warn("    -- WARNING: Item", itemContextName, "still exists after TP loot attempts.") end; return looted
    end

    -- Function to trigger a container prompt reliably (teleport and fire ONCE or TWICE)
    local function triggerContainerPrompt_Reliable(prompt, containerPart, promptContextName)
        -- [...] (Function unchanged)
        warn("    -- Triggering Container Prompt Reliably:", promptContextName)
        if not (containerPart and containerPart.Parent) then warn("      -- ERROR: Invalid container part."); return end; if not (prompt and prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Enabled) then warn("      -- ERROR: Invalid or disabled prompt."); return end; local originalCFrame = character.HumanoidRootPart.CFrame; local promptParent = prompt.Parent; local targetCFrame; if promptParent:IsA("Model") then targetCFrame = promptParent:GetPivot() elseif promptParent:IsA("BasePart") then targetCFrame = promptParent.CFrame elseif promptParent:IsA("Attachment") then targetCFrame = promptParent.WorldCFrame end; if not targetCFrame then warn("      -- ERROR: Could not get target CFrame."); character:PivotTo(originalCFrame); return end
        character:PivotTo(targetCFrame); task.wait(0.07); local success1, err1 = pcall(fireproximityprompt, prompt); task.wait(0.08); if prompt and prompt.Parent and prompt.Enabled then pcall(fireproximityprompt, prompt); task.wait(0.05) end; character:PivotTo(originalCFrame); warn("      -- Finished reliable trigger attempt for:", promptContextName)
    end


    -- MODIFIED: Function to find and loot gold (Handles Table structure correctly)
    local function findAndLootGold(itemContainer, containerContextName)
        -- warn("  -- [Loot Phase] findAndLootGold called for:", containerContextName, "Part:", itemContainer and itemContainer:GetFullName() or "nil")
        if not itemContainer then warn("    -- ERROR: itemContainer is nil. Aborting loot."); return end

        local itemParentToSearch = itemContainer -- Default search location
        local spawnFolder = nil

        -- Check for direct spawn folder first (Drawers, Lockers, etc.)
        spawnFolder = itemContainer:FindFirstChild("ItemSpawns") or itemContainer:FindFirstChild("SpawnAreas")

        -- If no direct spawn folder, check for Table structure (Outside_Container -> BaseOutline -> ItemSpawns)
        if not spawnFolder and itemContainer.Name == "Outside_Container" then
             warn("    -- Checking Table structure inside Outside_Container...")
             local baseOutline = itemContainer:FindFirstChild("BaseOutline")
             if baseOutline then
                  warn("      -- Found BaseOutline:", baseOutline:GetFullName())
                  spawnFolder = baseOutline:FindFirstChild("ItemSpawns") or baseOutline:FindFirstChild("SpawnAreas")
                  if spawnFolder then
                       warn("        -- Found Spawn Folder inside BaseOutline:", spawnFolder:GetFullName())
                  else
                       warn("        -- No Spawn Folder found inside BaseOutline.")
                  end
             else
                  warn("      -- No BaseOutline found inside Outside_Container.")
             end
        end

        -- Set the final search target
        if spawnFolder then
            itemParentToSearch = spawnFolder
            -- warn("    -- Final Search Target set to Spawn Folder:", itemParentToSearch:GetFullName())
        -- else warn("    -- No specific Spawn Folder found. Searching directly inside:", itemParentToSearch:GetFullName())
        end

        if not itemParentToSearch or not itemParentToSearch.Parent then warn("    -- ERROR: Invalid itemParentToSearch:", itemParentToSearch and itemParentToSearch:GetFullName() or "nil"); return end
        -- warn("    -- Final Search Target:", itemParentToSearch:GetFullName())

        local potentialItems = itemParentToSearch:GetChildren(); -- warn("    -- Found", #potentialItems, "potential items inside search target.");
        if #potentialItems == 0 then return end

        for i, item in ipairs(potentialItems) do
            local itemModel = item; if not (itemModel and itemModel.Parent) then continue end
            -- warn("      -- Checking item #", i, ":", itemModel.Name, "(Class:", itemModel.ClassName, ") Full Path:", itemModel:GetFullName())
            if table.find(goldItemNames, itemModel.Name) then
                -- warn("        -- MATCH! Found gold item:", itemModel.Name);
                local itemPrompt = itemModel:FindFirstChild("ItemPrompt")
                if itemPrompt then
                    -- warn("          -- Found ItemPrompt:", itemPrompt:GetFullName());
                    local lootedThisItem = false
                    if useFastMode then
                        local fastAttempts = 0; local maxFastAttempts = 3
                        while fastAttempts < maxFastAttempts do if not (itemModel and itemModel.Parent) then lootedThisItem = true; break end; if not (itemPrompt and itemPrompt.Parent and itemPrompt.Enabled) then warn("      -- Gold Prompt became invalid during fast loot attempt."); break end; pcall(fireproximityprompt, itemPrompt); task.wait(0.05); fastAttempts = fastAttempts + 1 end
                        if not (itemModel and itemModel.Parent) then itemsLootedCount = itemsLootedCount + 1; lootedThisItem = true else warn("          -- FAILURE: Gold still exists after brief direct fire. Falling back to teleport.") end
                    end
                    if not lootedThisItem then if tryFirePromptForItem_Teleport(itemPrompt, itemModel, itemModel.Name .. " ItemPrompt in " .. containerContextName) then itemsLootedCount = itemsLootedCount + 1 else warn("          -- FAILED teleport loot for GOLD:", itemModel.Name) end end
                else warn("        -- ERROR: Could not find ItemPrompt inside gold item:", itemModel.Name) end
            end
        end
         -- warn("  -- [Loot Phase] Finished searching in:", containerContextName)
    end -- End of findAndLootGold function

    -- =============================================================
    -- Phase 1: Check True State, Trigger if Needed, Identify Loot Locations
    -- =============================================================
    warn("\n--- Starting Phase 1: Checking True State & Identifying Loot Locations ---")

    -- Recursive function to process items
    local function processItemForOpening(item)
        if not item or not item.Parent then return end
        local children = item:GetChildren()
        for _, child in ipairs(children) do
            if not child or not child.Parent then continue end
            -- *** MODIFIED: isKnownContainer check includes Table_ variants ***
            local isKnownContainer = child:IsA("Model") and (child.Name:find("LockerVariant") or child.Name:find("CrowbarVariant") or child.Name == "Drawer" or child.Name:find("Table") or child.Name == "Rolltop" or child.Name == "ToolBox")

            if isKnownContainer then
                overallContainerIndex = overallContainerIndex + 1
                local containerModel = child; local modelIndex = overallContainerIndex
                warn("-- [Open Phase] Processing Container:", containerModel.Name, "#", modelIndex)
                local containerChildren = containerModel:GetChildren(); local lootPartsToAdd = {}

                -- Centralized logic to check state and trigger
                local function checkAndTrigger(promptRef, innerModelRef, partForTrigger, context)
                    -- [...] (Function unchanged)
                    local promptOpenedAttr = promptRef and promptRef:GetAttribute("Opened"); local nameOK = innerModelRef and innerModelRef.Name == "OpenedSTORAGE"; local isTrulyOpen = (promptOpenedAttr == true and nameOK == true)
                    warn("      -- Check:", context, "Prompt Attr:", tostring(promptOpenedAttr), "Inner Name:", innerModelRef and innerModelRef.Name or "N/A", "Truly Open:", isTrulyOpen)
                    if not isTrulyOpen and promptRef then warn("        -- Marked for opening trigger."); triggerContainerPrompt_Reliable(promptRef, partForTrigger, context .. " Trigger #" .. modelIndex) elseif not promptRef then warn("      -- WARNING: No prompt found for", context) end
                end

                -- Find inner container model(s) first
                local innerModels = {}
                for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name == "Container" or cChild.Name == "OpenedSTORAGE") then table.insert(innerModels, cChild) end end
                local innerModelRef = #innerModels > 0 and innerModels[1] or nil -- Use first found for general name check if needed

                -- Handle Drawer (Unchanged from 2.17)
                if containerModel.Name == "Drawer" then
                    local addedAnyLootPart = false
                    for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name:find("Container", 1, true) or cChild.Name == "OpenedSTORAGE") and cChild.Name ~= "Outside_Container" then local currentInnerModel = cChild; local mainDrawer = currentInnerModel:FindFirstChild("MainDrawer"); if mainDrawer then local prompt = mainDrawer:FindFirstChild("ProxAttach", true):FindFirstChild("ProximityPrompt"); checkAndTrigger(prompt, currentInnerModel, mainDrawer, "Drawer." .. currentInnerModel.Name); table.insert(lootPartsToAdd, mainDrawer); addedAnyLootPart = true else warn("    -- ERROR: No MainDrawer in", cChild:GetFullName()) end end end
                    local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer); addedAnyLootPart = true end

                -- Handle Lockers/Crowbars (Unchanged from 2.17)
                elseif containerModel.Name:find("LockerVariant") or containerModel.Name:find("CrowbarVariant") then
                     local basePart = innerModelRef and innerModelRef:FindFirstChild("Base"); if basePart then table.insert(lootPartsToAdd, basePart) else warn("    -- WARNING: Could not find Base part for Locker.") end
                     if containerModel.Name:find("LLV2") or containerModel.Name:find("Variant2") then local doorBottom = containerModel:FindFirstChild("DoorBottom"); local promptB = doorBottom and doorBottom:FindFirstChild("DoorBottom", true):FindFirstChild("ProximityPrompt"); local doorTop = containerModel:FindFirstChild("DoorTop"); local promptT = doorTop and doorTop:FindFirstChild("DoorTop", true):FindFirstChild("ProximityPrompt"); checkAndTrigger(promptB, innerModelRef, doorBottom, "LockerV2 Bottom Door"); checkAndTrigger(promptT, innerModelRef, doorTop, "LockerV2 Top Door")
                     else local door = containerModel:FindFirstChild("Door"); local promptD = door and door:FindFirstChild("ProximityPrompt"); checkAndTrigger(promptD, innerModelRef, door, "Locker Single Door") end

                -- Handle Rolltop (Unchanged from 2.17)
                elseif containerModel.Name == "Rolltop" then
                     local mainDrawerRef = innerModelRef and innerModelRef:FindFirstChild("MainDrawer"); if mainDrawerRef then local pA = mainDrawerRef:FindFirstChild("ProxAttach"); local promptR = pA and pA:FindFirstChild("ProximityPrompt"); checkAndTrigger(promptR, innerModelRef, mainDrawerRef, "Rolltop MainDrawer"); table.insert(lootPartsToAdd, mainDrawerRef) else warn("    -- WARNING: Could not find MainDrawer for Rolltop.") end
                     local outsideContainer = containerModel:FindFirstChild("Outside_Container"); if outsideContainer then table.insert(lootPartsToAdd, outsideContainer) end

                -- *** RE-ADDED: Handle ToolBox ***
                elseif containerModel.Name == "ToolBox" then
                     local spawnAreasRef = nil
                     -- Find the specific inner model for ToolBox
                     local toolBoxInnerModel = nil
                     for _, cChild in ipairs(containerChildren) do if cChild:IsA("Model") and (cChild.Name == "Container" or cChild.Name == "OpenedSTORAGE") then toolBoxInnerModel = cChild; break end end

                     if toolBoxInnerModel then
                          local promptTB = containerModel:FindFirstChild("ProximityPrompt") -- Prompt is on main model
                          checkAndTrigger(promptTB, toolBoxInnerModel, toolBoxInnerModel, "ToolBox") -- Check state and trigger if needed
                          local baseRef = toolBoxInnerModel:FindFirstChild("Base")
                          if baseRef then
                               spawnAreasRef = baseRef:FindFirstChild("SpawnAreas")
                               if spawnAreasRef then
                                    table.insert(lootPartsToAdd, spawnAreasRef) -- Add SpawnAreas for looting
                               else warn("    -- WARNING: ToolBox Base found, but no SpawnAreas.") end
                          else warn("    -- WARNING: ToolBox InnerContainer found, but no Base.") end
                     else warn("    -- WARNING: Could not find InnerContainer for ToolBox.") end

                -- *** MODIFIED: Handle ALL Table variants ***
                elseif containerModel.Name:find("Table") then -- Catches "Table", "Table_RightDrawer", "Table_LeftDrawer"
                     warn("  -- Handling Table Variant:", containerModel.Name)
                     local outsideContainer = containerModel:FindFirstChild("Outside_Container")
                     if outsideContainer then
                          warn("    -- Found Outside_Container. Adding to loot list.")
                          table.insert(lootPartsToAdd, outsideContainer)
                     else
                          warn("    -- WARNING: No Outside_Container found for Table variant:", containerModel.Name)
                     end
                     -- Note: Drawers inside Table_Right/LeftDrawer are handled if they follow the standard "Container/OpenedSTORAGE" structure,
                     -- but based on your description, only Outside_Container matters for loot.
                end

                -- Add identified loot parts from temp list to main list
                if #lootPartsToAdd > 0 then
                    for _, part in ipairs(lootPartsToAdd) do
                        if part and part.Parent then table.insert(partsToLootAfterOpening, part) else warn("      -- Skipping invalid loot part.") end
                    end
                end

            -- Case 2: AddedAssets Folder / Case 3: SideRoom Model
            elseif child.Name == "AddedAssets" and child:IsA("Folder") then processItemForOpening(child)
            elseif lootSideRooms and child.Name == "SideRoom" and child:IsA("Model") then processItemForOpening(child)
            end
            task.wait() -- Minimal yield between processing top-level items
        end
    end

    -- Start the recursive processing
    warn("--- Starting Phase 1 Recursive Processing ---"); processItemForOpening(currentRoomModel); warn("--- Finished Phase 1 Recursive Processing ---")
    warn("-- Phase 1 Summary: Identified", #partsToLootAfterOpening, "potential loot locations.")

    -- Intermediate Step: Global Wait
    if lootWaitTime > 0 and #partsToLootAfterOpening > 0 then warn("\n--- Performing global wait for", lootWaitTime, "seconds... ---"); task.wait(lootWaitTime)
    elseif #partsToLootAfterOpening == 0 then warn("\n--- No open containers identified for looting. Skipping wait and Loot Phase. ---")
    else warn("\n--- Loot wait time is 0. Proceeding directly to Loot Phase. ---") end

    -- Phase 2: Loot Gold from Identified Locations
    if #partsToLootAfterOpening > 0 then
        warn("\n--- Starting Phase 2: Looting Gold ---"); local uniquePartsLooted = {}
        for i, part in ipairs(partsToLootAfterOpening) do
            if not (part and part.Parent) then warn("    -- Skipping part #", i, "as it no longer exists."); continue end
            if uniquePartsLooted[part] then continue end
            local contextName = part.Name; local parentModel = part:FindFirstAncestorWhichIsA("Model"); if parentModel then contextName = parentModel.Name .. " " .. contextName end
            findAndLootGold(part, contextName .. " #" .. i); uniquePartsLooted[part] = true
        end
        warn("--- Finished Phase 2: Looting Gold ---")
    end

    -- Final Notification
    warn("--- Auto Loot Gold Finished ---")
    Library:Notify("Auto Loot Gold Finished (v" .. AutoLootVersion .. "). Looted " .. itemsLootedCount .. " gold items.", 3)

end,
DoubleClick = false, Disabled = false, Visible = true,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})

LeftGroupBox:AddButton({
Text = "+1 Revive (FE)",
Func = function()
shared.giveIt()
end,

Disabled = false,
Visible = true,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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

table.sort(room_numbers, function(a, b) return a > b end)

if #room_numbers < 2 then return nil end

local latest_room_number = room_numbers[2]
local latest_room_name = "Room" .. latest_room_number

return rooms_folder:FindFirstChild(latest_room_name)
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end

LeftGroupBox:AddButton({
Text = "Open Current Room Door",
Func = function()
if ClientMain and ClientMain.CLIENT.Values.CurrentRoom.Value and ClientMain.CLIENT.Values.CurrentRoom.Value.Name:find("Room") then
local Room = ClientMain.CLIENT.Values.CurrentRoom.Value
if Room:FindFirstChild("Door") and Room.Door:FindFirstChild("Hitbox") then
Room.Door.Hitbox.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
end
else
Library:Notify("You are not in a room!")
end
end,

Disabled = false,
Visible = true,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
LeftGroupBox:AddButton({
Text = "Open Latest Room Door",
Func = function()
local Room = get_latest_room()
if Room:FindFirstChild("Door") and Room.Door:FindFirstChild("Hitbox") then
Room.Door.Hitbox.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
end
end,

Disabled = false,
Visible = true,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
LeftGroupBox:AddButton({
Text = "Enable Observatory Lever",
Func = function()
if ClientMain and ClientMain.CLIENT.Values.CurrentRoom.Value.Name == "Room194" then
ClientMain.CLIENT.Values.CurrentRoom.Value:FindFirstChild("CaveLever", true).ProximityPrompt.Enabled = true
else
Library:Notify("You must be in the observatory!")
end
end,

Disabled = false,
Visible = true,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
local PartialGod = false
LeftGroupBox:AddToggle("PartialGod", {
Text = "Infinite Healing",

Default = false,
Disabled = false, 
Visible = true, 

Callback = function(Value)
	PartialGod = Value
end,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})

local InfRev = false
LeftGroupBox:AddToggle("InfRev", {
Text = "Infinite Revives",

Default = false,
Disabled = false, 
Visible = true, 

Callback = function(Value)
	InfRev = Value
end,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
task.spawn(function()
while wait() do
if InfRev then task.spawn(shared.giveIt) end
end
end)
local SIP
LeftGroupBox:AddDropdown("StealItemsPicker", {
SpecialType = "Player",
ExcludeLocalPlayer = true,
Text = "Steal Item Target",

Callback = function(Value)
	SIP = Value
end,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
local expectingDrop = false
LeftGroupBox:AddButton({
Text = "Steal target's equipped item",
Func = function()
if SIP and SIP.Character and SIP.Character:FindFirstChildWhichIsA("Tool") then
expectingDrop = true
print("RE")
RepStorage.Events.PlayerActions.DropItem:InvokeServer( SIP.Character:FindFirstChildWhichIsA("Tool"))

else
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

Library:Notify("Failed to steal!")
end
end,

Disabled = false,
Visible = true,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
workspace.DroppedItems.ChildAdded:Connect(function(item)
if not expectingDrop then return end
task.wait(0.5)
fireproximityprompt(item:FindFirstChild("Pickup", true))
Library:Notify("Stole item!")
expectingDrop = false
end)

local AutoCage = false
local DoConLoop = false
LeftGroupBox:AddToggle("AutoCage", {
Text = "Auto Escape Watcher-cage",

Default = true,
Disabled = false, 
Visible = false, 

Callback = function(Value)
    DoConLoop = Value
    if Value then
        for _, Connection in getconnections(RepStorage.Events.ThePrision.PlayerCaged.OnClientEvent) do
            Connection:Disable()
        end
    else
        for _, Connection in getconnections(RepStorage.Events.ThePrision.PlayerCaged.OnClientEvent) do
            Connection:Enable()
        end
    end
end,
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})

task.spawn(function()
while wait() do
if DoConLoop then
for _, Connection in getconnections(RepStorage.Events.ThePrision.PlayerCaged.OnClientEvent) do
Connection:Disable()
end
else
for _, Connection in getconnections(RepStorage.Events.ThePrision.PlayerCaged.OnClientEvent) do
Connection:Enable()
end
end
end
end)

RepStorage.Events.ThePrision.PlayerCaged.OnClientEvent:Connect(function()
if not AutoCage then return end
task.wait(4)
RepStorage.Events.ThePrision.MinigameFinished:FireServer()
end)
task.spawn(function()
while wait() do
if PartialGod then
RepStorage.Events.EntityEvents.DamageFromClient:FireServer({
AttackedBy = "Blacklight",
IsSet = true,
IgnoresHide = false,
Damage = math.huge
})
end
end
end)
local RightGroupBox = Tabs.Exploits:AddRightGroupbox("<b>Anti-Entity</b>")
local AntiEntity = {"Blacklight", "Screech", "Void", "Decoy", "Seek"}

for _, Entity in AntiEntity do
AntiEntityInternal[Entity] = false
RightGroupBox:AddToggle("Anti" .. Entity, {
Text = "Anti-" .. Entity,

Default = false,
    Disabled = false, 
    Visible = true, 

    Callback = function(Value)
        if Entity == "Screech" and Value == false and ClientMain then
            ClientMain.CLIENT.Values.ScreechActive.Value = false
        end
        if Entity == "Decoy" and Value == false then
            for _, Obj in workspace:GetDescendants() do
                if Obj.Name == "AttackRange" then
                    Obj.CanTouch = true
                end
            end
        elseif Entity == "Decoy" and Value then
            for _, Obj in workspace:GetDescendants() do
                if Obj.Name == "AttackRange" then
                    Obj.CanTouch = false
                end
            end
        end
        if Entity == "Seek" and Value == false then
            for _, Obj in workspace:GetDescendants() do
                if Obj.Name == "Hitbox" and Obj.Parent.Name == "Seek" then
                    Obj.CanTouch = true
                end
            end
        elseif Entity == "Seek" and Value then
            for _, Obj in workspace:GetDescendants() do
                if Obj.Name == "Hitbox" and Obj.Parent.Name == "Seek" then
                    Obj.CanTouch = false
                end
            end
        end
	   AntiEntityInternal[Entity] = Value
    end,
})
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end

workspace.DescendantAdded:Connect(function(Obj)
if Obj.Name == "AttackRange" and AntiEntityInternal["Decoy"] then
Obj.CanTouch = false
end
if Obj.Name == "Hitbox" and Obj.Parent.Name == "Seek" and AntiEntityInternal["Seek"] then
Obj.CanTouch = false
end
end)

task.spawn(function()
while wait() do
if AntiEntityInternal["Screech"] then
ClientMain.CLIENT.Values.ScreechActive.Value = true
end
if AntiEntityInternal["Watcher"] then
RepStorage:WaitForChild("Events"):WaitForChild("PlayerCrouching"):FireServer(true)
end
end
end)

task.spawn(function()
while wait() do
if workspace:FindFirstChild("WanderWatcher") then
workspace.WanderWatcher:FindFirstChild("PickupArea", true).CanTouch = not AntiEntityInternal["Watcher"]
end
end
end)

old = hookfunction(require(ClientMain.CLIENT.CurrentRoomDependency.Modules.Void).VoidPlayer, function(...)
if AntiEntityInternal["Void"] then
return
else
return old(...)
end
end)

task.spawn(function()
while wait() do
workspace.GameInfo.BlacklightDisabled.Value = AntiEntityInternal["Blacklight"]
end
end)

workspace.ChildAdded:Connect(function(Object)
if Object.Name == 'Eyes' and NotifyEntitiesInternal["Eyes"] then
Library:Notify('Eyes has spawned')
end
if Object.Name == 'Stare' and NotifyEntitiesInternal["Stare"] then
Library:Notify('Stare has spawned')
end
if Object.Name == 'Ram' and NotifyEntitiesInternal["Ram"] then
Library:Notify('Ram has spawned')
end
if Object.Name == 'Ambush' and NotifyEntitiesInternal["Ambush"] then
Library:Notify('Ambush has spawned')
end
if Object.Name == 'Rush' and NotifyEntitiesInternal["Rush"] then
Library:Notify('Rush has spawned')
end

end)

workspace.DescendantAdded:Connect(function(Object)
if Object.Name == 'ScreechAHHHH' and NotifyEntitiesInternal["Screech"] then
Library:Notify('Screech has spawned')
end
end)

workspace.GameInfo.HoardbatsActive:GetPropertyChangedSignal("Value"):Connect(function()
if workspace.GameInfo.HoardbatsActive.Value == true and NotifyEntitiesInternal["Hoardbats"] then
Library:Notify('Hoardbats Swarm has spawned')
end
end)

workspace.GameInfo.LureActive:GetPropertyChangedSignal("Value"):Connect(function()
if workspace.GameInfo.LureActive.Value == true and NotifyEntitiesInternal["Onslaught"]then
Library:Notify('Onslaught has spawned')
end
end)

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

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
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

})
MenuGroup:AddButton("Unload", function()
Library:Unload()
end)

Library:OnUnload(function()
ARCon = ARCon and ARCon:Disconnect()
shared.giveIt = nil
Toggles["FP"]:SetValue(true)
Toggles["FP"]:SetValue(false)
for _, toggle in Toggles do
toggle:SetValue(false)
end
end)

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

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
local esp = ESPLibrary:Add({
Name = name,
Model = part,
Color = colors[category],
MaxDistance = math.huge,
TextSize = 17,
ESPType = 'Highlight',
FillColor = colors[category],
OutlineColor = colors[category],
Tracer = {
Enabled = true,
Color = colors[category],
},
})
table.insert(allTrackedESPs, {
ESP = esp,
Category = category,
})

if not espCategories[category] then
    esp:Hide()
end

return esp
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end

local roomSpecESPs = {}

local function processRoom(room)
for _, object in room:GetDescendants() do
task.spawn(function()
if espCategories.HidingSpots then
if object.Name == 'Locker' or object.Name == 'Toolshed_Hiding' then
table.insert(roomSpecESPs, addESP(object, 'Hiding-Spot', 'HidingSpots'))
elseif object.Name == 'decoyLocker' then
table.insert(roomSpecESPs, addESP(object, 'Decoy', 'Entity'))
end
end

if espCategories.Objectives then
            if object.Name == 'OilCanister' then
                table.insert(roomSpecESPs, addESP(object, 'Oil Can', 'Objectives'))
            elseif object.Name == 'GasCanister' then
                table.insert(roomSpecESPs, addESP(object, 'Gas Canister', 'Objectives'))
            elseif object.Name == 'GeneratorPuzzle' then
                table.insert(roomSpecESPs, addESP(object, 'Generator', 'Objectives'))
            elseif object.Name == 'Terminal' then
                table.insert(roomSpecESPs, addESP(object, 'Terminal', 'Objectives'))
            elseif object.Name == 'Switch' and not object:FindFirstAncestor('Switch') and not object:FindFirstAncestor('Flashlight') then
                table.insert(roomSpecESPs, addESP(object, 'Fuse', 'Objectives'))
            elseif object.Name == 'GivingCoins' then
                table.insert(roomSpecESPs, addESP(object.Parent, 'Coins', 'Coins'))
            elseif object.Name == 'Container' and not object.Parent:HasTag("ContainerMarked") then
                object.Parent:AddTag("ContainerMarked")
                table.insert(roomSpecESPs, addESP(object.Parent, 'Container', 'Containers'))
            elseif object.Name == 'Minigame' and object:FindFirstChild('Switches') then
                table.insert(roomSpecESPs, addESP(object, 'Breaker Minigame', 'Objectives'))
            elseif object.Name == 'ObservatoryKey' then
                table.insert(roomSpecESPs, addESP(object, 'Key', 'Objectives'))
            elseif object.Name == 'SignModel' then
                local sign = object:WaitForChild('Sign')
                table.insert(roomSpecESPs, addESP(sign, 'Directional Sign', 'Objectives'))
                sign.Material = Enum.Material.Neon
                sign.Color = Color3.fromRGB(255, 255, 255)
            elseif object.Name == 'Control'
                and object.Parent.Name == 'Elevator'
                and object.Parent.Parent:FindFirstChild('ElevatorHandler') then
                table.insert(roomSpecESPs, addESP(object, 'Exit Elevator', 'Objectives'))
                object:WaitForChild('Sign').Material = Enum.Material.Neon
            elseif object.Name == 'OxygenTank' then
                table.insert(roomSpecESPs, addESP(object, 'Oxygen Can', 'Objectives'))
            elseif (object.Name == 'CaveLever' or object.Name == 'Lever')
                and not object:FindFirstAncestor('GeneratorPuzzle')
                and not object:FindFirstAncestor('EndPanel')
                and not object:FindFirstAncestor('GeneratorDeco') then
                if object:GetAttribute('Order') then
                    table.insert(roomSpecESPs, addESP(object, 'Lever ' .. object:GetAttribute('Order'), 'Objectives'))
                else
                    table.insert(roomSpecESPs, addESP(object, 'Lever', 'Objectives'))
                end
            end
        end

        if espCategories.Doors then
            if (object.Name == 'Door' and object.Parent.Parent.Name == 'GeneratedRooms') or object.Name == 'Chunk_Watcher' then
                table.insert(roomSpecESPs, addESP(object, 'Door', 'Doors'))
            end
        end
    end)
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end

local function doProcVal(object)
local foundRoom = object.Value

if foundRoom then
    for _, ESP in roomSpecESPs do
        ESP:Hide()
    end
    table.clear(roomSpecESPs)
    processRoom(foundRoom)
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end

local function processLocalPlayerDescendant(object)
if object.Name == 'CurrentRoom' and object:IsA('ObjectValue') then
print('Found val at ' .. object:GetFullName())
task.delay(1, function()
doProcVal(object)
end)

object:GetPropertyChangedSignal('Value'):Connect(function()
        doProcVal(object)
    end)
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end

game.Players.LocalPlayer.DescendantAdded:Connect(processLocalPlayerDescendant)
for _, object: Instance in game.Players.LocalPlayer:GetDescendants() do
processLocalPlayerDescendant(object)
end

local function processObject(object)
if object:FindFirstAncestor('Game Configuration') then return end

if espCategories.Entity then
    if object.Name == 'HoardbatClient' or object.Name == "HoardBat" then
        addESP(object, 'Hoardbat', 'Entity')
    elseif object.Name == 'Eyes' and not object.Parent.Name == 'Bob' then
        addESP(object, 'Eyes', 'Entity')
    elseif object.Name == 'Stare' then
        addESP(object, 'Stare', 'Entity')
    elseif object.Name == 'Ram' then
        addESP(object, 'Ram', 'Entity')
    elseif object.Name == 'Ambush' then
        addESP(object, 'Ambush', 'Entity')
    elseif object.Name == 'Rush' then
        addESP(object, 'Rush', 'Entity')
    elseif object.Name == 'FigureRig' then
        addESP(object, 'Figure', 'Entity')
    elseif object.Name == 'WanderWatcher' then
        addESP(object, 'Watcher', 'Entity')
    elseif object.Name == 'Seek' then
        addESP(object, 'Seek', 'Entity')
    end
end
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
IGNORE_WHEN_COPYING_END

end

workspace.DescendantAdded:Connect(processObject)
for _, object in workspace:GetDescendants() do
processObject(object)
end
