
-- Bars:
-- cat = 7, moon/tree = 8, bear = 9
-- battle = 7, def = 8, berz = 9
-- stealth = 7
-- shadow = 6

local factory = tekPopBar_MakeButton


local _G = _G
local _, class = UnitClass("player")
local usebars = {2,5,6}
local gap = 5


local function PermaHide(frame)
	frame:Hide()
	frame.Show = frame.Hide
end


-----------------------------------
--      Create mah buttons!      --
-----------------------------------

local anch1 = ChatFrame1

local driver = CreateFrame("Frame", nil, UIParent, "SecureStateDriverTemplate")
if class == "DRUID" then
	driver:SetAttribute("statemap-stance", "$input")
	driver:SetAttribute("statebutton", "1:bear;2:cat;5:moon")
elseif class == "PRIEST" then
	driver:SetAttribute("statemap-stance", "$input")
	driver:SetAttribute("statebutton", "1:shadowform")
end

for actionID=1,12 do
	local mainbtn = factory("tekPopbar"..actionID, driver, "ActionBarButtonTemplate,SecureAnchorEnterTemplate")
	mainbtn:SetPoint("LEFT", anch1, "RIGHT", (actionID == 4 or actionID == 9) and gap * 2.5 or gap, 0)
	if class == "DRUID" or class == "PRIEST" then
		driver:SetAttribute('addchild', mainbtn)
		mainbtn:SetAttribute('useparent-statebutton', 'true')
	end
	mainbtn:SetAttribute("*childraise-OnEnter", true)
	mainbtn:SetAttribute("*childstate-OnEnter", "enter")
	mainbtn:SetAttribute("*childstate-OnLeave", "leave")
	if class == "DRUID" then
		mainbtn:SetAttribute("*action-cat", 6*12 + actionID) -- cat
		mainbtn:SetAttribute("*action-moon", 7*12 + actionID) -- moonkin/tree
		mainbtn:SetAttribute("*action-bear", 8*12 + actionID) -- bear
	end
	if class == "PRIEST" then
		mainbtn:SetAttribute("*action-shadowform", 6*12 + actionID)
	end
	mainbtn:SetAttribute("*action*", actionID)


	local hdr = CreateFrame("Frame", "tekPopbarHdr"..actionID, mainbtn, "SecureStateHeaderTemplate")
	hdr:SetPoint("CENTER") hdr:SetWidth(2) hdr:SetHeight(2)
	hdr:SetAttribute("statemap-anchor-enter", "1")
	hdr:SetAttribute("statemap-anchor-leave", ";")
	hdr:SetAttribute("delaystatemap-anchor-leave", "1:0")
	hdr:SetAttribute("delaytimemap-anchor-leave",  "1:1")
	hdr:SetAttribute("delayhovermap-anchor-leave", "1:true")
	mainbtn:SetAttribute("anchorchild", hdr)

	local anch2 = mainbtn
	for _,bar in ipairs(usebars) do
		local btnID = actionID - 12 + bar*12
		local btn = factory("tekPopbar"..btnID, hdr, "ActionBarButtonTemplate")
		btn:SetAttribute("hidestates", 0)
		btn:SetAttribute("type", "action")
		btn:SetAttribute("*action*", btnID)
		hdr:SetAttribute("addchild", btn)
		btn:SetPoint("BOTTOM", anch2, "TOP", 0, gap)
		anch2 = btn
	end

	anch1 = mainbtn
end


tekPopbar1:ClearAllPoints()
tekPopbar1:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 10)


MainMenuBar:Hide()


--------------------------------
--      Bonus Action Bar      --
--------------------------------

local f = CreateFrame("Frame", "BonusActionBarParent", UIParent)
BonusActionBarFrame:SetParent(f)

if class == "DRUID" or class == "PRIEST" or class == "WARRIOR" then
	f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, -100) f:SetWidth(1) f:SetHeight(1)
	return
else
	f:SetPoint("BOTTOMLEFT", tekPopbar1, "BOTTOMLEFT", -8, -4) f:SetWidth(1) f:SetHeight(36)

	PermaHide(BonusActionBarTexture0)
	PermaHide(BonusActionBarTexture1)
	for i=1,12 do
		PermaHide(_G["BonusActionButton"..i.."Name"])
		PermaHide(_G["BonusActionButton"..i.."HotKey"])
		_G["BonusActionButton"..i]:SetNormalTexture("")
	end

	BonusActionBarFrame:SetScript("OnShow", function() for i=1,12 do _G["tekPopbar"..i]:SetAlpha(.25) end end)
	BonusActionBarFrame:SetScript("OnHide", function() for i=1,12 do _G["tekPopbar"..i]:SetAlpha(1) end end)
end


---------------------------
--      Possess Bar      --
---------------------------

PossessBarFrame:SetParent(UIParent)
PossessButton1:SetNormalTexture("")
PossessButton2:SetNormalTexture("")
PossessButton1:ClearAllPoints()
PossessButton1:SetPoint("BOTTOMLEFT", tekPopbar1, "TOPRIGHT", gap, gap)
PermaHide(PossessBarLeft)
PermaHide(PossessBarRight)


