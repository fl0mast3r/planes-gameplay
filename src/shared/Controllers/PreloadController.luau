--!strict
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local PlaneClass = require(ReplicatedStorage.Shared.Classes.PlaneClass)
local Net = require(ReplicatedStorage.Shared.ClientNet)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Controllers = require(ReplicatedStorage.Shared.Controllers)

type Data = {
    ChoosenPlane: string,
    Parameters: {
        Length: number,
        Attempts: number,
        RingsSpread: number,
        Wind: number,
    },
}

local Attempts = {
    [1] = 6,
    [2] = 3,
    [3] = 1,
}

local PreloadController = {
    Data = {} :: Data,
    Attempts = Fusion.Value(6) :: Fusion.Value<number>,

    _player = Players.LocalPlayer :: Player,
}

function PreloadController.Start(self: Controller)
    self.GenerationController = Controllers:Get("GenerationController")

    self.Data = TeleportService:GetLocalPlayerTeleportData()

    if not self.Data then
        self.Data = {
            ChoosenPlane = "Basic",
            Parameters = {
                Length = 1,
                Attempts = 1,
                RingsSpread = 1,
                Wind = 1,
            },
        }
    end

    self.Attempts:set(Attempts[self.Data.Parameters.Attempts] + 1)

    UserInputService.InputBegan:Connect(function(input: InputObject) 
        if input.KeyCode ~= Enum.KeyCode.R then
            return
        end

        if self.GenerationController:IsWon() then
            return
        end

        Net.Respawn.Fire()
    end)

    Observers.observeCharacter(function(player: Player, character: Model): (() -> ())?  
        local newObject = self:_createPlane()
        if not newObject then
            return
        end

        if self.Attempts:get() == 0 then
            return TeleportService:Teleport(109845393505750, self._player)
        end

        self.Attempts:set(self.Attempts:get() - 1)

        return function()
            newObject:Destroy()
        end
    end)
end

function PreloadController._createPlane(self: Controller): PlaneClass.ClassType?
    local model: Model? = select(2, Net.Spawn.Invoke(self.Data.ChoosenPlane):await())
    if not model then
        return
    end

    return PlaneClass.new(model)
end

export type Controller = typeof(PreloadController)
return PreloadController