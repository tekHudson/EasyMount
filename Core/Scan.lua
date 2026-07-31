--[[
	Core/Scan.lua - bag + spellbook scan, keeps EM.activeMounts up to date.

	Most players only ever carry one mount item at a time, so re-scanning is
	cheap and only needs to happen when something could have changed: bags
	(BAG_UPDATE_DELAYED, which Blizzard already coalesces into one fire per
	batch of changes), learning a class mount spell (SPELLS_CHANGED), or
	Riding skill rank changing (SKILL_LINES_CHANGED). Between those events the
	active-mount list is just read from memory - the keybind press itself
	never scans anything.
]]

local ADDON, ns = ...
local EM = ns.EM

-- C_Container compatibility (present on Era 1.15.9, but be safe) - same
-- pattern as HoneyLock's Shards.lua, already verified working on this client.
local Container = C_Container or {}
local GetNumSlots = Container.GetContainerNumSlots or _G.GetContainerNumSlots
local GetItemInfo = Container.GetContainerItemInfo or _G.GetContainerItemInfo

local function slotItemID(bag, slot)
	local info = GetItemInfo(bag, slot)
	if type(info) == "table" then return info.itemID end
	local link = (Container.GetContainerItemLink or _G.GetContainerItemLink)(bag, slot)
	if link then return tonumber(link:match("item:(%d+)")) end
	return nil
end

local function isSpellKnown(spellID)
	if IsPlayerSpell and IsPlayerSpell(spellID) then return true end
	if IsSpellKnown and IsSpellKnown(spellID) then return true end
	return false
end

-- Riding skill rank (0/75/150 in Classic) -> effective speed cap.
-- Journeyman Riding (75) = 60%, Expert Riding (150) = 100%. This client only
-- ships an enUS locale (matching the rest of Tek's addons), so the skill
-- line name is compared against the literal string rather than resolved
-- from a spell/locale table.
local RIDING_SKILL_NAME = "Riding"

function EM:GetRidingSpeedCap()
	for i = 1, GetNumSkillLines() do
		local name, isHeader, _, rank = GetSkillLineInfo(i)
		if not isHeader and name == RIDING_SKILL_NAME then
			if rank >= 150 then return 100 end
			if rank >= 75 then return 60 end
			return 0
		end
	end
	return 0
end

------------------------------------------------------------------------
-- Scan
------------------------------------------------------------------------

-- Rebuilds EM.activeMounts: every mount entry the player currently has
-- (bag item in hand, or class mount spell known), regardless of the
-- disabled-in-options list - Mount.lua filters that out at selection time.
function EM:ScanMounts()
	local found = {}
	local seen = {}

	for bag = 0, 4 do
		local slots = GetNumSlots and GetNumSlots(bag) or 0
		for slot = 1, slots do
			local id = slotItemID(bag, slot)
			local entry = id and ns.MountByID[id]
			if entry and entry.kind == "item" and not seen[id] then
				seen[id] = true
				found[#found + 1] = entry
			end
		end
	end

	for _, entry in ipairs(ns.MountSpells) do
		if entry.class == EM.class and not seen[entry.id] and isSpellKnown(entry.id) then
			seen[entry.id] = true
			found[#found + 1] = entry
		end
	end

	EM.activeMounts = found
	if EM.RefreshMount then EM:RefreshMount() end
	return found
end

function EM:PrintActiveMounts()
	local cap = EM:GetRidingSpeedCap()
	EM:Print(("Riding speed cap: %d%%"):format(cap))
	if not EM.activeMounts or #EM.activeMounts == 0 then
		EM:Print("No known mounts detected in bags/spellbook.")
		return
	end
	for _, entry in ipairs(EM.activeMounts) do
		local effective = math.min(entry.speed, math.max(cap, 0))
		local disabled = EM.db.disabled[entry.id] and " |cffff5555(disabled)|r" or ""
		EM:Print(("  %s - %d%% listed, %d%% effective (%s)%s"):format(
			entry.name, entry.speed, effective, entry.kind, disabled))
	end
	local best = EM:PickFastestMount()
	if best then
		EM:Print("Would summon: " .. best.name)
	else
		EM:Print("No usable mount to summon (all disabled, or none owned).")
	end
end

------------------------------------------------------------------------
-- Wiring: rescan on the events that can actually change the answer
------------------------------------------------------------------------

function EM:InitScan()
	EM:RegisterEvent("BAG_UPDATE_DELAYED")
	EM:RegisterEvent("SPELLS_CHANGED")
	EM:RegisterEvent("SKILL_LINES_CHANGED")
	EM:ScanMounts()
end

function EM:BAG_UPDATE_DELAYED()
	EM:ScanMounts()
end

function EM:SPELLS_CHANGED()
	EM:ScanMounts()
end

function EM:SKILL_LINES_CHANGED()
	EM:ScanMounts()
end
