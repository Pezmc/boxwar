---
-- Copyright 2013 Pez Cuckow & Oliver Brown. All rights reserved.
---
-- Load, create and spawn a maze
---

---- Represents parts of the maze ----
-- Hollow enum
MAZE_WALL = "#"
MAZE_PATH = " "
MAZE_WIDE_PATH_X = "_"
MAZE_WIDE_PATH_Y = "|"

-- Hollow enum
RANDOM_HOLLOW = "H"
CENTER_HOLLOW = "C"

-- Double square direction enums
DOUBLE_UP = "↑"
DOUBLE_RIGHT = "→"
DOUBLE_DOWN = "↓"
DOUBLE_LEFT = "←"
DOUBLE_EMPTY = "-"

-- Count how many boxes there are
TOTAL_MAZE_BOXES = 0
CURRENT_MAZE_BOXES = 0

-- Include the two parts of maze building
include("maze_spawner.lua")
include("maze_generator.lua")

---- Main methods ----
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
	if(DEBUG_MODE) then PrintMazeGrid(mazeGrid, xWidth, yWidth) end
	
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