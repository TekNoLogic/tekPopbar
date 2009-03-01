
local _, _, _, enabled = GetAddOnInfo("tekPopBar")
if not enabled then return end

local factory = tekPopBar_MakeButton
tekPopBar_MakeButton = nil


local _, class = UnitClass("player")

local usebars = {4, 10}
if class ~= "DRUID" and class ~= "PRIEST" then table.insert(usebars, 7) end
if class ~= "DRUID" then table.insert(usebars, 8) end
if class ~= "DRUID" then table.insert(usebars, 9) end


local gap = -6


local anch1 = MultiBarRightButton1
for actionID=36,25,-1 do
	local mainbtn = factory("tekPopbar"..actionID, UIParent, "ActionBarButtonTemplate,SecureHandlerEnterLeaveTemplate,SecureHandlerStateTemplate")
	mainbtn:SetPoint("BOTTOM", anch1, "TOP", 0, -gap)
	mainbtn:SetAttribute("*type*", "action")
	mainbtn:SetAttribute("*action*", actionID)

	mainbtn:SetAttribute('_onstate-popped', [[ control:ChildUpdate(self:IsUnderMouse(true) and "doshow" or "dohide") ]])
	mainbtn:SetAttribute("_onenter", [[ self:SetAttribute("state-popped", "inself") ]])
	mainbtn:SetAttribute("_onleave", [[ self:SetAttribute("state-popped", "self") ]])

	local anch2 = mainbtn
	for _,bar in ipairs(usebars) do
		local btnID = actionID - 36 + bar*12
		local btn = factory("tekPopbar"..btnID, mainbtn, "ActionBarButtonTemplate,SecureHandlerEnterLeaveTemplate")
		btn:SetAttribute("*type*", "action")
		btn:SetAttribute("*action*", btnID)
		btn:SetPoint("RIGHT", anch2, "LEFT", gap, 0)

		btn:Hide()

		mainbtn:SetAttribute("_adopt", btn)
		btn:SetFrameRef("mainbtn", mainbtn)
		btn:SetAttribute("_childupdate-doshow", [[ self:Show() ]])
		btn:SetAttribute("_childupdate-dohide", [[ self:Hide() ]])
		btn:SetAttribute("_onleave", [[ self:GetFrameRef("mainbtn"):SetAttribute("state-popped", ]]..bar..[[) ]])

		anch2 = btn
	end

	local back = CreateFrame("Button", nil, mainbtn, "SecureHandlerEnterLeaveTemplate")
	back:SetPoint("TOPLEFT", anch2, "TOPRIGHT")
	back:SetPoint("BOTTOMRIGHT", mainbtn, "BOTTOMLEFT")
	back:Hide()

	mainbtn:SetAttribute("_adopt", back)
	back:SetFrameRef("mainbtn", mainbtn)
	back:SetAttribute("_childupdate-doshow", [[ self:Show() ]])
	back:SetAttribute("_childupdate-dohide", [[ self:Hide() ]])
	back:SetAttribute("_onleave", [[ self:GetFrameRef("mainbtn"):SetAttribute("state-popped", "back") ]])

	anch1 = mainbtn
end


tekPopbar36:ClearAllPoints()
tekPopbar36:SetPoint("BOTTOMRIGHT", WorldFrame, "BOTTOMRIGHT", 0, -gap)

if select(4, GetBuildInfo()) ~= 30100 then
	local function movetracker()
		QuestWatchFrame:ClearAllPoints()
		QuestWatchFrame:SetPoint("TOP", MinimapCluster, "BOTTOM", 0, 0)
		QuestWatchFrame:SetPoint("RIGHT", tekPopbar25, "LEFT", -6, 0)

		AchievementWatchFrame:ClearAllPoints()
		AchievementWatchFrame:SetPoint("TOPRIGHT", tekPopbar30, "TOPLEFT", -6, 0)
	end

	hooksecurefunc("UIParent_ManageFramePositions", movetracker)
	movetracker()
end
