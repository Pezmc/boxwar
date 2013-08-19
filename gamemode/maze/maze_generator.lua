---
-- Copyright 2013 Pez Cuckow & Oliver Brown. All rights reserved.
---
-- These methods generate and manage a maze GRID (of 0's and 1's etc...)
---

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
	local requiredLength = xWidth*0.3 -- 1/3 of the map

	local totalAddedPaths = 0

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
					if (valid and (math.random(1,10) >= totalAddedPaths)) then				
						-- Reset x
						pathX = x
						
						-- Above or below in Y
						local newPathY = y + 1
						if(newPathY > yWidth) then
							newPathY = y - 1
						end
						
						-- Mark the entire path as double width
						while(pathX < xWidth && grid[pathX][y] == MAZE_PATH) do
							grid[pathX][y] = MAZE_WIDE_PATH_X
							grid[pathX][newPathY] = MAZE_WIDE_PATH_X
							pathX = pathX + 1 -- move right
						end
						
						-- If we can, skip the next column
						if(y + 2 < yWidth) then
							y = y + 2
						end
						
						totalAddedPaths = totalAddedPaths + 1
						
					else  -- search in Y
						if(y+requiredLength < yWidth) then
							valid = true
							local pathY = y
							local yEndPoint = y+requiredLength
							
							-- Search up to see if this is valid
							while(valid and pathY < yEndPoint) do
								if(grid[x][pathY] != MAZE_PATH) then valid = false end
								pathY = pathY + 1 -- move right
							end
							
							-- Spawn a path in Y
							if (valid and (math.random(1,10) >= totalAddedPaths))  then				
								-- Reset x
								pathY = y
								
								-- Above or below in Y
								local newPathX = x + 1
								if(newPathX > xWidth) then
									newPathX = x - 1
								end
								
								-- Mark the entire path as double width
								while(pathY < yWidth && grid[pathY][x] == MAZE_PATH) do
									grid[x][pathY] = MAZE_WIDE_PATH_Y
									grid[newPathX][pathY] = MAZE_WIDE_PATH_Y
									pathY = pathY + 1 -- move right
								end
								
								-- If we can, skip the next row
								if(x + 2 < xWidth) then
									x = x + 2
								end
								
								totalAddedPaths = totalAddedPaths + 1
							end -- spawn in y
						end -- fits in y
					end	-- search in y
				end
			end
		end
	end
	
	print("INFO: Added "..totalAddedPaths.. " double width paths")
	
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