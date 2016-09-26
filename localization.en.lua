local _, L = ...;
if ((GetLocale() == "enUS") or (GetLocale() == "enGB")) then
	print("enGB")
	L = {
		["Fishing"] = "Fishing",
		-- DK
		["Frost"] = "Frost",
		["Unholy"] = "Unholy",
		["Blood"] = "Blood",
		-- Druid
		["Guardian"] = "Guardian",
		["Feral"] = "Feral",
		["Restoration"] = "Restoration",
		["Balance"] = "Boomkin", --"Balance"
		-- Paladin
		["Holy"] = "Holy",
		["Retribution"] = "Retribution",
		["Protection"] = "Protection",
		-- Rogue
		["Outlaw"] = "Outlaw",
		["Assassination"] = "Assassination",
		["Sublety"] = "Sublety",
		-- DH
		["Vengeance"] = "Vengeance",
		["Havoc"] = "Havoc",
		-- Warlock
		["Destruction"] = "Destruction",
		["Demonology"] = "Demonology",
		["Affliction"] = "Affliction",
		-- Mage
		["Fire"] = "Fire",
		["Arcane"] = "Arcane",
		["Frost"] = "Frost",
		-- Priest
		["Holy"] = "Holy",
		["Discipline"] = "Discipline",
		["Shadow"] = "Shadow",
		-- Monk
		["Brewmaster"] = "Brewmaster",
		["Mistweaver"] = "Mistweaver",
		["Windwalker"] = "Windwalker",
		-- Warrior
		["Fury"] = "Fury",
		["Arms"] = "Arms",
		["Protection"] = "Protection",
		-- Shaman
		["Elemental"] = "Elemental",
		["Restoration"] = "Restoration",
		["Enhancement"] = "Enhancement",
		-- Hunter
		["Beast Mastery"] = "Beast Mastery",
		["Marksmanship"] = "Marksmanship",	
		["Survival"] = "Survival",
	}
end

