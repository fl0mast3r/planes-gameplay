--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Controllers = require(ReplicatedStorage.Shared.Controllers)
local ButtonClass = require(ReplicatedStorage.Shared.Classes.ButtonClass)

local BlurEffect = Lighting:WaitForChild("Blur") :: BlurEffect

local UIController = {
    PreloadController = nil :: any,

    _player = Players.LocalPlayer :: Player,
    _playerUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("UI") :: PlayerGui?,

    _attemptsLabel = nil :: TextLabel?,
    _returnFrame = nil :: Frame?,
    _sideFrame = nil :: Frame?,
    _backButton = nil :: TextButton?,

    _buttons = {} :: {[TextButton | ImageButton]: ButtonClass.ClassType},

    _returnFrameVisible = Fusion.Value(false),
}

function UIController.Start(self: Controller)
    self.PreloadController = Controllers:Get("PreloadController")
    self.GenerationController = Controllers:Get("GenerationController")

    if not self._playerUI then
        return
    end

    self._sideFrame = self._playerUI:WaitForChild("SideFrame") :: Frame
    if not self._sideFrame then
        return
    end

    self._backButton = self._sideFrame:WaitForChild("Lobby") :: TextButton
    self._attemptsLabel = self._sideFrame:WaitForChild("Title") :: TextLabel
    self._returnFrame = self._playerUI:WaitForChild("ReturnFrame") :: Frame

    self:_buildUI()
end

function UIController.RenderWin(self: Controller)
    self._returnFrameVisible:set(true)
end

function UIController._buildUI(self: Controller)
    self:_animateButtons()
    self:_bindBackToLobby()
    self:_bindAttempts()
    self:_bindReturnFrame()
    self:_bindSideFrame()
end

function UIController._bindReturnFrame(self: Controller)
    if not self._returnFrame then
        return
    end

    local button = self._returnFrame:WaitForChild("Return") :: TextButton
    if not button then
        return
    end

    Fusion.Hydrate(self._returnFrame){
        Visible = self._returnFrameVisible,
        Size = Fusion.Spring(Fusion.Computed(function()  
            return if self._returnFrameVisible:get() then UDim2.fromScale(0.355, 0.444) else UDim2.fromScale(0.355/1.5, 0.444/1.5)
        end, Fusion.cleanup), 30, 0.75)
    }

    Fusion.Hydrate(self._returnFrame:WaitForChild("Money")){
        Text = Fusion.Computed(function()  
            return `Money: {self.GenerationController.MoneyCollected:get()}`
        end, Fusion.cleanup)
    }

    Fusion.Hydrate(BlurEffect) {
        Size = Fusion.Spring(Fusion.Computed(function()  
            return if self._returnFrameVisible:get() then 40 else 0
        end, Fusion.cleanup), 100, 0.8)
    }
    
    button.MouseButton1Click:Connect(function()  
        TeleportService:Teleport(109845393505750, self._player, self.GenerationController.MoneyCollected:get())
    end)
end

function UIController._bindSideFrame(self: Controller)
    if not self._sideFrame then
        return
    end

    Fusion.Hydrate(self._sideFrame){
        Position = Fusion.Spring(Fusion.Computed(function()  
            return if not self._returnFrameVisible:get() then UDim2.fromScale(0.5, 0.5) else UDim2.fromScale(0, 0.5)
        end, Fusion.cleanup))
    }
end

function UIController._bindAttempts(self: Controller)
    if not self._attemptsLabel then
        return
    end

    Fusion.Hydrate(self._attemptsLabel){
        Text = Fusion.Computed(function()  
            return `Attempts: {self.PreloadController.Attempts:get()}`
        end, Fusion.cleanup)
    }
end

function UIController._bindBackToLobby(self: Controller)
    if not self._backButton then
        return
    end

    self._backButton.MouseButton1Click:Connect(function(...: any)
        if RunService:IsStudio() then
            return
        end

        TeleportService:Teleport(109845393505750, self._player)
    end)
end

function UIController._animateButtons(self: Controller)
    if not self._playerUI then
        return
    end

    for _, button: Instance in next, self._playerUI:GetDescendants() do
        if (not button:IsA("TextButton")) and (not button:IsA("ImageButton")) then
            continue
        end

        self._buttons[button] = ButtonClass.new(button)
    end
end

export type Controller = typeof(UIController)
return UIController