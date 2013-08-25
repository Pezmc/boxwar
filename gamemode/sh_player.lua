-- Grab a copy of the player meta table.
local meta = FindMetaTable("Player")

-- If there is none, then stop executing this file.
if !meta then
	if(DEBUG_MODE) then print("WARNING: Unable to find player meta table") end
	return 
end

-- Is the player ready to spawn?
function meta:ShouldSpawn()
   return true
end

-- Removes the player prop if it exists.
function meta:RemoveProp()

	-- If we are executing from client side or the player/player's prop isn't valid, terminate.
	if CLIENT || !self:IsValid() || !self.prop || !self.prop:IsValid() then
		return
	end
	
	-- Despawn box
	self.boxSpawned = false

	-- Remove the player's prop
	self.prop:Remove()
	self.prop = nil
end

-- Kill the player, spawning in ragdolls, breaking their prop etc...
function meta:BoxwarKill() 

	-- If we are executing from client side player prop isn't valid, terminate.
	if CLIENT || !self:IsValid() then
		return
	end

	-- Create an invisible prop to copy
    local invisibleDoll = ents.Create("prop_physics")
    invisibleDoll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
    invisibleDoll:SetModel("models/Humans/Group01/Male_05.mdl")
    invisibleDoll:SetAngles(self:GetAngles())
    invisibleDoll:SetPos( self:GetPos() )
    invisibleDoll:SetColor(Color(0, 0, 0, 0)) 
    invisibleDoll:Spawn()

    -- Set the invisible prop to crouch
    sequence = invisibleDoll:LookupSequence("roofidle1")
	invisibleDoll:SetPlaybackRate( 1.0 )
	invisibleDoll:SetSequence(sequence)
	invisibleDoll:ResetSequence( sequence )
	invisibleDoll:SetCycle( 1 )
    
    -- Spawn a ragdoll for the player
    local doll = ents.Create("prop_ragdoll")
    doll:SetParent(invisibleDoll)
    doll:AddEffects(EF_BONEMERGE)
    
    -- Try to use players model
    if(self.selectedPlayerModel ~= nil) then
    	doll:SetModel( self.selectedPlayerModel ) -- could store the player model?
    else
    	doll:SetModel( "models/Humans/Group01/Male_05.mdl" )
    end
    
    --doll:SetModel( player:GetModel() )
    doll:SetPos( self:GetPos() )
    doll:SetAngles( self:GetAngles() )
    doll:Spawn()
    doll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
    
    -- Link the ragdoll to the invisible, then remove the invisible
    doll:SetParent()
    invisibleDoll:Remove()
    
    -- Smash the box
	if (self.prop ~= nil)	then	
		self.prop:PrecacheGibs()
		self.prop:GibBreakClient(Vector(0,0,100))
	end
	
	-- Safely remove the doll after 60 seconds
    SafeRemoveEntityDelayed(doll, 60)
    
    -- Human blood
	DecalName = "Blood" --"Impact.Wood" --Impact.Wood, Blood
	EffectName = "BloodImpact" --"BloodImpact"
				  
    -- Delete the prop
	self:RemoveProp()
	
	-- Perform a trace from the player down towards the ground
	local Trace = {}
	Trace.start = self:GetPos()
	Trace.endpos = Trace.start - Vector(0,0,500);
	Trace.filter = self.prop --self
	local tr = util.TraceLine( Trace )
			
	-- If we hit something
	if ( tr.Hit && tr.HitPos:Distance( self:GetPos() ) < 50 ) then
	
		-- Spawn some blood
		util.Decal( DecalName, tr.HitPos + tr.HitNormal + Vector(0.1, 0.1, 0) * math.random(0,100),
							   tr.HitPos - tr.HitNormal - Vector(0.1, 0.1, 0) * math.random(0,100))
		util.Decal( DecalName, tr.HitPos - tr.HitNormal - Vector(0.1, 0.1, 0) * math.random(0,100),
							   tr.HitPos + tr.HitNormal + Vector(0.1, 0.1, 0) * math.random(0,100))
		util.Decal( DecalName, tr.HitPos - tr.HitNormal - Vector(0.1, 0.1, 0) * math.random(0,100),
							   tr.HitPos - tr.HitNormal - Vector(0.1, 0.1, 0) * math.random(0,100))
		util.Decal( DecalName, tr.HitPos + tr.HitNormal + Vector(0.1, 0.1, 0) * math.random(0,100),
							   tr.HitPos + tr.HitNormal + Vector(0.1, 0.1, 0) * math.random(0,100))
							   
		-- Then show a blood "explosion"
		local Effect = EffectData()
		Effect:SetOrigin( tr.HitPos )
		util.Effect( EffectName, Effect )
		Effect = EffectData()
		Effect:SetOrigin( self:GetPos() )
		util.Effect( EffectName, Effect )			
		
	end
end

