--[[
	Core/DemonForm.lua - drop Warlock demon form (Metamorphosis) so a mount
	attempt actually goes through, instead of erroring for being shapeshifted.

	Ported from HoneyLock/DemonForm.lua (see that file for the original
	writeup). Demon form counts as a shapeshift, which blocks mounting. The
	protected CancelShapeshiftForm() API can't be called from addon code, but
	running the unprotected `/cancelform` slash command via ChatEdit_SendText
	works out of combat.

	Two mechanisms:
	- Proactive: EasyMountButton's PreClick (Core/Mount.lua) calls
	  DropDemonFormForMount() right before the secure macrotext1 click
	  resolves, so the mount cast goes through on the same keypress instead
	  of needing a second press.
	- Reactive: a UI_ERROR_MESSAGE safety net, in case some other path (e.g.
	  a manually-clicked bag item) gets refused for being shapeshifted.
]]

local ADDON, ns = ...
local EM = ns.EM

local function runSlash(cmd)
	if InCombatLockdown() then return end
	local eb = DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox
	if eb and ChatEdit_SendText then
		eb:SetText(cmd)
		ChatEdit_SendText(eb, 0)
	end
end

local function cancelForm()
	runSlash("/cancelform")
end

-- Public: called from Core/Mount.lua's PreClick, right before the secure
-- click casts the picked mount.
function EM:DropDemonFormForMount()
	if EM.class ~= "WARLOCK" then return end
	if not EM.db.dropDemonFormToMount then return end
	cancelForm()
end

local function isShapeshiftError(msg)
	return type(msg) == "string" and msg:lower():find("shapeshift", 1, true) ~= nil
end

function EM:UI_ERROR_MESSAGE(_, arg1, arg2)
	if EM.class ~= "WARLOCK" or not EM.db.dropDemonFormToMount then return end
	local msg = (type(arg2) == "string" and arg2) or (type(arg1) == "string" and arg1) or nil
	if isShapeshiftError(msg) then
		cancelForm()
	end
end

function EM:InitDemonForm()
	if EM.class ~= "WARLOCK" then return end
	EM:RegisterEvent("UI_ERROR_MESSAGE")
end
