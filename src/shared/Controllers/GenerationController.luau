--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local Controllers = require(ReplicatedStorage.Shared.Controllers)
local Net = require(ReplicatedStorage.Shared.ClientNet)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local RingModel: Model = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Ring") :: Model
local Sounds = SoundService:WaitForChild("SFX") :: SoundGroup

type Data = {
    ChoosenPlane: string,
    Parameters: {
        Length: number,
        Attempts: number,
        RingsSpread: number,
        Wind: number,
    },
}

local GenerationController = {
    MoneyCollected = Fusion.Value(0) :: Fusion.Value<number>,
    SpawnConfig = {
        [1] = {
            Distance = {120, 150},
            Spread = {-10, 10},
            Rotation = {-0.1, 0.1},
            Quantity = 10,
            Wind = Vector3.new(0, 0, 0),
        },

        [2] = {
            Distance = {120, 150},
            Spread = {-20, 20},
            Rotation = {-1, 1},
            Quantity = 20,
            Wind = Vector3.new(math.random(25, 50), 0, math.random(25, 50)),
        },

        [3] = {
            Distance = {100, 130},
            Spread = {-30, 30},
            Rotation = {-2.5, 2.5},
            Quantity = 30,
            Wind = Vector3.new(math.random(50, 100), 0, math.random(50, 100)),
        },
    },

    _length = 0 :: number,
    _lastRingIndex = nil :: number?,
    _player = Players.LocalPlayer :: Player,
    _isWon = false :: boolean,
}

function GenerationController.Start(self: Controller)
    self.PreloadController = Controllers:Get("PreloadController")
    self.UIController = Controllers:Get("UIController")

    Observers.observeCharacter(function(player: Player, character: Model): (() -> ())? 
        for _, models in next, workspace:WaitForChild("Rings"):GetChildren() do
            local ringMesh = models:WaitForChild("Ring") :: BasePart
            if not ringMesh then
                continue
            end

            local hitbox = models:WaitForChild("Part") :: BasePart
            hitbox.Touched:Once(function(hit: BasePart)
                self:_collectRing(models)
            end)

            ringMesh.Transparency = 0
        end

        self._lastRingIndex = nil

        return
    end)

    self:_generateRings()
end

function GenerationController.IsWon(self: Controller): (boolean)
    return self._isWon
end

function GenerationController._createRing(self: Controller, iteration: number, position: CFrame)
    if iteration == 0 then
        return
    end

    local data: Data = self.PreloadController.Data
    local distanceData = self.SpawnConfig[data.Parameters.RingsSpread].Distance
    local spreadData = self.SpawnConfig[data.Parameters.RingsSpread].Spread
    local rotationData = self.SpawnConfig[data.Parameters.RingsSpread].Rotation

    local newCFrame: CFrame = position + position.UpVector*math.max(math.random(spreadData[1], spreadData[2]), 0) + position.LookVector*math.random(distanceData[1], distanceData[2]) + position.RightVector*math.random(spreadData[1], spreadData[2])
    newCFrame *= CFrame.fromEulerAnglesXYZ(0, math.rad(math.random(rotationData[1], rotationData[2])), 0)
    
    local newRing = RingModel:Clone()
    newRing.Parent = workspace.Rings
    newRing:PivotTo(newCFrame)
    newRing.Name = tostring(self._length - iteration + 1)

    local hitbox = newRing:WaitForChild("Part") :: BasePart
    hitbox.Touched:Once(function(hit: BasePart)
        self:_collectRing(newRing)
    end)

    return self:_createRing(iteration - 1, newCFrame)
end

function GenerationController._win(self: Controller)
    self._isWon = true
    local goal: number = 0
    for _, number: number in next, self.PreloadController.Data.Parameters do
        goal += number * 20
    end

    self.MoneyCollected:set(goal)

    self.UIController:RenderWin()

    local character: Model? = self._player.Character
    if not character then
        return
    end

    local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
    if not humanoidRootPart then
        return
    end

    humanoidRootPart.Anchored = true
end

function GenerationController._collectRing(self: Controller, ring: Model)
    local currentIndex: number? = tonumber(ring.Name)
    if not currentIndex then
        return
    end

    local mesh: BasePart = ring:WaitForChild("Ring") :: BasePart
    if mesh.Transparency == 1 then
        return
    end

    if self._lastRingIndex then
        if currentIndex - self._lastRingIndex > 1 then
            local character = self._player.Character
            if character then
                character:Destroy()
            end
            
            return Net.Respawn.Fire()
        end
    else
        if currentIndex ~= 1 then
            local character = self._player.Character
            if character then
                character:Destroy()
            end

            return Net.Respawn.Fire()
        end
    end

    mesh.Transparency = 1

    self._lastRingIndex = tonumber(ring.Name)

    local newSound = Sounds:WaitForChild("Collect"):Clone() :: Sound
    newSound.Parent = Sounds
    newSound:Destroy()

    if self._length == currentIndex then
        local winSound = Sounds:WaitForChild("Win"):Clone() :: Sound
        winSound.Parent = Sounds
        winSound:Destroy()

        self:_win()
    end
end

function GenerationController._generateRings(self: Controller)
    task.defer(function()
        repeat
            task.wait()
        until self.PreloadController.Data.Parameters
        local startPoint: CFrame = workspace:WaitForChild("Start").CFrame

        self._length = self.PreloadController.Data.Parameters.Length * 10

        workspace.GlobalWind = self.SpawnConfig[self.PreloadController.Data.Parameters.Wind].Wind
        print(workspace.GlobalWind, self.PreloadController.Data.Parameters.Wind)

        self:_createRing(self._length, startPoint)
    end)
end

export type Controller = typeof(GenerationController)
return GenerationController