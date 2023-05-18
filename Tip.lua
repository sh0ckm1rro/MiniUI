local _, ns = ...

--locale
if GetLocale()=="zhTW" then
	RARE = "稀有"
elseif GetLocale()=="zhCN" then
	RARE = "稀有"
elseif GetLocale()=="enUS" then
	RARE = "Rare"
end
  
-- main
local mediapath = "Interface\\AddOns\\NDui\\media\\"
local cfg = {
    font = GameTooltipText:GetFont(),
    fontsize = 14,
	flag = "OUTLINE",
    tex = mediapath.."normTex",

    scale = 1.2,
    --point = { "BOTTOMRIGHT", "BOTTOMRIGHT", -100, 80 },
    cursor = true,

    hideTitles = false,
    hideRealm = false,

    backdrop = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = mediapath.."glowTex",
        tile = true,
        tileSize = 16,
        edgeSize = 4,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    },
    bgcolor = { r=0.05, g=0.05, b=0.05, t=.75 },
    bdrcolor = { r=0, g=0, b=0 },
    gcolor = { r=1, g=0.1, b=0.8 },
    colorborderClass = true,
    combathide = false,
	
    Itemicons = true,
    Itemcount = true,
    Itemlevel = true,
    Spellid = true,
	Role = true,
	PetTip = true,
	Talent = true,
	castby = true,
	Symbiotic = true,
}

GameTooltipText:SetFont(cfg.font, 15, cfg.flag)
Tooltip_Small:SetFont(cfg.font, 15, cfg.flag)

local classification = {
    elite = " |cffcc8800"..ELITE.."|r",
    rare = " |cffff99cc"..RARE.."|r",
    rareelite = " |cffff99cc"..RARE.."|r ".."|cffcc8800"..ELITE.."|r",
}

local find = string.find
local format = string.format
local hex = function(color)
    return format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
end

local nilcolor = { r=1, g=1, b=1 }
local tapped = { r=.6, g=.6, b=.6}
local function unitColor(unit)
	if not unit then unit = "mouseover" end
	local color
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		color = RAID_CLASS_COLORS[class]
	else
		local reaction = UnitReaction(unit, "player")
		if reaction then
			color = FACTION_BAR_COLORS[reaction]
		end
	end
	return (color or nilcolor)
end

function GameTooltip_UnitColor(unit)
    local color = unitColor(unit)
	if color then return color.r, color.g, color.b end
end

local function getTarget(unit)
    if UnitIsUnit(unit, "player") then
        return ("|cffff0000%s|r"):format("<"..string.upper(YOU)..">")
    else
        return hex(unitColor(unit))..UnitName(unit).."|r"
    end
end

--GameTooltip:HookScript("OnTooltipSetUnit", function(self)
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(self)
    local name, unit = self:GetUnit()

    if unit then
        if cfg.combathide and InCombatLockdown() then
            return self:Hide()
        end

        local color = unitColor(unit)
        local ricon = GetRaidTargetIndex(unit)

        if ricon then
            local text = GameTooltipTextLeft1:GetText()
            GameTooltipTextLeft1:SetText(("%s %s"):format(ICON_LIST[ricon].."18|t", text))
        end

        if UnitIsPlayer(unit) then
            self:AppendText((" |cff00cc00%s|r"):format(UnitIsAFK(unit) and CHAT_FLAG_AFK or 
            UnitIsDND(unit) and CHAT_FLAG_DND or 
            not UnitIsConnected(unit) and "<斷線>" or ""))

            if cfg.hideTitles then
                local title = UnitPVPName(unit)
                if title then
                    local text = GameTooltipTextLeft1:GetText()
                    title = title:gsub(name, "")
                    text = text:gsub(title, "")
                    if text then GameTooltipTextLeft1:SetText(text) end
                end
            end

            if cfg.hideRealm then
                local _, realm = UnitName(unit)
                if realm then
                    local text = GameTooltipTextLeft1:GetText()
                    text = text:gsub("- "..realm, "")
                    if text then GameTooltipTextLeft1:SetText(text) end
                end
            end
			local unitGuild, tmp,tmp2 = GetGuildInfo(unit)
            local text = GameTooltipTextLeft2:GetText()
            if tmp then
               tmp2=tmp2+1
               GameTooltipTextLeft2:SetText("<"..text..">  "..tmp.."("..tmp2..")")
			   GameTooltipTextLeft2:SetTextColor(cfg.gcolor.r, cfg.gcolor.g, cfg.gcolor.b)
            end
        end


        local alive = not UnitIsDeadOrGhost(unit)
        local level = UnitLevel(unit)

        if level then
            local unitClass = UnitIsPlayer(unit) and hex(color)..UnitClass(unit).."|r" or ""
            local creature = not UnitIsPlayer(unit) and UnitCreatureType(unit) or ""
            local diff = GetQuestDifficultyColor(level)

            if level == -1 then
                level = "|cffff0000"..BOSS..'|r'
            end

            local classify = UnitClassification(unit)
			local reaction = UnitReaction(unit, "player")
			reaction = _G["FACTION_STANDING_LABEL"..reaction]
			reaction = hex(color)..reaction.."|r"
            local textLevel = ("%s%s%s|r"):format(hex(diff), tostring(level), classification[classify] or "")

            for i=2, self:NumLines() do
                local tiptext = _G["GameTooltipTextLeft"..i]
                if tiptext:GetText():find(LEVEL) then
				    if alive and not UnitIsPlayer(unit) then
                        tiptext:SetText(("%s %s%s %s %s"):format(textLevel, creature, UnitRace(unit) or "", unitClass, reaction):trim())
                    elseif alive then
                        tiptext:SetText(("%s %s%s %s"):format(textLevel, creature, UnitRace(unit) or "", unitClass):trim())
                    else
                        tiptext:SetText(("%s %s"):format(textLevel, "|cffCCCCCC"..DEAD.."|r"):trim())
                    end
                end

                if tiptext:GetText():find(PVP) then
                    tiptext:SetText(nil)
                end
            end
        end

        if not alive then
            GameTooltipStatusBar:Hide()
        end

        if UnitExists(unit.."target") then
            local tartext = ("%s: %s"):format(TARGET, getTarget(unit.."target"))
            self:AddLine(tartext)
        end

        GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
    else
        for i=2, self:NumLines() do
            local tiptext = _G["GameTooltipTextLeft"..i]

            --[[if tiptext:GetText():find(PVP) then
                tiptext:SetText(nil)
            end]]
        end

        GameTooltipStatusBar:SetStatusBarColor(0, .9, 0)
    end

    --[[if GameTooltipStatusBar:IsShown() then
        self:AddLine(" ")
        GameTooltipStatusBar:ClearAllPoints()
        GameTooltipStatusBar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 10)
        GameTooltipStatusBar:SetPoint("TOPRIGHT", self, 0, 0)
    end]]
end)

GameTooltipStatusBar:SetStatusBarTexture(cfg.tex)
GameTooltipStatusBar:SetHeight(4)
local bg = GameTooltipStatusBar:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(GameTooltipStatusBar)
bg:SetTexture(cfg.tex)
bg:SetVertexColor(0.05, 0.05, 0.05, 0.6)

local SBG = CreateFrame("Frame", "StatusBarBG", GameTooltipStatusBar)
SBG:SetFrameLevel(GameTooltipStatusBar:GetFrameLevel() - 1)
SBG:SetPoint("TOPLEFT", -3, 3)
SBG:SetPoint("BOTTOMRIGHT", 3, -3)
--SBG:SetBackdrop({edgeFile = mediapath.."glowTex", edgeSize = 3})
--SBG:SetBackdropColor(0,0,0)
--SBG:SetBackdropBorderColor(0,0,0)

local numberize = function(val)
		if (val >= 1e8) then
			return ("%.2f億"):format(val / 1e8)
		elseif (val >= 1e4) then
			return ("%.2f萬"):format(val / 1e4)
		else
			return ("%d"):format(val)
		end
end

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
            self.text:SetFont(cfg.font, 12, cfg.flag)
        end
        self.text:Show()
        local hp = numberize(min).." / "..numberize(max)
        self.text:SetText(hp)
    end
end)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
    local frame = GetMouseFocus()
    if cfg.cursor and frame == WorldFrame then
        --tooltip:SetOwner(parent, "ANCHOR_CURSOR")
		tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 40, -135)	--錨點
    --elseif Bags:IsShown() then
		--tooltip:SetOwner(parent, "ANCHOR_NONE")
		--tooltip:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -55, 170)
	--else
        --tooltip:SetOwner(parent, "ANCHOR_NONE")	
        --tooltip:SetPoint(cfg.point[1], UIParent, cfg.point[2], cfg.point[3], cfg.point[4])
    end
    tooltip.default = 1
end)

local function setBakdrop(frame)
    --frame:SetBackdrop(cfg.backdrop)
    frame:SetScale(cfg.scale)

    frame.freebBak = true
end

local function style(frame)
    if not frame.freebBak then
        setBakdrop(frame)
    end

    --frame:SetBackdropColor(cfg.bgcolor.r, cfg.bgcolor.g, cfg.bgcolor.b, cfg.bgcolor.t)
    --frame:SetBackdropBorderColor(cfg.bdrcolor.r, cfg.bdrcolor.g, cfg.bdrcolor.b)
	
	--[[if cfg.colorborderClass then
		if frame.GetItem then
			local _, item = frame:GetItem()
			if item then
				local quality = select(3, GetItemInfo(item))
				if(quality) then
					local r, g, b = GetItemQualityColor(quality)
					frame:SetBackdropBorderColor(r, g, b)
				end
			else
				frame:SetBackdropBorderColor(cfg.bdrcolor.r, cfg.bdrcolor.g, cfg.bdrcolor.b)
			end
		end
		local _, unit = GameTooltip:GetUnit()
		if UnitIsPlayer(unit) then
			frame:SetBackdropBorderColor(GameTooltip_UnitColor(unit))
		end
    end]]

    if frame.NumLines then
        for index=1, frame:NumLines() do
            if index == 1 then
                _G[frame:GetName()..'TextLeft'..index]:SetFont(cfg.font, cfg.fontsize+2, cfg.outline)
            else
                _G[frame:GetName()..'TextLeft'..index]:SetFont(cfg.font, cfg.fontsize, cfg.outline)
            end
            _G[frame:GetName()..'TextRight'..index]:SetFont(cfg.font, cfg.fontsize, cfg.outline)
        end
    end
end

local tooltips = {
	GameTooltip,
	ItemRefTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	ItemRefShoppingTooltip3,
	AutoCompleteBox,
	FriendsTooltip,
	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3,
	ChatMenu,
	EmoteMenu,
	LanguageMenu,
	VoiceMacroMenu,
	DropDownList1MenuBackdrop,
	DropDownList2MenuBackdrop,
	DropDownList3MenuBackdrop,
}

for i, frame in ipairs(tooltips) do
    frame:SetScript("OnShow", function(frame) style(frame) end)
end

-- Pet Battle Tooltips
local ptooltips = {
	PetJournalPrimaryAbilityTooltip,
	PetJournalSecondaryAbilityTooltip,
	BattlePetTooltip,
	PetBattlePrimaryAbilityTooltip,
	PetBattlePrimaryUnitTooltip,
	FloatingBattlePetTooltip,
	FloatingPetBattleAbilityTooltip
}
for _, f in pairs(ptooltips) do
	f:DisableDrawLayer("BACKGROUND")
	local bg = CreateFrame("Frame", nil, f)
	bg:SetAllPoints()
	bg:SetFrameLevel(0)
	style(bg)
end

--[[local itemrefScripts = {
    "OnTooltipSetItem",
    "OnTooltipSetAchievement",
    "OnTooltipSetQuest",
    "OnTooltipSetSpell",
}]]

--[[for i, script in ipairs(itemrefScripts) do
    ItemRefTooltip:HookScript(script, function(self)
        style(self)
    end)
end]]

local f = CreateFrame"Frame"
f:SetScript("OnEvent", function(self, event, ...) if ns[event] then return ns[event](ns, event, ...) end end)
function ns:RegisterEvent(...) for i=1,select("#", ...) do f:RegisterEvent((select(i, ...))) end end
function ns:UnregisterEvent(...) for i=1,select("#", ...) do f:UnregisterEvent((select(i, ...))) end end

ns:RegisterEvent"PLAYER_LOGIN"
function ns:PLAYER_LOGIN()
    for i, frame in ipairs(tooltips) do
        setBakdrop(frame)
    end

    ns:UnregisterEvent"PLAYER_LOGIN"
end

ns.config = cfg