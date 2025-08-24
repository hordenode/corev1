-- BedWars Script for CatV5
-- Implements a Killaura and Aimbot.

local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = playersService.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Create a new category in the GUI for BedWars
local combatCategory = vape:AddCategory("BedWars", "combaticon")

local killaura = combatCategory:AddToggle({
    Id = "Killaura",
    Name = "Killaura",
    Description = "Automatically attacks the nearest enemy player.",
    Default = false
})

local aimbot = combatCategory:AddToggle({
    Id = "Aimbot",
    Name = "Aimbot",
    Description = "Automatically aims at the nearest enemy player.",
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

    local closestPlayer, minDistance = nil, math.huge
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

-- Main Killaura and Aimbot loop
runService.Heartbeat:Connect(function()
    local target = getTarget()
    if not target or not target.Character or not target.Character:FindFirstChild("Humanoid") or target.Character.Humanoid.Health <= 0 then
        return
    end

    if aimbot.Enabled then
        -- Aimbot: Make the local player's character face the target
        local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local targetPosition = target.Character.HumanoidRootPart.Position
            local lookVector = (targetPosition - humanoidRootPart.Position).Unit
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, targetPosition)
        end
    end

    if killaura.Enabled then
        -- Use the SilentAim function from main.lua
        vape:SilentAim(target, function()
            -- Attempt to fire a generic SwordHit remote. 
            -- You might need to replace 'SwordHit' with the actual remote event name and parameters used for attacking in BedWars.
            local swordHitRemote = replicatedStorage:FindFirstChild("SwordHit") -- Assuming it's directly in ReplicatedStorage
            if swordHitRemote and swordHitRemote:IsA("RemoteEvent") then
                swordHitRemote:FireServer(target.Character) -- Assuming the remote takes the target's character as an argument
                vape:CreateNotification("Killaura", "Attacked " .. target.Name, 0.5, "info")
            else
                vape:CreateNotification("Killaura", "'SwordHit' remote not found or is not a RemoteEvent. Please check the remote name.", 2, "alert")
            end
        end)
    end
end)