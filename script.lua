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
-- STATE VARIABLES
-- =========================

local autoEgg = false
local autoMini = false
local autoTotem = false
local autoTap = false
local antiAFK_PC = false
local antiAFK_Mobile = false
local tapRemote = nil

-- EGG SETTINGS
local eggList = {
	"Azteca",
	"Viking",
	"Space",
	"Spring Blossom"
}

local selectedEgg = "Spring Blossom"
local eggAmountList = {"1","7","13"}
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

print("Remotes:", openEggRemote, startRemote, finishRemote, totemRemote)

-- =========================
-- TAP REMOTE (INDEX 27)
-- =========================

task.spawn(function()
	local eventsFolder = ReplicatedStorage
		:WaitForChild("8e451043-6fff-443b-9aaa-8321310685ea")
		:WaitForChild("Events")

	task.wait(1)

	local children = eventsFolder:GetChildren()
	tapRemote = children[27]

	print("Tap Remote:", tapRemote)
end)

-- =========================
-- UI
-- =========================

FarmTab:CreateToggle({
	Name = "Auto Hatch",
	CurrentValue = false,
	Callback = function(v)
		autoEgg = v
	end
})

FarmTab:CreateToggle({
	Name = "Auto Tap",
	CurrentValue = false,
	Callback = function(v)
		autoTap = v
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

FarmTab:CreateDropdown({
	Name = "Egg Amount",
	Options = eggAmountList,
	CurrentOption = {"13"},
	Callback = function(v)
		eggAmount = tonumber(v[1])
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

-- AUTO TAP
task.spawn(function()
	while true do
		if autoTap and tapRemote then
			pcall(function()
				tapRemote:FireServer(true, nil, true)
			end)
		end
		task.wait(0.05)
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
			pcall(function()
				totemRemote:InvokeServer(
					"TotemOfLuck",
					{
						X = -31486.48,
						Y = 5808.20,
						Z = 3577.79
					}
				)
			end)
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

print("Jules Hub Loaded")