--[[
	Core/Mount.lua - fastest-mount selection + the secure button that actually
	casts it.

	Bindings.xml hooks the keybind to a synthesized click on "EasyMountButton"
	(the "CLICK <name>:LeftButton" convention - see HoneyLock/Buttons.lua for
	prior art in this codebase). The same button doubles as a small draggable
	icon so it's also mouse-clickable, matching this session's choice of
	"minimap icon + options panel" over a fully headless slash-only addon.

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

local function mountIcon(entry)
	if not entry then return "Interface\\Icons\\INV_Misc_QuestionMark" end
	if entry.kind == "item" then
		return (C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(entry.id))
			or GetItemIcon(entry.id)
			or "Interface\\Icons\\INV_Misc_QuestionMark"
	end
	return (select(3, GetSpellInfo(entry.id))) or "Interface\\Icons\\INV_Misc_QuestionMark"
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
	-- Numbered (button1 = LeftButton) attributes only, so RightButton falls
	-- through to PostClick below and opens options instead of also mounting.
	btn:SetAttribute("type1", "macro")
	btn:SetAttribute("macrotext1", buildMacro(best))
	btn.icon:SetTexture(mountIcon(best))
	btn.icon:SetDesaturated(not best)
	btn.icon:SetAlpha(best and 1 or 0.4)
	btn.currentMount = best
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

	local btn = CreateFrame("Button", "EasyMountButton", UIParent, "SecureActionButtonTemplate")
	btn:SetSize(32, 32)
	btn:RegisterForClicks("AnyUp")
	btn:RegisterForDrag("LeftButton")
	-- Since 1.15.9, SecureActionButtonTemplate's OnClick is gated by the
	-- "ActionButtonUseKeyDown" CVar; pin it so the button always fires on
	-- mouse-up regardless (same fix HoneyLock/PallySquire needed).
	btn:SetAttribute("useOnKeyDown", false)
	btn:SetClampedToScreen(true)

	local pos = EM.db.buttonPos or { "CENTER", "UIParent", "CENTER", 0, -200 }
	btn:SetPoint(unpack(pos))

	local icon = btn:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints(btn)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	btn.icon = icon

	btn:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
	btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

	btn:SetScript("OnDragStart", function(self)
		if not InCombatLockdown() then self:StartMoving() end
	end)
	btn:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relPoint, x, y = self:GetPoint()
		EM.db.buttonPos = { point, "UIParent", relPoint, x, y }
	end)
	btn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("EasyMount")
		if self.currentMount then
			GameTooltip:AddLine(self.currentMount.name, 1, 1, 1)
		else
			GameTooltip:AddLine("No usable mount detected", 1, 0.3, 0.3)
		end
		GameTooltip:AddLine("Drag to move  |  Right-click: options", 0.7, 0.7, 0.7)
		GameTooltip:Show()
	end)
	btn:SetScript("OnLeave", GameTooltip_Hide)
	btn:SetScript("PostClick", function(self, button)
		if button == "RightButton" and not InCombatLockdown() then
			EM:OpenOptions()
		end
	end)

	EM.button = btn
	EM:RegisterEvent("PLAYER_REGEN_ENABLED")
	EM:ConfigureMountButton()
end
