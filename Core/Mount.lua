--[[
	Core/Mount.lua - fastest-mount selection + the secure button that actually
	casts it.

	Bindings.xml hooks the keybind to a synthesized click on "EasyMountButton"
	(the "CLICK <name>:LeftButton" convention - see HoneyLock/Buttons.lua for
	prior art in this codebase). This button is deliberately invisible: it has
	no textures, so there's nothing to render, and a CLICK-type keybinding
	targets the named frame directly rather than hit-testing the screen, so
	visibility has no bearing on whether the keybind works. Right-click/mouse
	interaction isn't needed - the minimap icon (UI/Options.lua) already opens
	options.

	Secure attributes can only be changed out of combat lockdown, so every
	reconfigure checks InCombatLockdown() and defers to PLAYER_REGEN_ENABLED
	if needed - same pattern PallySquire and HoneyLock already use.
]]

local ADDON, ns = ...
local EM = ns.EM

-- Label for Bindings.xml (auto-loaded by the client after all .toc-listed
-- files, so setting this here - in a toc-listed file - is early enough).
-- Spaces/colons aren't valid in a bare Lua identifier, so this must be set
-- via _G[...] indexing rather than a plain assignment.
_G["BINDING_NAME_CLICK EasyMountButton:LeftButton"] = "Summon fastest mount"

------------------------------------------------------------------------
-- Selection
------------------------------------------------------------------------

-- Best mount currently available: highest *effective* speed (nominal speed
-- clamped by actual Riding skill), skipping anything disabled in options.
-- Ties prefer the higher nominal speed, then the first one found.
function EM:PickFastestMount()
	if not EM.activeMounts then return nil end
	local cap = EM:GetRidingSpeedCap()
	local best, bestEffective, bestNominal
	for _, entry in ipairs(EM.activeMounts) do
		if not EM.db.disabled[entry.id] then
			local effective = math.min(entry.speed, math.max(cap, 0))
			if not best or effective > bestEffective
				or (effective == bestEffective and entry.speed > bestNominal) then
				best, bestEffective, bestNominal = entry, effective, entry.speed
			end
		end
	end
	return best
end

------------------------------------------------------------------------
-- Secure button
------------------------------------------------------------------------

local pendingRefresh = false

local function buildMacro(entry)
	local lines = { "/dismount [mounted]" }
	if entry then
		if entry.kind == "item" then
			lines[#lines + 1] = "/use item:" .. entry.id
		else
			local name = GetSpellInfo(entry.id)
			if name then lines[#lines + 1] = "/cast " .. name end
		end
	end
	return table.concat(lines, "\n")
end

function EM:ConfigureMountButton()
	if InCombatLockdown() then
		pendingRefresh = true
		return
	end
	pendingRefresh = false
	local btn = EM.button
	if not btn then return end

	local best = EM:PickFastestMount()
	-- Numbered (button1 = LeftButton) attribute, matching the LeftButton
	-- click the keybind synthesizes.
	btn:SetAttribute("type1", "macro")
	btn:SetAttribute("macrotext1", buildMacro(best))
end

-- Called by Scan.lua after every rescan.
function EM:RefreshMount()
	EM:ConfigureMountButton()
end

function EM:PLAYER_REGEN_ENABLED()
	if pendingRefresh then EM:ConfigureMountButton() end
end

------------------------------------------------------------------------
-- Frame creation
------------------------------------------------------------------------

function EM:InitMount()
	if EM.button then return end

	-- No textures added, so there's nothing for this frame to render -
	-- it exists purely as a keybind target.
	local btn = CreateFrame("Button", "EasyMountButton", UIParent, "SecureActionButtonTemplate")
	btn:RegisterForClicks("AnyUp")
	-- Since 1.15.9, SecureActionButtonTemplate's OnClick is gated by the
	-- "ActionButtonUseKeyDown" CVar; pin it so the button always fires on
	-- mouse-up regardless (same fix HoneyLock/PallySquire needed).
	btn:SetAttribute("useOnKeyDown", false)

	EM.button = btn
	EM:RegisterEvent("PLAYER_REGEN_ENABLED")
	EM:ConfigureMountButton()
end
