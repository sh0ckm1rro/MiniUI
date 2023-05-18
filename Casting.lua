--Class HP color 頭像血條按職業顏色
local function colorHPBar(bar, unit)
	if UnitIsPlayer(unit) and UnitClass(unit) then
		local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
		bar:SetStatusBarColor(color.r, color.g, color.b)
		bar:SetStatusBarDesaturated(true)
	else
		bar:SetStatusBarColor(0, 0.9, 0.3)			-- defaultColor
		bar:SetStatusBarDesaturated(false)
	end
end
hooksecurefunc("UnitFrameHealthBar_Update", colorHPBar)
hooksecurefunc("HealthBar_OnValueChanged", function(self) colorHPBar(self, self.unit) end)

--Class ID color 頭像ID按職業顏色
function SetNameColor(frame)
	if frame.name and frame.unit then
		local color = UnitIsPlayer(frame.unit) and RAID_CLASS_COLORS[select(2, UnitClass(frame.unit))] or NORMAL_FONT_COLOR
		frame.name:SetTextColor(color.r, color.g, color.b)
	end
end
hooksecurefunc("UnitFrame_Update", function(self)
	if self.name and self.unit then
		SetNameColor(self)
	end
end)



--Focuser
local modifier = "shift"	--shift, alt 或 ctrl
local mouseButton = "1"	--1 = 左鍵, 2 = 右鍵, 3 = 中鍵, 4 和 5 = 滑鼠的其他按鍵

local function SetFocusHotkey(frame)
	frame:SetAttribute(modifier.."-type"..mouseButton, "focus")
end

local function CreateFrame_Hook(type, name, parent, template)
	if name and template == "SecureUnitButtonTemplate" then
		SetFocusHotkey(_G[name])
	end
end

hooksecurefunc("CreateFrame", CreateFrame_Hook)

local f = CreateFrame("CheckButton", "FocuserButton", UIParent, "SecureActionButtonTemplate")
f:SetAttribute("type1", "macro")
f:SetAttribute("macrotext", "/focus mouseover")
SetOverrideBindingClick(FocuserButton, true, modifier.."-BUTTON"..mouseButton, "FocuserButton")

local duf = {
	PetFrame,
	PartyMemberFrame1,
	PartyMemberFrame2,
	PartyMemberFrame3,
	PartyMemberFrame4,
	PartyMemberFrame1PetFrame,
	PartyMemberFrame2PetFrame,
	PartyMemberFrame3PetFrame,
	PartyMemberFrame4PetFrame,
	PartyMemberFrame1TargetFrame,
	PartyMemberFrame2TargetFrame,
	PartyMemberFrame3TargetFrame,
	PartyMemberFrame4TargetFrame,
	TargetFrame,
	TargetFrameToT,
	TargetFrameToTTargetFrame,
}

for i, frame in pairs(duf) do
	SetFocusHotkey(frame)
end


--施法時間
PlayerCastingBarFrame.timer = PlayerCastingBarFrame:CreateFontString(nil)
PlayerCastingBarFrame.timer:SetFont(STANDARD_TEXT_FONT, 24, "THINOUTLINE")
PlayerCastingBarFrame.timer:SetPoint("LEFT", PlayerCastingBarFrame, "RIGHT", 10, -5)	--調整位置
PlayerCastingBarFrame.update = .1

TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
TargetFrameSpellBar.timer:SetFont(STANDARD_TEXT_FONT, 24, "THINOUTLINE")
TargetFrameSpellBar.timer:SetPoint("LEFT", TargetFrameSpellBar, "RIGHT", 10, -5)
TargetFrameSpellBar.update = .1

FocusFrameSpellBar.timer = FocusFrameSpellBar:CreateFontString(nil)
FocusFrameSpellBar.timer:SetFont(STANDARD_TEXT_FONT, 24, "THINOUTLINE")
FocusFrameSpellBar.timer:SetPoint("LEFT", FocusFrameSpellBar, "RIGHT", 10, -5)
FocusFrameSpellBar.update = .1

local function PlayerCastingBarFrame_OnUpdate_Hook(self, elapsed)
	if not self.timer then return end
	if self.update and self.update < elapsed then
		if self.casting then
			self.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
		elseif self.channeling then
			self.timer:SetText(format("%.1f", max(self.value, 0)))
		else
			self.timer:SetText("")
		end
		self.update = .1
	else
		self.update = self.update - elapsed
	end
end
PlayerCastingBarFrame:HookScript('OnUpdate', PlayerCastingBarFrame_OnUpdate_Hook)
TargetFrameSpellBar:HookScript('OnUpdate', PlayerCastingBarFrame_OnUpdate_Hook)
FocusFrameSpellBar:HookScript('OnUpdate', PlayerCastingBarFrame_OnUpdate_Hook)


--目標Buff和Debuff大小+非自身施放改灰
local desaturatedBuff = true									-- Enable or Disable desaturation

local PLAYER_UNITS = {
	player = true,
	vehicle = true,
	pet = true,
}

local function setupDesaturation(frame, index, isBuff)
	if not desaturatedBuff then return end
	local caster
	local canAssist = UnitCanAssist("player", frame.unit)
	if isBuff then
		caster = select(7, UnitBuff(frame.unit, index, nil))
		if canAssist and not PLAYER_UNITS[caster] then
			frame.Icon:SetDesaturated(true)						-- true = desaturate (greyscale)
		else
			frame.Icon:SetDesaturated(false)					-- false = normal colors
		end
	else
		caster = select(7, UnitDebuff(frame.unit, index, "INCLUDE_NAME_PLATE_ONLY"))
		if not canAssist and not PLAYER_UNITS[caster] then
			frame.Icon:SetDesaturated(true)
			frame.Border:Hide()
		else
			frame.Icon:SetDesaturated(false)
			frame.Border:Show()
		end
	end
end

local buffxy=26
local debuffxy=32

hooksecurefunc("TargetFrame_UpdateBuffAnchor", function(_, buff, index) buff:SetSize(buffxy, buffxy) setupDesaturation(buff, index, true) end)
hooksecurefunc("TargetFrame_UpdateDebuffAnchor", function(_, debuff, index) debuff:SetSize(debuffxy, debuffxy) setupDesaturation(debuff, index) end)



-- Buttonrange 射程著色
hooksecurefunc("ActionButton_UpdateRangeIndicator", function(self, checksRange, inRange)
if self.action == nil then return end
local isUsable, notEnoughMana = IsUsableAction(self.action)
	if ( checksRange and not inRange ) then
		_G[self:GetName().."Icon"]:SetVertexColor(0.5, 0.1, 0.1)
	elseif isUsable ~= true or notEnoughMana == true then
		_G[self:GetName().."Icon"]:SetVertexColor(0.4, 0.4, 0.4)
	else
		_G[self:GetName().."Icon"]:SetVertexColor(1, 1, 1)
	end
end
)
