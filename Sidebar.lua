
local _, _, _, enabled = GetAddOnInfo("tekPopBar")
if not enabled then return end

local factory = tekPopBar_MakeButton
tekPopBar_MakeButton = nil


local _, class = UnitClass("player")

local usebars = {4, 10}
if class ~= "DRUID" and class ~= "PRIEST" then table.insert(usebars, 7) end
if class ~= "DRUID" then table.insert(usebars, 8) end
if class ~= "DRUID" then table.insert(usebars, 9) end


local colors = {
	none = {1.0, 1.0, 1.0},
	grey = {0.4, 0.4, 0.4},
	blue = {0.1, 0.3, 1.0},
	red  = {0.8, 0.1, 0.1},
}


local gap = -6


local icons, ids, onupdates = {}, {}, {}
local function OnUpdate(self, elapsed, ...)
	ActionButton_UpdateAction()
	local id = ids[self]
	local oor, isUsable, notEnoughMana = IsActionInRange(id), IsUsableAction(id)
	local c = notEnoughMana and "blue" or oor == 0 and "red" or isUsable and "none" or "grey"
	icons[self]:SetVertexColor(unpack(colors[c]))
	if onupdates[self] then return onupdates[self](self, elapsed, ...) end
end


local function HideTooltip(frame)
	GameTooltip:Hide()
end


local anch1 = MultiBarRightButton1
for actionID=36,25,-1 do
	local mainbtn = factory("tekPopbar"..actionID, UIParent, "ActionBarButtonTemplate,SecureHandlerEnterLeaveTemplate")
--~ 	local mainbtn = CreateFrame("CheckButton", "tekPopbar"..actionID, UIParent, "ActionBarButtonTemplate,SecureAnchorEnterTemplate")
--~ 	_G["tekPopbar"..actionID.."Name"]:Hide()
--~ 	_G["tekPopbar"..actionID.."Name"].Show = _G["tekPopbar"..actionID.."Name"].Hide
	mainbtn:SetPoint("BOTTOM", anch1, "TOP", 0, -gap)
--~ 	ids[mainbtn] = actionID
--~ 	icons[mainbtn] = _G["tekPopbar"..actionID.."Icon"]
--~ 	onupdates[mainbtn] = mainbtn:GetScript("OnUpdate")
--~ 	mainbtn:SetScript("OnUpdate", OnUpdate)
--~ 	mainbtn:SetScript("OnAttributeChanged", ActionButton_Update)
--~ 	mainbtn:HookScript("OnEnter", ActionButton_SetTooltip)
--~ 	mainbtn:HookScript("OnLeave", HideTooltip)
	mainbtn:SetAttribute("*type*", "action")
	mainbtn:SetAttribute("*action*", actionID)
--~ 	mainbtn:SetAttribute("*childraise-OnEnter", true)
--~ 	mainbtn:SetAttribute("*childstate-OnEnter", "enter")
--~ 	mainbtn:SetAttribute("*childstate-OnLeave", "leave")

--~ 	local hdr = CreateFrame("Frame", "tekPopbarHdr"..actionID, mainbtn, "SecureStateHeaderTemplate")
--~ 	hdr:SetPoint("CENTER") hdr:SetWidth(2) hdr:SetHeight(2)
--~ 	hdr:SetAttribute("statemap-anchor-enter", "1")
--~ 	hdr:SetAttribute("statemap-anchor-leave", ";")
--~ 	hdr:SetAttribute("delaystatemap-anchor-leave", "1:0")
--~ 	hdr:SetAttribute("delaytimemap-anchor-leave",  "1:1")
--~ 	hdr:SetAttribute("delayhovermap-anchor-leave", "1:true")
--~ 	mainbtn:SetAttribute("anchorchild", hdr)

	mainbtn:SetAttribute("_execute", [[buttons = newtable()]])
	mainbtn:SetAttribute("_onenter", [[for _,button in pairs(buttons) do button:Show() end]])
	mainbtn:SetAttribute("_onleave", [[
		elap = 0
		return nil, nil, true
	]])
	mainbtn:SetAttribute("_onupdate", [[
		if self:IsUnderMouse(true) then return nil, nil, true end

		elap = elap + elapsed
		if elap >= 2 then
			for _,button in pairs(buttons) do button:Hide() end
			return
		end
		return nil, nil, true
	]])

	local anch2 = mainbtn
	for _,bar in ipairs(usebars) do
		local btnID = actionID - 36 + bar*12
		local btn = factory("tekPopbar"..btnID, mainbtn, "ActionBarButtonTemplate")
--~ 		_G["tekPopbar"..btnID.."Name"]:Hide()
--~ 		_G["tekPopbar"..btnID.."Name"].Show = _G["tekPopbar"..btnID.."Name"].Hide
--~ 		ids[btn] = btnID
--~ 		icons[btn] = _G["tekPopbar"..btnID.."Icon"]
--~ 		onupdates[btn] = btn:GetScript("OnUpdate")
--~ 		btn:SetScript("OnUpdate", OnUpdate)
--~ 		btn:SetScript("OnAttributeChanged", ActionButton_Update)
--~ 		btn:SetAttribute("hidestates", 0)
		btn:SetAttribute("*type*", "action")
		btn:SetAttribute("*action*", btnID)
--~ 		hdr:SetAttribute("addchild", btn)
		btn:SetPoint("RIGHT", anch2, "LEFT", gap, 0)

		btn:Hide()

		mainbtn:SetAttribute("_adopt", btn)
		mainbtn:SetAttribute("_frame-kid", btn)
		mainbtn:SetAttribute("_execute", "buttons["..bar.."] = self:GetAttribute('frameref-kid')")

		anch2 = btn
	end

	anch1 = mainbtn
end


tekPopbar36:ClearAllPoints()
tekPopbar36:SetPoint("BOTTOMRIGHT", WorldFrame, "BOTTOMRIGHT", 0, -gap)

local function movetracker()
	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetPoint("TOP", MinimapCluster, "BOTTOM", 0, 0)
	QuestWatchFrame:SetPoint("RIGHT", tekPopbar25, "LEFT", -6, 0)
end

hooksecurefunc("UIParent_ManageFramePositions", movetracker)
movetracker()
