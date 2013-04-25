do
	if (not GladiusEx.L) then
		GladiusEx.L = setmetatable({
			-- cooldowns module
			["cat:pvp_trinket"] = "PvP Trinket",
			["cat:mass_dispel"] = "Mass Dispel",
			["cat:cc"] = "CC",
			["cat:offensive"] = "Offensive",
			["cat:defensive"] = "Defensive",
			["cat:silence"] = "Silence",
			["cat:interrupt"] = "Interrupt",
			["cat:dispel"] = "Dispel",
			["cat:heal"] = "Heal",
			["cat:knockback"] = "Knockback",
			["cat:stun"] = "Stun",
			["cat:immune"] = "Immune",
			["cat:uncat"] = "Uncategorized",

			["maxhealthTag"] = "Max Health",
			["maxpower:shortTag"] = "Max Power (Short)",
			["powerTag"] = "Power",
			["health:shortTag"] = "Health (Short)",
			["classTag"] = "Class",
			["class:shortTag"] = "Class (Short)",
			["power:percentageTag"] = "Power (Percentage)",
			["power:shortTag"] = "Power (Short)",
			["raceTag"] = "Race",
			["nameTag"] = "Name",
			["name:statusTag"] = "Name/Status",
			["specTag"] = "Spec",
			["spec:shortTag"] = "Spec (Short)",
			["health:percentageTag"] = "Health (Percentage)",
			["healthTag"] = "Health",
			["maxhealth:shortTag"] = "Max Health (Short)",
			["maxpowerTag"] = "Max Power",

			-- Specs
			["specID:250:short"] = "Blood",
			["specID:251:short"] = "Frost",
			["specID:252:short"] = "Unholy",

			["specID:102:short"] = "Balance",
			["specID:103:short"] = "Feral",
			["specID:104:short"] = "Guardian",
			["specID:105:short"] = "Resto",

			["specID:253:short"] = "BM",
			["specID:254:short"] = "Marks",
			["specID:255:short"] = "Surv",

			["specID:62:short"] = "Arcane",
			["specID:63:short"] = "Fire",
			["specID:64:short"] = "Frost",

			["specID:268:short"] = "Brew",
			["specID:269:short"] = "Wind",
			["specID:270:short"] = "Mist",

			["specID:65:short"] = "Holy",
			["specID:66:short"] = "Prot",
			["specID:70:short"] = "Retri",

			["specID:256:short"] = "Disc",
			["specID:257:short"] = "Holy",
			["specID:258:short"] = "Shadow",

			["specID:259:short"] = "Assa",
			["specID:260:short"] = "Combat",
			["specID:261:short"] = "Subtl",

			["specID:262:short"] = "Ele",
			["specID:263:short"] = "Enha",
			["specID:264:short"] = "Resto",

			["specID:265:short"] = "Affli",
			["specID:266:short"] = "Demo",
			["specID:267:short"] = "Destru",

			["specID:71:short"] = "Arms",
			["specID:72:short"] = "Fury",
			["specID:73:short"] = "Prot",

			-- Classes
			["WARRIOR:short"] = "Warr",
			["DEATHKNIGHT:short"] = "DK",
			["WARLOCK:short"] = "Lock",
			["PRIEST:short"] = "Priest",
			["HUNTER:short"] = "Hunter",
			["ROGUE:short"] = "Rogue",
			["SHAMAN:short"] = "Shaman",
			["DRUID:short"] = "Druid",
			["PALADIN:short"] = "Pala",
			["MAGE:short"] = "Mage",
			["MONK:short"] = "Monk"
		}, {
			__index = function(t, index)
				return index end
		})
	end
end