repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

shared.VapeDeveloper = true
getgenv().run = task.spawn

if identifyexecutor then
	if table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/new-qwertyui/CatV5/'..readfile('newcatvape/profiles/commit.txt')..'/'..select(1, path:gsub('newcatvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[ 
				shared.VapeDeveloper = true
				loadfile('newcatvape/init.lua')({
					Developer = true
				})
			]]
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
			vape:CreateNotification('Cat', 'We have a discord server! If theres any problems, please report them here: discord.gg/pVEB6qJh33', 13, 'alert')
		end
	end
end

if not isfile('newcatvape/profiles/gui.txt') then
	writefile('newcatvape/profiles/gui.txt', 'new')
end
local gui = readfile('newcatvape/profiles/gui.txt')

if gui == nil or gui == '' then
	gui = 'new'
end

if not isfolder('newcatvape/assets/'..gui) then
	makefolder('newcatvape/assets/'..gui)
end
vape = loadstring(downloadFile('newcatvape/guis/'..gui..'.lua'), 'gui')()
shared.vape = vape

-- Anti-Cheat Disabler
task.spawn(function()
    local player = playersService.LocalPlayer
    local function findAndDisable(instance)
        for _, child in ipairs(instance:GetChildren()) do
            if child:IsA("LocalScript") and (child.Name:lower():find("anti") or child.Name:lower():find("cheat") or child.Name:lower():find("exploit")) then
                child.Disabled = true
                vape:CreateNotification('Vape', 'Disabled suspicious script: ' .. child.Name, 5, 'alert')
            end
        end
    end

    findAndDisable(player.PlayerGui)
    player.CharacterAdded:Connect(function(character)
        task.wait(2) -- Wait for other scripts to load in character
        findAndDisable(character)
    end)
    if player.Character then
        findAndDisable(player.Character)
    end
end)

-- Silent Aim / Teleport Hit Vulnerability
function vape:SilentAim(target, attackFunction)
    local localPlayer = playersService.LocalPlayer
    if not localPlayer.Character or not target.Character or not target.Character:FindFirstChild('HumanoidRootPart') or not localPlayer.Character:FindFirstChild('HumanoidRootPart') then
        return
    end

    local originalPosition = localPlayer.Character.HumanoidRootPart.CFrame
    local targetPosition = target.Character.HumanoidRootPart.CFrame

    -- Move to target, attack, and move back in a single frame to bypass server-side checks
    local connection = game:GetService("RunService").Stepped:Connect(function()
        localPlayer.Character.HumanoidRootPart.CFrame = targetPosition
        attackFunction()
        localPlayer.Character.HumanoidRootPart.CFrame = originalPosition
    end)

    -- Disconnect after one frame to avoid getting stuck
    task.delay(0, function()
        connection:Disconnect()
    end)
end

if not shared.VapeIndependent then
	loadstring(downloadFile('newcatvape/games/universal.lua'), 'universal')()
	if isfile('newcatvape/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('newcatvape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/new-qwertyui/CatV5/'..readfile('newcatvape/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('newcatvape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
