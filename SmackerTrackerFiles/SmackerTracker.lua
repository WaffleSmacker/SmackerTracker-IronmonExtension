
local function IronMonData()
	local self = {
		version = "1.1",
		name = "Smacker Tracker V1.1",
		author = "WaffleSmacker",
		description = "Enables you to keep data from all your ironmon seeds and view them in a dashboard.  Auto Updates when your run ends.",
		textfile = "SmackerTracker/ironmon-seed-data.csv",
		github = "WaffleSmacker/SmackerTracker-IronmonExtension",
	}

	self.url = string.format("https://github.com/%s", self.github)


	-- Executed when the user clicks the "Check for Updates" button while viewing the extension details within the Tracker's UI
	function self.checkForUpdates()
		local versionCheckUrl = string.format("https://api.github.com/repos/%s/releases/latest", self.github)
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"' -- matches "1.0" in "tag_name": "v1.0"
		local downloadUrl = string.format("https://github.com/%s/releases/latest", self.github)
		local compareFunc = function(a, b) return a ~= b and not Utils.isNewerVersion(a, b) end -- if current version is *older* than online version
		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, compareFunc)
		return isUpdateAvailable, downloadUrl
	end

	local DASHBOARD_URL = "extensions/SmackerTracker/dashboard.html"

	function addStatsButtonToGameOverScreen()
		local STATS_ICON = { -- 12x11
			{0,1,1,1,1,0,0,0,0,0,0,0},
			{0,1,0,0,1,0,0,0,0,0,0,0},
			{0,1,0,0,1,0,0,0,0,0,0,0},
			{0,1,0,0,1,0,0,1,1,1,1,0},
			{0,1,0,0,1,0,0,1,0,0,1,0},
			{0,1,0,0,1,1,1,1,0,0,1,0},
			{0,1,0,0,1,0,0,1,0,0,1,0},
			{0,1,0,0,1,0,0,1,0,0,1,0},
			{0,1,0,0,1,0,0,1,0,0,1,0},
			{1,1,1,1,1,1,1,1,1,1,1,1},
		}
	
		local button = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = STATS_ICON,
			iconColors = { "Default text" },
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 81, Constants.SCREEN.MARGIN + 3, 12, 12},
			isVisible = function() return true end,
			onClick = function(this)
				Utils.openBrowserWindow(DASHBOARD_URL)
			end,
		}
	
		GameOverScreen.Buttons.SmackerTracker = button
	end

	------------------------------------ Data Tracking Section ------------------------------------
	local function getPokemonOrDefault(input)
		local id
		if not Utils.isNilOrEmpty(input, true) then
			id = DataHelper.findPokemonId(input)
		else
			local pokemon = Tracker.getPokemon(1, true) or {}
			id = pokemon.pokemonID
		end
		return PokemonData.Pokemon[id or false]
	end

	-- If true then 1, false is 0.
	local function boolToInteger(input)
		if input then
			return 1
		else return 0
		end
	end
    
	-- This section sets up the data which will be saved into the csv
	local function pokemonInfoToTable(pokemon, labMon)
		local info = {}
		if not PokemonData.isValid(pokemon.pokemonID) then
			return info
		end

		local uniqueId = tostring(GameSettings.game) .. "_" .. tostring(pokemon.personality)
		local seedNumber = Main.currentSeed
		local playTime = Program.GameTimer:getText()
		local currentDate = os.date("%Y-%m-%d")
		local pokemonName = PokemonData.Pokemon[pokemon.pokemonID].name or "Unknown Pokemon"
		local pokemonBST = PokemonData.Pokemon[pokemon.pokemonID].bst or 0
		local hpPercentage = (pokemon.curHP or 0) / (pokemon.stats.hp or 100)
		local abilityName = AbilityData.Abilities[PokemonData.getAbilityId(pokemon.pokemonID, pokemon.abilityNum)].name
		local type_1 = getPokemonOrDefault(pokemon.PokemonId).types[1]
		local type_2 = getPokemonOrDefault(pokemon.PokemonId).types[2]
		local move_1 = MoveData.Moves[pokemon.moves[1].id].name
		local move_2 = MoveData.Moves[pokemon.moves[2].id].name
		local move_3 = MoveData.Moves[pokemon.moves[3].id].name
		local move_4 = MoveData.Moves[pokemon.moves[4].id].name
		local shedinja_encounters
		if Tracker.Data.allPokemon[303] ~= nil then
    		shedinja_encounters = Tracker.Data.allPokemon[303].eT or 0
		else
    		shedinja_encounters = 0
		end
		local end_run_location = RouteData.Info[TrackerAPI.getMapId()].name

		local gameName
		if GameSettings.game == 3 then
			gameName = 'FireRed'
		elseif GameSettings.game == 2 then
			gameName = 'Emerald'
		else
			gameName = 'Unknown'
		end

		-- Get settings file name. Only works if the user generates a rom each time.
		local settingsFileName
		if Options["Generate ROM each time"] and not Utils.isNilOrEmpty(Options.FILES["Settings File"]) then
			settingsFileName = FileManager.extractFileNameFromPath(Options.FILES["Settings File"])
		else
			settingsFileName = ''
		end

		local enemyPokemonId
		local enemyPokemonName
		local lastEnemyMoveName
		local runEndCause
		local runEndTrainer = ""
		local lastEnemyMoveId = Memory.readword(GameSettings.gBattleResults + 0x24)
		local beatKaizo = Program.hasDefeatedTrainer(438) or Program.hasDefeatedTrainer(439)  or Program.hasDefeatedTrainer(440) or Program.hasDefeatedTrainer(739) or Program.hasDefeatedTrainer(740) or Program.hasDefeatedTrainer(741)

		local brockId = 414
		local mistyId = 415
		local surgeId = 416
		local erikaId = 417
		local kogaId = 418
		local sabrinaId = 420
		local blaineId = 419
		local giovanniId = 350

		if Battle.inActiveBattle() and MoveData.isValid(lastEnemyMoveId) then
			enemyPokemonId = Battle.getViewedPokemon(false).pokemonID
			enemyPokemonName = PokemonData.Pokemon[enemyPokemonId].name
			lastEnemyMoveName = MoveData.Moves[lastEnemyMoveId].name
		elseif beatKaizo then
			enemyPokemonName = 'None'
			lastEnemyMoveName = 'None'
		else
			enemyPokemonName = 'Poision'
			lastEnemyMoveName = 'Skissue'
		end

		local defeatedRivalOne = (Program.hasDefeatedTrainer(326) or Program.hasDefeatedTrainer(327) or Program.hasDefeatedTrainer(328))

		if Battle.inActiveBattle() and not defeatedRivalOne then 
			runEndCause = "Lab"
			runEndTrainer = Battle.opposingTrainerId
		elseif Battle.inActiveBattle() and not Battle.isWildEncounter then 
			runEndCause = "Trainer Battle"
			runEndTrainer = Battle.opposingTrainerId
		elseif Battle.inActiveBattle() and not Battle.isWildEncounter and Battle.opposingTrainerId == brockId then
			runEndCause = 'Brock Blocked'
		elseif Battle.inActiveBattle() and not Battle.isWildEncounter and Battle.opposingTrainerId == mistyId then
			runEndCause = 'Misty Mishap'
		elseif Battle.inActiveBattle() and not Battle.isWildEncounter and Battle.opposingTrainerId == surgeId then
			runEndCause = 'Surge Slapped'
		elseif Battle.inActiveBattle() and not Battle.isWildEncounter and Battle.opposingTrainerId == erikaId then
			runEndCause = 'Erased by Erika'
		elseif Battle.inActiveBattle() and not Battle.isWildEncounter and Battle.opposingTrainerId == kogaId then
			runEndCause = 'Krushed by Koga'
		elseif Battle.inActiveBattle() and not Battle.isWildEncounter and Battle.opposingTrainerId == sabrinaId then
			runEndCause = 'Sabrina Smacked'
		elseif Battle.inActiveBattle() and not Battle.isWildEncounter and Battle.opposingTrainerId == blaineId then
			runEndCause = 'Blaine Bonked'
		elseif Battle.inActiveBattle() and not Battle.isWildEncounter and Battle.opposingTrainerId == giovanniId then
			runEndCause = 'Got by Giovanni'
		elseif Battle.inActiveBattle() and Battle.isWildEncounter and not Program.hasDefeatedTrainer(102) then -- if die to wild before beating 1st forest trainer, died pivoting
			runEndCause = "Pivoting"
		elseif Battle.inActiveBattle() and Battle.isWildEncounter and Program.hasDefeatedTrainer(102) then
			runEndCause = "Fast Wild Mon"
		elseif beatKaizo then
			runEndCause = "Kaizo Victory"
		else
			runEndCause = "Poison"
		end

		-- labMon is just the pokemonID
		local labPokemon = PokemonData.Pokemon[labMon].name
		local isPivotRun = labPokemon ~= pokemonName

		-- Taken from TrainerData
		-- https://github.com/besteon/Ironmon-Tracker/blob/d13de0d7480d32897161cb12c692b3a2b5197b08/ironmon_tracker/data/TrainerData.lua
		local beat_brock = boolToInteger(Program.hasDefeatedTrainer(brockId))
		local beat_misty = boolToInteger(Program.hasDefeatedTrainer(mistyId))
		local beat_surge = boolToInteger(Program.hasDefeatedTrainer(surgeId))
		local beat_erika = boolToInteger(Program.hasDefeatedTrainer(erikaId))
		local beat_koga = boolToInteger(Program.hasDefeatedTrainer(kogaId))
		local beat_sabrina = boolToInteger(Program.hasDefeatedTrainer(sabrinaId))
		local beat_blaine = boolToInteger(Program.hasDefeatedTrainer(blaineId))
		local beat_giovanni = boolToInteger(Program.hasDefeatedTrainer(giovanniId))
		local beat_lorelai =boolToInteger( Program.hasDefeatedTrainer(410) or Program.hasDefeatedTrainer(735))
		local beat_bruno = boolToInteger(Program.hasDefeatedTrainer(411) or Program.hasDefeatedTrainer(736))
		local beat_agatha = boolToInteger(Program.hasDefeatedTrainer(412) or Program.hasDefeatedTrainer(737))
		local beat_lance = boolToInteger(Program.hasDefeatedTrainer(413) or Program.hasDefeatedTrainer(738))
		local beat_champ = boolToInteger(beatKaizo)

		

		-- Order matters. Only add new signals at the end.
		table.insert(info, tostring(uniqueId))
		table.insert(info, tostring(seedNumber))
		table.insert(info, tostring(playTime))
		table.insert(info, tostring(currentDate))
		table.insert(info, tostring(pokemonName))
		table.insert(info, tostring(pokemon.pokemonID))
		table.insert(info, tostring(type_1))
		table.insert(info, tostring(type_2))
		table.insert(info, tostring(pokemon.nickname or ""))
		table.insert(info, tostring(pokemon.level))
		table.insert(info, tostring(pokemon.stats.hp or 0))
		table.insert(info, tostring(pokemon.stats.atk or 0))
		table.insert(info, tostring(pokemon.stats.def or 0))
		table.insert(info, tostring(pokemon.stats.spa or 0))
		table.insert(info, tostring(pokemon.stats.spd or 0))
		table.insert(info, tostring(pokemon.stats.spe or 0))
		table.insert(info, tostring(pokemonBST))
		table.insert(info, tostring(abilityName))
		table.insert(info, tostring(move_1))
        table.insert(info, tostring(move_2))
		table.insert(info, tostring(move_3))
		table.insert(info, tostring(move_4))
		table.insert(info, tostring(shedinja_encounters))
		table.insert(info,tostring(end_run_location))
		table.insert(info, tostring(beat_brock))
		table.insert(info, tostring(beat_misty))
		table.insert(info, tostring(beat_surge))
		table.insert(info, tostring(beat_erika))
		table.insert(info, tostring(beat_koga))
		table.insert(info, tostring(beat_sabrina))
		table.insert(info, tostring(beat_blaine))
		table.insert(info, tostring(beat_giovanni))
		table.insert(info, tostring(beat_lorelai))
		table.insert(info, tostring(beat_bruno))
		table.insert(info, tostring(beat_agatha))
		table.insert(info, tostring(beat_lance))
		table.insert(info, tostring(beat_champ))
		table.insert(info, tostring(enemyPokemonId))
		table.insert(info, tostring(enemyPokemonName))
		table.insert(info, tostring(lastEnemyMoveName))
		table.insert(info, tostring(labPokemon))
		table.insert(info, tostring(isPivotRun))
		table.insert(info, tostring(runEndCause))
		table.insert(info, tostring(runEndTrainer))
		table.insert(info, tostring(gameName))
		table.insert(info, tostring(settingsFileName))
		return info
	end

	self.PerSeedVars = {
		PokemonDead = false,
	}


	function self.getHpPercent()
		local leadPokemon = Tracker.getPokemon(1, true) or Tracker.getDefaultPokemon()
		if PokemonData.isValid(leadPokemon.pokemonID) then
			local hpPercentage = (leadPokemon.curHP or 0) / (leadPokemon.stats.hp or 100)
			if hpPercentage >= 0 then
				return hpPercentage
			end
		end
	end
	
	function self.resetSeedVars()
		local V = self.PerSeedVars
		V.PokemonDead = false
		V.WonKaizo = false
		V.ShowInfo = false
		V.FirstPokemon = false
		V.FirstPokemonId = ""
	end

	local loadedVarsThisSeed
	local function isPlayingFRLG() return GameSettings.game == 3 end
	local function isPlayingE() return GameSettings.game == 2 end
	local function isPlayingFRorE() return isPlayingFRLG() or isPlayingE() end

	local function outputStatsToFile(pokemon, labMon, filename)
		if not PokemonData.isValid(pokemon.pokemonID) then
			return false
		end
	
		local customCodeFolder = FileManager.getCustomFolderPath()
		local filepath = customCodeFolder .. filename

		-- Check if the file exists
		local fileExists = io.open(filepath, "r")
		if not fileExists then
			-- File does not exist, create it and write headers
			fileExists = io.open(filepath, "w")
			if fileExists then
				-- Replace these header names with your desired column names
				local headers = "UniqueId,Seed Number,PlayTime,Date,Pokemon Name,Pokemon ID,Type 1,Type 2,Nickname,Level,HP,Attack,Defense,Sp. Atk,Sp. Def,Speed,BST,Ability,Moves 1,Moves 2,Moves 3,Moves 4,Shedinja Encounters,End Run Location,Beat Brock,Beat Misty,Beat Surge,Beat Erika,Beat Koga,Beat Sabrina,Beat Blaine,Beat Giovanni,Beat Lorelai,Beat Bruno,Beat Agatha,Beat Lance,Beat Champ,Enemy Pokemon ID,Enemy Pokemon,Last Enemy Move,Lab Pokemon,Pivot Run,Run End Cause,Run End Trainer,Game Name,Game Settings\n"
				fileExists:write(headers)
				fileExists:close()
			end
		else
			-- File exists, just close it
			fileExists:close()
		end
	
		-- Append data to the file
		local file = io.open(filepath, "a")
		if file then
			local linesToWrite = pokemonInfoToTable(pokemon, labMon) or {}
			local csvLine = table.concat(linesToWrite, ",") .. "\n"  -- Add a newline character at the end
			file:write(csvLine)
			file:close()
		end
	
		return true
	end
	
	local function valueExistsInFirstColumn(filename, checkValue)
		local file = io.open(filename, "r") -- Open the file in read mode
		if not file then
			return false, "Could not open file " .. filename
		end
	
		for line in file:lines() do
			local firstField = line:match("([^,]+)") -- Get the first field before the comma
			if firstField == checkValue then
				file:close()
				return true
			end
		end
	
		file:close()
		return false
	end

	-- Executed once every 30 frames, after most data from game memory is read in
	function self.afterProgramDataUpdate()
		-- Once per seed, when the player is able to move their character, initialize the seed variables
		if not isPlayingFRLG() or not Program.isValidMapLocation() then
			return
		elseif not loadedVarsThisSeed then
			self.resetSeedVars()
			loadedVarsThisSeed = true
		end
			
		local V = self.PerSeedVars
		local leadPokemon = Tracker.getPokemon(1, true) or Tracker.getDefaultPokemon()
		
		if isPlayingFRorE() and leadPokemon.pokemonID ~= nil and leadPokemon.pokemonID ~= 0 and not V.FirstPokemon then
			V.FirstPokemonId = leadPokemon.pokemonID
			V.FirstPokemon = true
			valueExistsInFirstColumn = valueExistsInFirstColumn("extensions/SmackerTracker/ironmon-seed-data.csv", tostring(GameSettings.game) .. "_" .. tostring(leadPokemon.personality))
		end

		-- Set up variable to use in the following checks.
		hpPercentage = self.getHpPercent()
		
		-- Lead Pokemon Died
		if hpPercentage ~= nil and hpPercentage == 0 and V.PokemonDead == false and not valueExistsInFirstColumn then
			V.PokemonDead = true
			outputStatsToFile(leadPokemon, V.FirstPokemonId, self.textfile)
			local csvPath = "extensions/SmackerTracker/ironmon-seed-data.csv"
			local jsonString = csvToJsonString(csvPath)
			writeJsonData(jsonString)
		end

		if (Program.hasDefeatedTrainer(438) or Program.hasDefeatedTrainer(439)  or Program.hasDefeatedTrainer(440) or Program.hasDefeatedTrainer(739) or Program.hasDefeatedTrainer(740) or Program.hasDefeatedTrainer(741)) and not V.WonKaizo and not valueExistsInFirstColumn then
			V.WonKaizo = true
			outputStatsToFile(leadPokemon, V.FirstPokemonId, self.textfile)
			local csvPath = "extensions/SmackerTracker/ironmon-seed-data.csv"
			local jsonString = csvToJsonString(csvPath)
			writeJsonData(jsonString)
		end
	end


	------------------------------------ Dashboard Generation Section ------------------------------------

	-- Function to split a string by a delimiter
	function split(str, delimiter)
		local result = {}
		for match in (str..delimiter):gmatch("(.-)"..delimiter) do
			table.insert(result, match)
		end
		return result
	end

	-- Function to convert CSV to a simple JSON string
	function csvToJsonString(csvFile)
		local file = io.open(csvFile, "r")
		local headers = split(file:read(), ",")
		local jsonLines = {}

		for line in file:lines() do
			local fields = split(line, ",")
			local jsonLine = "{"
			local value = "null";
			for i, header in ipairs(headers) do
				if fields[i] ~= nil then
					value = fields[i];
				end
				jsonLine = jsonLine .. '"' .. header .. '":"' .. value .. '"'
				if i < #headers then
					jsonLine = jsonLine .. ","
				end
			end
			jsonLine = jsonLine .. "}"
			table.insert(jsonLines, jsonLine)
		end
		file:close()

		return "[" .. table.concat(jsonLines, ",") .. "]"
	end
	-- You can now use jsonString as your JSON data in Lua

	-- Main function to generate the HTML dashboard
	function writeJsonData(jsonString)
        local dataJsString = [=[var data = ]=] .. jsonString .. [=[;]=]
		local jsFile = io.open("extensions/SmackerTracker/data.js", "w")
        jsFile:write(dataJsString)
        jsFile:close()
	
		print("Dashboard HTML file generated at extensions/SmackerTracker/dashboard.html")
	end

	-- Executed only once: When the extension is enabled by the user, and/or when the Tracker first starts up, after it loads all other required files and code
	function self.startup()
		addStatsButtonToGameOverScreen()
	end

	-- Executed only once: When the extension is disabled by the user, necessary to undo any customizations, if able
	function self.unload()
		GameOverScreen.Buttons.SmackerTracker = nil
	end

	return self
end
return IronMonData