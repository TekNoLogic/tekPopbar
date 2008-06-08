
-- Bars:
-- cat = 7, moon/tree = 8, bear = 9
-- battle = 7, def = 8, berz = 9
-- stealth = 7


local _G = _G
local _, class = UnitClass("player")
local usebars = {2,5,6}
local gap = 5
local onupdates, colors = {}, {
	none = {1.0, 1.0, 1.0},
	grey = {0.4, 0.4, 0.4},
	blue = {0.1, 0.3, 1.0},
	red  = {0.8, 0.1, 0.1},
}
local events = {
	"ACTIONBAR_UPDATE_STATE", "UPDATE_INVENTORY_ALERTS", "PLAYER_AURAS_CHANGED", "ACTIONBAR_UPDATE_COOLDOWN",
	"CRAFT_SHOW", "CRAFT_CLOSE", "TRADE_SKILL_SHOW", "TRADE_SKILL_CLOSE", "PLAYER_ENTER_COMBAT", "PLAYER_LEAVE_COMBAT", "START_AUTOREPEAT_SPELL", "STOP_AUTOREPEAT_SPELL",
}


local function UpdateCooldown(self)
	CooldownFrame_SetTimer(self.cooldown, GetActionCooldown(self.action))
end



local function ActionButton_UpdateFlash(self)
	if IsAttackAction(self.action) and IsCurrentAction(self.action) or IsAutoRepeatAction(self.action) then
		self.flashtime = 0
		ActionButton_UpdateState()
	else
		self.flashtime = nil
		self.flash:Hide()
		ActionButton_UpdateState()
	end
end


local function ActionButton_Update(self)
	local texture = GetActionTexture(self.action)
	if texture then
		self.icon:SetTexture(texture)
		self.icon:Show()
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
	else
		self.icon:Hide()
		self.cooldown:Hide()
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot")
	end

	ActionButton_UpdateCount()

	if HasAction(self.action) then
		if not self.eventsRegistered then
			for _,event in pairs(events) do self:RegisterEvent(event) end
			self.eventsRegistered = 1
		end

		ActionButton_UpdateState()
--~ 		ActionButton_UpdateUsable()
		CooldownFrame_SetTimer(self.cooldown, GetActionCooldown(self.action))
		ActionButton_UpdateFlash(self)
	else
		if self.eventsRegistered then
			for _,event in pairs(events) do self:UnregisterEvent(event) end
			self.eventsRegistered = nil
		end

		if self.showgrid ~= 0 then self.cooldown:Hide() end
	end

	-- Add a green border if button is an equipped item
	local border = _G[self:GetName().."Border"]
	if IsEquippedAction(self.action) then
		border:SetVertexColor(0, 1.0, 0, 0.35)
		border:Show()
	else
		border:Hide()
	end

	-- Update tooltip
	local cd = GetActionCooldown(self.action)
	if GameTooltip:GetOwner() == self and (self.wascd or cd ~= 0) then ActionButton_SetTooltip(self) end

	self.feedback_action = self.action
	self.wascd = cd ~= 0
end


local function OnUpdate(self, elapsed, ...)
	local id = SecureButton_GetModifiedAttribute(self, "action", SecureButton_GetEffectiveButton(self)) or 1
	if id ~= self.action then
		self.action = id
		ActionButton_Update(self)
	end

	local oor, isUsable, notEnoughMana = IsActionInRange(id), IsUsableAction(id)
	local c = notEnoughMana and "blue" or oor == 0 and "red" or isUsable and "none" or "grey"
	self.icon:SetVertexColor(unpack(colors[c]))

	if HasAction(self.action) and self.flashtime then
		self.flashtime = self.flashtime - elapsed
		if self.flashtime <= 0 then
			local overtime = -self.flashtime
			if overtime >= ATTACK_BUTTON_FLASH_TIME then overtime = 0 end
			self.flashtime = ATTACK_BUTTON_FLASH_TIME - overtime

			if self.flash:IsShown() then self.flash:Hide() else self.flash:Show() end
		end
	else self.flash:Hide() end
end


local function OnReceiveDrag(self)
	PlaceAction(self.action)
	ActionButton_UpdateState()
	ActionButton_UpdateFlash(self)
end

local function SetTooltip(frame)
	local id = SecureButton_GetModifiedAttribute(self, "action", SecureButton_GetEffectiveButton(self)) or 1
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetAction(id)
end


local function HideTooltip(frame)
	GameTooltip:Hide()
end


local function ActionButton_OnLoad(self)
	self.showgrid = 0
	self:SetAttribute("type", "action")
	self:SetAttribute("checkselfcast", true)
	self:SetAttribute("useparent-unit", true)
	self:SetAttribute("useparent-actionpage", true)
	self:RegisterForDrag("LeftButton", "RightButton")
	self:RegisterForClicks("AnyUp")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ACTIONBAR_SHOWGRID")
	self:RegisterEvent("ACTIONBAR_HIDEGRID")
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")

	local action = ActionButton_CalculateAction(self)
	if action ~= self.action then
		self.action = action
		ActionButton_Update(self)
	end
end


local function OnDragStart(self)
	if LOCK_ACTIONBAR ~= "1" or IsModifiedClick("PICKUPACTION") then
		PickupAction(self.action)
		ActionButton_UpdateState()
		ActionButton_UpdateFlash(self)
	end
end

local function ActionButton_OnEvent(self, event, a1)
	if event == "ACTIONBAR_UPDATE_COOLDOWN" then return UpdateCooldown(self) end
	if event == "ACTIONBAR_SLOT_CHANGED" and (a1 ~= 0 or a1 == self.action) or event == "PLAYER_ENTERING_WORLD" then return ActionButton_Update(self) end

--~ 	if ( event == "ACTIONBAR_SHOWGRID" ) then
--~ 		ActionButton_ShowGrid();
--~ 		return;
--~ 	end
--~ 	if ( event == "ACTIONBAR_HIDEGRID" ) then
--~ 		ActionButton_HideGrid();
--~ 		return;
--~ 	end

	-- All event handlers below this line are only set when the button has an action

	if event == "ACTIONBAR_UPDATE_STATE" or event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" then return ActionButton_UpdateState()
	elseif event == "PLAYER_ENTER_COMBAT" then
		if IsAttackAction(self.action) then
			self.flashtime = 0
			ActionButton_UpdateState()
		end
	elseif event == "PLAYER_LEAVE_COMBAT" then
		if IsAttackAction(self.action) then
			self.flashtime = nil
			self.flash:Hide()
			ActionButton_UpdateState()
		end
	elseif event == "START_AUTOREPEAT_SPELL" then
		if IsAutoRepeatAction(self.action) then
			self.flashtime = 0
			ActionButton_UpdateState()
		end
	elseif event == "STOP_AUTOREPEAT_SPELL" then
		if self.flashtime and not IsAttackAction(self.action) then
			self.flashtime = nil
			self.flash:Hide()
			ActionButton_UpdateState()
		end
	end
end


local function makeframe(name, parent, inherit)
	inherit = inherit and "SecureActionButtonTemplate,"..inherit or "SecureActionButtonTemplate"
	local b = CreateFrame("CheckButton", name, parent, inherit)
	b:SetWidth(36) b:SetHeight(36)
	b:SetScript("OnEvent", ActionButton_OnEvent)
	b:SetScript("PostClick", ActionButton_UpdateState)
	b:SetScript("OnDragStart", OnDragStart)
	b:SetScript("OnReceiveDrag", OnReceiveDrag)

	b.icon = b:CreateTexture(nil, "BACKGROUND")
	b.icon:SetAllPoints()

	b.flash = b:CreateTexture(nil, "ARTWORK")
	b.flash:SetAllPoints()
	b.flash:SetTexture("Interface\\Buttons\\UI-QuickslotRed")
	b.flash:Hide()

	b.count = b:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
	b.count:SetJustifyH("RIGHT")
	b.count:SetPoint("BOTTOMRIGHT", -2, 2)

	b.border = b:CreateTexture(nil, "OVERLAY")
	b.border:SetWidth(62) b.border:SetHeight(62)
	b.border:SetPoint("CENTER")
	b.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	b.border:SetBlendMode("ADD")
	b.border:Hide()

	b.cooldown = CreateFrame("Cooldown", nil, b, "CooldownFrameTemplate")
	b.cooldown:SetWidth(36) b.cooldown:SetHeight(36)
	b.cooldown:SetPoint("CENTER", 0, -1)

	b:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
	local norm = b:GetNormalTexture()
	norm:SetWidth(66) norm:SetHeight(66)
	norm:SetPoint("CENTER", 0, -1)

	b:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square") --ADD
	b:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight") --ADD

	ActionButton_OnLoad(b)

	return b
end


function tekPopBar_MakeButton(frametype, name, parent, inherit)
	local b = makeframe(name, parent, inherit)
	b:SetScript("OnUpdate", OnUpdate)
	b:SetScript("OnAttributeChanged", ActionButton_Update)
	b:HookScript("OnEnter", ActionButton_SetTooltip)
	b:HookScript("OnLeave", HideTooltip)
	return b
end

