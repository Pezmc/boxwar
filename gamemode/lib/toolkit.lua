function vardump(value, depth, key)
  local linePrefix = ""
  local spaces = ""
  
  if key ~= nil then
    linePrefix = "["..key.."] = "
  end
  
  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do spaces = spaces .. "  " end
  end
  
  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces ..linePrefix.."(table) ")
    else
      print(spaces .."(metatable) ")
        value = mTable
    end		
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)	== 'function' or 
      type(value)	== 'thread' or 
      type(value)	== 'userdata' or
      value		== nil
  then
    print(spaces..tostring(value))
  else
    print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
  end
end

DEBUG_MODE = false
function printDebug(message)
	if(DEBUG_MODE) then
		print("DEBUG: " .. message)
	end
end

-- Recursively adds everything in a directory to be downloaded by client
function AddResourcesByDirectory(directory) 
	local files, dirs = file.Find(directory.."/*", "GAME")
	
	-- Also check dirs
	for _, fdir in pairs(dirs) do
		-- If the first letter isn't a . recurce into that folder
		if string.sub(fdir,1,1) != "." then
			AddResourcesByDirectory(directory.."/"..fdir)
		else
			print("INFO: Ignored "..fdir.." when adding resourses");
		end
	end
 
	-- Add files
	for _,filename in pairs(files, true) do
		resource.AddSingleFile(directory.."/"..filename)
		printDebug(directory.."/"..filename)
	end
end