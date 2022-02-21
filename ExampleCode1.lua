--[[
    :GetModule(<string> ModuleName): ModuleScript
    :GetRemote(<string> RemoteName): Remote
    :GetBindable(<string> RemoteName): Remote-
    :FireAllClientsInRange(<string> RemoteName, <table> Args) -- Both Remotes
    :GetSound(<string> SoundName): Sound
]]

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local PublicModules = ReplicatedStorage:WaitForChild("PublicModules")
local Modules = (RunService:IsServer() and ServerScriptService:FindFirstChild("Server")) or Player.PlayerScripts:WaitForChild("Client")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Bindables = ReplicatedStorage:WaitForChild("Bindables")
local PlayerModule = (RunService:IsClient() and Player.PlayerScripts:WaitForChild("PlayerModule")) or nil
local Sounds = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Audios")

local cache = {
    ["Modules"] = {
        ["PlayerModule"] = PlayerModule
    },
    ["Remotes"] = {},
    ["Bindables"] = {},
    ["Sounds"] = {}
}

local function SetUp()
    for i,v in ipairs({PublicModules, Modules}) do
        for _, Module in ipairs(v:GetDescendants()) do
            if Module:IsA("ModuleScript") then
                cache["Modules"][Module.Name] = Module
            end
        end
    end

    for _, Remote in ipairs(Remotes:GetDescendants()) do
        if Remote:IsA("RemoteEvent") or Remote:IsA("RemoteFunction") then
            cache["Remotes"][Remote.Name] = Remote

            if not RunService:IsServer() then
                Remote.Name = ""
                Remote.Parent = Remotes
            end
        end
    end

    if not RunService:IsServer() then
        for i,v in pairs(Remotes:GetChildren()) do
            if v:IsA("Folder") then
                v:Destroy()
            end
        end
    end

    for _, Bindable in ipairs(Bindables:GetDescendants()) do
        if Bindable:IsA("BindableEvent") or Bindable:IsA("BindableFunction") then
            cache["Bindables"][Bindable.Name] = Bindable
        end
    end

    for i, Sound in pairs(Sounds:GetChildren()) do
        cache["Sounds"][Sound.Name] = Sound
    end
end
SetUp()

local Framework = {
    ["Library"] = require(ReplicatedStorage.PublicModules.Util:FindFirstChild("Library"))
};

function Framework:GetModule(ModuleName: string)
    assert(cache["Modules"][ModuleName], "The module '" .. ModuleName .. "' does not exist!")
    
    return require(cache["Modules"][ModuleName])
end

function Framework:GetRemote(RemoteName: string)
    assert(cache["Remotes"][RemoteName], "The remote '" .. RemoteName .. "' does not exist!")

    return cache["Remotes"][RemoteName]
end

function Framework:GetBindable(BinableName: string)
    assert(cache["Bindables"][BinableName], "The bindable '" .. BinableName .. "' does not exist!")
    
    return cache["Bindables"][BinableName]
end

function Framework:FireAllClientsInRange(Origin, Range, RemoteName: string, ...)
    assert(RunService:IsServer(), "This function can only be called on the server")
    local Remote = cache["Remotes"][RemoteName]
    
    if typeof(Origin) == "CFrame" then
        Origin = Origin.Position
    end
    
    for _, Character in pairs(workspace.Players:GetChildren()) do
        local PrimaryPart = Character.PrimaryPart
        local Player = game.Players:GetPlayerByUserId(Character.Name)
        
        if (Origin - PrimaryPart.Position).Magnitude >= Range then
            Remote:FireClient(Player, ...)
        end
    end
end

function Framework:GetSound(SoundName, DeleteOnFinished)
    assert(cache["Sounds"][SoundName], "The Audio '" .. SoundName .. "' does not exist!")

    local Cloned = cache["Sounds"][SoundName]:Clone()
    
    if DeleteOnFinished then
        Cloned.Ended:Connect(function()
            Cloned:Destroy()
        end)
    end
    return Cloned
end

return Framework