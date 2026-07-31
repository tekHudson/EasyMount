--[[ EasyMount — bootstrap, shared namespace, utilities, event dispatch.

One keybind that scans your bags/spellbook and summons the fastest mount you
currently have, clamped to your actual Riding skill. Classic Era / Season of
Discovery only. Pure Lua, no XML except Bindings.xml, no Ace3.
]]

local ADDON, ns = ...

-- The public object. Modules hang methods off this; the event frame below
-- dispatches WoW events to same-named methods (e.g. EasyMount:BAG_UPDATE_DELAYED).
local EM = {}
_G.EasyMount = EM
ns.EM = EM
ns.ADDON = ADDON

----------------------------------------------------------------------
-- Environment / constants
----------------------------------------------------------------------
EM.version = C_AddOns.GetAddOnMetadata(ADDON, "Version") or "0.0"
EM.player = nil

----------------------------------------------------------------------
-- Saved variables + defaults merge
----------------------------------------------------------------------
local DEFAULTS = {
	disabled = {},        -- [mountID] = true for mounts the player has turned off
	minimap = { hide = false },
}

local function mergeDefaults(db, defaults)
	for k, v in pairs(defaults) do
		if db[k] == nil then
			db[k] = (type(v) == "table") and {} or v
		end
		if type(v) == "table" then
			mergeDefaults(db[k], v)
		end
	end
	return db
end

----------------------------------------------------------------------
-- Output helper
----------------------------------------------------------------------
local PREFIX = "|cff66bbffEasyMount:|r "
function EM:Print(...)
	print(PREFIX .. strjoin(" ", tostringall(...)))
end

----------------------------------------------------------------------
-- Event dispatch: EM:RegisterEvent("X") -> calls EM:X(event, ...)
----------------------------------------------------------------------
local frame = CreateFrame("Frame", "EasyMountEventFrame")
ns.eventFrame = frame
local registered = {}

function EM:RegisterEvent(event)
	if not registered[event] then
		registered[event] = true
		frame:RegisterEvent(event)
	end
end

function EM:UnregisterEvent(event)
	if registered[event] then
		registered[event] = nil
		frame:UnregisterEvent(event)
	end
end

frame:SetScript("OnEvent", function(_, event, ...)
	local handler = EM[event]
	if handler then
		handler(EM, event, ...)
	end
end)

----------------------------------------------------------------------
-- Bootstrap lifecycle
----------------------------------------------------------------------
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

function EM:ADDON_LOADED(_, name)
	if name ~= ADDON then return end
	EM:UnregisterEvent("ADDON_LOADED")
	EasyMountDB = EasyMountDB or {}
	EM.db = mergeDefaults(EasyMountDB, DEFAULTS)
end

function EM:PLAYER_LOGIN()
	EM.player = (UnitName("player"))
	_, EM.class = UnitClass("player")

	EM:InitScan()   -- Core/Scan.lua: builds EM.activeMounts, wires rescan events
	EM:InitMount()  -- Core/Mount.lua: creates the secure button, configures it
	EM:InitOptions() -- UI/Options.lua: minimap icon + options panel

	EM:RegisterEvent("PLAYER_ENTERING_WORLD")

	EM:SetupSlash()
	EM:Print("v" .. EM.version .. " loaded. /em for options.")
end

----------------------------------------------------------------------
-- Slash commands
----------------------------------------------------------------------
function EM:SetupSlash()
	SLASH_EASYMOUNT1 = "/easymount"
	SLASH_EASYMOUNT2 = "/em"
	_G.SlashCmdList["EASYMOUNT"] = function(msg)
		msg = (msg or ""):lower():trim()
		if msg == "list" then
			EM:PrintActiveMounts()
		else
			EM:OpenOptions()
		end
	end
end
