
-- Bars:
-- cat = 7, tree = 8, bear = 9, moon = 10
-- battle = 7, def = 8, berz = 9
-- stealth = 7
-- shadow = 6

local factory = tekPopBar_MakeButton


local _G = _G
local _, class = UnitClass("player")
local usebars = {2,5,6}
local gap = 5


-----------------------------------
--      Create mah buttons!      --
-----------------------------------

local anch1 = ChatFrame1


--~ local possbar = {
--~ 	132,      121,      124, -- nil            attack          action1
--~ 	122, 131, 125, 126, 127, -- follow nil     action2 action3 action4
--~ 	123, 128, 129, 130,      -- stay   aggro   defen   passive
--~ }
local possbar = {
	132,      124,      127,
	125, 126, 121, 122, 123,
	131, 128, 129, 130,
}
for actionID=1,12 do
	local mainbtn = factory("tekPopbar"..actionID, UIParent, "ActionBarButtonTemplate,SecureHandlerEnterLeaveTemplate,SecureHandlerStateTemplate")
	mainbtn:SetPoint("LEFT", anch1, "RIGHT", (actionID == 4 or actionID == 9) and gap * 2.5 or gap, 0)

	RegisterStateDriver(mainbtn, "bonusbar", "[bonusbar:1]1;[bonusbar:2]2;[bonusbar:3]3;[bonusbar:4]4;[bonusbar:5]5;[overridebar]8;[vehicleui]9;0") -- See http://www.wowwiki.com/API_GetBonusBarOffset for details
	mainbtn:SetAttribute('_onstate-bonusbar', [[
		scrolloffset = 0
		baseaction = (not newstate or newstate == 0) and ]].. actionID..[[ or newstate == 5 and ]].. possbar[actionID]..[[ or (]].. actionID..[[ + (newstate+5)*12)
		self:SetAttribute("*action*", baseaction)

		control:ChildUpdate("offset")
		if not self:IsUnderMouse(true) then self:GetFrameRef('popout'):Hide() end
	]])

	mainbtn:Execute([[
		scrolloffset = 0
		baseaction = ]].. actionID)
	mainbtn:SetAttribute("*action*", actionID)
	if GetBonusBarOffset() ~= 0 then mainbtn:SetAttribute("state-bonusbar", GetBonusBarOffset()) end
	mainbtn.action = actionID

	mainbtn:RegisterEvent("UPDATE_BINDINGS")


	local actions = {}
	local anch2 = mainbtn
	local hidebutt
	local butts = {}
	for i,bar in ipairs(usebars) do
		local btnID = actionID - 12 + bar*12
		table.insert(actions, btnID)
		local btn = factory("tekPopbar"..btnID, mainbtn, "ActionBarButtonTemplate,SecureHandlerShowHideTemplate")
		btn:SetAttribute("type", "action")
		btn:SetAttribute("*action*", btnID)
		btn.action = btnID
		btn:SetPoint("BOTTOM", anch2, "TOP", 0, gap)
		anch2 = btn
		table.insert(butts, btn)

		btn:Hide()

		mainbtn:SetAttribute("_adopt", btn)
		btn:SetAttribute("myoffset", i)
		btn:SetFrameRef("mainbtn", mainbtn)
		btn:SetAttribute("_childupdate-offset", [[
			local myoffset = (self:GetAttribute("myoffset") + scrolloffset) % (table.maxn(scrollactions) + 1)
			self:SetAttribute("*action*", myoffset == 0 and baseaction or scrollactions[myoffset])
		]])
	end

	local onshow, onhide = "self:RegisterAutoHide(2) self:AddToAutoHide(self:GetFrameRef('mainbtn'))", ""
	for i=2,#butts do
		butts[1]:SetFrameRef("btn"..i, butts[i])
		onshow = onshow.."\n self:GetFrameRef('btn"..i.."'):Show() \n self:AddToAutoHide(self:GetFrameRef('btn"..i.."'))"
		onhide = onhide.."\n self:GetFrameRef('btn"..i.."'):Hide()"
	end
	butts[1]:SetAttribute("_onshow", onshow)
	butts[1]:SetAttribute("_onhide", onhide)

	mainbtn:SetFrameRef("popout", butts[1])
	mainbtn:SetAttribute('_onenter', [[ self:GetFrameRef('popout'):Show() ]])

	mainbtn:EnableMouseWheel(true)
	mainbtn:Execute([[ scrollactions = newtable( ]].. table.concat(actions, ",").. [[ ) ]])
	mainbtn:WrapScript(mainbtn, "OnMouseWheel", [[
		scrolloffset = scrolloffset - offset
		if scrolloffset < 0 then scrolloffset = table.maxn(scrollactions) end
		if scrolloffset > table.maxn(scrollactions) then scrolloffset = 0 end

		self:SetAttribute("*action*", scrolloffset == 0 and baseaction or scrollactions[scrolloffset])
		control:ChildUpdate("offset")
	]])

	anch1 = mainbtn
end


tekPopbar1:ClearAllPoints()
tekPopbar1:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 10)


MainMenuBar:Hide()
MainMenuBar.Show = MainMenuBar.Hide


----------------------------
--      Vehicle crap      --
----------------------------

VehicleMenuBar:Hide()
VehicleMenuBar.Show = VehicleMenuBar.Hide

local f = CreateFrame("Button", nil, tekPopbar1)
f:SetWidth(48) f:SetHeight(48)
f:SetPoint("BOTTOMLEFT", tekPopbar6, "TOPRIGHT", gap, gap)
f:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
if not CanExitVehicle() then f:Hide() end

f:SetScript("OnClick", VehicleExit)
f:SetScript("OnEvent", function(self, event, unit)
	if unit ~= "player" then return end
	if CanExitVehicle() then self:Show() else self:Hide() end
end)
f:RegisterEvent("UNIT_ENTERED_VEHICLE")
f:RegisterEvent("UNIT_ENTERING_VEHICLE")
f:RegisterEvent("UNIT_EXITED_VEHICLE")


local icon = f:CreateTexture(nil, "BACKGROUND")
icon:SetAllPoints()
icon:SetTexture("Interface\\Icons\\Spell_Shadow_SacrificialShield")


--------------------------------
--      Bonus Action Bar      --
--------------------------------

local f = CreateFrame("Frame", "BonusActionBarParent", UIParent)
f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, -100) f:SetWidth(1) f:SetHeight(1)
BonusActionBarFrame:SetParent(f)


---------------------------
--      Possess Bar      --
---------------------------

PossessBarFrame:SetParent(UIParent)
PossessButton1:SetNormalTexture("")
PossessButton2:SetNormalTexture("")
PossessButton1:ClearAllPoints()
PossessButton1:SetPoint("BOTTOMLEFT", tekPopbar1, "TOPRIGHT", gap, gap)

PossessBackground1:Hide()
PossessBackground2:Hide()
PossessBackground1.Show = PossessBackground1.Hide
PossessBackground2.Show = PossessBackground2.Hide

