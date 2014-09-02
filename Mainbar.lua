
-- Bars:
-- cat = 7, tree = 8, bear = 9, moon = 10
-- battle = 7, def = 8, berz = 9
-- stealth = 7
-- shadow = 6

local myname, ns = ...


local _G = _G
local _, class = UnitClass("player")
local usebars = {2,5,6}
local gap = 5


-----------------------------------
--      Create mah buttons!      --
-----------------------------------

local anch1 = ChatFrame1


local overridebarlayout = {
	12,    4,     7,
	 5, 6, 1,  2, 3,
	11, 8, 9, 10,
}
for actionID=1,12 do
	local mainbtn = ns.factory("tekPopbar"..actionID, UIParent, "ActionBarButtonTemplate,SecureHandlerEnterLeaveTemplate,SecureHandlerStateTemplate")
	mainbtn:SetPoint("LEFT", anch1, "RIGHT", (actionID == 4 or actionID == 9) and gap * 2.5 or gap, 0)

	RegisterStateDriver(mainbtn, "visibility", "[petbattle] hide; show")
	RegisterStateDriver(mainbtn, "bonusbar", "[petbattle]pet;[vehicleui]11;[overridebar]13;[bonusbar:1]6;[bonusbar:2]7;[bonusbar:3]8;[bonusbar:4]9;[bonusbar:5]10;0") -- See http://www.wowwiki.com/API_GetBonusBarOffset for details
	mainbtn:SetAttribute('_onstate-bonusbar', [[
		scrolloffset = 0
		baseaction = ]].. actionID..[[
		newstate = newstate or 0

		if newstate == 'pet' then
			self:SetAttribute("*type*", 'macro')
			if baseaction <= 3 then
				self:SetAttribute("*macrotext*", '/run C_PetBattles.UseAbility('..baseaction..')')
			elseif baseaction == 4 then
				self:SetAttribute("*macrotext*", '/run PetBattleFrame.BottomFrame.SwitchPetButton:Click()')
			elseif baseaction == 5 then
				self:SetAttribute("*macrotext*", '/run PetBattleFrame.BottomFrame.CatchButton:Click()')
			else
				self:SetAttribute("*macrotext*", '')
			end
		else
			if newstate >= 10 then
			  baseaction = ]].. overridebarlayout[actionID]..[[ + newstate*12
			elseif newstate >= 6 then
			  baseaction = ]].. actionID..[[ + newstate*12
			end
			self:SetAttribute("*type*", 'action')
		end

		self:SetAttribute("*action*", baseaction)

		control:ChildUpdate("offset")
		if not self:IsUnderMouse(true) then self:GetFrameRef('popout'):Hide() end
	]])

	mainbtn:Execute([[
		scrolloffset = 0
		baseaction = ]].. actionID)
	mainbtn:SetAttribute("*action*", actionID)
	mainbtn.action = actionID

	mainbtn:RegisterEvent("UPDATE_BINDINGS")


	local actions = {}
	local anch2 = mainbtn
	local hidebutt
	local butts = {}
	for i,bar in ipairs(usebars) do
		local btnID = actionID - 12 + bar*12
		table.insert(actions, btnID)
		local btn = ns.factory("tekPopbar"..btnID, mainbtn, "ActionBarButtonTemplate,SecureHandlerShowHideTemplate")
		btn:SetAttribute("type", "action")
		btn:SetAttribute("*action*", btnID)
		btn:SetAttribute("statehidden", true)
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
		scrolloffset = scrolloffset + offset
		if scrolloffset < 0 then scrolloffset = table.maxn(scrollactions) end
		if scrolloffset > table.maxn(scrollactions) then scrolloffset = 0 end

		self:SetAttribute("*action*", scrolloffset == 0 and baseaction or scrollactions[scrolloffset])
		control:ChildUpdate("offset")
	]])

	if GetBonusBarOffset() ~= 0 then mainbtn:SetAttribute("state-bonusbar", (5 + GetBonusBarOffset())) end

	anch1 = mainbtn
end


tekPopbar1:ClearAllPoints()
tekPopbar1:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 10)


MainMenuBar:Hide()
MainMenuBar.Show = MainMenuBar.Hide


-----------------------
--      Pet bar      --
-----------------------

-- PetActionBarFrame:SetParent(UIParent)
-- PetActionBarFrame:ClearAllPoints()
-- PetActionBarFrame:SetPoint("BOTTOMLEFT", tekPopbar12, "BOTTOMRIGHT")
-- SlidingActionBarTexture0:Hide()
-- SlidingActionBarTexture1:Hide()


local lastf
for i=1,10 do
	local f = _G["PetActionButton"..i]
	f:SetParent(UIParent)
-- 	f:ClearAllPoints()
-- 	if lastf then f:SetPoint("LEFT", lastf, "RIGHT", 5, 0) end
	lastf = f
end

PetActionButton1:SetPoint("BOTTOMLEFT", tekPopbar12, "BOTTOMRIGHT", 20, 0)


----------------------------
--      Vehicle crap      --
----------------------------

-- VehicleMenuBar:Hide()
-- VehicleMenuBar.Show = VehicleMenuBar.Hide

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


--------------------------------
--      Extra Action Bar      --
--------------------------------

ExtraActionBarFrame:SetParent(UIParent)
ExtraActionBarFrame:ClearAllPoints()
ExtraActionBarFrame:SetPoint("BOTTOM", 0, 160)
ExtraActionBarFrame:SetAlpha(1)
