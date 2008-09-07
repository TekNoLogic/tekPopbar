

local _G = _G
local function noop() end
local colors = {
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



local function ActionButton_UpdateState(self)
	self:SetChecked(IsCurrentAction(self.action) or IsAutoRepeatAction(self.action))
end


local function ActionButton_UpdateFlash(self)
	if IsAttackAction(self.action) and IsCurrentAction(self.action) or IsAutoRepeatAction(self.action) then
		self.flashtime = 0
		ActionButton_UpdateState(self)
	else
		self.flashtime = nil
		self.flash:Hide()
		ActionButton_UpdateState(self)
	end
end


local function ActionButton_Update(self)
	local texture = GetActionTexture(self.action)
	self.icon:SetTexture(texture)
	if texture then
		self.icon:Show()
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
	else
		self.icon:Hide()
		self.cooldown:Hide()
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot")
	end

	self.count:SetText((IsConsumableAction(self.action) or IsStackableAction(self.action)) and GetActionCount(self.action) or "")

	if HasAction(self.action) then
		if not self.eventsRegistered then
			for _,event in pairs(events) do self:RegisterEvent(event) end
			self.eventsRegistered = 1
		end

		ActionButton_UpdateState(self)
		CooldownFrame_SetTimer(self.cooldown, GetActionCooldown(self.action))
		ActionButton_UpdateFlash(self)
	else
		self:SetChecked(false)
		if self.eventsRegistered then
			for _,event in pairs(events) do self:UnregisterEvent(event) end
			self.eventsRegistered = nil
		end
	end

	-- Add a green border if button is an equipped item
	if IsEquippedAction(self.action) then
		self.border:SetVertexColor(0, 1.0, 0, 0.35)
		self.border:Show()
	else
		self.border:Hide()
	end

	-- Update tooltip
	local cd = GetActionCooldown(self.action)
	if GameTooltip:GetOwner() == self and (self.wascd or cd ~= 0) then ActionButton_SetTooltip(self) end

	self.feedback_action = self.action
	self.wascd = cd ~= 0
end


local function OnUpdate(self, elapsed, ...)
	self = self.owner
	local id = SecureButton_GetModifiedAttribute(self, "*action*", SecureButton_GetEffectiveButton(self))
	if not id then return end

	if self.cachedaction ~= id then
		self.action, self.cachedaction = id, id
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
	ActionButton_UpdateState(self)
	ActionButton_UpdateFlash(self)
end

local function SetTooltip(frame)
	local id = SecureButton_GetModifiedAttribute(self, "action", SecureButton_GetEffectiveButton(self))
	if not id then return end

	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetAction(id)
end


local function HideTooltip(frame)
	GameTooltip:Hide()
end


local function OnDragStart(self)
	if LOCK_ACTIONBAR ~= "1" or IsModifiedClick("PICKUPACTION") then
		PickupAction(self.action)
		ActionButton_UpdateState(self)
		ActionButton_UpdateFlash(self)
	end
end

local function ActionButton_OnEvent(self, event, action)
	if event == "UPDATE_BINDINGS" then
		self:UnregisterEvent("UPDATE_BINDINGS")
		local id = self:GetAttribute("*action*")
		if id <= 12 then SetOverrideBindingClick(UIParent, nil, select(2, GetBinding(29 + id)), "tekPopbar"..id) end
		return
	end

	if event == "ACTIONBAR_UPDATE_COOLDOWN" then return UpdateCooldown(self) end
	if event == "ACTIONBAR_SLOT_CHANGED" and (action ~= 0 or action == self.action) or event == "PLAYER_ENTERING_WORLD" then return ActionButton_Update(self) end

	-- All event handlers below this line are only set when the button has an action

	if event == "ACTIONBAR_UPDATE_STATE" or event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" then
		return ActionButton_UpdateState(self)
	elseif event == "PLAYER_ENTER_COMBAT" and IsAttackAction(self.action) or event == "START_AUTOREPEAT_SPELL" and IsAutoRepeatAction(self.action) then
		self.flashtime = 0
		return ActionButton_UpdateState(self)
	elseif event == "PLAYER_LEAVE_COMBAT" and IsAttackAction(self.action) or event == "STOP_AUTOREPEAT_SPELL" and self.flashtime and not IsAttackAction(self.action) then
		self.flashtime = nil
		self.flash:Hide()
		return ActionButton_UpdateState(self)
	end
end


function tekPopBar_MakeButton(name, parent, inherit)
	inherit = inherit and "SecureActionButtonTemplate,"..inherit or "SecureActionButtonTemplate"
	local b = CreateFrame("CheckButton", name, parent, inherit)
	b:SetWidth(36) b:SetHeight(36)
	b:Show()

	local updater = CreateFrame("frame", nil, b)
	updater.owner = b
	updater:SetScript("OnUpdate", OnUpdate)

	b:SetScript("PostClick", ActionButton_UpdateState)
	b:SetScript("OnEvent", ActionButton_OnEvent)
	b:SetScript("OnDragStart", OnDragStart)
	b:SetScript("OnReceiveDrag", OnReceiveDrag)
	b:HookScript("OnEnter", ActionButton_SetTooltip)
	b:HookScript("OnLeave", HideTooltip)

	b:RegisterEvent("PLAYER_ENTERING_WORLD")
	b:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	b:RegisterForDrag("LeftButton", "RightButton")
	b:RegisterForClicks("AnyUp")

	b:SetAttribute("type", "action")
	b:SetAttribute("checkselfcast", true)
	b:SetAttribute("useparent-unit", true)
	b:SetAttribute("useparent-actionpage", true)

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

	b:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square") --ADD
	b:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight") --ADD

	b.action = ActionButton_CalculateAction(b)
	ActionButton_Update(b)

	-- Cleanup
	local icon = name and _G[name.."Icon"]
	if icon then
		icon:Hide()
		icon.Show = icon.Hide
	end

	return b
end


