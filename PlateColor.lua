--PlateColor	血條字體描邊+職業著色
local instanceType
local restricted = {
	party = true,
	raid = true,
}

local f = CreateFrame("Frame")
function f:OnEvent(event, ...)
	if IsInInstance() then return end
	if event == "PLAYER_ENTERING_WORLD" then
		instanceType = select(2, IsInInstance())
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		C_Timer.After(4, function() instanceType = select(2, IsInInstance()) end)
	elseif event == "ADDON_LOADED" then
		if ... == "EzMyUI" then
			-- need to be able to toggle bars, dirty hack because lazy af at the moment
			C_Timer.After(1, function()
				if GetCVar("nameplateShowOnlyNames") == "1" then
					SetCVar("nameplateShowOnlyNames", 0)
					if not InCombatLockdown() then
						NamePlateDriverFrame:UpdateNamePlateOptions()            -- taints
					end
				end
			end)
			self:SetupNameplates()
			self:UnregisterEvent(event)
		end
	end
end

local function colorize(color, text)
	return ("%s%s|r"):format(ConvertRGBtoColorString(color), text)
end

local CompactUnitFrame = CreateFrame("Frame")
hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
	if IsInInstance() then return end
	if frame:IsForbidden() then return end

	if ShouldShowName(frame) then
		if frame.optionTable.colorNameBySelection then
			local name = GetUnitName(frame.unit)
			local isFriend = UnitIsFriend("player", frame.unit)
			if UnitIsPlayer(frame.unit) then
				local _, class = UnitClass(frame.unit)
				local color = RAID_CLASS_COLORS[class]
				if not CompactUnitFrame_IsTapDenied(frame) and isFriend and class then
					name = colorize(color, name)
				end
			end
			local level = UnitLevel(frame.unit)
			if level and level >= 1 then
				local lcolor = not isFriend and GetCreatureDifficultyColor(level) or NORMAL_FONT_COLOR
				name = colorize(lcolor, level) .. " " .. name
			end
			frame.name:SetText(name)
		end
	end
end)