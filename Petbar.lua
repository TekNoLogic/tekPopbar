
local _, myclass = UnitClass("player")
local gap, lastf = 5
for i=1,10 do
	local f = _G["PetActionButton"..i]
	f:SetParent(UIParent)
	f:ClearAllPoints()
	if lastf then f:SetPoint("LEFT", lastf, "RIGHT", gap, 0) end
	lastf = f
end

PetActionButton1:SetPoint("BOTTOMLEFT", tekPopbar12, "BOTTOMRIGHT", gap*2, 0)
--~ PetActionButton2:SetPoint("LEFT", PetActionButton1, "RIGHT", gap, 0)
--~ PetActionButton3:SetPoint("LEFT", PetActionButton2, "RIGHT", gap, 0)

--~ PetActionButton4:SetPoint("BOTTOM", PetActionButton9, "TOP", 0, gap)
--~ PetActionButton5:SetPoint("LEFT", PetActionButton4, "RIGHT", gap, 0)
--~ PetActionButton6:SetPoint("LEFT", PetActionButton5, "RIGHT", gap, 0)
--~ PetActionButton7:SetPoint("LEFT", PetActionButton6, "RIGHT", gap, 0)

--~ PetActionButton8:SetPoint("BOTTOM", PetActionButton1, "TOP", 0, gap)
--~ PetActionButton9:SetPoint("BOTTOM", PetActionButton2, "TOP", 0, gap)
--~ PetActionButton10:SetPoint("BOTTOM", PetActionButton3, "TOP", 0, gap)

if myclass == "SHAMAN" then
	-- UIPARENT_MANAGED_FRAME_POSITIONS["MultiCastActionBarFrame"] = nil
	MultiCastActionBarFrame:SetParent(tekPopbar12)
	-- MultiCastActionBarFrame.SetParent = MultiCastActionBarFrame.Show
	MultiCastActionBarFrame:ClearAllPoints()
	MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", tekPopbar12, "BOTTOMRIGHT", gap*2, 0)
	MultiCastActionBarFrame.SetPoint = MultiCastActionBarFrame.Show
end

if true then return end

if myclass == "HUNTER" or myclass == "WARLOCK" then
	local base = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate,SecureAnchorEnterTemplate")
	base:SetPoint("BOTTOMLEFT", tekPopbar12, "BOTTOMRIGHT", gap*2, 0)
	base:SetWidth(30)
	base:SetHeight(30)
	base:EnableMouse(true)
	base:RegisterForClicks("anyUp")
	base:SetAttribute("*childraise-OnEnter", true)
	base:SetAttribute("*childstate-OnEnter", "enter")
	base:SetAttribute("*childstate-OnLeave", "leave")
	base:SetAttribute("type", "macro")
	base:SetAttribute("macrotext", "/click FuzzyLogicFrame")
	base:SetNormalTexture("Interface\\Icons\\Spell_Holy_BlessingOfAgility")


	-- State header, god I hate this shit
	-- S0: No hover, no pet
	-- S1: No hover, pet
	-- S2: Hover, no pet
	-- S3: Hover, pet

	local hdr = CreateFrame("Frame", nil, base, "SecureStateHeaderTemplate")
	hdr:SetPoint("CENTER") hdr:SetWidth(2) hdr:SetHeight(2)
	hdr:SetAttribute("unit", "pet")
	hdr:SetAttribute("statemap-unitexists-true", "0:1;2:3")
	hdr:SetAttribute("statemap-unitexists-false", "1:0;3:2")
	RegisterStateDriver(hdr, "unitexists", "[pet] true; false")
	hdr:SetAttribute("statemap-anchor-enter", "0:2;1:3")
	hdr:SetAttribute("statemap-anchor-leave", ";")
	hdr:SetAttribute("delaystatemap-anchor-leave", "2:0;3:1")
	hdr:SetAttribute("delaytimemap-anchor-leave",  "2:1;3:1")
	hdr:SetAttribute("delayhovermap-anchor-leave", "2:true;3:true")
	base:SetAttribute("anchorchild", hdr)

	local parent = CreateFrame("Frame", nil, UIParent)
	parent:SetPoint("CENTER") parent:SetWidth(1) parent:SetHeight(1)
	parent:SetAttribute("showstates", "3")
	hdr:SetAttribute("addchild", parent)
	parent:Hide()

	local function makebutt(states, a1, a2, tex, ...)
		local f = CreateFrame("Button", nil, base, "SecureActionButtonTemplate")
		f:SetPoint(...)
		f:SetWidth(30)
		f:SetHeight(30)
		f:EnableMouse(true)
		f:RegisterForClicks("anyUp")
		f:SetAttribute("type", a1)
		f:SetAttribute(a1, a2)
		f:SetNormalTexture(tex)

		f:SetScript("OnEnter", PetActionButton_OnEnter)
		f:SetScript("OnLeave", PetActionButton_OnLeave)
		f.tooltipName = a2

		f:SetAttribute("showstates", states)
		hdr:SetAttribute("addchild", f)

		return f
	end

	local call = makebutt("2", "spell", "Call Pet", "Interface\\Icons\\Ability_Hunter_BeastCall", "BOTTOM", base, "TOP", 0, gap)
	local rez  = makebutt("2", "spell", "Revive Pet", "Interface\\Icons\\Ability_Hunter_BeastSoothe", "BOTTOM", call, "TOP", 0, gap)
	local tame = makebutt("2", "spell", "Tame Beast", "Interface\\Icons\\Ability_Hunter_BeastTaming", "BOTTOM", rez, "TOP", 0, gap)
	local lore = makebutt("2", "spell", "Beast Lore", "Interface\\Icons\\Ability_Physical_Taunt", "BOTTOM", tame, "TOP", 0, gap)

	local mend = makebutt("3", "spell", "Mend Pet", "Interface\\Icons\\Ability_Hunter_MendPet", "BOTTOM", base, "TOP", 0, gap)
	local kill = makebutt("3", "spell", "Kill Command", "Interface\\Icons\\Ability_Hunter_KillCommand", "BOTTOM", mend, "TOP", 0, gap)
	local eyes = makebutt("3", "spell", "Eyes of the Beast", "Interface\\Icons\\Ability_EyeOfTheOwl", "BOTTOM", kill, "TOP", 0, gap)
	local train = makebutt("3", "spell", "Beast Training", "Interface\\Icons\\Ability_Hunter_BeastCall02", "BOTTOM", PetActionButton8, "TOP", 0, gap)

	-- Spell_Nature_SpiritWolf - Dismiss

	for i=1,10 do
		local f = _G["PetActionButton"..i]
		f:SetParent(parent)
		f:ClearAllPoints()
	end

	PetActionButton1:SetPoint("BOTTOMLEFT", base, "BOTTOMRIGHT", gap, 0)
	PetActionButton2:SetPoint("LEFT", PetActionButton1, "RIGHT", gap, 0)
	PetActionButton3:SetPoint("LEFT", PetActionButton2, "RIGHT", gap, 0)

	PetActionButton4:SetPoint("BOTTOM", PetActionButton9, "TOP", 0, gap)
	PetActionButton5:SetPoint("BOTTOM", PetActionButton4, "TOP", 0, gap)
	PetActionButton6:SetPoint("BOTTOM", PetActionButton10, "TOP", 0, gap)
	PetActionButton7:SetPoint("BOTTOM", PetActionButton6, "TOP", 0, gap)

	PetActionButton8:SetPoint("BOTTOM", PetActionButton1, "TOP", 0, gap)
	PetActionButton9:SetPoint("BOTTOM", PetActionButton2, "TOP", 0, gap)
	PetActionButton10:SetPoint("BOTTOM", PetActionButton3, "TOP", 0, gap)

else
	for i=1,10 do
		local f = _G["PetActionButton"..i]
		f:SetParent(UIParent)
		f:ClearAllPoints()
	end

	PetActionButton1:SetPoint("BOTTOMLEFT", tekPopbar12, "BOTTOMRIGHT", gap*2, 0)
	PetActionButton2:SetPoint("LEFT", PetActionButton1, "RIGHT", gap, 0)
	PetActionButton3:SetPoint("LEFT", PetActionButton2, "RIGHT", gap, 0)

	PetActionButton4:SetPoint("BOTTOM", PetActionButton9, "TOP", 0, gap)
	PetActionButton5:SetPoint("LEFT", PetActionButton4, "RIGHT", gap, 0)
	PetActionButton6:SetPoint("LEFT", PetActionButton5, "RIGHT", gap, 0)
	PetActionButton7:SetPoint("LEFT", PetActionButton6, "RIGHT", gap, 0)

	PetActionButton8:SetPoint("BOTTOM", PetActionButton1, "TOP", 0, gap)
	PetActionButton9:SetPoint("BOTTOM", PetActionButton2, "TOP", 0, gap)
	PetActionButton10:SetPoint("BOTTOM", PetActionButton3, "TOP", 0, gap)
end


