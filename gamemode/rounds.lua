-- Sent the current round state to the clients
function SendRoundState(state)
   umsg.Start("round_state")
   	umsg.Char(state)
   umsg.End()
end

-- Set the current round state
function SetRoundState(state)
   GAMEMODE.RoundState = state

   --SCORE:RoundStateChange(state)

   SendRoundState(state)
end

-- Do we have enough players to start (2)
local function EnoughPlayers()
   local ready = 0
   
   -- count players that are ready to spawn
   for _, ply in pairs(player.GetAll()) do
      if IsValid(ply) and ply:ShouldSpawn() then
         ready = ready + 1
      end
   end
   return ready >= GetConVar("bw_minimum_players"):GetInt()
end

-- Get the round state
function GetRoundState()
   return GAMEMODE.RoundState
end

-- Used to be in Think/Tick, now in a timer
function WaitingForPlayers()
	if GetRoundState() == ROUND_WAIT then
    	if EnoughPlayers() then
	      -- In one second prepare the round
	      timer.Create("bw_prepare_round", 1, 1, PrepareRound)
	      timer.Stop("bw_waiting_for_players")
      else
      	printDebug("Not enough players to start the round")
      end
   end
end

-- Start waiting for players
function WaitForPlayers()
   SetRoundState(ROUND_WAIT)

   -- If we're not already waiting, wait
   if not timer.Start("bw_waiting_for_players") then
   	  -- Run the waiting method every two seconds, for ever
      timer.Create("bw_waiting_for_players", 2, 0, WaitingForPlayers)
   end
end

function ResetPlayerScores()
   -- Reset all players score
   for _, ply in pairs(player.GetAll()) do
      if IsValid(ply) then
         ply:SetFrags(0)
         ply:SetDeaths(0)
      end
   end
end

function ResetPlayers()
   -- Reset all players
   for _, ply in pairs(player.GetAll()) do
      if IsValid(ply) then
         ply:KillSilent()
      end
   end
end

-- Get a round ready to start
function PrepareRound()

   -- Cleanup the the map (remove ALL entities which were not created by the map)
   game.CleanUpMap(false)

   -- Reset all scores
   ResetPlayers()
   ResetPlayerScores()

   -- Current preparing
   SetRoundState(ROUND_PREP)

   -- See Maze.Lua
   timer.Simple(0.01,CreateMazes)
   
   -- Start the round in one second
   timer.Simple(1,BeginRound)   
end

-- Spawn in the players
function SpawnPlayers() 
	for _, ply in pairs(player.GetAll()) do
		if IsValid(ply) then
			ply:Spawn()
		end
	end
end

-- Checks if the round has ended
function StartWinChecks()
   if not timer.Start("bw_winchecker") then
      timer.Create("bw_winchecker", 1, 0, WinChecker)
   end
end

-- Cancel the win checking
function StopWinChecks()
   timer.Stop("bw_winchecker")
end

-- If the round has ended, ends the round
function WinChecker()
	local maxFrags = GetConVar("bw_max_frags"):GetInt()

	if GetRoundState() == ROUND_ACTIVE then
		if CurTime() > GetGlobalFloat("bw_round_end", 0) then
			EndRound(WIN_TIMELIMIT)
		else
			local winner = nil
			for _, ply in pairs(player.GetAll()) do
				if IsValid(ply) then
					if(ply:Frags() > maxFrags) then
						winner = player
					end
				end
			end
		
			if(winner ~= nil) then
				EndRound(WIN_PLAYER, winner)
			end
		end -- round hasn't ended
	end -- round active
end

local function SetRoundEndTime(endtime)
	SetGlobalFloat("bw_round_end", endtime)
end

-- Actually start a round
function BeginRound()
   AnnounceVersion()

   -- Spawn in our players
   SpawnPlayers()
   
   -- Round has started
   SetRoundState(ROUND_ACTIVE)
   
   -- Init round time
   local endtime = CurTime() + (GetConVar("bw_roundtime_minutes"):GetInt() * 60)
   SetRoundEndTime(endtime)

   -- Start the win condition check timer
   StartWinChecks()

end

-- The round ended
function EndRound(wintype, winner)
   -- The round has ended
   SetRoundState(ROUND_POST)
   
   -- Tell the users what went down
   TellPlayersAboutWin(wintype, winner)
   
   -- Stop checking for wins
   StopWinChecks()
   
   -- Wait to start the next round
   timer.Simple(3, WaitForPlayers())
end

-- Tell the players about the end of the round
function TellPlayersAboutWin(wintype, winner)

	-- Message to send to players
	local message = ""

	if(wintype == WIN_PLAYER) then
		if(winner:IsValid()) then 
			message = "The winner is " .. winner:GetName() .. ' with '.. winner:GetFrags() ..' kills.'
		else
			message = "The round ended, but the winner has left"
		end
	else
	
		-- Find the player with the most kills
		local mostFrags = nil
		for _, ply in pairs(player.GetAll()) do
			if IsValid(ply) and IsValid(mostFrags) then
				if(ply:GetFrags() > mostFrags:GetFrags()) then
					mostFrags = player
				end
			else
				if mostFrags ~= nil then
					mostFrags = player
				end
			end
		end
		
		if(mostFrags:IsValid()) then 
			message =  "The time limit ran out, the winner was " .. mostFrags:GetName() .. ' with '.. mostFrags:GetFrags() ..' kills.'
		else
			message =  "The time limit ran out, there was no winner."		
		end
	end
	
	
	PrintMessage(HUD_PRINTCENTER, message)
	PrintMessage(HUD_PRINTTALK, message)
	
end