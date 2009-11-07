
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

	local anch2 = mainbtn
	local butts = {}
	for _,bar in ipairs(usebars) do
		local btnID = actionID - 36 + bar*12
		local btn = factory("tekPopbar"..btnID, mainbtn, "ActionBarButtonTemplate,SecureHandlerShowHideTemplate")
		btn:SetAttribute("*type*", "action")
		btn:SetAttribute("*action*", btnID)
		btn:SetPoint("RIGHT", anch2, "LEFT", gap, 0)

		btn:Hide()

		mainbtn:SetAttribute("_adopt", btn)
		btn:SetFrameRef("mainbtn", mainbtn)

		table.insert(butts, btn)
		anch2 = btn
	end

	local onshow, onhide = "self:RegisterAutoHide(1) self:AddToAutoHide(self:GetFrameRef('mainbtn'))", ""
	for i=2,#butts do
		butts[1]:SetFrameRef("btn"..i, butts[i])
		onshow = onshow.."\n self:GetFrameRef('btn"..i.."'):Show() \n self:AddToAutoHide(self:GetFrameRef('btn"..i.."'))"
		onhide = onhide.."\n self:GetFrameRef('btn"..i.."'):Hide()"
	end
	butts[1]:SetAttribute("_onshow", onshow)
	butts[1]:SetAttribute("_onhide", onhide)

	mainbtn:SetFrameRef("popout", butts[1])
	mainbtn:SetAttribute('_onenter', [[ self:GetFrameRef('popout'):Show() ]])

	anch1 = mainbtn
end


tekPopbar36:ClearAllPoints()
tekPopbar36:SetPoint("BOTTOMRIGHT", WorldFrame, "BOTTOMRIGHT", 0, -gap)


WatchFrame:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -36, 20)
function WatchFrame.SetPoint() end
