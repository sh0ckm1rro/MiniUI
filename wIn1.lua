--[[自動清記憶體
local eventcount = 0
local a = CreateFrame("Frame")
a:RegisterAllEvents()
a:SetScript("OnEvent", function(self, event)
   eventcount = eventcount + 1
   if InCombatLockdown() then return end
   if eventcount > 6000 or event == "PLAYER_ENTERING_WORLD" then
      --collectgarbage("collect")
	  collectgarbage()
      eventcount = 0
   end
end)
--脫戰清記憶體
local F = CreateFrame("Frame")
   F:RegisterEvent("PLAYER_ENTERING_WORLD")
   F:RegisterEvent("PLAYER_REGEN_ENABLED")
   F:SetScript("OnEvent", function() _G.collectgarbage("collect") end)]]


--Interrupt 斷法提示
local Interrupt = CreateFrame("frame")
Interrupt:SetScript("OnEvent",function(self, event, ...)

local EventType, SourceName, DestName, SpellID, ExtraskillID = select(2, ...), select(5, ...), select(9, ...), select(12, ...), select(15, ...)
local icon = GetSpellTexture(SpellID)
local ExtraskillID = GetSpellLink(ExtraskillID)

	if EventType=="SPELL_INTERRUPT" then
	if SourceName==UnitName("player") then
		m = GetSpellLink(SpellID).."打斷 ["..DestName.."] 的"..ExtraskillID
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance() then
			SendChatMessage(m, "INSTANCE_CHAT")
		elseif IsInRaid() then
			SendChatMessage(m, "RAID")
		elseif GetNumSubgroupMembers() ~= nil and GetNumSubgroupMembers() > 0 then
			SendChatMessage(m, "PARTY")
		end
	end
	RaidNotice_AddMessage(RaidWarningFrame,"|cffFFFF00"..SourceName.."|r"..ACTION_SPELL_INTERRUPT.."".."|cffFF1111"..DestName.."|r的".."\124T"..icon..":17:17:0:0:64:64:5:59:5:59\124t\124cff71d5ff\124Hspell:"..SpellID.."\124h"..ExtraskillID.."\124h\124r!",{g=1,b=1})
	end
end)
Interrupt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")


-- 修復打開公會報錯
GuildControlUIRankSettingsFrameRosterLabel = CreateFrame("Frame")
GuildControlUIRankSettingsFrameRosterLabel:Hide()


--删除自動填Delete
hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(boxEditor)
	boxEditor.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
end)



----------------------------------------------------------------------------------------
--	Universal Mount macro(by Monolit)
--	/run Mountz("your_ground_mount","your_flying_mount","your_underwater_mount")
----------------------------------------------------------------------------------------
function Mountz(groundmount, flyingmount, underwatermount)
	local flyablex, swimablex, vjswim, InVj, nofly
	local num = C_MountJournal.GetNumMounts()
	if not num or IsMounted() then
		Dismount()
		return
	end
	if CanExitVehicle() then
		VehicleExit()
		return
	end
	if IsUsableSpell(59569) == nil then
		nofly = true
	end
	if not nofly and (IsFlyableArea() and GetCurrentMapContinent() ~= 7) then
		flyablex = true
	end
	for i = 1, 40 do
		local sid = select(11, UnitBuff("player", i))
		if sid == 73701 or sid == 76377 then
			InVj = true
		end
	end
	if InVj and IsSwimming() then
		vjswim = true
	end
	if IsSwimming() and (nofly or GetCurrentMapContinent() == 7) and not vjswim then
		swimablex = true
	end
	if IsControlKeyDown() then
		if not vjswim then
			flyablex = not flyablex
		else
			vjswim = not vjswim
		end
	end
	for i = 1, num, 1 do
		local info, id = C_MountJournal.GetMountInfo(i)
		if flyingmount and info == flyingmount and flyablex and not swimablex then
			C_MountJournal.Summon(i)
			return
		elseif groundmount and info == groundmount and not flyablex and not swimablex and not vjswim then
			C_MountJournal.Summon(i)
			return
		elseif underwatermount and info == underwatermount and swimablex then
			C_MountJournal.Summon(i)
			return
		elseif id == 75207 and vjswim then
			C_MountJournal.Summon(i)
			return
		end
	end
end

--[重載命令] 
SlashCmdList["RELOADUI"] = function() ReloadUI() end 
SLASH_RELOADUI1 = "/rl"

--[[ Slash commands 命令 ]]
print("|cff3399ffMini|rUI 已加載，重載請打/rl")

