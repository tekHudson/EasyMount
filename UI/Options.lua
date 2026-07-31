--[[
	UI/Options.lua - minimap icon + options panel via the modern Settings API.

	The enable/disable list only ever shows mounts EM.activeMounts currently
	contains (i.e. mounts the player actually has), not the full ~144-entry
	database - nobody needs to toggle mounts they don't own, and it keeps this
	a plain static-height panel instead of a scroll frame.
]]

local ADDON, ns = ...
local EM = ns.EM

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

local QUALITY_COLOR = {
	[1] = { 1, 1, 1 },       -- common
	[2] = { 0.12, 1, 0 },    -- uncommon
	[3] = { 0, 0.44, 0.87 }, -- rare
	[4] = { 0.64, 0.21, 0.93 }, -- epic
	[5] = { 1, 0.5, 0 },     -- legendary
}

local checkRows = {}

local function makeCheck(parent, label, r, g, b, get, set, y)
	local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	cb:SetPoint("TOPLEFT", 24, y)
	cb.Text:SetText(label)
	cb.Text:SetTextColor(r, g, b)
	cb:SetChecked(get())
	cb:SetScript("OnClick", function(self) set(self:GetChecked()) end)
	return cb
end

-- Rebuild the "detected mounts" checkbox list against the current
-- EM.activeMounts snapshot. Called on panel show, since bags can change
-- between one open and the next.
local function refreshMountList(panel)
	for _, row in ipairs(checkRows) do row:Hide(); row:SetParent(nil) end
	wipe(checkRows)

	local y = panel.mountListTop
	if not EM.activeMounts or #EM.activeMounts == 0 then
		if not panel.emptyText then
			panel.emptyText = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
			panel.emptyText:SetPoint("TOPLEFT", 26, y)
		end
		panel.emptyText:SetText("No mounts detected in bags/spellbook yet.")
		panel.emptyText:Show()
		return
	end
	if panel.emptyText then panel.emptyText:Hide() end

	local cap = EM:GetRidingSpeedCap()
	local sorted = {}
	for _, entry in ipairs(EM.activeMounts) do sorted[#sorted + 1] = entry end
	table.sort(sorted, function(a, b) return a.speed > b.speed end)

	for _, entry in ipairs(sorted) do
		local color = QUALITY_COLOR[entry.quality] or QUALITY_COLOR[1]
		local effective = math.min(entry.speed, math.max(cap, 0))
		local label = ("%s (%d%%, %d%% effective)"):format(entry.name, entry.speed, effective)
		local cb = makeCheck(panel, label, color[1], color[2], color[3],
			function() return not EM.db.disabled[entry.id] end,
			function(checked)
				EM.db.disabled[entry.id] = (not checked) or nil
				EM:RefreshMount()
			end, y)
		checkRows[#checkRows + 1] = cb
		y = y - 24
	end
end

function EM:CreateOptions()
	local panel = CreateFrame("Frame", "EasyMountOptionsPanel", UIParent)
	panel.name = "EasyMount"

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("EasyMount")

	local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	sub:SetText("Bind a key to \"EasyMount: Summon fastest mount\" in Key Bindings. /em list for a debug dump.")

	local y = -58
	local minimapCheck = makeCheck(panel, "Show minimap icon", 1, 1, 1,
		function() return not EM.db.minimap.hide end,
		function(checked)
			EM.db.minimap.hide = not checked
			if checked then LDBIcon:Show(ADDON) else LDBIcon:Hide(ADDON) end
		end, y)
	y = y - 34

	local header = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	header:SetPoint("TOPLEFT", 16, y)
	header:SetText("Detected mounts (uncheck to exclude from selection)")
	header:SetTextColor(1, 0.82, 0)
	y = y - 24

	panel.mountListTop = y

	panel:SetScript("OnShow", function(self) refreshMountList(self) end)

	if Settings and Settings.RegisterCanvasLayoutCategory then
		local category = Settings.RegisterCanvasLayoutCategory(panel, "EasyMount")
		Settings.RegisterAddOnCategory(category)
		EM.optionsCategory = category
	elseif InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(panel)
	end
	EM.optionsPanel = panel
end

function EM:OpenOptions()
	if Settings and Settings.OpenToCategory and EM.optionsCategory then
		Settings.OpenToCategory(EM.optionsCategory:GetID())
	elseif InterfaceOptionsFrame_OpenToCategory then
		InterfaceOptionsFrame_OpenToCategory(EM.optionsPanel)
		InterfaceOptionsFrame_OpenToCategory(EM.optionsPanel)
	end
end

------------------------------------------------------------------------
-- Minimap icon
------------------------------------------------------------------------

local function setupMinimap()
	if not LDB or not LDBIcon then return end
	local ldbObject = LDB:NewDataObject(ADDON, {
		type = "data source",
		text = "EasyMount",
		icon = "Interface\\Icons\\Ability_Mount_JungleTiger",
		OnClick = function() EM:OpenOptions() end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine("EasyMount")
			tooltip:AddLine("Click for options", 1, 1, 1)
		end,
	})
	LDBIcon:Register(ADDON, ldbObject, EM.db.minimap)
end

function EM:InitOptions()
	EM:CreateOptions()
	setupMinimap()
end
