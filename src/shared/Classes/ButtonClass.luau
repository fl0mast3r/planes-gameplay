--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Promise = require(ReplicatedStorage.Packages.TypedPromise)

local Sounds = SoundService:WaitForChild("SFX") :: SoundGroup
local ClickSFX = Sounds:WaitForChild("Pop") :: SoundEffect
local HoverSFX = Sounds:WaitForChild("MouseEnter") :: SoundEffect

local ButtonClass = {}
ButtonClass.__index = ButtonClass

type Properties = {
    OriginalSize: UDim2,
    Activated: Fusion.Value<boolean>,

    _button: TextButton | ImageButton,
    _size: Fusion.Value<UDim2>,
    _animationPromise: Promise.Promise<>?,
}
export type ClassType = typeof(setmetatable({} :: Properties, ButtonClass))

function ButtonClass.new(button: TextButton | ImageButton)
    local self: Properties = {
        OriginalSize = button.Size,
        Activated = Fusion.Value(false),

        _button = button,
        _size = Fusion.Value(button.Size),
        _animationPromise = nil,
    }
    setmetatable(self, ButtonClass)

    self:_bindMethods()

    return self
end

function ButtonClass._bindMethods(self: ClassType)
    Fusion.Hydrate(self._button){
        Size = Fusion.Spring(Fusion.Computed(function()
            return self._size:get()
        end, Fusion.cleanup), 30, 0.6)
    }

    self._button.MouseEnter:Connect(function(a0: number, a1: number)
        if self._animationPromise then
            self._animationPromise:cancel()
            self._animationPromise = nil
        end

        local sound = HoverSFX:Clone()
        sound.Parent = Sounds
        sound:Destroy()

        self._size:set(UDim2.fromScale(self.OriginalSize.X.Scale * 1.03, self.OriginalSize.Y.Scale * 1.03))
    end)

    self._button.MouseLeave:Connect(function(a0: number, a1: number) 
        if self._animationPromise then
            self._animationPromise:cancel()
            self._animationPromise = nil
        end
        
        self._size:set(self.OriginalSize)
    end)

    self._button.MouseButton1Click:Connect(function(...: any)
        if self._animationPromise then
            self._animationPromise:cancel()
            self._animationPromise = nil
        end

        local sound = ClickSFX:Clone()
        sound.Parent = Sounds
        sound:Destroy()

        self._animationPromise = Promise.try(function(...)  
            self._size:set(UDim2.fromScale(self.OriginalSize.X.Scale / 1.1, self.OriginalSize.Y.Scale / 1.1))

            Promise.delay(0.1):await()
        end):andThen(function(...: any): ...any  
            self._size:set(self.OriginalSize)
        end)
    end)
end

function ButtonClass.RenderChanges(self: ClassType)
    self._size:set(self.OriginalSize)
end

function ButtonClass.Destroy(self: ClassType)
    
end

return ButtonClass
