--!strict

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local AIR_DENSITY = 0.01

local PlaneClass = {}
PlaneClass.__index = PlaneClass

type Properties = {
    Model: Model,

    _seat: VehicleSeat,
    _hinges: {HingeConstraint},
    _beams: {{
        Part: BasePart,
        Beam: Beam,
        Attachment0: Attachment,
        Attachment1: Attachment,
        Force: VectorForce,
        SizeX: number,
        SizeY: number,
        SizeZ: number,
        MinimumX: number,
        MaximumX: number,
        MinimumY: number,
        MaximumY: number,
        MinimumZ: number,
        MaximumZ: number,
    }},
    _thurst: number,
    _character: Model?,

    _increasing: boolean,
    _decreasing: boolean,
    
    _player: Player,
    _connections: {[string]: RBXScriptConnection}
}
export type ClassType = typeof(setmetatable({} :: Properties, PlaneClass))

function PlaneClass.new(model: Model)
    local self: Properties = {
        Model = model,
        
        _seat = model:WaitForChild("VehicleSeat") :: VehicleSeat,
        _connections = {},
        _beams = {},
        _hinges = {},
        _character = Players.LocalPlayer.Character,
        _thurst = 0,
        
        _increasing = false,
        _decreasing = false,
        
        _player = Players.LocalPlayer,
    }
    setmetatable(self, PlaneClass)

    self:_setupPlane()

    self._connections.Update = RunService.RenderStepped:Connect(function(deltaTime: number)  
        self:_update(deltaTime)
    end)

    self._connections.InputStarted = UserInputService.InputBegan:Connect(function(key: InputObject)  
        if key.KeyCode == Enum.KeyCode.E then
            self._increasing = true
            self._decreasing = false
        elseif key.KeyCode == Enum.KeyCode.Q then
            self._decreasing = true
            self._increasing = false
        end
    end)

    self._connections.InputEnded = UserInputService.InputEnded:Connect(function(key: InputObject)  
        if key.KeyCode == Enum.KeyCode.E then
            self._increasing = false
        elseif key.KeyCode == Enum.KeyCode.Q then
            self._decreasing = false
        end
    end)

    return self
end

function PlaneClass._setupPlane(self: ClassType)
    local character: Model? = self._player.Character
    if not character then
        return
    end

    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    self._seat:Sit(humanoid)

    for i,v in next, self.Model:GetDescendants() do
		if v:IsA("BasePart") then
			local attachment0 = Instance.new("Attachment", v)
			local attachment1 = Instance.new("Attachment", v)
			
			local beam = Instance.new("Beam",v)
			beam.FaceCamera = true
			beam.Segments = 1
			beam.Width0 = 0.2
			beam.Width1 = 0.2
			beam.Color = ColorSequence.new(Color3.new(1,0,0))
			beam.Attachment0 = attachment0
			beam.Attachment1 = attachment1
			
			local force = Instance.new("VectorForce", v)
			force.Attachment0 = attachment0
			
			local rayOffsetX = math.max(v.Size.X/2 - 0.1, 0)
			local rayOffsetY = math.max(v.Size.Y/2 - 0.1, 0)
			local rayOffsetZ = math.max(v.Size.Z/2 - 0.1, 0)
			
			table.insert(self._beams, {
				Part = v,
				Beam = beam,
				Attachment0 = attachment0,
				Attachment1 = attachment1,
				Force = force,
				SizeX = v.Size.Y*v.Size.Z,
				SizeY = v.Size.X*v.Size.Z,
				SizeZ = v.Size.X*v.Size.Y,
				MinimumX = -self:_raycastParts(v.Position + v.CFrame.RightVector*rayOffsetX, v.CFrame.RightVector),
				MaximumX = self:_raycastParts(v.Position - v.CFrame.RightVector*rayOffsetX, -1*v.CFrame.RightVector),
				MinimumY = -self:_raycastParts(v.Position + v.CFrame.UpVector*rayOffsetY, v.CFrame.UpVector),
				MaximumY = self:_raycastParts(v.Position - v.CFrame.UpVector*rayOffsetY, -1*v.CFrame.UpVector),
				MinimumZ = -self:_raycastParts(v.Position + v.CFrame.LookVector*rayOffsetZ, v.CFrame.LookVector),
				MaximumZ = self:_raycastParts(v.Position - v.CFrame.LookVector*rayOffsetZ, -1*v.CFrame.LookVector),
			})
		elseif v:IsA("HingeConstraint") then
			table.insert(self._hinges, v)
		end	
	end
end

function PlaneClass._thurstCheck(self: ClassType, deltaTime)
	if self._increasing then
		self._thurst += 2000 * deltaTime
	end
	
	if self._decreasing then
		self._thurst -= 2000 * deltaTime
	end
end

function PlaneClass._raycastParts(self: ClassType, origin, direction)
    local castParams = RaycastParams.new()
    castParams.FilterType = Enum.RaycastFilterType.Include
    castParams.FilterDescendantsInstances = {self.Model}
    
    local result = workspace:Raycast(origin, direction, castParams)
    
    return if result then 0 else 1
end

function PlaneClass._updateHinges(self: ClassType)
	for index, hinge in next, self._hinges do
		hinge.TargetAngle = 0

        local steerFloat = hinge:GetAttribute("SteerFloat")
        local throttleFloat = hinge:GetAttribute("ThrottleFloat")
        if typeof(steerFloat) ~= "number" then
            continue
        end

        if typeof(throttleFloat) ~= "number" then
            continue
        end 

        hinge.TargetAngle += self._seat.SteerFloat*steerFloat
        hinge.TargetAngle += self._seat.ThrottleFloat*throttleFloat
	end
end

function PlaneClass._update(self: ClassType, deltaTime: number)
    self:_thurstCheck(deltaTime)
	self:_updateHinges()
	
	for i,v in next, self._beams do
		local velocity = -v.Part:GetVelocityAtPosition(v.Part.Position) + workspace.GlobalWind
		
		if v.Part.Name == "Motor" then
			v.Force.Force = Vector3.new(0,0, -self._thurst)
		else
			v.Force.Force = Vector3.zero
		end
		
		if velocity.Magnitude > 0 then
			local upVectorDotProduct = math.clamp(v.Part.CFrame.UpVector:Dot(velocity.Unit), v.MinimumY, v.MaximumY)
			v.Force.Force += Vector3.yAxis * AIR_DENSITY * upVectorDotProduct * v.SizeY * velocity.Magnitude^2
			
			local rightVectorDotProduct = math.clamp(v.Part.CFrame.RightVector:Dot(velocity.Unit), v.MinimumX, v.MaximumX)
			v.Force.Force += Vector3.xAxis * AIR_DENSITY * rightVectorDotProduct * v.SizeX * velocity.Magnitude^2
			
			local frontVectorDotProduct = math.clamp(v.Part.CFrame.LookVector:Dot(velocity.Unit), v.MinimumZ, v.MaximumZ)
			v.Force.Force -= Vector3.zAxis * AIR_DENSITY * frontVectorDotProduct * v.SizeZ * velocity.Magnitude^2
		end
		
		v.Attachment1.Position = v.Force.Force / 200
	end
end

function PlaneClass.Destroy(self: ClassType)
	for i,v in next, self._connections do
		v:Disconnect()
	end
end

return PlaneClass
