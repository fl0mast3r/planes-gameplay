--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Net = require(ServerScriptService.Server.ServerNet)
local Observer = require(ReplicatedStorage.Packages.Observers)

local Assets = ReplicatedStorage:WaitForChild("Assets") :: Folder
local Planes = Assets:WaitForChild("Planes") :: Folder

local PlaneService = {}

function PlaneService.Start(self: Service)
    Observer.observeCharacter(function(player: Player, character: Model): (() -> ())?  
        return function()
            local thisPlane = workspace.Planes:FindFirstChild(player.Name) :: Model?
            if not thisPlane then
                return
            end

            thisPlane:Destroy()
        end
    end)

    Net.Spawn.On(function(player: Player, name: string): Model?  
        return self:_spawnAttempt(player, name)
    end)

    Net.Respawn.On(function(Player: Player)  
        Player:LoadCharacter()
    end)
end

function PlaneService._spawnAttempt(self: Service, player: Player, name: string): (Model?)
    local thisModel = Planes:FindFirstChild(name) :: Model?
    if not thisModel then
        return
    end

    thisModel = thisModel:Clone()
    thisModel.Parent = workspace.Planes
    thisModel.Name = player.Name
    thisModel:PivotTo(workspace:WaitForChild("SpawnLocation").CFrame)

    local vehicleSeat = thisModel:FindFirstChild("VehicleSeat") :: VehicleSeat?
    if not vehicleSeat then
        return thisModel
    end

    local connection: RBXScriptConnection 
    connection = vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
        if not vehicleSeat.Parent then
            connection:Disconnect()

            return
        end

        if vehicleSeat.Occupant then
            return vehicleSeat:SetNetworkOwner(player)
        end

        return vehicleSeat:SetNetworkOwner()
    end)

    return thisModel
end

export type Service = typeof(PlaneService)
return PlaneService