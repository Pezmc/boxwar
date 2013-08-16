// Entity information.
ENT.Type = "anim"
ENT.Base = "base_anim"

local min, max

function ENT:Initialize()
	min = self:OBBMins()
	max = self:OBBMaxs()
end

local lastYaw = 0;

function ENT:Think() 
	local pl = self:GetOwner()
	
	if pl:IsValid() then

		-- Shift the box up by it's min Z position
		self:SetPos(self:GetOwner():GetPos() + Vector(0,0,-min.z))
			
		-- If the player is holding down attack 2 don't rotate
		if(pl:KeyDown(IN_ATTACK2) && pl:GetVelocity():Length() == 0) then
			self:SetAngles(Angle(0, lastYaw, 0)) --only the yaw (rotation in z)
		else
			local angles = pl:GetAngles()
			self:SetAngles(Angle(0,angles.y,0))
			lastYaw = angles.y
		end
	
	end
	
end