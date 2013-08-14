-- Randomized Prim's algorithm
function GenerateMaze(xWidth, yWidth)

	
	-- Walls
	walls = nil -- currently an empty table/list
    
	-- Set up the grid as all walls
	grid = {}
    for x=0,xWidth do
      grid[x] = {}     -- create a new row 
      for y=0,yWidth do
        grid[x][y] = 1 -- 1 == wall, 0 == hole/maze
      end
    end
    
    -- Pick a cell, mark it as part of the maze. Add the walls of the cell to the wall list.
    local randomX = math.Round(xWidth/2)
    local randomY = math.Round(yWidth/2)
    grid[randomX][randomY] = 0 -- part of the maze
    
    -- iterate through direct neighbors of node
    for i=-1,1 do
    	for j=-1,1 do
    		if(!(i==0&&j==0||i!=0&&j!=0)) then --only direct neighbors and not self
    			if(randomX + i >= 0 || randomX + i <= xWidth) then --if inside the maze on x
    				if(randomY + j >= 0 || randomY + j <= yWidth) then --if inside the maze on y
    					if(grid[randomX + i][randomY + j] != 0) then -- if the chozen square isn't a "maze"
    						walls = {next = walls, x = randomX + i, y = randomY + j, parent = {x = randomX, y = randomY}} -- add the wall to the list
    					end
    				end
    			end
    		end
    	end
    end
    
    -- While there are walls in the list:
    while(walls != nil && walls.next != nil) do
	    --[[postWall = walls
	    print("Full wall list:")
	    while(postWall != nil) do
	    	print(postWall.x .. ":" .. postWall.y)
	    	postWall = postWall.next
	    end]]
    
    	
    	-- Pick a random wall from the list. If the cell on the opposite side isn't in the maze yet:
    	-- Reservoir sampling with a reservoir of size 1.
    	chosenWall = walls -- select the first element
    	chosenWallParent = walls -- set to the parent item
    	currentWall = chosenWall -- start at the first item
    	seenWalls = 1
    	
    	-- Pick the first element regardless (for a list of length 1, the first element is always the sample).
    	while(currentWall.next != null) do
    		--print("Looking at " .. currentWall.next.x .. ":" .. currentWall.next.y .. " have considered " .. seenWalls .. " walls.")
    		
    		--For every other element with probability 1/n where n is the number of elements observed so far
    		--Replace the already picked element with the current element you are on.
    		if(math.random(0,seenWalls) == 1) then
    			chosenWall = currentWall.next
    			--print("Random was == 1, setting chosen wall to " .. chosenWall.x .. ":" .. chosenWall.y)
    			
    			chosenWallParent = currentWall 
    			currentWall = chosenWall -- we're currently on this item
    		else
    			currentWall = currentWall.next -- move one forward
    		end
    		seenWalls = seenWalls + 1
    		
    	end
    	
    	-- Get the opposite cell
	    opposite = nil
	    
		if( chosenWall.x - chosenWall.parent.x !=0 ) then -- if the parent is in X
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

		--print("Parent wall is x: " .. chosenWall.parent.x .. " y: " .. chosenWall.parent.y)		
		--print("Chosen wall is x: " .. chosenWall.x .. " y: " .. chosenWall.y)
		if (opposite != nil) then
			--print("Opposite wall is x: " .. opposite.x .. " y: " .. opposite.y)
		end
		
		-- Only opposites in the field
		if(opposite.x < 0 || opposite.x > xWidth || opposite.y < 0 || opposite.y > yWidth) then
			opposite = nil
		end
		
		-- If the cell on the opposite side isn't in the maze yet
		if( grid[chosenWall.x][chosenWall.y] == 1
			&& opposite != nil && grid[opposite.x][opposite.y] == 1 ) then
		
			-- Make the wall a passage and mark the cell on the opposite side as part of the maze.
			grid[chosenWall.x][chosenWall.y] = 0
			grid[opposite.x][opposite.y] = 0
			
			-- Add the neighboring walls of the cell to the wall list.
			-- But if any only if they are not already in the list
			    -- iterate through direct neighbors of node
			    for i=-1,1 do
			    	for j=-1,1 do
			    		if(!(i==0&&j==0||i!=0&&j!=0)) then --only direct neighbors and not self
			    			if(opposite.x + i >= 0 && opposite.x + i <= xWidth) then --if inside the maze on x
			    				if(opposite.y + j >= 0 && opposite.y + j <= yWidth) then --if inside the maze on y
			    					--print("Attempting to index ".. opposite.x + i .. ":" .. opposite.y + j)
			    					--print("Grid size is " .. xWidth .. ":" .. yWidth)
			    					if(grid[opposite.x + i][opposite.y + j] != 0) then -- if the chozen square isn't a "maze"
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
    
    --[[for x=0,xWidth do
      for y=0,yWidth do
        Msg(grid[x][y])
      end
      Msg("\n")
    end]]
    
    return grid
end

-- Add the boxes to the world
function SpawnBoxMaze() 
	jumpSize = 40;
	
	-- This config should somehow load from the map
	floorz = 0;
	minX = -470;
	maxX = 980;
	minY = -980;
	maxY = 470;
	
	xWidth = math.Round((maxX - minX) / jumpSize) 
	yWidth = math.Round((maxY - minY) / jumpSize)
	
	grid = GenerateMaze(xWidth, yWidth)
	
	crates = {
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
	
	doubleCrates = {
		"models/props_junk/wood_crate002a.mdl" --two wide!
	}
	
	-- Double direction
	DOUBLE_UP = "↑"
	DOUBLE_RIGHT = "→"
	DOUBLE_DOWN = "↓"
	DOUBLE_LEFT = "←"
	DOUBLE_EMPTY = 5
	
	-- Search for doubles
	for x=0,xWidth do
		for y=0,yWidth do
			if(x > 1 && x < xWidth - 1 && y > 1 && y < yWidth - 1) then --is this surrounded by valid cells?
				if(math.random(1,10) <= 2 ) then -- 20% chance to look for a double 
					local doubleWidthCell = nil
					
					 -- If this is a solid
					if(grid[x][y] == 1) then
						-- Check the nearby cell
						if(grid[x][y+1] == 1) then doubleWidthCell = DOUBLE_UP --check "above"
							elseif(grid[x+1][y] == 1) then doubleWidthCell = DOUBLE_RIGHT --check "right"
							elseif(grid[x][y-1] == 1) then doubleWidthCell = DOUBLE_DOWN --check "below"
							elseif(grid[x-1][y] == 1) then doubleWidthCell = DOUBLE_LEFT--check "left"
						end
						
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
	
	--[[
		Testing code]]
	-- Top right is largest
	for y=yWidth,0,-1 do
	  for x=0,xWidth do
      	Msg(grid[x][y])
      end
      Msg("\n")
    end	
	
	--[[grid[5][5] = 1;
	grid[5][6] = DOUBLE_UP;
	grid[5][7] = DOUBLE_EMPTY;
	grid[5][8] = 1;
	grid[6][5] = DOUBLE_RIGHT;
	grid[7][5] = DOUBLE_EMPTY;
	grid[8][5] = 1;
	grid[5][4] = DOUBLE_DOWN;
	grid[5][3] = DOUBLE_EMPTY;
	grid[5][2] = 1;
	grid[4][5] = DOUBLE_LEFT
	grid[3][5] = DOUBLE_EMPTY;
	grid[2][5] = 1;
	]]
	
	-- Spawn the map items
	for x=0,xWidth do
		for y=0,yWidth do
			-- Grid position
			xPos = minX + jumpSize * x;
			yPos = minY + jumpSize * y;
			
			-- If a wall spawn some boxes
			if(grid[x][y]==1) then
			
				if(math.random(0,10) <= 7) then -- 70% chance
					doubleWidthCell = nil
					
					SpawnProp(Vector(xPos, yPos, floorz + jumpSize ), crates[math.random( #crates )])
					if(math.random(0,10) <= 5) then -- 50% chance
						SpawnProp(Vector(xPos, yPos, floorz + jumpSize * 2 ), crates[math.random( #crates )])
						if(math.random(0,10) <= 3) then -- 30% chance
							SpawnProp(Vector(xPos, yPos, floorz + jumpSize * 3 ), crates[math.random( #crates )])
						end	
					end
				end
				
			-- If this is a double box square
			elseif(grid[x][y] == DOUBLE_UP || grid[x][y] == DOUBLE_RIGHT || grid[x][y] == DOUBLE_DOWN || grid[x][y] == DOUBLE_LEFT) then
				
				xDPos = xPos
				yDPos = yPos
				angle = 0
				
				if(grid[x][y] == DOUBLE_UP) then
					yDPos = yPos + jumpSize/2
				elseif(grid[x][y] == DOUBLE_RIGHT) then
					angle = 90
					xDPos = xPos + jumpSize/2
				elseif(grid[x][y] == DOUBLE_DOWN) then
					angle = 180
					yDPos = yPos - jumpSize/2
				elseif(grid[x][y] == DOUBLE_LEFT) then angle = 270
					angle = 270
					xDPos = xPos - jumpSize/2
				end
				
				SpawnProp(Vector(xDPos, yDPos, floorz + jumpSize ), doubleCrates[1], angle)
				if(math.random(1,20) <= 1) then -- 5% chance
					SpawnProp(Vector(xDPos, yDPos, floorz + jumpSize * 2 ), doubleCrates[1], angle)
				elseif(math.random(1,10) <= 2) then -- 20% chance
					SpawnProp(Vector(xPos, yPos, floorz + jumpSize * 2 ), crates[1])
				end
				
			elseif(grid[x][y] == DOUBLE_EMPTY) then
				-- Just do nothing
			else --empty hole
				xPadding = math.Round(xWidth / 10)
				yPadding = math.Round(yWidth / 10)
				if(x > xPadding && x < xWidth - xPadding && y > yPadding && y < yWidth - yPadding) then
					spawn=ents.Create("info_player_axis")
					spawn:SetPos(Vector(xPos, yPos, floorz))
					--spawn:SetModel("models/Gibs/Antlion_gib_small_3.mdl")
					spawn:Spawn()
				end
			end
		end
	end
	
	print("Built maze")
end

-- Completely random "maze"
function SpawnRandomBoxes()
	floorz = 0;

	for x=-500,1000,40  do
		for y=-1000,500,40 do
		
			if(math.random(0,10) <= 1) then
			SpawnProp(Vector(x, y, floorz + 40 ), "models/props_junk/wood_crate001a.mdl")
				if(math.random(0,5) <= 1) then
					SpawnProp(Vector(x, y, floorz + 80 ), "models/props_junk/wood_crate001a.mdl")
					if(math.random(0,5) <= 1) then
						SpawnProp(Vector(x, y, floorz + 120 ), "models/props_junk/wood_crate001a.mdl")
					end	
				end	
			end
		end
		
	end
	
end

-- Spawn a prop into the map that is solid & doesn't move 
function SpawnProp(position, model, angle)
	local prop = ents.Create("prop_physics") 
	local ang = Vector(0,0,1):Angle();
	ang.pitch = ang.pitch + 90;
	if(angle == nil) then
		if(math.random(1,10) <= 4) then -- % chance
			ang:RotateAroundAxis(ang:Up(), math.random(0,4) * 90)
		else
			ang:RotateAroundAxis(ang:Up(), math.random(0,4) * 90 + math.random(-5, 5))
		end
	else
		ang:RotateAroundAxis(ang:Up(), angle)
	end
	
	prop:SetAngles(ang)
	prop:SetModel(model)
	prop:SetMoveType(MOVETYPE_NONE)
	prop:SetVelocity( Vector(0, 0, 0) )
	
	
	local pos = position
	pos.z = pos.z - prop:OBBMaxs().z
	prop:SetPos( pos )
	prop:Spawn()
	
	-- Set box to have 50 health
	prop:SetMaxHealth(50)
	prop:SetHealth( prop:GetMaxHealth( ) )
	
	local physObj = prop:GetPhysicsObject()
	if physObj:IsValid( ) then physObj:EnableMotion( false ) end
end