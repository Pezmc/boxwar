-- == MAZE ENUMS == --
-- Hollow enum
local MAZE_WALL = "#"
local MAZE_PATH = " "
local MAZE_WIDE_PATH = "_"

-- Hollow enum
local RANDOM_HOLLOW = "H"
local CENTER_HOLLOW = "C"

-- Double square direction enums
local DOUBLE_UP = "↑"
local DOUBLE_RIGHT = "→"
local DOUBLE_DOWN = "↓"
local DOUBLE_LEFT = "←"
local DOUBLE_EMPTY = "-"

-- Load, then generate, then spawn a maze
function CreateMazes()
	totalMazeBoxes = 0;

	mazeConfigs = LoadMazeFile()
	
	if(mazeConfigs == nil || mazeConfigs['mazes'] == nil) then
		print("ERROR: No map maze to draw, not creating a maze");
		return
	end
	
	if next(mazeConfigs['mazes']) == nil then
		print("ERROR: Maze config doesn't contain any mazes!");
		return
	end
	
	local mazeCount = 0
	
	-- Create a maze for each one specified
	for _, mazeConfig in pairs(mazeConfigs['mazes']) do
        CreateMazeFromConfig(mazeConfig)
        mazeCount = mazeCount + 1
    end
    
    -- Set the current maze box count
	currentMazeBoxes = totalMazeBoxes
	print("INFO: Generated " .. mazeCount .. " mazes.")
end

-- Generate and spawn a maze from a config
function CreateMazeFromConfig(mazeConfig) 	
	boxWidth = 40; -- the size of the boxes

	-- Validate the config
	if(mazeConfig['xBegin'] == nil || mazeConfig['xEnd'] == nil
		||  mazeConfig['yBegin'] == nil || mazeConfig['yEnd'] == nil
		|| mazeConfig['zBegin'] == nil || mazeConfig['zEnd'] == nil) then
		print("ERROR: Maze config is invalid, must contain x,y,z begin and end")
		vardump(mazeConfig)
		return
	end
	
	-- Rename to make a bit clearer
	minX = mazeConfig['xBegin']
	maxX = mazeConfig['xEnd']
	minY = mazeConfig['yBegin']
	maxY = mazeConfig['yEnd']
	minZ = mazeConfig['zBegin']
	maxZ = mazeConfig['zEnd']
	
	-- How wide is the grid?
	xWidth = math.Round((maxX - minX) / boxWidth) 
	yWidth = math.Round((maxY - minY) / boxWidth)
	
	-- Generate the maze
	mazeGrid = GenerateMaze(xWidth, yWidth)

	-- Add double width paths to the maze
	mazeGrid = AddDoubleWidthPaths(mazeGrid,xWidth,yWidth)

	-- Make a hole in the middle of the maze
	local xHoleWidth = math.floor(xWidth / 10)
	local yHoleWidth = math.floor(yWidth / 10)
	mazeGrid = HollowMazeGrid(mazeGrid, xHoleWidth, yHoleWidth, xWidth, yWidth)
	
	-- Make some random holes throughout the map
	local holeCount = math.ceil(xWidth / 5)
	print(holeCount)
	RandomHollows(mazeGrid, holeCount, xHoleWidth, yHoleWidth, xWidth, yWidth)
	
	-- Add double width squares to the maze
	mazeGrid = AddDoublesToMazeGrid(mazeGrid, xWidth, yWidth) 
	
	-- Print the grid to help with debug
	if(debugMode) then PrintMazeGrid(mazeGrid, xWidth, yWidth) end
	
	-- Spawn the maze into the map
	SpawnBoxMaze(mazeGrid, xWidth, yWidth, minX, maxY, minY, maxY, minZ, maxZ, boxWidth) 
	
	-- Print info about spawned weapons
	PrintWeaponCounts()
end

-- Try and load the maze config file from the disk
function LoadMazeFile() 
	
	local mapMazeFilename = "maps/" .. string.lower(game.GetMap()) .. "_boxwar.txt";
	
	-- Does this map have a maze file?
	if(file.Exists(mapMazeFilename, "GAME")) then
	
		print("Found " .. mapMazeFilename)
		
		-- Read in the file	
		local f = file.Open( mapMazeFilename, "r", "GAME" )
		if ( !f ) then
			print("ERROR: Couldn't open " .. mapMazeFilename .. " for reading")
			return nil
		end
		
		local str = f:Read( f:Size() )
		f:Close()
		return JSON:decode(str) or nil
		
	else -- No maze file, create one for the user in /data/boxwar/maps/maps_boxwar.txt

		print("ERROR: This map doesn't have a .maze file, there will be no box maze");
	
		if(!file.Exists( "boxwar/", "DATA" )) then --"DATA" Data folder (garrysmod/data)
			file.CreateDir( "boxwar" )
		end
		
		-- Create the map folder if it doesn't exists
		if(!file.Exists( "boxwar/maps/", "DATA" )) then --"DATA" Data folder (garrysmod/data)
			file.CreateDir( "boxwar/maps/" )
		end
		
		-- Check if there is a file in the data dir
		local fileName = "boxwar/maps/" .. string.lower(game.GetMap()) .. "_boxwar.txt";
		if(file.Exists( fileName, "DATA" )) then
			print("WARNING: Found map maze file (" .. fileName .. ").")
			print("WARNING: This needs must be copied to maps/ to be loaded.");
			
		else -- Create an example file
			
			-- Example
			local exampleMapFile = {}
			exampleMapFile['mazes'] = {}
			
			local exampleMaze = {xBegin = 0, xEnd = 1000, yBegin = 0, yEnd = 1000, zBegin = 0, zEnd = 100}
			exampleMapFile['mazes']['groundFloor'] = exampleMaze
			
			exampleMaze = {xBegin = 1000, xEnd = 2000, yBegin = -100, yBegin = 100, zBegin = 100, zEnd = 1000}
			exampleMapFile['mazes']['firstFloor'] = exampleMaze
			
			-- Write the file to disk
			print("INFO: Created example map file at " .. fileName .. ".")
			print("INFO: This needs to be copied to maps/ to load.")
			file.Write(fileName, JSON:encode_pretty(exampleMapFile) )
		end
	end
	
	return nil
end

-- Randomized Prim's algorithm
function GenerateMaze(xWidth, yWidth)
	
	-- Walls
	walls = nil -- currently an empty table/list
    
	-- Set up the grid as all walls
	grid = {}
    for x=0,xWidth do
      grid[x] = {}     -- create a new row 
      for y=0,yWidth do
        grid[x][y] = MAZE_WALL -- 1 == wall, 0 == hole/maze
      end
    end
    
    -- Pick a cell, mark it as part of the maze. Add the walls of the cell to the wall list.
    local randomX = math.Round(xWidth/2)
    local randomY = math.Round(yWidth/2)
    grid[randomX][randomY] = MAZE_PATH -- part of the maze
    
    -- iterate through direct neighbors of node
    for i=-1,1 do
    	for j=-1,1 do
    		if(!(i==0&&j==0||i!=0&&j!=0)) then --only direct neighbors and not self
    			if(randomX + i >= 0 || randomX + i <= xWidth) then --if inside the maze on x
    				if(randomY + j >= 0 || randomY + j <= yWidth) then --if inside the maze on y
    					if(grid[randomX + i][randomY + j] != MAZE_PATH) then -- if the chozen square isn't a "maze"
    						walls = {next = walls, x = randomX + i, y = randomY + j, parent = {x = randomX, y = randomY}} -- add the wall to the list
    					end
    				end
    			end
    		end
    	end
    end
    
    -- While there are walls in the list:
    while(walls != nil && walls.next != nil) do
    	-- Pick a random wall from the list. If the cell on the opposite side isn't in the maze yet:
    	-- Reservoir sampling with a reservoir of size 1.
    	chosenWall = walls -- select the first element
    	chosenWallParent = walls -- set to the parent item
    	currentWall = chosenWall -- start at the first item
    	seenWalls = 1
    	
    	-- Pick the first element regardless (for a list of length 1, the first element is always the sample).
    	while(currentWall.next != null) do
    	
    		--For every other element with probability 1/n where n is the number of elements observed so far
    		--Replace the already picked element with the current element you are on.
    		if(math.random(0,seenWalls) == 1) then
    			chosenWall = currentWall.next
    			chosenWallParent = currentWall 
    			currentWall = chosenWall -- we're currently on this item
    		else
    			currentWall = currentWall.next -- move one forward
    		end
    		seenWalls = seenWalls + 1
    		
    	end
    	
    	-- Get the opposite cell
	    opposite = nil
	    
		if( chosenWall.x - chosenWall.parent.x != 0 ) then -- if the parent is in X
				opposite = { x = chosenWall.x + (chosenWall.x - chosenWall.parent.x),
							 y = chosenWall.y,
							 parent = { x = chosenWall.x, y = chosenWall.y }}
		elseif ( chosenWall.y - chosenWall.parent.y != 0 ) then -- if the parent is in y
				opposite = { x = chosenWall.x,
							 y = chosenWall.y - (chosenWall.parent.y - chosenWall.y),
							 parent = { x = chosenWall.x, y = chosenWall.y }}	
		else
			opposite = nil
		end	
		
		-- Only opposites in the field
		if(opposite.x < 0 || opposite.x > xWidth || opposite.y < 0 || opposite.y > yWidth) then
			opposite = nil
		end
		
		-- If the cell on the opposite side isn't in the maze yet
		if( grid[chosenWall.x][chosenWall.y] == MAZE_WALL
			&& opposite != nil && grid[opposite.x][opposite.y] == MAZE_WALL ) then
		
			-- Make the wall a passage and mark the cell on the opposite side as part of the maze.
			grid[chosenWall.x][chosenWall.y] = MAZE_PATH
			grid[opposite.x][opposite.y] = MAZE_PATH
			
			-- Add the neighboring walls of the cell to the wall list.
			-- But if any only if they are not already in the list
		    -- iterate through direct neighbors of node
		    for i=-1,1 do
		    	for j=-1,1 do
		    		if(!(i==0&&j==0||i!=0&&j!=0)) then --only direct neighbors and not self
		    			if(opposite.x + i >= 0 && opposite.x + i <= xWidth) then --if inside the maze on x
		    				if(opposite.y + j >= 0 && opposite.y + j <= yWidth) then --if inside the maze on y
		    				
		    					if(grid[opposite.x + i][opposite.y + j] != MAZE_PATH) then -- if the chozen square isn't a "maze"
		    						walls = {next = walls,
		    								 x = opposite.x + i,
		    								 y = opposite.y + j,
		    								 parent = {x = opposite.x, y = opposite.y}} -- add the wall to the list
		    					end
		    				end
		    			end
		    		end
		    	end
		    end	    
		end
		
		-- Remove the chosen wall from the list
		chosenWallParent.next = chosenWall.next
		
    end
    
    return grid
end

-- Hollow the center of the provided grid
function HollowMazeGrid(grid, xHoleWidth, yHoleWidth, xWidth, yWidth)

	-- For the center xHoleWidth tiles
	for x=math.floor(xWidth/2-xHoleWidth/2),
		  math.ceil(xWidth/2+xHoleWidth/2) do
		-- For the center yHoleWidth tiles
		for y=math.floor(yWidth/2-yHoleWidth/2),
			  math.ceil(yWidth/2+yHoleWidth/2) do
			  
			-- Make a hole
			if(math.random(1,10) <= 8) then
				grid[x][y] = CENTER_HOLLOW
			end
		end
	end
	
	return grid
end

-- Make random hallows in the grid
function RandomHollows(grid, count, xMaxWidth, yMaxWidth, xWidth, yWidth)

	local xHoleWidth = xMaxWidth
	local yHoleWidth = yMaxWidth
	for c=1,count do
		-- Make a hole
		grid = RandomHollow(grid, xHoleWidth, yHoleWidth, xWidth, yWidth)
		
		-- Make a little smaller each time
		xHoleWidth = math.ceil(xHoleWidth * 0.8) --won't get smaller than 4
		yHoleWidth = math.ceil(yHoleWidth * 0.8)
	end
	
	return grid
end

-- Make single random hollow
function RandomHollow(grid, xHoleWidth, yHoleWidth, xWidth, yWidth)
	-- Choose random start/end points
	xStart = math.random(1,xWidth)
	yStart = math.random(1,yWidth)
	
	-- don't go outside the map
	xEnd = math.Clamp(xStart + xHoleWidth,1,xWidth)
	yEnd = math.Clamp(yStart + yHoleWidth,1,yWidth)
	
	-- Make the hole
	for x=xStart,xEnd do
		for y=yStart,yEnd do
			if math.random(1,10) <= 8 then
				grid[x][y] = RANDOM_HOLLOW;
			end
		end
	end

	return grid
end

-- Find a few paths and make them wider 
function AddDoubleWidthPaths(grid,xWidth,yWidth)
	local requiredLength = xWidth*0.3

	for y=1,yWidth do	
		for x=1,xWidth do
						
			if(grid[x][y] == MAZE_PATH) then
				if(x+requiredLength < xWidth) then
					local valid = true
					local pathX = x
					local xEndPoint = x+requiredLength
					
					-- Search right to see if this is valid
					while(valid and pathX < xEndPoint) do
						if(grid[pathX][y] != MAZE_PATH) then valid = false end
						pathX = pathX + 1 -- move right
					end
					
					-- If we got to the end this must be a valid path
					if (valid and math.random(0,1) == 1) then				
						-- Reset x
						pathX = x
						
						-- Above or below in Y
						local newPathY = y + 1
						if(newPathY > yWidth) then
							newPathY = y - 1
						end
						
						-- Mark the entire path as double width
						while(grid[pathX][y] == MAZE_PATH) do
							grid[pathX][y] = MAZE_WIDE_PATH
							grid[pathX][newPathY] = MAZE_WIDE_PATH
							pathX = pathX + 1 -- move right
						end
					end
						
				end
			end
		end
	end
	
	return grid
end

-- Add double width squars to the provided grid
function AddDoublesToMazeGrid(grid, xWidth, yWidth) 
		
	-- Search for doubles
	for x=1,xWidth do
		for y=1,yWidth do
			if(x > 1 && x < xWidth - 1 && y > 1 && y < yWidth - 1) then -- is this surrounded by valid cells?
				if(math.random(1,10) <= 2 ) then -- 20% chance to look for a double 
					local doubleWidthCell = nil
					
					 -- If this is a solid
					if(grid[x][y] == MAZE_WALL) then
					
						-- Check the nearby cell
						if(grid[x][y+1] == MAZE_WALL) then doubleWidthCell = DOUBLE_UP --check "above"
							elseif(grid[x+1][y] == MAZE_WALL) then doubleWidthCell = DOUBLE_RIGHT --check "right"
							elseif(grid[x][y-1] == MAZE_WALL) then doubleWidthCell = DOUBLE_DOWN --check "below"
							elseif(grid[x-1][y] == MAZE_WALL) then doubleWidthCell = DOUBLE_LEFT--check "left"
						end
						
						-- If we found a double that would fit, then set it and it's neighbour
						if(doubleWidthCell ~= nil) then
							grid[x][y] = doubleWidthCell
							if(doubleWidthCell == DOUBLE_UP) then grid[x][y+1] = DOUBLE_EMPTY
								elseif(doubleWidthCell == DOUBLE_RIGHT) then grid[x+1][y] = DOUBLE_EMPTY 
								elseif(doubleWidthCell == DOUBLE_DOWN) then grid[x][y-1] = DOUBLE_EMPTY 
								elseif(doubleWidthCell == DOUBLE_LEFT) then grid[x-1][y] = DOUBLE_EMPTY
							end
						end
						
					end --grid[x][y] == 1
				end
			end	
		end
	end
	
	return grid;
end

function PrintMazeGrid(grid, xWidth, yWidth)
	-- Top right is largest
	for y=yWidth,0,-1 do
	  for x=0,xWidth do
      	Msg(grid[x][y])
      end
      Msg("\n")
    end	
end 

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

-- Crates used in mazes	
local crates = {
	-- Hacky weighted random
	"models/props_junk/wood_crate001a.mdl", --1
	"models/props_junk/wood_crate001a.mdl", --1
	"models/props_junk/wood_crate001a.mdl", --1
	"models/props_junk/wood_crate001a.mdl", --1
	"models/props_junk/wood_crate001a.mdl", --1
	"models/props_junk/wood_crate001a.mdl", --1
	"models/props_junk/wood_crate001a.mdl", --1
	"models/props_junk/wood_crate001a.mdl", --1
	"models/props_junk/wood_crate001a.mdl", --1
	"models/props_junk/wood_crate001a.mdl", --1
	"models/props_junk/wood_crate001a_damagedmax.mdl", --2
	"models/props_junk/wood_crate001a_damaged.mdl" --3
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
			SpawnBox(Vector(xPos, yPos, zPos ), crates[math.random( #crates )])
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

local doubleCrates = {
		"models/props_junk/wood_crate002a.mdl" --two wide!
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
	SpawnBox(Vector(xDPos, yDPos, zPos ), doubleCrates[1], angle)
	
	-- Loop variables
	local chance = 5; -- 7/10 chance to spawn box
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
				SpawnBox(Vector(xDPos, yDPos, zPos ), doubleCrates[1], angle)
			
			-- Spawn two single boxes
			elseif(randomType == 2) then
				SpawnBox(Vector(xPos, yPos, zPos ), crates[1])
				SpawnBox(Vector(xSPos, ySPos, zPos ), crates[1])
				
			-- Spawn a single box
			else
				if(math.random(0,1) == 0) then
					SpawnBox(Vector(xPos, yPos, zPos ), crates[1])
				else
					SpawnBox(Vector(xSPos, ySPos, zPos ), crates[1])
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
					   "weapon_rpg",
					   "weapon_frag",
					   "weapon_slam"}
					   
local SpawnedWeaponCount = {}
local AdvancedSpawnedWeaponCount = {}

-- Spawn a random weapon into the map, based on the current zPos
function SpawnRandomWeapon(xPos, yPos, zPos, zHeight, zMaxHeight)
	local weaponCount = #rankedWeapons;
	local weaponDouble = (weaponCount / zMaxHeight) * zHeight + math.random(-1,1) - 1;
	local chosenWeapon = 0
	
	-- Round down by default
	if(math.random(1,10) <= 7) then
		chosenWeapon = math.floor(weaponDouble);
	else
		chosenWeapon = math.ceil(weaponDouble);
	end
	
	-- Avoid overflow
	chosenWeapon = math.Clamp( chosenWeapon, 1, weaponCount )
	
	-- Make higher weapins much rarer
	if(math.random(1,weaponCount) >= chosenWeapon) then

		local weaponName = rankedWeapons[chosenWeapon]
		
		local ent = ents.Create(weaponName)
		if not IsValid(ent) then print("ERROR:" .. weaponName .. " not a valid ent"); return false end
		
		-- Spawn in the entity
		ent:SetPos(Vector(xPos, yPos, zPos))
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetVelocity( Vector(0, 0, 0) )
		ent:Spawn()
		
		-- Disable physics on the weapon after spawn
		local physObj = ent:GetPhysicsObject()
		if physObj:IsValid( ) then physObj:EnableMotion( false ) end
		
		-- Log the weapons that were spawned		
		if(SpawnedWeaponCount[weaponName] == nil) then
			SpawnedWeaponCount[weaponName] = 0
		end
		SpawnedWeaponCount[weaponName] = SpawnedWeaponCount[weaponName] + 1
		
		-- If in debug keep advanced stats too
		if(debugMode) then
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
	if(debugMode) then
		for key,heights in pairs(AdvancedSpawnedWeaponCount) do
	    	print(" - " .. key)
	    	for height,count in pairs(heights) do
	    		print("   - " .. height .. " : " .. count)
	    	end
	    end
	
	-- Standars stats
	else
		for key,value in pairs(SpawnedWeaponCount) do
	    	print(" - " .. key .. ": " .. value)
	    end
    end
end

-- Spawn a prop into the map that is solid & doesn't move 
function SpawnBox(position, model, angle)
	spawnedBoxCount = spawnedBoxCount + 1
	
	-- Crate a maze_box entity
	local prop = ents.Create("maze_box") 
	
	--put it the right way up
	local ang = Vector(0,0,1):Angle();
	ang.pitch = ang.pitch + 90; 
	
	-- If an angle wasn't provided set it randomly
	if(angle == nil) then
	
		-- Set the prop straight some times
		if(math.random(1,10) <= 5) then
			ang:RotateAroundAxis(ang:Up(), math.random(0,4) * 90)
			
		-- The other times make it a bit wonky
		else
			ang:RotateAroundAxis(ang:Up(), math.random(0,4) * 90 + math.random(-5, 5))
		end
	else
		-- Use the provided angle
		ang:RotateAroundAxis(ang:Up(), angle)
	end
	
	-- Set the prop attributes
	prop:SetAngles(ang)
	prop:SetModel(model)
	
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