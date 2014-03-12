---
-- Copyright 2013 Pez Cuckow & Oliver Brown. All rights reserved.
---
-- Spawn a maze into the map when given a grid of maze enums (0/1 etc)
---

-- Add the boxes to the world
local spawnedBoxCount = 0
function SpawnBoxMaze(grid, xWidth, yWidth, minX, maxY, minY, maxY, zMin, zMax, boxWidth) 
	spawnedBoxCount = 0 --reset box counter
	
	-- Spawn the map items
	for x=0,xWidth do
		for y=0,yWidth do
			
			-- Where are we in the real world
			xPos = minX + boxWidth * x; 
			yPos = minY + boxWidth * y;
			
			-- If a wall spawn some boxes
			if(grid[x][y] == MAZE_WALL) then			
				SpawnBoxWall(xPos, yPos, zMin, zMax, boxWidth);
				
			-- If this is a double box square
			elseif(grid[x][y] == DOUBLE_UP || grid[x][y] == DOUBLE_RIGHT || grid[x][y] == DOUBLE_DOWN || grid[x][y] == DOUBLE_LEFT) then
				
				SpawnDoubleWidthWall(grid[x][y], xPos, yPos, zMin, zMax, boxWidth);
			
			-- For a double box hole	
			elseif(grid[x][y] == DOUBLE_EMPTY) then
				-- Just do nothing
			
			-- Unknown type or empty	
			else			
				-- Create a spawn point
				CreateSpawnPointIfValid(x, y, xWidth, yWidth, xPos, yPos, zMin);
			end
		end
	end
	
	totalMazeBoxes = totalMazeBoxes + spawnedBoxCount;
	print("INFO: Spawned maze with " .. spawnedBoxCount .. " boxes.")
end

-- Crate used in maze
local crate = "models/boxwar/boxwar_crate.mdl"
local crateSkins = {
	2, --barcode
	2, --barcode
	2, --barcode
	2, --barcode
	2, --barcode
	2, --barcode
	2, --barcode
	1 --stencil
}

-- Spawn a stack of boxes
function SpawnBoxWall(xPos, yPos, zMin, zMax, boxSize) 

	local zPos = zMin + boxSize;
	local chance = 7; -- 7/10 chance to spawn box
	local stopSpawn = false
	
	-- Current/min height in UNITS
	local zHeight = 1
	local zMaxHeight = math.Round((zMax - zMin) / boxSize)
	
	-- Create layers until we hit the roof
	while(zPos < zMax and chance > 0 and not stopSpawn) do
		if(math.random(0,10) <= chance) then 
			SpawnBox(Vector(xPos, yPos, zPos ), crate, crateSkins)
		else
			-- If we don't spawn a layer, don't do another one
			stopSpawn = true
			
			-- Put a spawnpoint on top
			if(math.random(1,4) == 1) then
				SpawnSpawnPoint(xPos, yPos, zPos - boxSize)
			elseif(math.random(1,4) == 1) then
				SpawnRandomWeapon(xPos, yPos, zPos - boxSize, zHeight, zMaxHeight)
			end
		end
		
		-- Go up one layer
		zPos = zPos + boxSize
		zHeight = zHeight + 1
		
		-- Reduce the chance each time
		chance = math.floor(chance * 0.8) -- max height is ~four
	end
	

end

local doubleCrate = "models/props_junk/wood_crate002a.mdl" --twoish wide!
local doubleCrateSkins = {
	1, --light
	1, --light
	1, --light
	1, --light
	1, --light
	2 --dark
}

-- Spawn a stack of double width boxes
function SpawnDoubleWidthWall(boxType, xPos, yPos, zMin, zMax, boxWidth)

	-- positon of double box
	local xDPos = xPos 
	local yDPos = yPos
	
	-- position of second single box
	local xSPos = xPos
	local ySPos = yPos
	local angle = 0
	
	-- Calculate where to put the box as it needs shifting
	if(boxType == DOUBLE_UP) then
		yDPos = yPos + boxWidth/2
		ySPos = yPos + boxWidth
	elseif(boxType == DOUBLE_RIGHT) then
		angle = 90
		xDPos = xPos + boxWidth/2
		xSPos = xPos + boxWidth
	elseif(boxType == DOUBLE_DOWN) then
		angle = 180
		yDPos = yPos - boxWidth/2
		ySPos = yPos - boxWidth
	elseif(boxType == DOUBLE_LEFT) then
		angle = 270
		xDPos = xPos - boxWidth/2
		xSPos = xPos - boxWidth
	end
	
	
	-- Spawn the first layer
	local zPos = zMin + boxWidth;
	SpawnBox(Vector(xDPos, yDPos, zPos ), doubleCrate, doubleCrateSkins, angle)
	
	-- Loop variables
	local chance = 5; -- /10 chance to spawn box
	local stopSpawn = false
	
	-- Create layers until we hit the roof
	while(zPos < zMax and chance > 0 and not stopSpawn) do
		-- Go up one layer
		zPos = zPos + boxWidth;
	
		-- Only add a layer sometimes
		if(math.random(1,10) <= chance) then
			randomType = math.random(1,3)
			
			-- Spawn a double box
			if(randomType == 1) then
				SpawnBox(Vector(xDPos, yDPos, zPos ), doubleCrate, doubleCrateSkins, angle)
			
			-- Spawn two single boxes
			elseif(randomType == 2) then
				SpawnBox(Vector(xPos, yPos, zPos ), crate, crateSkins)
				SpawnBox(Vector(xSPos, ySPos, zPos ), crate, crateSkins)
				
			-- Spawn a single box
			else
				if(math.random(0,1) == 0) then
					SpawnBox(Vector(xPos, yPos, zPos ), crate, crateSkins)
				else
					SpawnBox(Vector(xSPos, ySPos, zPos ), crate, crateSkins)
				end
				
				-- Break the loop to prevent bad stacking
				stopSpawn = true
			end
		else
			stopSpawn = true
		end
		
		-- Reduce the chance each time
		chance = math.floor(chance * 0.6) -- max height is four
	end
end

-- Add a custom spawn point if it confirms to the rule
function CreateSpawnPointIfValid(x, y, xWidth, yWidth, xPos, yPos, zMin)
	xPadding = math.ceil(math.Round(xWidth / 20))
	yPadding = math.ceil(math.Round(yWidth / 20))
	
	-- Avoid the edges of the map
	if(x > xPadding && x < xWidth - xPadding && y > yPadding && y < yWidth - yPadding) then
	
		-- Avoid the center of the map
		if(x < (xWidth - xPadding)/2 or x > (xWidth + xPadding)/2)	 then
			if ( y < (yWidth - yPadding)/2 or y > (yWidth + yPadding)/2) then
				SpawnSpawnPoint(xPos, yPos, zMin)
			end
		end
	end
end

-- Spawn a single spawn point
function SpawnSpawnPoint(xPos, yPos, zPos) 
	-- Create a spawn point
	--spawn=ents.Create("prop_dynamic")
	--spawn:SetModel("models/Gibs/Antlion_gib_small_3.mdl")
	spawn=ents.Create("info_player_axis")
	spawn:SetPos(Vector(xPos, yPos, zPos))
	spawn:Spawn()
end

local rankedWeapons = {"weapon_pistol", 
					   "weapon_357",
					   "weapon_smg1",
					   "weapon_shotgun",
					   "weapon_ar2",
					   "weapon_crossbow",
					   "weapon_frag",
					   "weapon_slam",
					   "weapon_rpg"}
					   
local SpawnedWeaponCount = {}
local AdvancedSpawnedWeaponCount = {}

-- Spawn a random weapon into the map, based on the current zPos
function SpawnRandomWeapon(xPos, yPos, zPos, zHeight, zMaxHeight)
	local weaponCount = #rankedWeapons;
	local weaponDouble = (weaponCount / zMaxHeight) * zHeight + math.random(-1,1) * 0.5;
	local chosenWeapon = 0
	
	-- Round down by default
	if(math.random(1,10) <= 7) then
		chosenWeapon = math.floor(weaponDouble);
	else
		chosenWeapon = math.ceil(weaponDouble);
	end
	
	-- Avoid overflow
	chosenWeapon = math.Clamp( chosenWeapon, 1, weaponCount )
	
	-- Make higher weapons much rarer
	if(math.random(1,weaponCount) >= chosenWeapon) then

		local weaponName = rankedWeapons[chosenWeapon]
		
		local ent = ents.Create(weaponName)
		--local ent = ents.Create("prop_physics")
		if not IsValid(ent) then print("ERROR:" .. weaponName .. " not a valid ent"); return false end
		--ent:SetModel( "models/weapons/w_crossbow.mdl" )
		
		-- Spawn in the entity
		ent:SetPos(Vector(xPos, yPos, zPos - ent:OBBMins().z/2))
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetAngles( Angle(0, 45, 90) )
		ent:SetVelocity( Vector(0, 0, 0) )
		ent:Spawn()
		
		-- Disable physics on the weapon after spawn
		local physObj = ent:GetPhysicsObject()
		if physObj:IsValid( ) then
			physObj:Wake()
			physObj:EnableMotion( false )
			physObj:EnableGravity( false )
		end
		
		-- Log the weapons that were spawned		
		if(SpawnedWeaponCount[weaponName] == nil) then
			SpawnedWeaponCount[weaponName] = 0
		end
		SpawnedWeaponCount[weaponName] = SpawnedWeaponCount[weaponName] + 1
		
		-- If in debug keep advanced stats too
		if(DEBUG_MODE) then
			if(AdvancedSpawnedWeaponCount[weaponName] == nil) then
				AdvancedSpawnedWeaponCount[weaponName] = {}
				for i=1,zMaxHeight do
					AdvancedSpawnedWeaponCount[weaponName][i] = 0; 
				end
			end

			AdvancedSpawnedWeaponCount[weaponName][zHeight] = AdvancedSpawnedWeaponCount[weaponName][zHeight] + 1			
		end
	end
end

function PrintWeaponCounts() 
	print("INFO: Spawned weapons:")
	
	-- Extra detailed stats
	if(DEBUG_MODE) then
		for key,heights in pairs(AdvancedSpawnedWeaponCount) do
	    	print(" - " .. key)
	    	for height,count in pairs(heights) do
	    		print("   - " .. height .. " : " .. count)
	    	end
	    end
	
	-- Standard stats
	else
		for key,value in pairs(SpawnedWeaponCount) do
	    	print(" - " .. key .. ": " .. value)
	    end
    end
end

-- Spawn a prop into the map that is solid & doesn't move 
function SpawnBox(position, model, skins, angle)
	spawnedBoxCount = spawnedBoxCount + 1
	
	-- Crate a maze_box entity
	local prop = ents.Create("maze_box") 
	
	--put it the right way up
	local ang = Vector(0,0,1):Angle();
	ang.pitch = ang.pitch + (90); 
	
	-- If an angle wasn't provided set it randomly
	if(angle == nil) then
	
		-- Set the prop straight some times
		if(math.random(1,10) <= 5) then
			ang:RotateAroundAxis(ang:Up(), math.random(0,3) * 90)
			
		-- The other times make it a bit wonky
		else
			ang:RotateAroundAxis(ang:Up(), math.random(0,3) * 90 + math.random(-5, 5))
		end
	else
		-- Use the provided angle
		ang:RotateAroundAxis(ang:Up(), angle)
	end
	
	-- Set the prop attributes
	prop:SetAngles(ang)
	prop:SetModel(model)
	
	-- If a skin list was provided (can be weighted), use it
	if(skins != nil) then
		prop:SetSkin(skins[math.random(#skins)])
	end
	
	
	-- Don't allow the box to move (disable move physics)
	prop:SetMoveType(MOVETYPE_NONE)
	prop:SetVelocity( Vector(0, 0, 0) )
	
	-- Compensate z by the box height
	local pos = position
	pos.z = pos.z - prop:OBBMaxs().z

	-- Set the box postion and spawn it
	prop:SetPos( pos )
	prop:Spawn()
	
	-- Set box to have 50 health
	prop:SetMaxHealth(50)
	prop:SetHealth( prop:GetMaxHealth( ) )
	
	-- Disable physics on the box after spawn
	local physObj = prop:GetPhysicsObject()
	if physObj:IsValid( ) then physObj:EnableMotion( false ) end
	
end
