

local function IronMonData()
	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	local self = {
		version = "0.8",
		name = "[BETA] Smacker Tracker",
		author = "WaffleSmacker",
		description = "Enables you to keep data from all your ironmon seeds and view them in a dashboard. Click 'Options' to create the dashboard.",
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

	local function pokemonInfoToTable(pokemon, labMon)
		local info = {}
		if not PokemonData.isValid(pokemon.pokemonID) then
			return info
		end

		local seedNumber = Main.currentSeed
		local currentDate = os.date("%Y-%m-%d")
		local pokemonName = PokemonData.Pokemon[pokemon.pokemonID].name or "Unknown Pokemon"
		local pokemonBST = PokemonData.Pokemon[pokemon.pokemonID].bst or 0
		local status = MiscData.StatusCodeMap[pokemon.status] or ""
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

		local enemyPokemonId
		local enemyPokemonName
		local lastEnemyMoveName
		local runEndCause
		local runEndTrainer = ""
		local lastEnemyMoveId = Memory.readword(GameSettings.gBattleResults + 0x24)
		local enemyPokemon = Tracker.getPokemon(1, false, true)

		if Battle.inActiveBattle() and MoveData.isValid(lastEnemyMoveId) then
			enemyPokemonId = enemyPokemon.pokemonID
			enemyPokemonName = PokemonData.Pokemon[enemyPokemon.pokemonID].name
			lastEnemyMoveName = MoveData.Moves[lastEnemyMoveId].name
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
		elseif Battle.inActiveBattle() and Battle.isWildEncounter and not Program.hasDefeatedTrainer(102) then -- if die to wild before beating 1st forest trainer, died pivoting
			runEndCause = "Pivoting"
		elseif Battle.inActiveBattle() and Battle.isWildEncounter and Program.hasDefeatedTrainer(102) then
			runEndCause = "Fast Wild Mon"
		elseif Program.hasDefeatedTrainer(438) or Program.hasDefeatedTrainer(439)  or Program.hasDefeatedTrainer(440) or Program.hasDefeatedTrainer(739) or Program.hasDefeatedTrainer(740) or Program.hasDefeatedTrainer(741) then
			runEndCause = "Kaizo Victory"
		else
			runEndCause = "Poison"
		end

		-- labMon is just the pokemonID
		local labPokemon = PokemonData.Pokemon[labMon].name
		local isPivotRun = labPokemon ~= pokemonName

		-- Taken from TrainerData
		-- https://github.com/besteon/Ironmon-Tracker/blob/d13de0d7480d32897161cb12c692b3a2b5197b08/ironmon_tracker/data/TrainerData.lua
		local beat_brock = boolToInteger(Program.hasDefeatedTrainer(414))
		local beat_misty = boolToInteger(Program.hasDefeatedTrainer(415))
		local beat_surge = boolToInteger(Program.hasDefeatedTrainer(416))
		local beat_erika = boolToInteger(Program.hasDefeatedTrainer(417))
		local beat_koga = boolToInteger(Program.hasDefeatedTrainer(418))
		local beat_sabrina = boolToInteger(Program.hasDefeatedTrainer(420))
		local beat_blaine = boolToInteger(Program.hasDefeatedTrainer(419))
		local beat_giovanni = boolToInteger(Program.hasDefeatedTrainer(350))
		local beat_lorelai =boolToInteger( Program.hasDefeatedTrainer(410) or Program.hasDefeatedTrainer(735))
		local beat_bruno = boolToInteger(Program.hasDefeatedTrainer(411) or Program.hasDefeatedTrainer(736))
		local beat_agatha = boolToInteger(Program.hasDefeatedTrainer(412) or Program.hasDefeatedTrainer(737))
		local beat_lance = boolToInteger(Program.hasDefeatedTrainer(413) or Program.hasDefeatedTrainer(738))
		local beat_champ = boolToInteger(Program.hasDefeatedTrainer(438) or Program.hasDefeatedTrainer(439)  or Program.hasDefeatedTrainer(440) or Program.hasDefeatedTrainer(739) or Program.hasDefeatedTrainer(740) or Program.hasDefeatedTrainer(741))

		

		-- Order matters. Only add new signals at the end.
		table.insert(info, tostring(seedNumber))
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

		return info
	end

	self.PerSeedVars = {
		PokemonDead = false,
	}


	function self.getHpPercent()
		local playingFRLG = GameSettings.game == 3 -- FRLG
		local leadPokemon = Tracker.getPokemon(1, true) or Tracker.getDefaultPokemon()
		if PokemonData.isValid(leadPokemon.pokemonID) then
			local hpPercentage = (leadPokemon.curHP or 0) / (leadPokemon.stats.hp or 100)
			if hpPercentage >= 0 then
				return hpPercentage
			end
		end
	end

	function self.getItemQuantity(itemId)
		-- Check each known item category table if the item is there in some quantity
		for _, category in pairs(Program.GameData.Items or {}) do
			if type(category) == "table" and category[itemId] then
				return category[itemId]
			end
		end
		return 0
	end
	
	function self.resetSeedVars()
		local V = self.PerSeedVars
		V.PokemonDead = false
		V.WonKaizo = false
		V.ShowInfo = false
		V.FirstPokemon = false
		V.FirstPokemonId = ""

	end

	-- To properly determine when new items are acquired, need to load them in first at least once
	local loadedVarsThisSeed
	local function isPlayingFRLG() return GameSettings.game == 3 end

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
				local headers = "Seed Number,Date,Pokemon Name,Pokemon ID,Type 1,Type 2,Nickname,Level,HP,Attack,Defense,Sp. Atk,Sp. Def,Speed,BST,Ability,Moves 1,Moves 2,Moves 3,Moves 4,Shedinja Encounters,End Run Location,Beat Brock,Beat Misty,Beat Surge,Beat Erika,Beat Koga,Beat Sabrina,Beat Blaine,Beat Giovanni,Beat Lorelai,Beat Bruno,Beat Agatha,Beat Lance,Beat Champ,Enemy Pokemon ID,Enemy Pokemon,Last Enemy Move,Lab Pokemon,Pivot Run,Run End Cause,Run End Trainer\n"
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
	

	

	-- Executed once every 30 frames, after most data from game memory is read in
	function self.afterProgramDataUpdate()
		-- Once per seed, when the player is able to move their character, initialize the seed variables
		if not isPlayingFRLG() or not Program.isValidMapLocation() then
			return
		elseif not loadedVarsThisSeed then
			self.resetSeedVars()
			loadedVarsThisSeed = true
			--local dumbTest = false
		end
			
		local V = self.PerSeedVars
		local leadPokemon = Tracker.getPokemon(1, true) or Tracker.getDefaultPokemon()
		local playingFRLG = GameSettings.game == 3 -- FRLG
		
		if playingFRLG and leadPokemon.pokemonID ~= nil and leadPokemon.pokemonID ~= 0 and not V.FirstPokemon then
			V.FirstPokemonId = leadPokemon.pokemonID
			V.FirstPokemon = true
		end

		-- Set up variable to use in the following checks.
		hpPercentage = self.getHpPercent()
		
		-- Lead Pokemon Died
		-- If the pokemon has no hp and the HP was low before this, then its dead.
		-- Due to how often the script is run the pokemon will always have low hp before dying.
		if hpPercentage ~= nil and hpPercentage == 0 and V.PokemonDead == false then
			V.PokemonDead = true
			outputStatsToFile(leadPokemon, V.FirstPokemonId, self.textfile)
		end

		if (Program.hasDefeatedTrainer(438) or Program.hasDefeatedTrainer(439)  or Program.hasDefeatedTrainer(440) or Program.hasDefeatedTrainer(739) or Program.hasDefeatedTrainer(740) or Program.hasDefeatedTrainer(741)) and not V.WonKaizo then
			V.WonKaizo = true
			outputStatsToFile(leadPokemon, V.FirstPokemonId, self.textfile)
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
			for i, header in ipairs(headers) do
				jsonLine = jsonLine .. '"' .. header .. '":"' .. fields[i] .. '"'
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
	function csvToHtmlDashboard(jsonString, htmlFilePath)
		-- Convert CSV data to JSON
		local jsonData = jsonString

		local htmlString = [=[
			<!DOCTYPE html>
			<html>
			<head>
			<title>[Beta] WaffleDash</title>
			<meta charset="utf-8">
			<style>
				:root {
					--body-color: #333;
					--heading-color: var(--body-color);
					--body-bg: #f0f0f0;
					--card-bg: #fff;
					--card-box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
					--table-head-bg: var(--card-bg);
					--table-head-color: var(--body-color);
					--table-border-color: #eee;
					--table-row-selected-bg: #eee;
					--select-bg-img: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23343a40' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e");
					--border-color: #dfe3e6;
					--border-radius: 8px;
				}
		
				/* hidden easter egg (dark mode theme) */
				[theme="dark"] {
					--body-color: #dee2e6;
					--heading-color: var(--body-color);
					--body-bg: #212428;
					--card-bg: #1b1e23;
					--card-box-shadow: 0 0 8px rgba(220, 220, 220, 0.2);
					--table-head-bg: var(--card-bg);
					--table-head-color: var(--body-color);
					--table-border-color: #333;
					--table-row-selected-bg: #343537;
					--select-bg-img: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23dee2e6' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m2 5 6 6 6-6'/%3e%3c/svg%3e");
					--border-color: #485056;
				}
		
				html, body {
					width: 100%;
					height: 100%;
				}
		
				body {
					margin: 0;
					font-family: sans-serif;
					font-size: 1rem;
					font-weight: 400;
					line-height: 1.5;
					color: var(--body-color);
					background-color: var(--body-bg);
					-webkit-text-size-adjust: 100%;
					-webkit-tap-highlight-color: transparent;
				}
		
				h1, h2, h3, h4, h5, h6 {
					margin-top: 0;
					margin-bottom: .5rem;
					font-weight: 500;
					line-height: 1.2;
					color: var(--heading-color);
				}
		
				.dash-title {
					color: var(--link-color);
					display: flex;
					flex-direction: row;
					justify-content: space-between;
					align-items: center;
				}
		
				.dash-title h1 {
					margin-bottom: 0;
				}
		
				.seed-image {
					/* yeah this is some weird flexbox hack */
					min-width: 140px;
					min-height: 140px;
					max-width: 140px;
					max-height: 140px;
				}
		
				.img-fluid {
					max-width: 100%;
					max-height: 100%;
					width: auto;
					height: auto;
					border-radius: var(--border-radius);
				}
		
				.page-body {
					display: flex;
					flex-direction: column;
					height: 100%;
				}
		
				.flex-grow {
					flex-grow: 1;
				}
		
				.flex-basis-0 {
					flex-basis: 0;
				}
		
				.flex-row {
					display: flex;
					flex-direction: row;
				}
		
				.container {
					display: flex;
					flex-wrap: wrap;
				}
		
				.label {
					display: inline-block;
					font-weight: 600;
				}
		
				.aggregated-metrics .label {
					min-width: 160px;
				}
		
				.card {
					background-color: var(--card-bg);
					margin: 10px;
					padding: 20px;
					border-radius: var(--border-radius);
					box-shadow: var(--card-box-shadow);
				}
		
				table {
					width: 100%;
					border-collapse: collapse;
				}
				tbody tr {
					border-top: 1px solid var(--table-border-color);
				}
				tbody tr:first-child {
					/* another weird fix for top border and sticky header */
					border-top: 2px solid var(--table-border-color);
				}
		
				th, td {
					padding: 8px;
					text-align: left;
				}
		
				td {
					cursor: pointer;
					white-space: nowrap;
				}
		
				th {
					background-color: var(--table-head-bg);
					color: var(--table-head-color);
				}
				th:first-child {
					border-top-left-radius: 8px;
				}
				th:last-child {
					border-top-right-radius: 8px;
				}
		
				tr.selected {
					background-color: var(--table-row-selected-bg);
				}
		
				thead.fixedHeader {
					position: sticky;
					top: 0;
				}
		
				#managerTable {
					max-height: 100%;
					position: relative;
					overflow: auto;
				}
		
				.selected-seed-info,
				.state-data-info {
					display: flex;
					flex-direction: row;
				}
		
				.selected-seed-info > div + div {
					margin-left: 2rem;
				}
		
				.selected-seed-pokeinfo {
					margin-left: 2rem;
				}
		
				.selected-seed-pokeinfo .label {
					min-width: 124px;
				}
		
				.seed-info-stats .label {
					min-width: 40px;
				}
		
				#top5Pokemon .label {
					min-width: 120px;
				}
		
				#top5Types .label {
					min-width: 60px;
				}
		
				.aggregate-data {
					height: 100%;
					min-height: 300px;
					overflow: hidden;
				}
		
				select {
					display: inline-block;
					padding: .375rem 2.25rem .375rem .75rem;
					font-size: 1rem;
					font-weight: 400;
					line-height: 1.5;
					color: var(--body-color);
					-webkit-appearance: none;
					-moz-appearance: none;
					appearance: none;
					background-color: var(--body-bg);
					background-image: var(--select-bg-img,none);
					background-repeat: no-repeat;
					background-position: right .75rem center;
					background-size: 16px 12px;
					border: 1px solid var(--border-color);
					border-radius: .375rem;
					transition: border-color .15s ease-in-out, box-shadow .15s ease-in-out;
				}
			</style>
			<script>
				//var csvData =;
				if (document.readyState === "loading") {
					document.addEventListener("DOMContentLoaded", init);
				} else {
					init();
				}

				function init() {
					let csvData = ]=] .. jsonData .. [=[ 
					new WaffleDashboard(csvData);

				}
		
				class WaffleDashboard {
					constructor(data) {
						/* EASTER EGG (DARK MODE) */
						if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
							document.body.setAttribute('theme', 'dark');
						}
					
						this.data = data;
						this.data.sort((a, b) => {return b["Seed Number"] - a["Seed Number"]});
						this.dataTable =  document.getElementById('data-table-body');
		
						// Reset filter selects
						document.getElementById('pokemonFilter').value = '';
						document.getElementById('bstFilter').value = '';
		
						// Add options to pokemon select
						this.renderPokemonSelect();
		
						this.setupEventListeners();
						// update stats
						this.update();
		
						// select most recent seed
						this.updateSelectedRecord(this.data[0]["Seed Number"]);
					}
		
					setupEventListeners() {
						document.getElementById('pokemonFilter').addEventListener('change', (event) => {
							document.getElementById('bstFilter').value = '';
							if (!event.target.value) {
								this.stateData = null;
								this.update();
								return;
							}
							this.filter((item) => item["Pokemon Name"] === event.target.value);
							this.update();
						});
		
						document.getElementById('bstFilter').addEventListener('change', (event) => {
							document.getElementById('pokemonFilter').value = '';
							if (!event.target.value) {
								this.stateData = null;
								this.update();
								return;
							}
							this.filter((item) => {
								let bst = parseInt(item["BST"]);
								switch (event.target.value) {
									case 'under300':
										return bst < 300;
									case '300to449':
										return bst >= 300 && bst <= 449;
									case '450to599':
										return bst >= 450 && bst <= 599;
									case 'over600':
										return bst > 600;
									default:
										return true; // Show all rows by default
								}
							});
							this.update();
						});
		
						this.dataTable.addEventListener("click", (event) => {
							let seedNumber = event.target.dataset.seed || event.target.parentNode.dataset.seed
							if (seedNumber) {
								this.updateSelectedRecord(event.target.parentNode.dataset.seed);
							}
						});
					}
		
					renderPokemonSelect() {
						let distinctNames = {};
						for (let item, i = 0; item = this.data[i++];) {
							let name = item["Pokemon Name"];
							if (!(name in distinctNames)) {
								distinctNames[name] = 1;
							}
						}
						distinctNames = Object.keys(distinctNames);
						distinctNames.sort();
						for (let idx in distinctNames) {
							let option = document.createElement('option');
							option.innerText = distinctNames[idx];
							document.getElementById('pokemonFilter').appendChild(option);
						}
					}
		
					update() {
						this.updateTop5PokemonAndTypes();
						this.renderDataTable();
						this.updateMetricsDisplay();
					}
		
					updateSelectedRecord(seedNumber) {
						if (!this.selectedRecord || (seedNumber > 0 && seedNumber != this.selectedRecord["Seed Number"])) {
							this.selectedRecord = this.data.filter((item) => item["Seed Number"] == seedNumber)[0];
						}
		
						// set selected row class
						this.dataTable.querySelectorAll('tr.selected').forEach((el) => el.classList.remove('selected'));
						this.dataTable.querySelector('tr[data-seed="'+this.selectedRecord["Seed Number"]+'"]').classList.add('selected');
		
						// update Info
						document.getElementById('recentSeedNumber').innerHTML = this.selectedRecord['Seed Number'];
						document.getElementById('recentName').innerHTML = this.selectedRecord['Pokemon Name'];
						document.getElementById('recentLVL').innerHTML = this.selectedRecord['Level'];
						document.getElementById('recentNickname').innerHTML = this.selectedRecord['Nickname'];
						document.getElementById('recentRunEnded').innerHTML = this.selectedRecord['End Run Location'];
						document.getElementById('recentRunEndCause').innerHTML = this.selectedRecord['Run End Cause'];
		
						// Update Image
						let imageName = this.selectedRecord['Pokemon Name'].toLowerCase().replace(/\s+/g, '-').replace(/\./g, '') + '.avif';
						let imagePath = "https://img.pokemondb.net/artwork/avif/" + imageName;
						document.getElementById('recentImage').src = imagePath;
						document.getElementById('recentImage').alt = this.selectedRecord['Pokemon Name'];
		
						// Update Stats
						document.getElementById('recentHP').innerHTML = this.selectedRecord['HP'];
						document.getElementById('recentATK').innerHTML = this.selectedRecord['Attack'];
						document.getElementById('recentDEF').innerHTML = this.selectedRecord['Defense'];
						document.getElementById('recentSPA').innerHTML = this.selectedRecord['Sp. Atk'];
						document.getElementById('recentSPD').innerHTML = this.selectedRecord['Sp. Def'];
						document.getElementById('recentSPE').innerHTML = this.selectedRecord['Speed'];
						document.getElementById('recentBST').innerHTML = this.selectedRecord['BST'];
		
						document.getElementById('recentMove1').innerHTML = this.selectedRecord['Moves 1'];
						document.getElementById('recentMove2').innerHTML = this.selectedRecord['Moves 2'];
						document.getElementById('recentMove3').innerHTML = this.selectedRecord['Moves 3'];
						document.getElementById('recentMove4').innerHTML = this.selectedRecord['Moves 4'];
					}
		
					getData() {
						return this.stateData || this.data;
					}
		
					filter(filter) {
						this.stateData = this.data.filter(filter);
					}
		
					renderDataTable() {
						let tBody = '';
						this.getData().forEach((item) => {
							tBody += `<tr data-seed="${item['Seed Number']}">
								<td>${item["Seed Number"]}</td>
								<td>${item["Date"]}</td>
								<td>${item["Pokemon Name"]}</td>
								<td>${item["Pivot Run"] === "true" ? "&#x2714;" : ""}</td>
								<td>${item["Level"]}</td>
								<td>${item["HP"]}</td>
								<td>${item["Attack"]}</td>
								<td>${item["Defense"]}</td>
								<td>${item["Sp. Atk"]}</td>
								<td>${item["Sp. Def"]}</td>
								<td>${item["Speed"]}</td>
								<td>${item["Ability"]}</td>
								<td>${item["Moves 1"]}</td>
								<td>${item["Moves 2"]}</td>
								<td>${item["Moves 3"]}</td>
								<td>${item["Moves 4"]}</td>
								<td>${item["Shedinja Encounters"]}</td>
								<td>${item["End Run Location"]}</td>
								<td>${item["Run End Cause"]}</td>
								<td>${item["Enemy Pokemon"]}</td>
								<td>${item["Last Enemy Move"]}</td>
							</tr>`;
						});
						this.dataTable.innerHTML = tBody;
					}
		
					updateTop5PokemonAndTypes() {
						// Calculate top 5 Pokémon
						let pokemonCounts = {};
						this.getData().forEach(record => {
							let name = record['Pokemon Name'];
							if (name) {
								pokemonCounts[name] = (pokemonCounts[name] || 0) + 1;
							}
						});
						let top5Pokemon = Object.entries(pokemonCounts)
							.sort((a, b) => b[1] - a[1])
							.slice(0, 5);
		
						// Calculate top 5 Types (assuming Type data is available)
						let typeCounts = {};
						this.getData().forEach(record => {
							let types = [record['Type 1'], record['Type 2']].filter(Boolean);
							types.forEach(type => {
								typeCounts[type] = (typeCounts[type] || 0) + 1;
							});
						});
						let top5Types = Object.entries(typeCounts).sort((a, b) => b[1] - a[1]).slice(0, 5);
						let top5PokemonHtml = '<h2>Top 5 Pokémon</h2>' + top5Pokemon.map(([name, count]) => `<span class="label">${name}:</span> ${count}`).join('<br>');
						let top5TypesHtml = '<h2>Top 5 Types</h2>' + top5Types.map(([type, count]) => `<span class="label">${type}:</span> ${count}`).join('<br>');
		
						document.getElementById('top5Pokemon').innerHTML = top5PokemonHtml;
						document.getElementById('top5Types').innerHTML = top5TypesHtml;
					}
		
					updateMetricsDisplay() {
						let seedData = this.getData();
						let totalSeeds = seedData.length;
						let labEscapeCount = seedData.filter(record => record["End Run Location"] !== "Oak's Lab").length;
						let runsPastBrock = seedData.filter(record => record["Beat Brock"] === "1").length;
						let labEscapeRate = (labEscapeCount * 100 / totalSeeds).toFixed(1); // Convert to percentage
						let brockEscapeRate = (runsPastBrock * 100 / totalSeeds).toFixed(1); // Convert to percentage
		
						document.getElementById("totalSeeds").textContent = totalSeeds;
						document.getElementById("labEscapeRate").textContent = labEscapeRate;
						document.getElementById("runsPastBrock").textContent = runsPastBrock;
						document.getElementById("brockEscapeRate").textContent = brockEscapeRate;
					}
				}
			</script>
		</head>
		<body>
		<div class="page-body">
			<div class="container">
				<div class="dash-title flex-grow card">
					<h1>IronMon Data Tracker - BETA</h1>
					<a href="https://twitch.tv/wafflesmacker" target="_blank">Created by Wafflesmacker</a>
				</div>
				<div class="dash-filters card">
					<select id="pokemonFilter" name="pokemonFilter">
						<option value="" selected>Select a Pokémon</option>
					</select>
					<select id="bstFilter" name="bstFilter">
						<option value="" selected>Select BST Range</option>
						<option value="under300">Under 300</option>
						<option value="300to449">300 - 449</option>
						<option value="450to599">450 - 599</option>
						<option value="over600">Over 600</option>
					</select>
				</div>
			</div>
			<div class="container">
				<div class="state-data-info flex-grow flex-basis-0">
					<div class="aggregated-metrics card flex-grow" id="metrics">
						<h2>Summary Data</h2>
						<div><span class="label">Total Seeds:</span> <span id="totalSeeds"></span></div>
						<div><span class="label">Lab Escape Rate:</span> <span id="labEscapeRate"></span>%</div>
						<div><span class="label">Runs Past Brock:</span> <span id="runsPastBrock"></span></div>
						<div><span class="label">Brock Escape Rate:</span> <span id="brockEscapeRate"></span>%</div>
					</div>
					<div id="top5Pokemon" class="card flex-grow"></div>
					<div id="top5Types" class="card flex-grow"></div>
				</div>
		
				<div class="flex-grow flex-basis-0">
					<div class="card selected-seed-info">
						<div class="seed-info-details">
							<h2>Seed #<span id="recentSeedNumber"></span></h2>
							<div class="flex-row">
								<div class="seed-image">
									<img id="recentImage" class="img-fluid" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"
											alt="Pokemon Image"/>
								</div>
								<div class="selected-seed-pokeinfo">
									<div><span class="label">PokeMon:</span> <span id="recentName"></span></div>
									<div><span class="label">Nickname:</span> <span id="recentNickname"></span></div>
									<div><span class="label">Level:</span> <span id="recentLVL"></span></div>
									<div><span class="label">BST:</span> <span id="recentBST"></span></div>
									<div><span class="label">Run Ended:</span> <span id="recentRunEnded"></span></div>
									<div><span class="label">Run End Cause:</span> <span id="recentRunEndCause"></span></div>
								</div>
							</div>
						</div>
						<div class="seed-info-stats">
							<h2>Stats</h2>
							<div><span class="label">HP:</span> <span id="recentHP"></span></div>
							<div><span class="label">ATK:</span> <span id="recentATK"></span></div>
							<div><span class="label">DEF:</span> <span id="recentDEF"></span></div>
							<div><span class="label">SPA:</span> <span id="recentSPA"></span></div>
							<div><span class="label">SPD:</span> <span id="recentSPD"></span></div>
							<div><span class="label">SPE:</span> <span id="recentSPE"></span></div>
						</div>
						<div>
							<h2>Moves</h2>
							<div id='recentMove1'>Psychic</div>
							<div id='recentMove2'>Magical Leaf</div>
							<div id='recentMove3'>Thief</div>
							<div id='recentMove4'>Rock Throw</div>
						</div>
					</div>
				</div>
			</div>
		
			<div class="aggregate-data card">
				<div id="managerTable">
					<table id="seed-detailed-table">
						<thead class="fixedHeader">
						<tr>
							<th>#</th>
							<th>Date</th>
							<th>Pokemon</th>
							<th>Pivot</th>
							<th>LVL</th>
							<th>HP</th>
							<th>ATK</th>
							<th>DEF</th>
							<th>SPA</th>
							<th>SPD</th>
							<th>SPE</th>
							<th>Ability</th>
							<th>Move 1</th>
							<th>Move 2</th>
							<th>Move 3</th>
							<th>Move 4</th>
							<th><img title="Shedinjas encountered" alt="shed"
										src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAATBAMAAABiojCGAAAAElBMVEUAAABBQUHV1Wq9pFpiYlr29qxtbM5HAAAAAXRSTlMAQObYZgAAAH9JREFUCNc9zdENwyAMRdGHlAFwyAJ5ZAHHHqAJLFCp3X+VAiq5X0e2JQMQzALjw/MhkuJ/Ft4iTYyNNEpgjlhS5v5Z8xVxryd5JOeOwkZTM8WVSTF1iQht9S1qCmBjvQ+V2Gmne/Lx2JxiFT0RydUHF60sL4zqdk9iKRWY7sMfeFARcwYTa1kAAAAASUVORK5CYII=">
							</th>
							<th>End Location</th>
							<th>End Cause</th>
							<th>Enemy Pokemon</th>
							<th>Last Move</th>
						</tr>
						</thead>
						<tbody id="data-table-body"></tbody>
					</table>
				</div>
			</div>
		</div>
		</body>
		</html>
		]=]
	
		-- Write the HTML string to a file
		local file = io.open(htmlFilePath, "w")
		file:write(htmlString)
		file:close()
	
		print("Dashboard HTML file generated at " .. htmlFilePath)
	end




	-- Executed when the user clicks the "Options" button while viewing the extension details within the Tracker's UI
	function self.configureOptions()
		if not Main.IsOnBizhawk() then return end
		-- Example usage
		-- Example usage (make sure to replace these paths with actual ones)
		local csvPath = "extensions/SmackerTracker/ironmon-seed-data.csv"
		local jsonString = csvToJsonString(csvPath)

		local htmlPath = "extensions/SmackerTracker/dashboard.html"
		
		csvToHtmlDashboard(jsonString, htmlPath)
		-- self.openOptionsPopup()
	end

	return self
end
return IronMonData