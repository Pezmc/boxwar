// Grab a copy of the player meta table.
local meta = FindMetaTable("Player")

// If there is none, then stop executing this file.
if !meta then
	return 
end


-- Removes the player prop if it exists.
function meta:RemoveProp()

	-- If we are executing from client side or the player/player's prop isn't valid, terminate.
	if CLIENT || !self:IsValid() || !self.prop || !self.prop:IsValid() then
		return
	end

	-- Remove the player's prop
	self.prop:Remove()
	self.prop = nil

end