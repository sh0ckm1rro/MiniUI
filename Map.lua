--[[副本內收任務追蹤
local autocollapse = CreateFrame("Frame")
autocollapse:RegisterEvent("ZONE_CHANGED_NEW_AREA")
autocollapse:RegisterEvent("PLAYER_ENTERING_WORLD")
autocollapse:SetScript("OnEvent", function(self)
	if IsInInstance() then
		ObjectiveTrackerFrame.collapsed = true
		ObjectiveTracker_Collapse()
	else
		ObjectiveTrackerFrame.collapsed = nil
		ObjectiveTracker_Expand()
	end
end)]]


--小地圖坐標
Minimap.coords = Minimap:CreateFontString(nil, 'ARTWORK') 
--Minimap.coords:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 1, -2);
Minimap.coords:SetPoint("TOP", Minimap, "TOP", 0, -10);
Minimap.coords:SetTextColor(1, 0.82, 0.1, 1);
Minimap.coords:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
Minimap.coords:SetJustifyH("LEFT");
Minimap:HookScript("OnUpdate", function(self, elapsed) 
    self.elapsed = (self.elapsed or 0) + elapsed
    if (self.elapsed < 0.2) then return end
    self.elapsed = 0
    local position = C_Map.GetPlayerMapPosition(MapUtil.GetDisplayableMapForPlayer(), "player")
    if (position) then
        self.coords:SetText(format("%.1f , %.1f", position.x*100, position.y*100))
    else
        self.coords:SetText("")
    end
end)


--[[大地圖坐標
WorldMapFrame.playerPos = WorldMapFrame.BorderFrame.TitleContainer:CreateFontString(nil, 'ARTWORK') 
WorldMapFrame.playerPos:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE") 
WorldMapFrame.playerPos:SetJustifyH("LEFT") 
WorldMapFrame.playerPos:SetPoint('LEFT', WorldMapFrameCloseButton, 'LEFT', -180, 0) ----WorldMapFrame.playerPos:SetPoint("BOTTOMRIGHT", WorldMapFrame.BorderFrame, "BOTTOM", -100, 22)
WorldMapFrame.playerPos:SetTextColor(1, 0.82, 0.1) 
WorldMapFrame.mousePos = WorldMapFrame.BorderFrame.TitleContainer:CreateFontString(nil, "ARTWORK") 
WorldMapFrame.mousePos:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE") 
WorldMapFrame.mousePos:SetJustifyH("LEFT") 
WorldMapFrame.mousePos:SetPoint('LEFT', WorldMapFrame.playerPos, 'LEFT', -160, 0) ----WorldMapFrame.mousePos:SetPoint("BOTTOMLEFT", WorldMapFrame.BorderFrame, "BOTTOM", -60, 22)
WorldMapFrame.mousePos:SetTextColor(1, 0.82, 0.1) 
WorldMapFrame:HookScript("OnUpdate", function(self, elapsed) 
    self.elapsed = (self.elapsed or 0) + elapsed
    if (self.elapsed < 0.2) then return end
    self.elapsed = 0
    --玩家坐標
    local position = C_Map.GetPlayerMapPosition(MapUtil.GetDisplayableMapForPlayer(), "player")
    if (position) then
        self.playerPos:SetText(format("玩家: %.1f , %.1f", position.x*100, position.y*100))
    else
        self.playerPos:SetText("")
    end
    --滑鼠坐標
    local mapInfo = C_Map.GetMapInfo(self:GetMapID())
    if (mapInfo and mapInfo.mapType == 3) then
        local x, y = self.ScrollContainer:GetNormalizedCursorPosition()
        if (x and y and x > 0 and x < 1 and y > 0 and y < 1) then
            self.mousePos:SetText(format("滑鼠: %.1f , %.1f", x*100, y*100))
        else
            self.mousePos:SetText("")
        end
    else
        self.mousePos:SetText("")
    end
end)]]


--WhoIsSpamming 誰點小地圖
local addon = CreateFrame('ScrollingMessageFrame', false, Minimap)
addon:SetSize(100,30)
addon:SetPoint('BOTTOM', Minimap, 0, 10)

addon:SetFont(STANDARD_TEXT_FONT, 15, 'OUTLINE')
addon:SetMaxLines(1)
addon:SetFading(true)
addon:SetFadeDuration(3)
addon:SetTimeVisible(5)

addon:RegisterEvent'MINIMAP_PING'
addon:SetScript('OnEvent', function(self, event, u)
local c = RAID_CLASS_COLORS[select(2,UnitClass(u))]
local name = UnitName(u)
addon:AddMessage(name, c.r, c.g, c.b)
end)


-- Performance
if not IsAddOnLoaded("Blizzard_TimeManager") then LoadAddOn("Blizzard_TimeManager") end

local function getNetColor()
	local _, _, lagHome, lagWorld = GetNetStats()
	local lag = lagHome > lagWorld and lagHome or lagWorld
	local r, g, b
	if lag > 600 then
		r = 1; g = 0; b = 0;
	elseif lag > 300 then
		r = 1; g = 1; b = 0;
	else
		r = 0; g = 1; b = 0;
	end
	return r, g, b, lag
end

hooksecurefunc("TimeManagerClockButton_Update", function()
	local r, g, b = getNetColor()
	TimeManagerClockTicker:SetVertexColor(r, g, b)
end)

local function formats(value)
	if value > 999 then
		return format("|cffffff00%.2f MB|r", value/1024)
	else
		return format("|cff00ff00%.1f KB|r", value)
	end
end

TimeManagerClockButton:SetScript("OnClick", function(self, button)
	if self.alarmFiring then
		PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
		TimeManager_TurnOffAlarm()
	else
		if button == "LeftButton" then
			UpdateAddOnMemoryUsage()
			local before = gcinfo()
			collectgarbage("collect")
			UpdateAddOnMemoryUsage()
			local after = gcinfo()
			DEFAULT_CHAT_FRAME:AddMessage("記憶體已回收: "..formats(before-after), 0, 0.6, 1)
		else
			TimeManager_Toggle()
		end
	end
end)


local maxShown = 30
local numAddons = min(GetNumAddOns(), maxShown)
local addons = {}
for i = 1, numAddons do	addons[i] = {value = 0, name = ""} end

local iTimer_Start = GetTime()

function TimeManagerClockButton_UpdateTooltip()
	local iTimer_Now = GetTime()
	local iTimer_Past = iTimer_Now - iTimer_Start
	if iTimer_Past >= 0.5 then
		GameTooltip:ClearLines()
		if TimeManagerClockButton.alarmFiring then
			if ( gsub(Settings.alarmMessage, "%s", "") ~= "" ) then
				GameTooltip:AddLine(Settings.alarmMessage, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1)
			end
			GameTooltip:AddLine(TIMEMANAGER_ALARM_TOOLTIP_TURN_OFF)
		else
			GameTime_UpdateTooltip()
			GameTooltip:AddLine("右鍵"..GAMETIME_TOOLTIP_TOGGLE_CLOCK)
			GameTooltip:AddLine("左鍵點擊這裡回收記憶體。")
		end
		GameTooltip:AddLine(" ")

		local r, g, b, lag = getNetColor()
		GameTooltip:AddLine("----------------- 性能 -----------------")
		GameTooltip:AddDoubleLine("延遲：", format("%d ms", lag), 1, 0.82, 0, r, g, b)
		GameTooltip:AddDoubleLine("幀數：", format("%.0f fps", GetFramerate()))

		for i = 1, numAddons do
			if not addons[i] then
				addons[i] = { value = 0, name = "" }
			end
			addons[i].value = 0
		end
		UpdateAddOnMemoryUsage()

		local totalMem = 0
		for i = 1, GetNumAddOns() do
			local mem = GetAddOnMemoryUsage(i)
			totalMem = totalMem + mem
			for j = 1, numAddons do
				if mem > addons[j].value then
					for k = numAddons, 1, -1 do
						if k == j then
							addons[k].value = mem
							addons[k].name = GetAddOnInfo(i)
							break
						elseif k ~= 1 then
							addons[k].value = addons[k-1].value
							addons[k].name = addons[k-1].name
						end
					end
					break
				end
			end
		end
		if totalMem > 0 then
			GameTooltip:AddDoubleLine("插件記憶體：", formats(totalMem))
			for i = 1, numAddons do
				if addons[i].value == 0 then break end
				GameTooltip:AddDoubleLine(addons[i].name, formats(addons[i].value))
			end
		end
		GameTooltip:Show()
		iTimer_Start = iTimer_Now
	end
end