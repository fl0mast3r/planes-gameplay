
--[=[
    Copyright Accoast x fl0mDeveloper DEVELOPER SPECIALLY FOR TOPCAT GAMES
	updated by qaltx: added ParticleEmitter, VectorForce, LinearVelocity, TextLabel, CanvasGroup,
		PlayerGui, ScreenGui, Model, Part, MeshPart
]=]

--!strict

local StrictGetter = {
	Humanoid = function(input: Instance?): Humanoid?
		if input and input:IsA("Humanoid") then
			return input
		end
		
		return nil
	end,

	Animator = function(input: Instance?): Animator?
		if input and input:IsA("Animator") then
			return input
		end
		
		return nil
	end,

	Shirt = function(input: Instance?): Shirt?
		if input and input:IsA("Shirt") then
			return input
		end
		
		return nil
	end,

	TextButton = function(input: Instance?): TextButton?
		if input and input:IsA("TextButton") then
			return input
		end
		
		return nil
	end,

	TextLabel = function(input: Instance?): TextLabel?
		if input and input:IsA("TextLabel") then
			return input
		end

		return nil
	end,

	ImageLabel = function(input: Instance?): ImageLabel?
		if input and input:IsA("ImageLabel") then
			return input
		end
		
		return nil
	end,

	Model = function(input: Instance?): Model?
		if input and input:IsA("Model") then
			return input
		end

		return nil
	end,

	Folder = function(input: Instance?): Folder?
		if input and input:IsA("Folder") then
			return input
		end
		
		return nil
	end,

	Frame = function(input: Instance?): Frame?
		if input and input:IsA("Frame") then
			return input
		end
		
		return nil
	end,

	CanvasGroup = function(input: Instance?): CanvasGroup?
		if input and input:IsA("CanvasGroup") then
			return input
		end

		return nil
	end,

	PlayerGui = function(input: Instance?): PlayerGui?
		if input and input:IsA("PlayerGui") then
			return input
		end

		return nil
	end,

	ScreenGui = function(input: Instance?): ScreenGui?
		if input and input:IsA("ScreenGui") then
			return input
		end

		return nil
	end,

	SurfaceGui = function(input: Instance?): SurfaceGui?
		if input and input:IsA("SurfaceGui") then
			return input
		end
		
		return nil
	end,

	Sound = function(input: Instance?): Sound?
		if input and input:IsA("Sound") then
			return input
		end
		
		return nil
	end,

	Part = function(input: Instance?): Part?
		if input and input:IsA("Part") then
			return input
		end

		return nil
	end,

	BasePart = function(input: Instance?): BasePart?
		if input and input:IsA("BasePart") then
			return input
		end
		
		return nil
	end,

	MeshPart = function(input: Instance?): MeshPart?
		if input and input:IsA("MeshPart") then
			return input
		end

		return nil
	end,

	Motor6D = function(input: Instance?): Motor6D?
		if input and input:IsA("Motor6D") then
			return input
		end
		
		return nil
	end,

	Weld = function(input: Instance?): Weld?
		if input and input:IsA("Weld") then
			return input
		end
		
		return nil
	end,

	VectorForce = function(input: Instance?): VectorForce?
		if input and input:IsA("VectorForce") then
			return input
		end

		return nil
	end,

	LinearVelocity = function(input: Instance?): LinearVelocity?
		if input and input:IsA("LinearVelocity") then
			return input
		end

		return nil
	end,

	BodyAngularVelocity = function(input: Instance?): BodyAngularVelocity?
		if input and input:IsA("BodyAngularVelocity") then
			return input
		end

		return nil
	end,

	Decal = function(input: Instance?): Decal?
		if input and input:IsA("Decal") then
			return input
		end
		
		return nil
	end,

	ParticleEmitter = function(input: Instance?): ParticleEmitter?
		if input and input:IsA("ParticleEmitter") then
			return input
		end

		return nil
	end,

	Attachment = function(input: Instance?): Attachment?
		if input and input:IsA("Attachment") then
			return input
		end
		
		return nil
	end,


    ModuleScript = function(input: Instance?): ModuleScript?
		if input and input:IsA("ModuleScript") then
			return input
		end
		
		return nil
	end,
}

return StrictGetter