----------------
--  鼠標提示  --
----------------
local unpack = unpack
local _, ns = ...
local cfg = {
	scale = 1.1,
	combathideALL = false,	--戰鬥隱藏
	
    backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 18,
        edgeSize = 2,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    },
	gcolor = {.6, .6, .6, 1 },
	deadcolor = {.5,.5,.5, .5},
	font = STANDARD_TEXT_FONT,
	fontflag = "OUTLINE",
	statusbar = "Interface\\TargetingFrame\\UI-StatusBar",
}

function ReskinQSF(f)
	if f.s then return end

	local s = CreateFrame("Frame", nil, f, "BackdropTemplate")
	s:SetFrameLevel(1)
	s:SetFrameStrata(f:GetFrameStrata())
	s:SetPoint("TOPLEFT", -0, 0)--s:SetPoint("TOPLEFT", -2, 2)
	s:SetPoint("BOTTOMRIGHT", 0, -0)--s:SetPoint("BOTTOMRIGHT", 2, -2)
	s:SetBackdrop(cfg.backdrop)
	s:SetBackdropColor(0, 0, 0, 0.65)
	s:SetBackdropBorderColor(0, 0, 0, 1)

	f.s = s
	return s
end


-- 9.1.5++++++NDui\Core\Functions.lua
-- Add API
do
	local function HideBackdrop(frame)
		if frame.NineSlice then frame.NineSlice:SetAlpha(0) end
		if frame.SetBackdrop then frame:SetBackdrop(nil) end
	end

	local function addapi(object)
		local mt = getmetatable(object).__index
		if not object.HideBackdrop then mt.HideBackdrop = HideBackdrop end
	end

	local handled = {["Frame"] = true}
	local object = CreateFrame("Frame")
	addapi(object)
	addapi(object:CreateTexture())
	addapi(object:CreateMaskTexture())

	object = EnumerateFrames()
	while object do
		if not object:IsForbidden() and not handled[object:GetObjectType()] then
			addapi(object)
			handled[object:GetObjectType()] = true
		end

		object = EnumerateFrames(object)
	end
end


-- 9.0.5++++++AuroraClassic
local fakeBg = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
fakeBg:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
local function __GetBackdrop() return fakeBg:GetBackdrop() end
local function __GetBackdropColor() return 0, 0, 0, 0.65 end
local function __GetBackdropBorderColor() return 0, 0, 0 end

function ReskinTooltip(tooltip)
	--if tooltip:IsForbidden() then return end

	--if not tooltip.auroraTip then
		if tooltip.SetBackdrop then tooltip:SetBackdrop(nil) end
		tooltip:HideBackdrop()-- 9.1.5++++++NDui
		tooltip:DisableDrawLayer("BACKGROUND")
		tooltip.bg = ReskinQSF(tooltip)

		if tooltip.GetBackdrop then
			tooltip.GetBackdrop = __GetBackdrop
			tooltip.GetBackdropColor = __GetBackdropColor
			tooltip.GetBackdropBorderColor = __GetBackdropBorderColor
		end

		tooltip.auroraTip = true
	--end
end

local tooltips = {
	ChatMenu,--聊天框相關
	EmoteMenu,--聊天框相關
	LanguageMenu,--聊天框相關
	VoiceMacroMenu,--聊天框相關
	GameTooltip,
	EmbeddedItemTooltip,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	ShoppingTooltip1,
	ShoppingTooltip2,
	AutoCompleteBox,
	FriendsTooltip,
	QuestScrollFrame.StoryTooltip,--？
	QuestScrollFrame.CampaignTooltip,--？
	GeneralDockManagerOverflowButtonList,--？
	ReputationParagonTooltip,
	NamePlateTooltip,--姓名板DEBUFF
	QueueStatusFrame,--排戰場眼睛的提示
	FloatingGarrisonFollowerTooltip,--發到聊天框的隨從提示
	FloatingGarrisonFollowerAbilityTooltip,--發到聊天框的隨從技能提示
	FloatingGarrisonMissionTooltip,--發到聊天框的職業大廳任務提示
	GarrisonFollowerAbilityTooltip,--要塞隨從界面技能提示
	GarrisonFollowerTooltip,--職業大廳任務界面隨從提示
	FloatingGarrisonShipyardFollowerTooltip,--？
	GarrisonShipyardFollowerTooltip,--船塢任務界面隨從船只提示
	BattlePetTooltip,--？
	PetBattlePrimaryAbilityTooltip,--寵物戰鬥界面主要技能提示
	PetBattlePrimaryUnitTooltip,--寵物戰鬥界面頭像提示
	FloatingBattlePetTooltip,--發到聊天框的寵物提示
	FloatingPetBattleAbilityTooltip,--？
	IMECandidatesFrame,--輸入法
	QuickKeybindTooltip,

	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	DropDownList1MenuBackdrop,
	DropDownList2MenuBackdrop,
	GeneralDockManagerOverflowButtonList,--？
	--"BNToastFrameGlowFrame",
	--"BNToastFrame"
	SmallTextTooltip,

	GarrisonFollowerAbilityWithoutCountersTooltip,--職業大廳隨從界面技能提示
	GarrisonFollowerMissionAbilityWithoutCountersTooltip,--職業大廳任務界面危害技能提示
	PetJournalPrimaryAbilityTooltip,--？
	PetJournalSecondaryAbilityTooltip,--？
	GarrisonShipyardMapMissionTooltip,--？

	PetJournalPrimaryAbilityTooltip,
	PetJournalSecondaryAbilityTooltip,

	}
	for _, tooltip in pairs(tooltips) do
		ReskinTooltip(tooltip)
	end


--跟隨游標
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
if UnitExists("mouseover") then
	tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 40, -135)	--錨點
	end
end)


--陣營圖
local ficon = GameTooltip:CreateTexture("UnitFactionGroup", "OVERLAY")
ficon:SetSize(60,60)
ficon:SetAlpha(.4)
ficon:SetPoint("TOPRIGHT", "GameTooltip", "TOPRIGHT", 0, -5)

GameTooltip:HookScript("OnHide", function(self)
	ficon:SetTexture(nil)
end)


--func GetHexColor ID染色
local function GetHexColor(color)
  return ("%.2x%.2x%.2x"):format(color.r*255, color.g*255, color.b*255)
end
local classColors, reactionColors = {}, {}

for class, color in pairs(RAID_CLASS_COLORS) do
  classColors[class] = GetHexColor(RAID_CLASS_COLORS[class])
end

for i = 1, #FACTION_BAR_COLORS do
  reactionColors[i] = GetHexColor(FACTION_BAR_COLORS[i])
end

local hex = function(r, g, b)
	if (r and not b) then
		r, g, b = r.r, r.g, r.b
	end
	return (b and format('|cff%02x%02x%02x', r * 255, g * 255, b * 255))
end
ns.hex = hex


local function GetTarget(unit)
  if UnitIsUnit(unit, "player") then
    return ("|cffff0000%s|r"):format(">你<")
  elseif UnitIsPlayer(unit, "player")then
    local _, class = UnitClass(unit)
    return ("|cff%s%s|r"):format(classColors[class], UnitName(unit))
  elseif UnitReaction(unit, "player") then
    return ("|cff%s%s|r"):format(reactionColors[UnitReaction(unit, "player")], UnitName(unit))
  else
    return ("|cffffffff%s|r"):format(UnitName(unit))
  end
end

GameTooltipHeaderText:SetFont(cfg.font, 19, cfg.fontflag)
GameTooltipText:SetFont(cfg.font, 16, cfg.fontflag)
Tooltip_Small:SetFont(cfg.font, 16, cfg.fontflag)


local classification = {
	elite = ("|cffFFCC00 精英|r"),
	rare = ("|cff999999 稀有|r"),
	rareelite = ("|cffCC00FF 稀有精英|r"),
	worldboss = ("|cffFF0000?? 首領|r")
}

--名字染色
function GameTooltip_UnitColor(unit)
	local r, g, b
	local reaction = UnitReaction(unit, "player")
		if reaction then
			r = FACTION_BAR_COLORS[reaction].r
			g = FACTION_BAR_COLORS[reaction].g
			b = FACTION_BAR_COLORS[reaction].b
		else
			r = 1.0
			g = 1.0
			b = 1.0
		end

		if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
			r = RAID_CLASS_COLORS[class].r
			g = RAID_CLASS_COLORS[class].g
			b = RAID_CLASS_COLORS[class].b
		end
		return r, g, b
end


--GameTooltip:HookScript("OnTooltipSetUnit", function(self, unit)
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(self)

	local unit = (select(2, self:GetUnit())) or nil
	if unit == "npc" then unit = "mouseover" end
	if (not unit) then return end
	
	if(cfg.combathideALL and InCombatLockdown()) then	--戰鬥隱藏
		return self:Hide()
	end
	
	
	--陣營圖
	if UnitFactionGroup(unit)=="Neutral" then	--判斷中立
	ficon:SetTexture(nil)
	elseif UnitIsPlayer(unit) then
		local icon = 'Interface\\FriendsFrame\\PlusManz-'..select(1, UnitFactionGroup(unit))..'.blp'
		ficon:SetTexture(icon)
	end
	
	--標記
	local ricon = GetRaidTargetIndex(unit)
	if (ricon) then
		local text = GameTooltipTextLeft1:GetText()
		GameTooltipTextLeft1:SetFormattedText(("%s %s"), ICON_LIST[ricon].."12|t", text)
	end

	if (UnitExists(unit .. "target")) then --目標職業顏色
		self:AddDoubleLine("目標："..GetTarget(unit.."target") or "Unknown")
	end
	
	--清除PVP陣營字樣
	tip, text, levelline, foundpvp, foundfact, tmp, tmp2 = nil
	local pvplinenum,factlinenum=nil
	trueNum = GameTooltip:NumLines()
	lastlinenum = trueNum
	
	for i = 2, trueNum do
		text = _G[GameTooltip:GetName().."TextLeft"..i]
		tip = text:GetText()
		if tip then
			if not levelline and (strfind(tip, LEVEL)) then
				levelline = i
			elseif tip == FACTION_ALLIANCE or tip == FACTION_HORDE then	--陣營
				text:SetText()
				foundfact = true
				factlinenum = i
				lastlinenum = lastlinenum - 1
			elseif tip == PVP then	--PVP
				text:SetText()
				pvplinenum = i
				lastlinenum = lastlinenum - 1
			end
		end
	end

	
	local unitGuild = GetGuildInfo(unit)	--公會染色
	local text = GameTooltipTextLeft2:GetText()
	if unitGuild and text and text:find("^"..unitGuild) then
		GameTooltipTextLeft2:SetText("<"..text..">")
		GameTooltipTextLeft2:SetTextColor(unpack(cfg.gcolor))
	end
	
	local isBattlePet = UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)
	local level = isBattlePet and UnitBattlePetLevel(unit) or UnitLevel(unit)
	
	if (level) then
		local levelLine
		for i = (isInGuild and 3) or 2, self:NumLines() do
			local line = _G["GameTooltipTextLeft"..i]
			local text = line:GetText()
			if (text and strfind(text, LEVEL)) then
				levelLine = line
				break
			end
		end
	
	if (levelLine) then
	local isPlayer = UnitIsPlayer(unit)
	local creature = not isPlayer and UnitCreatureType(unit)
	local race = player and player.race or UnitRace(unit)
	local dead = isDead and unpack(cfg.deadcolor)..CORPSE.."|r"
	local classify = UnitClassification(unit)
	
	local _, class = player and UnitClass(unit)..(player.class or "").."|r"
		if (isBattlePet) then
			class = ("|cff80ACEF%s|r"):format(_G["BATTLE_PET_NAME_"..UnitBattlePetType(unit)])
		elseif creature then
			class = ("|cffFFFFFF%s|r"):format(UnitCreatureType(unit))
		else
			class = UnitClass(unit) or ""
		end
		

		local lvltxt, diff
		if (level == -1) then
			level = classification.worldboss
			lvltxt = level
		else
			level = ("%d"):format(level)
			diff = GetQuestDifficultyColor(level)
			lvltxt = ("%s%s|r%s"):format(hex(diff) , level, (classify and classification[classify] or ""))
		end


		if (dead) then
			levelLine:SetFormattedText("%s %s", lvltxt, dead)
		else
			if (race and UnitIsEnemy(unit, "player")) then race = hex(FACTION_BAR_COLORS[2])..race.."|r" end
			levelLine:SetFormattedText("%s %s", lvltxt, race or "")
		end

		if (class) and UnitIsPlayer(unit) then class = hex(GameTooltip_UnitColor(unit))..class.."|r" end
			lvltxt = levelLine:GetText()
			levelLine:SetFormattedText("%s %s", lvltxt, class)
		--end

		if (UnitIsPVP(unit) and UnitCanAttack("player", unit)) then
			lvltxt = levelLine:GetText()
			levelLine:SetFormattedText("%s |cff00FF00(%s)|r", lvltxt, PVP)
		end

		if not (isPlayer or isBattlePet) then
		-- 1 憎恨 2 敵對 3 冷淡 4 中立 5 友好 6 尊敬 7 崇敬/崇拜
		local reaction = UnitReaction(unit, "player")
		local colors = FACTION_BAR_COLORS[reaction] or nilColor
		reaction = _G["FACTION_STANDING_LABEL"..reaction]
			if (reaction) then
				reaction = hex(colors)..reaction.."|r"
				lvltxt = levelLine:GetText()
				levelLine:SetFormattedText("%s %s", lvltxt, reaction)
				
			end
		end
	local status = (UnitIsAFK(unit) and CHAT_FLAG_AFK) or (UnitIsDND(unit) and CHAT_FLAG_DND) or (not UnitIsConnected(unit) and "<離線>")
	if (status) then
	self:AppendText((" |cff00DDDD%s|r"):format(status))
    end
		GameTooltipStatusBar:SetStatusBarColor(GameTooltip_UnitColor(unit))
		end
	end
end)


--GameTooltipStatusBar
local numberize = function(val)
		if (val >= 1e8) then
			return ("%.2f億"):format(val / 1e8)
		elseif (val >= 1e4) then
			return ("%.1f萬"):format(val / 1e4)
		else
			return ("%d"):format(val)
		end
end


--update HP value on status bar
GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
    if not value then
        return
    end
    local min, max = self:GetMinMaxValues()
    if (value < min) or (value > max) then
        return
    end
    local _, unit = GameTooltip:GetUnit()
    if unit then
        min, max = UnitHealth(unit), UnitHealthMax(unit)
        if not self.text then
            self.text = self:CreateFontString(nil, "OVERLAY")
            self.text:SetPoint("CENTER", GameTooltipStatusBar)
            self.text:SetFont(cfg.font, 13, "ThinOutline")
        end
        self.text:Show()
        local hp = numberize(min).." / "..numberize(max)
        self.text:SetText(hp)
    end
end)

