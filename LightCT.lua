-- LightCT by Alza

local fadeTime = 3				-- 文字消失時間
local fontType = STANDARD_TEXT_FONT	-- 字型路徑："Fonts\\xxx.ttf"
local fontSize = 18				-- 承受/輸出框架字型大小
local infoFont = 35				-- 資訊框架字型大小

local enable = true		-- 使用插件
local showAA = false		-- 顯示自動攻擊
local showHD = true	-- 顯示HOT和DOT
local showPET = false	-- 顯示寵物傷害/治療

local hdSize = {100, 250}	-- 承受/輸出框架大小
local ifSize = {300, 150}	-- 資訊框架大小

local infoP = {"BOTTOM", UIParent, "CENTER", 0, 300}	-- 資訊框架位置
local inputDP = {"RIGHT", UIParent, "CENTER", -200, 50}	-- 承受傷害位置
local inputHP = {"RIGHT", UIParent, "CENTER", -150, 50}	-- 承受治療位置
local outputDP = {"LEFT", UIParent, "CENTER", 150, 50}	-- 輸出傷害位置
local outputHP = {"LEFT", UIParent, "CENTER", 200, 50}	-- 輸出治療位置

local frames = {}

local eventFilter = {
	["SWING_DAMAGE"] = {suffix = "DAMAGE", index = 12, iconType = "swing", autoAttack = true},
	["RANGE_DAMAGE"] = {suffix = "DAMAGE", index = 15, iconType = "range"},
	["SPELL_DAMAGE"] = {suffix = "DAMAGE", index = 15, iconType = "spell"},
	["SPELL_PERIODIC_DAMAGE"] = {suffix = "DAMAGE", index = 15, iconType = "spell", isPeriod = true},

	["SPELL_HEAL"] = {suffix = "HEAL", index = 15, iconType = "spell"},
	["SPELL_PERIODIC_HEAL"] = {suffix = "HEAL", index = 15, iconType = "spell", isPeriod = true},

	["SWING_MISSED"] = {suffix = "MISS", index = 12, iconType = "swing"},
	["RANGE_MISSED"] = {suffix = "MISS", index = 15, iconType = "range"},
	["SPELL_MISSED"] = {suffix = "MISS", index = 15, iconType = "spell"},

	["SPELL_DISPEL"] = {suffix = "FAILED", index = 15, iconType = "spell", msg = ACTION_SPELL_DISPEL},
	["SPELL_STOLEN"] = {suffix = "FAILED", index = 15, iconType = "spell", msg = ACTION_SPELL_STOLEN},
	["SPELL_INTERRUPT"] = {suffix = "FAILED", index = 15, iconType = "spell", msg = ACTION_SPELL_INTERRUPT},

	["ENVIRONMENTAL_DAMAGE"] = {suffix = "ENVIRONMENT", index = 12, iconType = "env"},
}

-- Numberize
Numb = function(n)
	if type(n) == "number" then
		if n >= 1e8 then
			return ("%.2f億"):format(n / 1e8)
		elseif n >= 1e4 then
			return ("%.1f萬"):format(n / 1e4)
		else
			return ("%.0f"):format(n)
		end
	else
		return n
	end
end

local envTexture = {
	["Drowning"] = "spell_shadow_demonbreath",
	["Falling"] = "ability_rogue_quickrecovery",
	["Fatigue"] = "ability_creature_cursed_05",
	["Fire"] = "spell_fire_fire",
	["Lava"] = "ability_rhyolith_lavapool",
	["Slime"] = "inv_misc_slime_02",
}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:SetScript("OnEvent", function(self, event)
	if not enable then return end
	self[event](self)
end)

local function GetFloatingIcon(iconType, spellID, isPet)
	local texture, icon

	if iconType == "spell" then
		texture = GetSpellTexture(spellID)
	elseif iconType == "swing" then
		if isPet then
			texture = PET_ATTACK_TEXTURE
		else
			texture = GetSpellTexture(6603)
		end
	elseif iconType == "range" then
		texture = GetSpellTexture(75)
	elseif iconType == "env" then
		texture = "Interface\\Icons\\"..envTexture[spellID]
	end

	if not texture then
		texture = GetSpellTexture(195112)
	end

	icon = "|T"..texture..":"..fontSize..":"..fontSize..":0:-5:64:64:5:59:5:59|t"
	return icon
end

local function CreateCTFrame(name, justify, fontSize, framesize, point)
	local frame = CreateFrame("ScrollingMessageFrame", name, UIParent)

	frame:SetSpacing(3)		--間距
	frame:SetMaxLines(20)
	frame:SetSize(unpack(framesize))
	frame:SetFadeDuration(.5)		--淡入淡出時間
	frame:SetJustifyH(justify)
	frame:SetTimeVisible(fadeTime)
	frame:SetFont(fontType, fontSize, "OUTLINE")
	frame:SetPoint(unpack(point))

	return frame
end

frames["Information"] = CreateCTFrame("Information", "CENTER", infoFont, ifSize, infoP)
frames["InputDamage"] = CreateCTFrame("InputDamage", "LEFT", fontSize, hdSize, inputDP)
frames["InputHealing"] = CreateCTFrame("InputHealing", "LEFT", fontSize, hdSize, inputHP)
frames["OutputDamage"] = CreateCTFrame("OutputDamage", "RIGHT", fontSize, hdSize, outputDP)
frames["OutputHealing"] = CreateCTFrame("OutputHealing", "RIGHT", fontSize, hdSize, outputHP)

function eventFrame:PLAYER_LOGIN()
	SetCVar("enableFloatingCombatText", 0)
	SetCVar("floatingCombatTextCombatDamage", 1)
	SetCVar("floatingCombatTextCombatHealing", 0)
end

function eventFrame:PLAYER_REGEN_DISABLED()
	frames["Information"]:AddMessage("> "..ENTERING_COMBAT.." <", 1, 0, 0)
end

function eventFrame:PLAYER_REGEN_ENABLED()
	frames["Information"]:AddMessage("> "..LEAVING_COMBAT.." <", 0, 1, 0)
end

function eventFrame:COMBAT_LOG_EVENT_UNFILTERED()
	local icon, text, color, failedColor, inputD, inputH, outputD, outputH, outputIF
	local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName, school = CombatLogGetCurrentEventInfo()

	local noPlayer = UnitGUID("player") ~= sourceGUID

	local isPlayer = UnitGUID("player") == sourceGUID
	local isVehicle = UnitGUID("vehicle") == sourceGUID
	local isPet = UnitGUID("pet") == sourceGUID and showPET

	local atPlayer = UnitGUID("player") == destGUID
	local atTarget = UnitGUID("target") == destGUID

	if ((isPlayer or isVehicle or isPet or noPlayer) and atTarget) or atPlayer then
		local value = eventFilter[eventType]
		if value then
			if value.suffix == "DAMAGE" then
				local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(value.index, CombatLogGetCurrentEventInfo())
				if value.autoAttack and not showAA then return end
				if value.isPeriod and not showHD then return end
				if atTarget and (isPlayer or isVehicle or isPet) then
					text = Numb(amount)
					outputD = true		-- 輸出傷害顯示
				elseif atPlayer then
					text = "-"..Numb(amount)
					inputD = true		-- 承受傷害顯示
				end
				if text and (critical or crushing) then
					text = "*"..text
				end
			elseif value.suffix == "HEAL" then
				local amount, overhealing, absorbed, critical = select(value.index, CombatLogGetCurrentEventInfo())
				if value.isPeriod and not showHD then return end
				if atTarget and (isPlayer or isVehicle or isPet) then
					text = Numb(amount)
					outputH = true		-- 輸出治療顯示
				elseif atPlayer then
					text = "+"..Numb(amount)
					inputH = true		-- 承受治療顯示
				end
				if text and critical then
					text = "*"..text
				end
			elseif value.suffix == "MISS" then
				local missType, isOffHand, amountMissed = select(value.index, CombatLogGetCurrentEventInfo())
				text = _G["COMBAT_TEXT_"..missType]
				if atTarget and (isPlayer or isVehicle or isPet) then
					outputD = true		-- 輸出傷害MISS（招架、格擋、未命中等）顯示
				elseif atPlayer then
					inputD = true		-- 承受傷害MISS（招架、格擋、未命中等）顯示
				end
			--elseif value.suffix == "FAILED" then
			elseif value.suffix == "DISPEL_FAILED" then
				local extraSpellID, extraSpellName, extraSchool = select(value.index, CombatLogGetCurrentEventInfo())
				local intName = GetSpellInfo(extraSpellID)
				failedColor = _G.CombatLog_Color_ColorArrayBySchool(extraSchool) or {r = 1, g = 1, b = 1}
				if atTarget then
					if isPlayer or isVehicle or isPet then
						text = value.msg.." > "..intName
						outputIF = true		-- 自己的打斷提示
					elseif sourceName then
						text = sourceName..value.msg.." > "..intName
						outputIF = true		-- 他人的打斷提示
					end
				end
			elseif value.suffix == "ENVIRONMENTAL" then
				local envType, amount, overkill, school = select(value.index, CombatLogGetCurrentEventInfo())
				text = "-"..Numb(amount)
				if atPlayer then
					inputD = true			-- 環境傷害
				end
			end

			color = _G.CombatLog_Color_ColorArrayBySchool(school) or {r = .5, g = .5, b = .5}
			icon = GetFloatingIcon(value.iconType, spellID, isPet)
		end

		if text and icon then
			if outputD then
				frames["OutputDamage"]:AddMessage(text..icon, color.r, color.g, color.b)
			elseif outputH then
				frames["OutputHealing"]:AddMessage(text..icon, color.r, color.g, color.b)
			elseif inputD then
				frames["InputDamage"]:AddMessage(icon..text, color.r, color.g, color.b)
			elseif inputH then
				frames["InputHealing"]:AddMessage(icon..text, color.r, color.g, color.b)
			elseif outputIF then
				frames["Information"]:AddMessage(text, failedColor.r, failedColor.g, failedColor.b)
			end
		end
	end
end
