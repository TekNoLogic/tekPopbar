
local myname, ns = ...


-- Druid shapeshifts use bars 7-10
-- Monk stances use bars 7-9
local _, class = UnitClass("player")
local usebars
if class == "DRUID" then
	usebars = {4}
elseif class == "MONK" then
	usebars = {4, 10}
else
	usebars = {4, 7, 8, 9, 10}
end


local gap = -6


local anch1 = MultiBarRightButton1
for actionID=36,25,-1 do
	local mainbtn = ns.factory("tekPopbar"..actionID, UIParent, "ActionBarButtonTemplate,SecureHandlerEnterLeaveTemplate,SecureHandlerStateTemplate")
	mainbtn:SetPoint("BOTTOM", anch1, "TOP", 0, -gap)
	mainbtn:SetAttribute("*type*", "action")
	mainbtn:SetAttribute("*action*", actionID)

	RegisterStateDriver(mainbtn, "visibility", "[petbattle] hide; show")

	local anch2 = mainbtn
	local butts = {}
	for _,bar in ipairs(usebars) do
		local btnID = actionID - 36 + bar*12
		local btn = ns.factory("tekPopbar"..btnID, mainbtn, "ActionBarButtonTemplate,SecureHandlerShowHideTemplate")
		btn:SetAttribute("*type*", "action")
		btn:SetAttribute("*action*", btnID)
		btn:SetAttribute("statehidden", true)
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


local f = WatchFrame or ObjectiveTrackerFrame
local o = f.SetPoint
function f:SetPoint(a1, frame, a2, x, y)
	if frame == "MinimapCluster" then o(self, a1, frame, a2, x-36, y)
	elseif frame == "UIParent" then o(self, "BOTTOM", frame, "BOTTOM", 0, y) end
end
