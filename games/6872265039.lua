-- BedWars Script for CatV5
-- Implements a Killaura using the SilentAim vulnerability patch.

local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = playersService.LocalPlayer

-- Create a new category in the GUI for BedWars
local combatCategory = vape:AddCategory("BedWars", "combaticon")
local killaura = combatCategory:AddToggle({
    Id = "Killaura",
    Name = "Killaura",
    Description = "Automatically attacks the nearest enemy player.",
    Default = false
})

local auraTarget = combatCategory:AddPlayerDropdown("Target", "Select a specific player to target", function(player)
    return player ~= localPlayer
end)

local function getTarget()
    local selectedTarget = auraTarget.Value
    if selectedTarget and selectedTarget.Character then
        return selectedTarget
    end

    local closestPlayer, minDistance = nil, 100
    for _, player in ipairs(playersService:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (localPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < minDistance then
                closestPlayer = player
                minDistance = distance
            end
        end
    end
    return closestPlayer
end

-- Main Killaura loop
runService.Heartbeat:Connect(function()
    if not killaura.Enabled then return end

    local target = getTarget()
    if target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
        -- Use the SilentAim function from main.lua
        vape:SilentAim(target, function()
            --[[
                !!! IMPORTANT !!!
                This is a placeholder. You need to find the remote event in BedWars
                that is used to deal damage and fire it here.

                Example:
                game:GetService("ReplicatedStorage").Game.Remotes.Damage:FireServer(target.Character, 10)
            ]]
            vape:CreateNotification("Killaura", "Attacked " .. target.Name, 0.5, "info")
        end)
    end
end)
