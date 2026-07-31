--[[
	Data/Mounts.lua - the Classic Era / Season of Discovery mount database.

	Two kinds of entries:
	  "item"  - a bag item you right-click to summon (everyone but Paladin/Warlock)
	  "spell" - a self-cast mount spell (Paladin Warhorse/Charger, Warlock
	            Felsteed/Dreadsteed). These two classes never carry a mount
	            item; Scan.lua checks IsSpellKnown for these instead of bags.

	`speed` is 60 or 100 (percent movement speed increase). It mirrors the
	item's actual in-game Riding-skill requirement (Journeyman/40 -> 60%,
	Expert/60 -> 100%), which is what determines the mount's real speed
	regardless of which particular recolor it is. Mount.lua still clamps this
	against the player's *current* Riding skill, since owning a 100% mount
	before training Expert Riding only gets you 60%.

	`quality` is the item's rarity tier (1-5), used only to color entries in
	the options panel to match Blizzard's item-quality colors - it has no
	effect on mount selection.

	Item id/name/quality/reqlevel were pulled directly from Wowhead's Classic
	mount item listing (wowhead.com/classic/items/miscellaneous/mounts) to
	avoid hand-typing 140 item IDs from memory. A handful of items with
	non-standard reqlevels are special-cased below:
	  - Riding Turtle (23720, reqlevel 20) - old-world novelty mount
	  - Trainee's Outrider Wolf / Sentinel Nightsaber (211499/211498,
	    reqlevel 25) - SoD's early low-level starter mounts
	  - Testament of Divine Steed (228238, reqlevel 45) - SoD Paladin item
	  All three are treated as 60%-tier. Two literal dev-leftover items
	  ("Deptecated White Stallion Summoning", "Brown Horse Summoning",
	  ids 901/875) are excluded entirely - never obtainable by players.

	Faction is deliberately NOT tracked: item ownership already implies
	eligibility (a Horde player can never have an Alliance-only mount item in
	their bags in the first place), so a faction field would be redundant
	metadata with no effect on scanning, and Season of Discovery's Blood
	Knight quest muddies "Paladin mount = Alliance-only" anyway.
]]

local ADDON, ns = ...

ns.MountSpells = {
	{ id = 13819, kind = "spell", name = "Summon Warhorse",  speed = 60,  quality = 3, class = "PALADIN" },
	{ id = 23214, kind = "spell", name = "Summon Charger",   speed = 100, quality = 4, class = "PALADIN" },
	{ id = 5784,  kind = "spell", name = "Summon Felsteed",  speed = 60,  quality = 3, class = "WARLOCK" },
	{ id = 23161, kind = "spell", name = "Summon Dreadsteed",speed = 100, quality = 4, class = "WARLOCK" },
}

ns.MountItems = {
	{ id = 19902, kind = "item", name = "Swift Zulian Tiger", speed = 100, quality = 4 },
	{ id = 21176, kind = "item", name = "Black Qiraji Resonating Crystal", speed = 100, quality = 5 },
	{ id = 13086, kind = "item", name = "Reins of the Winterspring Frostsaber", speed = 100, quality = 4 },
	{ id = 19872, kind = "item", name = "Swift Razzashi Raptor", speed = 100, quality = 4 },
	{ id = 2411, kind = "item", name = "Black Stallion Bridle", speed = 60, quality = 1 },
	{ id = 2414, kind = "item", name = "Pinto Bridle", speed = 60, quality = 3 },
	{ id = 18778, kind = "item", name = "Swift White Steed", speed = 100, quality = 4 },
	{ id = 18902, kind = "item", name = "Reins of the Swift Stormsaber", speed = 100, quality = 4 },
	{ id = 5655, kind = "item", name = "Chestnut Mare Bridle", speed = 60, quality = 3 },
	{ id = 18766, kind = "item", name = "Reins of the Swift Frostsaber", speed = 100, quality = 4 },
	{ id = 19030, kind = "item", name = "Stormpike Battle Charger", speed = 100, quality = 4 },
	{ id = 19029, kind = "item", name = "Horn of the Frostwolf Howler", speed = 100, quality = 4 },
	{ id = 18776, kind = "item", name = "Swift Palomino", speed = 100, quality = 4 },
	{ id = 236662, kind = "item", name = "Reins of War", speed = 100, quality = 4 },
	{ id = 18242, kind = "item", name = "Reins of the Black War Tiger", speed = 60, quality = 4 },
	{ id = 5656, kind = "item", name = "Brown Horse Bridle", speed = 60, quality = 3 },
	{ id = 18767, kind = "item", name = "Reins of the Swift Mistsaber", speed = 100, quality = 4 },
	{ id = 236664, kind = "item", name = "Reins of Death", speed = 100, quality = 4 },
	{ id = 8629, kind = "item", name = "Reins of the Striped Nightsaber", speed = 60, quality = 3 },
	{ id = 13325, kind = "item", name = "Fluorescent Green Mechanostrider", speed = 60, quality = 3 },
	{ id = 18788, kind = "item", name = "Swift Blue Raptor", speed = 100, quality = 4 },
	{ id = 18777, kind = "item", name = "Swift Brown Steed", speed = 100, quality = 4 },
	{ id = 5668, kind = "item", name = "Horn of the Brown Wolf", speed = 60, quality = 3 },
	{ id = 8588, kind = "item", name = "Whistle of the Emerald Raptor", speed = 60, quality = 3 },
	{ id = 236665, kind = "item", name = "Reins of Famine", speed = 100, quality = 4 },
	{ id = 216570, kind = "item", name = "Reins of the Golden Sabercat", speed = 60, quality = 3 },
	{ id = 8632, kind = "item", name = "Reins of the Spotted Frostsaber", speed = 60, quality = 3 },
	{ id = 234960, kind = "item", name = "Reins of the Blood-Caked Tiger", speed = 100, quality = 4 },
	{ id = 5665, kind = "item", name = "Horn of the Dire Wolf", speed = 60, quality = 3 },
	{ id = 20221, kind = "item", name = "Fabled Steed", speed = 100, quality = 5 },
	{ id = 8631, kind = "item", name = "Reins of the Striped Frostsaber", speed = 60, quality = 3 },
	{ id = 234961, kind = "item", name = "Whistle of the Blood-Caked Raptor", speed = 100, quality = 4 },
	{ id = 12302, kind = "item", name = "Reins of the Frostsaber", speed = 100, quality = 4 },
	{ id = 5873, kind = "item", name = "White Ram", speed = 60, quality = 3 },
	{ id = 13332, kind = "item", name = "Blue Skeletal Horse", speed = 60, quality = 3 },
	{ id = 239695, kind = "item", name = "Scarlet Steed", speed = 100, quality = 4 },
	{ id = 18768, kind = "item", name = "Reins of the Swift Dawnsaber", speed = 100, quality = 4 },
	{ id = 1132, kind = "item", name = "Horn of the Timber Wolf", speed = 60, quality = 3 },
	{ id = 18789, kind = "item", name = "Swift Olive Raptor", speed = 100, quality = 4 },
	{ id = 18791, kind = "item", name = "Purple Skeletal Warhorse", speed = 100, quality = 4 },
	{ id = 13331, kind = "item", name = "Red Skeletal Horse", speed = 60, quality = 3 },
	{ id = 18241, kind = "item", name = "Black War Steed Bridle", speed = 60, quality = 4 },
	{ id = 12353, kind = "item", name = "White Stallion Bridle", speed = 100, quality = 4 },
	{ id = 236663, kind = "item", name = "Reins of Conquest", speed = 100, quality = 4 },
	{ id = 18246, kind = "item", name = "Whistle of the Black War Raptor", speed = 60, quality = 4 },
	{ id = 21321, kind = "item", name = "Red Qiraji Resonating Crystal", speed = 100, quality = 3 },
	{ id = 233352, kind = "item", name = "Dark Blue Qiraji Resonating Crystal", speed = 100, quality = 4 },
	{ id = 5864, kind = "item", name = "Gray Ram", speed = 60, quality = 3 },
	{ id = 18243, kind = "item", name = "Black Battlestrider", speed = 60, quality = 4 },
	{ id = 5872, kind = "item", name = "Brown Ram", speed = 60, quality = 3 },
	{ id = 18244, kind = "item", name = "Black War Ram", speed = 60, quality = 4 },
	{ id = 18248, kind = "item", name = "Red Skeletal Warhorse", speed = 60, quality = 4 },
	{ id = 18794, kind = "item", name = "Great Brown Kodo", speed = 100, quality = 4 },
	{ id = 8591, kind = "item", name = "Whistle of the Turquoise Raptor", speed = 60, quality = 3 },
	{ id = 8592, kind = "item", name = "Whistle of the Violet Raptor", speed = 60, quality = 3 },
	{ id = 13333, kind = "item", name = "Brown Skeletal Horse", speed = 60, quality = 3 },
	{ id = 18790, kind = "item", name = "Swift Orange Raptor", speed = 100, quality = 4 },
	{ id = 18797, kind = "item", name = "Horn of the Swift Timber Wolf", speed = 100, quality = 4 },
	{ id = 18796, kind = "item", name = "Horn of the Swift Brown Wolf", speed = 100, quality = 4 },
	{ id = 239694, kind = "item", name = "Covenant of Light", speed = 100, quality = 4 },
	{ id = 12326, kind = "item", name = "Reins of the Tawny Sabercat", speed = 60, quality = 3 },
	{ id = 18247, kind = "item", name = "Black War Kodo", speed = 60, quality = 4 },
	{ id = 13334, kind = "item", name = "Green Skeletal Warhorse", speed = 100, quality = 4 },
	{ id = 18785, kind = "item", name = "Swift White Ram", speed = 100, quality = 4 },
	{ id = 18798, kind = "item", name = "Horn of the Swift Gray Wolf", speed = 100, quality = 4 },
	{ id = 234465, kind = "item", name = "Reins of the Swift Spectral Tiger", speed = 100, quality = 4 },
	{ id = 235513, kind = "item", name = "Flawless Blue Qiraji Resonating Crystal", speed = 100, quality = 4 },
	{ id = 15277, kind = "item", name = "Gray Kodo", speed = 60, quality = 3 },
	{ id = 13326, kind = "item", name = "White Mechanostrider Mod A", speed = 100, quality = 4 },
	{ id = 18787, kind = "item", name = "Swift Gray Ram", speed = 100, quality = 4 },
	{ id = 18795, kind = "item", name = "Great Gray Kodo", speed = 100, quality = 4 },
	{ id = 12303, kind = "item", name = "Reins of the Nightsaber", speed = 100, quality = 4 },
	{ id = 13329, kind = "item", name = "Frost Ram", speed = 100, quality = 4 },
	{ id = 18793, kind = "item", name = "Great White Kodo", speed = 100, quality = 4 },
	{ id = 8630, kind = "item", name = "Reins of the Bengal Tiger", speed = 60, quality = 1 },
	{ id = 18245, kind = "item", name = "Horn of the Black War Wolf", speed = 60, quality = 4 },
	{ id = 12354, kind = "item", name = "Palomino Bridle", speed = 100, quality = 4 },
	{ id = 15290, kind = "item", name = "Brown Kodo", speed = 60, quality = 3 },
	{ id = 8595, kind = "item", name = "Blue Mechanostrider", speed = 60, quality = 3 },
	{ id = 216492, kind = "item", name = "Whistle of the Mottled Blood Raptor", speed = 60, quality = 3 },
	{ id = 13317, kind = "item", name = "Whistle of the Ivory Raptor", speed = 100, quality = 4 },
	{ id = 233351, kind = "item", name = "Light Green Qiraji Resonating Crystal", speed = 100, quality = 4 },
	{ id = 235514, kind = "item", name = "Flawless Red Qiraji Resonating Crystal", speed = 100, quality = 4 },
	{ id = 2415, kind = "item", name = "White Stallion", speed = 60, quality = 1 },
	{ id = 12327, kind = "item", name = "Reins of the Golden Sabercat", speed = 60, quality = 3 },
	{ id = 13322, kind = "item", name = "Unpainted Mechanostrider", speed = 60, quality = 3 },
	{ id = 23720, kind = "item", name = "Riding Turtle", speed = 60, quality = 1 },
	{ id = 8589, kind = "item", name = "Old Whistle of the Ivory Raptor", speed = 60, quality = 1 },
	{ id = 18786, kind = "item", name = "Swift Brown Ram", speed = 100, quality = 4 },
	{ id = 228747, kind = "item", name = "Reins of the Golden Sabercat", speed = 100, quality = 4 },
	{ id = 8628, kind = "item", name = "Reins of the Spotted Nightsaber", speed = 60, quality = 1 },
	{ id = 12351, kind = "item", name = "Horn of the Arctic Wolf", speed = 100, quality = 4 },
	{ id = 233353, kind = "item", name = "Light Blue Qiraji Resonating Crystal", speed = 100, quality = 4 },
	{ id = 233357, kind = "item", name = "Twilight Qiraji Resonating Crystal", speed = 100, quality = 4 },
	{ id = 216549, kind = "item", name = "Reins of the Bengal Tiger", speed = 60, quality = 3 },
	{ id = 18772, kind = "item", name = "Swift Green Mechanostrider", speed = 100, quality = 4 },
	{ id = 8563, kind = "item", name = "Red Mechanostrider", speed = 60, quality = 3 },
	{ id = 18774, kind = "item", name = "Swift Yellow Mechanostrider", speed = 100, quality = 4 },
	{ id = 21736, kind = "item", name = "Riding Gryphon Reins", speed = 100, quality = 3 },
	{ id = 18773, kind = "item", name = "Swift White Mechanostrider", speed = 100, quality = 4 },
	{ id = 2413, kind = "item", name = "Palomino", speed = 60, quality = 1 },
	{ id = 8627, kind = "item", name = "Reins of the Night saber", speed = 60, quality = 1 },
	{ id = 13321, kind = "item", name = "Green Mechanostrider", speed = 60, quality = 3 },
	{ id = 12330, kind = "item", name = "Horn of the Red Wolf", speed = 100, quality = 4 },
	{ id = 13328, kind = "item", name = "Black Ram", speed = 100, quality = 4 },
	{ id = 15293, kind = "item", name = "Teal Kodo", speed = 100, quality = 4 },
	{ id = 21323, kind = "item", name = "Green Qiraji Resonating Crystal", speed = 100, quality = 3 },
	{ id = 235511, kind = "item", name = "Flawless Yellow Qiraji Resonating Crystal", speed = 100, quality = 4 },
	{ id = 16343, kind = "item", name = "Blood Guard's Mount", speed = 60, quality = 1 },
	{ id = 15292, kind = "item", name = "Green Kodo", speed = 100, quality = 4 },
	{ id = 14062, kind = "item", name = "Kodo Mount", speed = 60, quality = 1 },
	{ id = 21218, kind = "item", name = "Blue Qiraji Resonating Crystal", speed = 100, quality = 3 },
	{ id = 233356, kind = "item", name = "Orange Qiraji Resonating Crystal", speed = 100, quality = 4 },
	{ id = 8633, kind = "item", name = "Reins of the Leopard", speed = 60, quality = 1 },
	{ id = 12325, kind = "item", name = "Reins of the Primal Leopard", speed = 60, quality = 3 },
	{ id = 21324, kind = "item", name = "Yellow Qiraji Resonating Crystal", speed = 100, quality = 3 },
	{ id = 23193, kind = "item", name = "Skeletal Steed Reins", speed = 100, quality = 4 },
	{ id = 228748, kind = "item", name = "Whistle of the Mottled Blood Raptor", speed = 100, quality = 4 },
	{ id = 235512, kind = "item", name = "Flawless Green Qiraji Resonating Crystal", speed = 100, quality = 4 },
	{ id = 1133, kind = "item", name = "Horn of the Winter Wolf", speed = 60, quality = 1 },
	{ id = 13327, kind = "item", name = "Icy Blue Mechanostrider Mod A", speed = 100, quality = 4 },
	{ id = 228746, kind = "item", name = "Fluorescent Green Mechanostrider", speed = 100, quality = 4 },
	{ id = 211499, kind = "item", name = "Trainee's Outrider Wolf", speed = 60, quality = 3 },
	{ id = 8586, kind = "item", name = "Whistle of the Mottled Red Raptor", speed = 100, quality = 4 },
	{ id = 13323, kind = "item", name = "Purple Mechanostrider", speed = 60, quality = 3 },
	{ id = 211498, kind = "item", name = "Trainee's Sentinel Nightsaber", speed = 60, quality = 3 },
	{ id = 1134, kind = "item", name = "Horn of the Gray Wolf", speed = 60, quality = 1 },
	{ id = 8583, kind = "item", name = "Horn of the Skeletal Mount", speed = 60, quality = 1 },
	{ id = 5875, kind = "item", name = "Harness: Blue Ram", speed = 60, quality = 1 },
	{ id = 13324, kind = "item", name = "Red & Blue Mechanostrider", speed = 60, quality = 3 },
	{ id = 16339, kind = "item", name = "Commander's Steed", speed = 100, quality = 1 },
	{ id = 16344, kind = "item", name = "Lieutenant General's Mount", speed = 100, quality = 1 },
	{ id = 228238, kind = "item", name = "Testament of Divine Steed", speed = 60, quality = 2 },
	{ id = 5663, kind = "item", name = "Horn of the Red Wolf", speed = 60, quality = 1 },
	{ id = 1041, kind = "item", name = "Horn of the Black Wolf", speed = 60, quality = 1 },
	{ id = 5874, kind = "item", name = "Harness: Black Ram", speed = 60, quality = 1 },
	{ id = 8590, kind = "item", name = "Old Whistle of the Obsidian Raptor", speed = 60, quality = 1 },
	{ id = 233358, kind = "item", name = "Tamed Silithid Tank", speed = 100, quality = 3 },
	{ id = 16338, kind = "item", name = "Knight-Lieutenant's Steed", speed = 60, quality = 1 },
	{ id = 191480, kind = "item", name = "Skeletal Steed", speed = 60, quality = 4 },
}

-- id -> entry, for O(1) lookup during bag/spellbook scans.
ns.MountByID = {}
for _, entry in ipairs(ns.MountItems) do
	ns.MountByID[entry.id] = entry
end
for _, entry in ipairs(ns.MountSpells) do
	ns.MountByID[entry.id] = entry
end
