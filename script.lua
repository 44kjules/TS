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

local openEggRemote, startRemote, finishRemote

for _,v in ipairs(ReplicatedStorage:GetDescendants()) do
	if v.Name == "OpenEgg" then
		openEggRemote = v
	elseif v.Name == "StartMinigame" then
		startRemote = v
	elseif v.Name == "FinishMinigame" then
		finishRemote = v
	end
end

print("Remotes:", openEggRemote, startRemote, finishRemote)

-- =========================
-- DEBUG: PRINT ALL EGGS
-- =========================

task.spawn(function()
	task.wait(2)

	local eggsFolder = workspace:FindFirstChild("Eggs")
	if eggsFolder then
		print("==== WORKSPACE EGGS ====")
		for _,egg in ipairs(eggsFolder:GetChildren()) do
			print(egg.Name)
		end
		print("==== END ====")
	else
		warn("Eggs folder not found")
	end
end)

-- =========================
-- MANUAL EGG LIST (YOU EDIT THIS)
-- =========================

local eggList = {
	"Azteca",
	"Viking",
	"Space",
	"Desert"
}

local selectedEgg = "Azteca"
local eggAmount = 11

-- =========================
-- STATE VARIABLES
-- =========================

local autoEgg = false
local autoMini = false
local antiAFK_PC = false
local antiAFK_Mobile = false

-- =========================
-- UI
-- =========================

FarmTab:CreateDropdown({
	Name = "Select Egg",
	Options = eggList,
	CurrentOption = selectedEgg,
	Callback = function(option)
		selectedEgg = option[1] or option -- FIXED
		print("Selected Egg:", selectedEgg)
	end
})

FarmTab:CreateSlider({
	Name = "Egg Amount",
	Range = {1, 11},
	CurrentValue = 11,
	Callback = function(v)
		eggAmount = v
	end
})

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

-- =========================
-- LOOPS
-- =========================

-- AUTO HATCH
task.spawn(function()
	while true do
		if autoEgg and openEggRemote then
			print("Hatching:", selectedEgg, eggAmount)

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
