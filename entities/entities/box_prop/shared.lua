// Entity information.
ENT.Type = "anim"
ENT.Base = "base_anim"

local min, max

function ENT:CalculateMinMax()
	min = self:OBBMins()
	max = self:OBBMaxs()
end

function ENT:Initialize()
	self:CalculateMinMax()
	self.lastYaw = 0;
end

function ENT:CalculateBoxPosition() 
	local pl = self:GetOwner()
	
	if pl:IsValid() then

		-- Shift the box up by it's min Z position
		self:SetPos(self:GetOwner():GetPos() + Vector(0,0,-min.z))
			
		-- If the player is holding down attack 2 don't rotate
		if(pl:KeyDown(IN_ATTACK2) && pl:GetVelocity():Length() == 0) then
			self:SetAngles(Angle(0, self.lastYaw, 0)) --only the yaw (rotation in z)
		else
			local angles = pl:GetAngles()
			self:SetAngles(Angle(0,angles.y,0))
			self.lastYaw = angles.y
		end
	
		--print(self.lastYaw)
	end
	
end

function ENT:Think() 
	self:CalculateBoxPosition()
end