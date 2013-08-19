---
-- Copyright 2013 Pez Cuckow & Oliver Brown. All rights reserved.
---
-- Function related to spawning the player
---

-- We use info_player_axis as no map should have these defined
local SpawnTypes = {"info_player_axis"}

function GetSpawnEnts(shuffled, force_all)
   local tbl = {}
   for k, classname in pairs(SpawnTypes) do
      for _, e in pairs(ents.FindByClass(classname)) do
         if IsValid(e) and (not e.BeingRemoved) then
            table.insert(tbl, e)
         end
      end
   end

   if shuffled then
      table.Shuffle(tbl)
   end

   return tbl
end