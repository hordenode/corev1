local run = function(func) func() end
local cloneref = cloneref or function(obj) return obj end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local inputService = cloneref(game:GetService('UserInputService'))
local runService = cloneref(game:GetService('RunService'))
local workspace = cloneref(game:GetService('Workspace'))

local lplr = playersService.LocalPlayer
local vape = shared.vape
local entitylib = vape.Libraries.entity
local sessioninfo = vape.Libraries.sessioninfo
local bedwars = {}

local function notif(...)
	return vape:CreateNotification(...)
end

run(function()
	local function dumpRemote(tab)
		local ind = table.find(tab, 'Client')
		return ind and tab[ind + 1] or ''
	end

	local KnitInit, Knit
	repeat
		KnitInit, Knit = pcall(function() return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 9) end)
		if KnitInit then break end
		task.wait()
	until KnitInit
	if not debug.getupvalue(Knit.Start, 1) then
		repeat task.wait() until debug.getupvalue(Knit.Start, 1)
	end
	local Flamework = require(replicatedStorage['rbxts_include']['node_modules']['@flamework'].core.out).Flamework
	local Client = require(replicatedStorage.TS.remotes).default.Client

	bedwars = setmetatable({
		Client = Client,
		CrateItemMeta = debug.getupvalue(Flamework.resolveDependency('client/controllers/global/reward-crate/crate-controller@CrateController').onStart, 3),
		Store = require(lplr.PlayerScripts.TS.ui.store).ClientStore
	}, {
		__index = function(self, ind)
			rawset(self, ind, Knit.Controllers[ind])
			return rawget(self, ind)
		end
	})

	local kills = sessioninfo:AddItem('Kills')
	local beds = sessioninfo:AddItem('Beds')
	local wins = sessioninfo:AddItem('Wins')
	local games = sessioninfo:AddItem('Games')

	vape:Clean(function()
		table.clear(bedwars)
	end)
end)

for _, v in vape.Modules do
	if v.Category == 'Combat' or v.Category == 'Minigames' then
		vape:Remove(i)
	end

end

run(function()
    local Aimbot
    local aimConnection

    Aimbot = vape.Categories.Combat:CreateModule({
        Name = 'Aimbot',
        Description = 'Automatically aims at enemies.',
        Settings = {
            FOV = vape.CreateSlider(180, 5, 360, 1),
            Smoothness = vape.CreateSlider(0.1, 0, 1, 0.05),
            TargetPart = vape.CreateDropdown({'Head', 'Torso', 'HumanoidRootPart'}, 'Head'),
            TeamCheck = vape.CreateToggle(true),
            WallCheck = vape.CreateToggle(false),
        },
        Function = function(callback)
            if callback then
                aimConnection = runService.RenderStepped:Connect(function()
                    local lplrChar = lplr.Character
                    if not lplrChar or not lplrChar:FindFirstChild('Humanoid') or lplrChar.Humanoid.Health <= 0 then return end

                    local bestTarget = nil
                    local minDistance = math.huge
                    local lplrHead = lplrChar:FindFirstChild('Head')
                    if not lplrHead then return end

                    local origin = lplrHead.Position
                    local lplrLookVector = workspace.CurrentCamera.CFrame.LookVector

                    for _, player in pairs(playersService:GetPlayers()) do
                        if player ~= lplr and player.Character and player.Character:FindFirstChild('Humanoid') and player.Character.Humanoid.Health > 0 then
                            if Aimbot.Settings.TeamCheck.Value and player.Team == lplr.Team then continue end

                            local targetPart = player.Character:FindFirstChild(Aimbot.Settings.TargetPart.Value)
                            if not targetPart then continue end

                            local targetPos = targetPart.Position
                            local direction = (targetPos - origin).Unit
                            local distance = (targetPos - origin).Magnitude

                            -- FOV Check
                            local angle = math.deg(math.acos(lplrLookVector:Dot(direction)))
                            if angle > Aimbot.Settings.FOV.Value / 2 then continue end

                            -- Wall Check
                            if not Aimbot.Settings.WallCheck.Value then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterDescendantsInstances = {lplrChar, player.Character}
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                local rayResult = workspace:Raycast(origin, direction * distance, rayParams)
                                if rayResult and rayResult.Instance.Parent ~= player.Character then
                                    continue -- Obstacle in the way
                                end
                            end

                            if distance < minDistance then
                                minDistance = distance
                                bestTarget = targetPart
                            end
                        end
                    end

                    if bestTarget then
                        local targetCFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, bestTarget.Position)
                        local smoothness = Aimbot.Settings.Smoothness.Value
                        workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(targetCFrame, smoothness)
                    end
                end)
            else
                if aimConnection then
                    aimConnection:Disconnect()
                    aimConnection = nil
                end
            end
        end,
    })
end)

run(function()
    local KillAura
    local auraConnection
    local lastAttackTime = 0

    KillAura = vape.Categories.Combat:CreateModule({
        Name = 'KillAura',
        Description = 'Automatically attacks nearby enemies.',
        Settings = {
            Range = vape.CreateSlider(10, 1, 50, 1),
            Delay = vape.CreateSlider(0.1, 0.05, 1, 0.01),
            TargetPlayers = vape.CreateToggle(true),
            TargetNPCs = vape.CreateToggle(false),
            TeamCheck = vape.CreateToggle(true),
            ThroughWalls = vape.CreateToggle(false),
        },
        Function = function(callback)
            if callback then
                auraConnection = runService.RenderStepped:Connect(function()
                    local lplrChar = lplr.Character
                    if not lplrChar or not lplrChar:FindFirstChild('Humanoid') or lplrChar.Humanoid.Health <= 0 then return end

                    local lplrHumanoidRootPart = lplrChar:FindFirstChild('HumanoidRootPart')
                    if not lplrHumanoidRootPart then return end

                    local currentTime = tick()
                    if currentTime - lastAttackTime < KillAura.Settings.Delay.Value then return end

                    local bestTarget = nil
                    local minDistance = KillAura.Settings.Range.Value

                    for _, targetPlayer in pairs(playersService:GetPlayers()) do
                        if targetPlayer ~= lplr and targetPlayer.Character and targetPlayer.Character:FindFirstChild('Humanoid') and targetPlayer.Character.Humanoid.Health > 0 then
                            if KillAura.Settings.TeamCheck.Value and targetPlayer.Team == lplr.Team then continue end
                            if not KillAura.Settings.TargetPlayers.Value then continue end

                            local targetHumanoidRootPart = targetPlayer.Character:FindFirstChild('HumanoidRootPart')
                            if not targetHumanoidRootPart then continue end

                            local distance = (lplrHumanoidRootPart.Position - targetHumanoidRootPart.Position).Magnitude
                            if distance <= minDistance then
                                -- Wall Check
                                if not KillAura.Settings.ThroughWalls.Value then
                                    local rayParams = RaycastParams.new()
                                    rayParams.FilterDescendantsInstances = {lplrChar, targetPlayer.Character}
                                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                    local rayResult = workspace:Raycast(lplrHumanoidRootPart.Position, (targetHumanoidRootPart.Position - lplrHumanoidRootPart.Position).Unit * distance, rayParams)
                                    if rayResult and rayResult.Instance.Parent ~= targetPlayer.Character then
                                        continue -- Obstacle in the way
                                    end
                                end
                                bestTarget = targetPlayer.Character
                                minDistance = distance
                            end
                        end
                    end

                    -- Add NPC targeting logic here if needed, similar to player targeting
                    -- For now, assuming NPCs are also Characters with Humanoids
                    if KillAura.Settings.TargetNPCs.Value then
                        for _, descendant in pairs(workspace:GetDescendants()) do
                            if descendant:IsA('Model') and descendant:FindFirstChildOfClass('Humanoid') and descendant.Humanoid.Health > 0 then
                                if descendant:FindFirstChild('HumanoidRootPart') and (descendant.HumanoidRootPart.Position - lplrHumanoidRootPart.Position).Magnitude <= KillAura.Settings.Range.Value then
                                    -- Basic NPC check, can be improved with specific tags/names
                                    if not playersService:GetPlayerFromCharacter(descendant) then -- Ensure it's not a player
                                        local distance = (lplrHumanoidRootPart.Position - descendant.HumanoidRootPart.Position).Magnitude
                                        if distance <= minDistance then
                                            -- Wall Check for NPCs
                                            if not KillAura.Settings.ThroughWalls.Value then
                                                local rayParams = RaycastParams.new()
                                                rayParams.FilterDescendantsInstances = {lplrChar, descendant}
                                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                                local rayResult = workspace:Raycast(lplrHumanoidRootPart.Position, (descendant.HumanoidRootPart.Position - lplrHumanoidRootPart.Position).Unit * distance, rayParams)
                                                if rayResult and rayResult.Instance.Parent ~= descendant then
                                                    continue -- Obstacle in the way
                                                end
                                            end
                                            bestTarget = descendant
                                            minDistance = distance
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if bestTarget then
                        -- Simulate attack. This is a placeholder. Actual remote might vary.
                        -- You might need to find the actual remote event used for attacking in the game.
                        -- For example, if the game uses a 'SwordHit' remote, you'd do:
                        -- bedwars.Client:GetNamespace('Combat'):Get('SwordHit'):SendToServer(bestTarget)
                        -- For now, we'll just print a message.
                        -- print("Attacking: " .. bestTarget.Name)
                        
                        -- Attempt to fire a common attack remote if it exists
                        local swordHitRemote = bedwars.Client:GetNamespace('Combat'):Get('SwordHit') -- Assuming 'Combat' namespace and 'SwordHit' remote
                        if swordHitRemote then
                            swordHitRemote:SendToServer(bestTarget)
                        else
                            -- Fallback if the specific remote is not found or doesn't work
                            -- This is a generic attempt and might not work for all games.
                            local useAbilityRemote = bedwars.Client:Get('useAbility') -- From remotes.txt
                            if useAbilityRemote then
                                useAbilityRemote:SendToServer('SwordAttack', bestTarget) -- Assuming 'SwordAttack' is an ability name
                            end
                        end

                        lastAttackTime = currentTime
                    end
                end)
            else
                if auraConnection then
                    auraConnection:Disconnect()
                    auraConnection = nil
                end
            end
        end,
    })
end)

run(function()
    local AntiKnockback
    local antiKnockbackConnection

    AntiKnockback = vape.Categories.Movement:CreateModule({
        Name = 'Anti-Knockback',
        Description = 'Reduces or eliminates knockback.',
        Settings = {
            Strength = vape.CreateSlider(100, 0, 100, 1),
        },
        Function = function(callback)
            if callback then
                antiKnockbackConnection = runService.Heartbeat:Connect(function()
                    local lplrChar = lplr.Character
                    if not lplrChar or not lplrChar:FindFirstChild('Humanoid') or lplrChar.Humanoid.Health <= 0 then return end

                    local lplrHumanoidRootPart = lplrChar:FindFirstChild('HumanoidRootPart')
                    if not lplrHumanoidRootPart then return end

                    local currentVelocity = lplrHumanoidRootPart.AssemblyLinearVelocity
                    local strength = AntiKnockback.Settings.Strength.Value / 100

                    if currentVelocity.Magnitude > 0.1 then -- Only apply if there's significant velocity
                        lplrHumanoidRootPart.AssemblyLinearVelocity = currentVelocity * (1 - strength)
                    end
                end)
            else
                if antiKnockbackConnection then
                    antiKnockbackConnection:Disconnect()
                    antiKnockbackConnection = nil
                end
            end
        end,
    })
end)

run(function()
    local Speed
    local originalWalkSpeed
    local originalJumpPower

    Speed = vape.Categories.Movement:CreateModule({
        Name = 'Speed',
        Description = 'Increases player movement speed and jump power.',
        Settings = {
            WalkSpeed = vape.CreateSlider(16, 16, 100, 1),
            JumpPower = vape.CreateSlider(50, 50, 100, 1),
        },
        Function = function(callback)
            local lplrHumanoid = lplr.Character and lplr.Character:FindFirstChildOfClass('Humanoid')
            if not lplrHumanoid then return end

            if callback then
                originalWalkSpeed = lplrHumanoid.WalkSpeed
                originalJumpPower = lplrHumanoid.JumpPower
                lplrHumanoid.WalkSpeed = Speed.Settings.WalkSpeed.Value
                lplrHumanoid.JumpPower = Speed.Settings.JumpPower.Value
            else
                lplrHumanoid.WalkSpeed = originalWalkSpeed
                lplrHumanoid.JumpPower = originalJumpPower
            end
        end,
    })
end)

run(function()
    local Fly
    local flyConnection
    local originalGravity
    local flyRemote = bedwars.Client:Get('SetFlyEnabled') -- Assuming this remote exists and controls fly

    Fly = vape.Categories.Movement:CreateModule({
        Name = 'Fly',
        Description = 'Allows the player to fly.',
        Settings = {
            Speed = vape.CreateSlider(1, 0.1, 5, 0.1),
            Bypass = vape.CreateToggle(false), -- Placeholder for potential anti-cheat bypass
        },
        Function = function(callback)
            local lplrHumanoid = lplr.Character and lplr.Character:FindFirstChildOfClass('Humanoid')
            local lplrHumanoidRootPart = lplr.Character and lplr.Character:FindFirstChild('HumanoidRootPart')

            if not lplrHumanoid or not lplrHumanoidRootPart then return end

            if callback then
                originalGravity = workspace.Gravity
                workspace.Gravity = 0 -- Disable gravity

                if flyRemote then
                    flyRemote:SendToServer(true)
                end

                flyConnection = runService.RenderStepped:Connect(function()
                    local flySpeed = Fly.Settings.Speed.Value
                    local moveDirection = Vector3.new(0,0,0)

                    if inputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
                    end
                    if inputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
                    end
                    if inputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
                    end
                    if inputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
                    end
                    if inputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveDirection = moveDirection + Vector3.new(0,1,0)
                    end
                    if inputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        moveDirection = moveDirection - Vector3.new(0,1,0)
                    end

                    if moveDirection.Magnitude > 0 then
                        lplrHumanoidRootPart.CFrame = lplrHumanoidRootPart.CFrame + moveDirection.Unit * flySpeed
                    end
                end)
            else
                workspace.Gravity = originalGravity
                if flyRemote then
                    flyRemote:SendToServer(false)
                end
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
            end
        end,
    })
end)

run(function()
    local PlayerESP
    local espConnections = {}
    local activeHighlights = {}

    local function createPlayerESP(player)
        local highlight = Instance.new('Highlight')
        highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Default red for enemies
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Enabled = true
        highlight.Parent = player.Character
        highlight.Adornee = player.Character.HumanoidRootPart

        -- Name ESP
        local nameTag = Instance.new('BillboardGui')
        nameTag.AlwaysOnTop = true
        nameTag.Size = UDim2.new(0, 100, 0, 20)
        nameTag.Adornee = player.Character.HumanoidRootPart
        nameTag.Parent = player.Character

        local nameLabel = Instance.new('TextLabel')
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextScaled = true
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Text = player.Name
        nameLabel.Parent = nameTag

        -- Health ESP
        local healthTag = Instance.new('BillboardGui')
        healthTag.AlwaysOnTop = true
        healthTag.Size = UDim2.new(0, 100, 0, 10)
        healthTag.Adornee = player.Character.HumanoidRootPart
        healthTag.Parent = player.Character
        healthTag.StudsOffset = Vector3.new(0, 1.5, 0)

        local healthBar = Instance.new('Frame')
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = healthTag

        local healthLabel = Instance.new('TextLabel')
        healthLabel.Size = UDim2.new(1, 0, 1, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.TextScaled = true
        healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        healthLabel.TextStrokeTransparency = 0
        healthLabel.Parent = healthBar

        local function updateHealth()
            local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
            if humanoid then
                healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                healthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - humanoid.Health / humanoid.MaxHealth), 255 * (humanoid.Health / humanoid.MaxHealth), 0)
                healthLabel.Text = math.floor(humanoid.Health) .. '/' .. math.floor(humanoid.MaxHealth)
            end
        end

        local healthChangedConnection = player.Character.Humanoid.HealthChanged:Connect(updateHealth)
        updateHealth()

        return {
            Highlight = highlight,
            NameTag = nameTag,
            HealthTag = healthTag,
            HealthChangedConnection = healthChangedConnection
        }
    end

    local function removePlayerESP(playerUsername)
        if activeHighlights[playerUsername] then
            activeHighlights[playerUsername].Highlight:Destroy()
            activeHighlights[playerUsername].NameTag:Destroy()
            activeHighlights[playerUsername].HealthTag:Destroy()
            activeHighlights[playerUsername].HealthChangedConnection:Disconnect()
            activeHighlights[playerUsername] = nil
        end
    end

    PlayerESP = vape.Categories.Render:CreateModule({
        Name = 'Player ESP',
        Description = 'Shows players through walls.',
        Settings = {
            BoxESP = vape.CreateToggle(true),
            NameESP = vape.CreateToggle(true),
            HealthESP = vape.CreateToggle(true),
            TeamColor = vape.CreateToggle(true),
            Distance = vape.CreateSlider(500, 10, 1000, 10),
        },
        Function = function(callback)
            if callback then
                -- Initial setup for existing players
                for _, player in pairs(playersService:GetPlayers()) do
                    if player ~= lplr and player.Character and player.Character:FindFirstChild('Humanoid') then
                        activeHighlights[player.Name] = createPlayerESP(player)
                    end
                end

                -- Listen for new players
                espConnections.PlayerAdded = playersService.PlayerAdded:Connect(function(player)
                    player.CharacterAdded:Connect(function(char)
                        if player ~= lplr and char:FindFirstChild('Humanoid') then
                            activeHighlights[player.Name] = createPlayerESP(player)
                        end
                    end)
                end)

                -- Listen for players leaving
                espConnections.PlayerRemoving = playersService.PlayerRemoving:Connect(function(player)
                    removePlayerESP(player.Name)
                end)

                -- Update ESP visibility based on settings
                espConnections.RenderStepped = runService.RenderStepped:Connect(function()
                    for playerName, espData in pairs(activeHighlights) do
                        local player = playersService:FindFirstChild(playerName)
                        if player and player.Character and player.Character:FindFirstChild('Humanoid') then
                            local distance = (lplr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            local shouldBeVisible = distance <= PlayerESP.Settings.Distance.Value

                            espData.Highlight.Enabled = PlayerESP.Settings.BoxESP.Value and shouldBeVisible
                            espData.NameTag.Enabled = PlayerESP.Settings.NameESP.Value and shouldBeVisible
                            espData.HealthTag.Enabled = PlayerESP.Settings.HealthESP.Value and shouldBeVisible

                            if PlayerESP.Settings.TeamColor.Value then
                                espData.Highlight.FillColor = player.TeamColor.Color
                                espData.Highlight.OutlineColor = player.TeamColor.Color
                            else
                                espData.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                espData.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            end
                        else
                            removePlayerESP(playerName)
                        end
                    end
                end)

            else
                -- Disconnect all connections
                for _, connection in pairs(espConnections) do
                    if connection and typeof(connection) == 'RBXScriptConnection' then
                        connection:Disconnect()
                    end
                end
                espConnections = {}

                -- Remove all active ESP visuals
                for playerName, _ in pairs(activeHighlights) do
                    removePlayerESP(playerName)
                end
                activeHighlights = {}
            end
        end,
    })
end)