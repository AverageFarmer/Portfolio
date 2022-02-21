local Framework = _G.Framework
local Library = Framework.Library
local QuirkInfo = Framework:GetModule("QuirkInformation")
local DataService = Framework:GetModule("DataService")

local CooldownRemote = Framework:GetRemote("Cooldown")

local Cooldown = {}

function Cooldown:IsCooldown(Player, Move)
    local Character = Player.Character
    local Quirk = DataService:Get(Player, "Quirk")
    local MoveInfo = QuirkInfo[Quirk]["Moves"][Move]
    local Keybind = MoveInfo["KeyBind"]
    local CooldownTime = MoveInfo["Cooldown"]

    if not Character:GetAttribute(Keybind) then
        Character:SetAttribute(Keybind, 0)
    end

    if tick() - Character:GetAttribute(Keybind) >= CooldownTime then
        return false
    else
        return true
    end
end

function Cooldown:AddCooldown(Player: Player, Move, custom)
    local Character = Player.Character
    local Quirk = DataService:Get(Player, "Quirk")
    local MoveInfo = QuirkInfo[Quirk]["Moves"][Move]
    local Keybind = MoveInfo["KeyBind"]
    local Cooldown = custom or tick()
    local MoveCooldown = MoveInfo["Cooldown"]

    Character:SetAttribute(Keybind, Cooldown)

    if Cooldown ~= 0 then
        CooldownRemote:FireClient(Player, Keybind, (Cooldown ~= 0 and MoveCooldown) or 0)
    end
end

function Cooldown:Init()

end

return Cooldown