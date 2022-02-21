local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Hz = 1/60
local UpdateTime = tick()

local ParticleSystem = {
    ["_Particles"] = {}
}

function ParticleSystem:AddParticle(Particle: ParticleEmitter, Properties)
    local Tag = HttpService:GenerateGUID(false)
    local DefaultProperties = {}
    DefaultProperties.Rate = 10
    DefaultProperties.Particle = Particle
    DefaultProperties.Callback = function(Particle)
        
    end
    
    for Index, Value in pairs(Properties) do
        DefaultProperties[Index] = Value
    end
    
    DefaultProperties.WaitTime = 1/(DefaultProperties.Rate)
    DefaultProperties.Time = tick()
    Particle:SetAttribute("Dead", false)
    self["_Particles"][Tag] = DefaultProperties
    
    return self["_Particles"][Tag]
end

function ParticleSystem:StopParticle(ID: string)
    local ParticleInfo = self["_Particles"][ID]
    local Particle = ParticleInfo.Particle

    Particle:SetAttribute("Dead", true)
end

if RunService:IsClient() then
    ParticleSystem["Event"] = RunService.Heartbeat:Connect(function(DT)
        for Tag, Information in pairs(ParticleSystem["_Particles"]) do
            if (tick() - Information.Time) >= Information.WaitTime then
                Information.Time = tick()
    
                if not (Information.Particle.Parent) then
                    ParticleSystem["_Particles"][Tag] = nil
                    continue
                end
                
                if not Information.Particle:GetAttribute("Dead") then
                    Information.Particle:Emit(math.ceil(Information.Rate * .01))
                else
                    ParticleSystem["_Particles"][Tag] = nil
                end
            end
        end
    end)
end

return ParticleSystem