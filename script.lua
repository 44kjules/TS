-- JULES HUB

-- LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Jules Hub",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "by Jules",
	ConfigurationSaving = {Enabled = false}
})

local FarmTab = Window:CreateTab("Farming")
local UtilityTab = Window:CreateTab("Utility")

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- =========================
-- FIND REMOTES
-- =========================

local openEggRemote, startRemote, finishRemote, totemRemote

for _,v in ipairs(ReplicatedStorage:GetDescendants()) do
	if v.Name == "OpenEgg" then
		openEggRemote = v
	elseif v.Name == "StartMinigame" then
		startRemote = v
	elseif v.Name == "FinishMinigame" then
		finishRemote = v
	elseif v.Name == "PlaceTotem" and v:IsA("RemoteFunction") then
		totemRemote = v
	end
end

local tapRemote

local eventsFolder = nil

for _,v in ipairs(ReplicatedStorage:GetDescendants()) do
	if v.Name == "Events" then
		eventsFolder = v
		break
	end
end

if eventsFolder then
	local children = eventsFolder:GetChildren()
	tapRemote = children[27]
end

print("Tap Remote:", tapRemote)

print("Remotes:", openEggRemote, startRemote, finishRemote, totemRemote)

-- =========================
-- STATE VARIABLES
-- =========================

local autoEgg = false
local autoMini = false
local autoTotem = false
local antiAFK_PC = false
local antiAFK_Mobile = false
local autoTap = false
-- EGG SETTINGS (MANUAL)
local eggList = {
	"Azteca",
	"Viking",
	"Space",
	"Spring Blossom"
}

local selectedEgg = "Azteca"
local eggAmount = 13

-- =========================
-- UI (ONLY SET VARIABLES)
-- =========================

FarmTab:CreateToggle({
	Name = "Auto Hatch",
	CurrentValue = false,
	Callback = function(v)
		autoEgg = v
	end
})

FarmTab:CreateToggle({
	Name = "Auto Dig Minigame",
	CurrentValue = false,
	Callback = function(v)
		autoMini = v
	end
})

FarmTab:CreateToggle({
	Name = "Auto Totem",
	CurrentValue = false,
	Callback = function(v)
		autoTotem = v
	end
})

UtilityTab:CreateToggle({
	Name = "Anti AFK (PC)",
	CurrentValue = false,
	Callback = function(v)
		antiAFK_PC = v
	end
})

UtilityTab:CreateToggle({
	Name = "Anti AFK (Mobile)",
	CurrentValue = false,
	Callback = function(v)
		antiAFK_Mobile = v
	end
})

FarmTab:CreateDropdown({
	Name = "Select Egg",
	Options = eggList,
	CurrentOption = selectedEgg,
	Callback = function(option)
		selectedEgg = option[1] or option
		print("Selected Egg:", selectedEgg)
	end
})

FarmTab:CreateSlider({
	Name = "Egg Amount",
	Range = {1, 13},
	CurrentValue = 13,
	Callback = function(v)
		eggAmount = v
	end
})

FarmTab:CreateToggle({
	Name = "Auto Tap",
	CurrentValue = false,
	Callback = function(v)
		autoTap = v
	end
})

-- =========================
-- LOOPS
-- =========================

-- AUTO HATCH
task.spawn(function()
	while true do
		if autoEgg and openEggRemote then
			pcall(function()
				openEggRemote:InvokeServer(selectedEgg, eggAmount)
			end)
		end
		task.wait(0.1)
	end
end)

-- AUTO DIG
task.spawn(function()
	while true do
		if autoMini and startRemote and finishRemote then
			for i = 1,15 do
				if not autoMini then break end

				pcall(function()
					startRemote:InvokeServer("DigGame")
					finishRemote:InvokeServer("DigGame")
				end)

				task.wait(1)
			end

			task.wait(60)
		end

		task.wait(1)
	end
end)

-- AUTO TOTEM
task.spawn(function()
	while not totemRemote do
		for _,v in ipairs(ReplicatedStorage:GetDescendants()) do
			if v.Name == "PlaceTotem" and v:IsA("RemoteFunction") then
				totemRemote = v
				break
			end
		end
		task.wait(1)
	end

	print("Totem Remote Found:", totemRemote)

	while true do
		if autoTotem then
			local success, err = pcall(function()
				totemRemote:InvokeServer(
					"TotemOfLuck",
					{
						X = -31486.48,
						Y = 5808.20,
						Z = 3577.79
					}
				)
			end)

			if not success then
				warn("Totem Error:", err)
			end
		end

		task.wait(1)
	end
end)

-- =========================
-- ANTI AFK
-- =========================

player.Idled:Connect(function()
	if antiAFK_PC then
		VirtualUser:CaptureController()
		VirtualUser:SetKeyDown(" ")
		task.wait(0.1)
		VirtualUser:SetKeyUp(" ")
	end

	if antiAFK_Mobile then
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Jump = true
		end
	end
end)
---atuotap

task.spawn(function()
	while true do
		if autoTap and tapRemote then
			pcall(function()
				tapRemote:FireServer(true, nil, true)
			end)
		end
		task.wait(0.05) -- fast but safe
	end
end)


for i,v in ipairs(eventsFolder:GetChildren()) do
	print(i, v)
end

print("Jules Hub Loaded")