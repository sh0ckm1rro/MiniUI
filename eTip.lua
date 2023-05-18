local unpack = unpack
local cfg = {
	scale = 1.2,
	combathideALL = false,	--戰鬥隱藏

    backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 2,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    },
	bgcolor = {0, 0, 0, .8},
	bdrcolor = { .3, .3, .3, 1 },
	gcolor = {.6, .6, .6 },
	font = STANDARD_TEXT_FONT,
	flag = "OUTLINE",
	statusbar = "Interface\\TargetingFrame\\UI-StatusBar",
}

-- Texture tooltips
local tooltips = {
	GameTooltip,
	ItemRefTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
	DropDownList1MenuBackdrop,
	DropDownList2MenuBackdrop,
	DropDownList3MenuBackdrop,
	AutoCompleteBox,
	WorldMapTooltip,
	BNToastFrame.tooltip,
	FriendsTooltip,
	IMECandidatesFrame,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	ItemRefShoppingTooltip3,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3,
}


--[[local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor

local OnTooltipSetItem = function(self, ...)
local name, item = self:GetItem()
if(item) then
local _, _, quality = GetItemInfo(item)
if(quality) then
local r, g, b = GetItemQualityColor(quality)

self:SetBackdropBorderColor(r, g, b, a)
end
end
end

for _, obj in next, {
GameTooltip,
ShoppingTooltip1,
ShoppingTooltip2,
ShoppingTooltip3,
ItemRefTooltip,
} do
obj:HookScript("OnTooltipSetItem", OnTooltipSetItem)
end]]


-- Unit color
GameTooltip_UnitColor = function(unit)
	local player = UnitIsPlayer(unit)
	local reaction = UnitReaction(unit, "player")
	local connected = UnitIsConnected(unit)
	local dead = UnitIsDead(unit)
	local ghost = UnitIsGhost(unit)
	local r, g, b

	if not connected or dead or ghost then
		r, g, b = 0.55, 0.57, 0.61, 0.7
	elseif player then
		local _, class = UnitClass(unit)
		r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, RAID_CLASS_COLORS[class].a
	elseif reaction then
		r, g, b = FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b, FACTION_BAR_COLORS[reaction].a
	else
		r, g, b = UnitSelectionColor(unit)
	end

	return r, g, b
end

-- Hide PVP text
PVP_ENABLED = ""


--陣營圖
local ficon = GameTooltip:CreateTexture("UnitFactionGroup", "OVERLAY")
ficon:SetSize(50,50)
ficon:SetAlpha(.6)
ficon:SetPoint("TOPRIGHT", "GameTooltip", "TOPRIGHT", 0, -5)

GameTooltip:HookScript("OnHide", function(self)
	ficon:SetTexture(nil)
end)

-- Statusbar
GameTooltipStatusBar:SetStatusBarTexture(cfg.statusbar)

-- Statusbar background
GameTooltipStatusBar:SetHeight(4)

GameTooltipText:SetFont(cfg.font, 15, cfg.flag)
Tooltip_Small:SetFont(cfg.font, 15, cfg.flag)

-- Position default anchor
local function defaultPosition(tt, parent)
if UnitExists("mouseover") then
	tt:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 40, -135)	--錨點
	end
end
hooksecurefunc("GameTooltip_SetDefaultAnchor", defaultPosition)

local function OnUpdate(self, ...)
	if self:GetAnchorType() == "ANCHOR_NONE" then
		if InCombatLockdown() then
			self:SetAlpha(0)
		else
			self:SetAlpha(1)
		end
	end
	--self:SetBackdropColor(unpack(cfg.bgcolor))
end


-- Unit tooltip style
--local OnTooltipSetUnit = function(self)
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(self)
	local lines = self:NumLines()
	lastlinenum = lines
	local _, unit = self:GetUnit()

	if not(unit or UnitExists(unit)) then return end

	local isBattlePet = UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)
	local level = UnitLevel(unit)
	local race	= UnitRace(unit)
	local title = UnitPVPName(unit)
	local unitName, unitRealm = UnitName(unit)
	local isPlayer = UnitIsPlayer(unit)
	local r, g, b = GameTooltip_UnitColor(unit)


	if level == -1 then
		level = "??"
		levelColor = { r=1, g=0, b=0 }
	elseif isBattlePet then
		level = UnitBattlePetLevel(unit)
	else
		levelColor = GetQuestDifficultyColor(level)
	end

	if UnitIsPlayer(unit) then

	-- display unit name / realm / AFK or DND
	if UnitIsAFK(unit) then Status = CHAT_FLAG_AFK elseif UnitIsDND(unit) then Status = CHAT_FLAG_DND
	elseif not UnitIsConnected(unit) then Status = "<離線>" else Status = "" end
	_G["GameTooltipTextLeft1"]:SetFormattedText("%s%s |cff00DDDD%s|r", title or unitName, unitRealm and unitRealm ~= "" and " - "..unitRealm or "", Status)

		--陣營圖
		if UnitFactionGroup(unit)=="Neutral" then	--判斷中立
			ficon:SetTexture(nil)
		else
			local icon = 'Interface\\FriendsFrame\\PlusManz-'..select(1, UnitFactionGroup(unit))..'.blp'
			ficon:SetTexture(icon)
		end

		--標記
		local ricon = GetRaidTargetIndex(unit)
		if (ricon) then
			local text = GameTooltipTextLeft1:GetText()
			GameTooltipTextLeft1:SetFormattedText(("%s %s"), ICON_LIST[ricon].."12|t", text)
		end
		
		tip = nil
		for i = 2, lines do
			local line = _G["GameTooltipTextLeft"..i]
			tip = line:GetText()
			if tip then
				if not line or not line:GetText() then
					lines = i
				elseif tip == FACTION_ALLIANCE or tip == FACTION_HORDE then
					line:SetText()
					tip = i
					lastlinenum = lastlinenum - 1
				elseif tip == PVP then	--PVP
					line:SetText()
					tip = i
					lastlinenum = lastlinenum - 1
				end
			end
		end

		--if GetGuildInfo(unit) then
		local _, rank, tmp2 = GetGuildInfo(unit)
		if rank then
			_G["GameTooltipTextLeft2"]:SetFormattedText("<%s> %s(%s)", GetGuildInfo(unit),rank,tmp2)
			_G["GameTooltipTextLeft2"]:SetTextColor(unpack(cfg.gcolor))
		end

		local n = GetGuildInfo(unit) and 3 or 2
		--  thx TipTac for the fix above with color blind enabled
		if GetCVar("colorblindMode") == "1" then n = n + 1 end
		if (race and UnitIsEnemy(unit, "player")) then race = ("|cffDD0000%s|r"):format(race) end
		_G["GameTooltipTextLeft"..n]:SetFormattedText("|cff%02x%02x%02x%s|r %s |cff%02x%02x%02x%s|r", levelColor.r*255, levelColor.g*255, levelColor.b*255, level, race, r*255, g*255, b*255, UnitClass(unit))

	else
		local classification = UnitClassification(unit)
		local creatureType = UnitCreatureType(unit)
		local BattlePetType = UnitBattlePetType(unit)
		local reaction = UnitReaction(unit, "player")

		classification = (classification == "rareelite" and "|cffCC00FFR+|r") or
			(classification == "rare" and "|cff999999R|r") or
			(classification == "elite" and "|cffFFCC00+|r") or ""

		if isBattlePet then
		for i = 3, lines do
			local line = _G["GameTooltipTextLeft"..i]
			line:SetFormattedText("|cff80ACEF%s|r %s", level, _G["BATTLE_PET_NAME_"..UnitBattlePetType(unit)] or "")
			break
		end
		else
		for i = 2, lines do
			local line = _G["GameTooltipTextLeft"..i]
			if not line or not line:GetText() then i = 3 end

			if (level and line:GetText():find("^"..LEVEL)) or (creatureType and line:GetText():find("^"..creatureType)) or (reaction and line:GetText():find("^"..reaction)) then
				reaction = _G["FACTION_STANDING_LABEL"..reaction]
				line:SetFormattedText("|cff%02x%02x%02x%s%s|r %s |cff%02x%02x%02x%s|r", levelColor.r*255, levelColor.g*255, levelColor.b*255, level, classification, creatureType, r*255, g*255, b*255, reaction or "")
			end
		end
		end

	end

	-- ToT line
	if UnitIsUnit(unit.."target","player") then
		self:AddLine("|cffff0000>你<|r")
	elseif UnitExists(unit.."target") then
		local r, g, b = GameTooltip_UnitColor(unit.."target")
		self:AddLine("|cffFFCC00@ |r"..UnitName(unit.."target") or "Unknown", r, g, b)
	end

	-- tooltip border color, status bar color & status bar background border color
	--GameTooltip:SetBackdropBorderColor(r, g, b, a)
	GameTooltipStatusBar:SetStatusBarColor(r, g, b)
end)


-- function to short-display HP value on StatusBar
local function ShortValue(value)
		if (value >= 1e8) then
			return ("%.2f億"):format(value / 1e8)
		elseif (value >= 1e4) then
			return ("%.2f萬"):format(value / 1e4)
		else
			return ("%d"):format(value)
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
        local hp = ShortValue(min).." / "..ShortValue(max)
        self.text:SetText(hp)
    end
end)


-- border color according to if unit is player/friendly/hostile and item quality
local OnShow = function(self,...)
	local unit = select(2, self:GetUnit())
	local reaction = unit and UnitReaction("player", unit)
	local isPlayer = unit and UnitIsPlayer(unit)

	if isPlayer or reaction then
		local r, g, b, a = GameTooltip_UnitColor(unit)
		GameTooltipStatusBar:SetStatusBarColor(r, g, b)
	end
end

ItemRefTooltip:HookScript("OnShow", OnShow)
GameTooltip:HookScript("OnShow", OnShow)
--GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
--GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
