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
--脫戰清記憶體(適合副本用)
local F = CreateFrame("Frame")
   --F:RegisterEvent("PLAYER_ENTERING_WORLD")
   F:RegisterEvent("PLAYER_REGEN_ENABLED")
   F:SetScript("OnEvent", function() _G.collectgarbage("collect") end)
]]


--EventBossAutoSelect 自動選擇節慶地城
LFDParentFrame:HookScript("OnShow",function()
for i=1,GetNumRandomDungeons() do
local id,name=GetLFGRandomDungeonInfo(i)
local isHoliday=select(15,GetLFGDungeonInfo(id))
if(isHoliday and not GetLFGDungeonRewards(id)) then LFDQueueFrame_SetType(id) end
end
end)


--删除自動填Delete
hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(boxEditor)
	boxEditor.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
end)


--[[抵達鳥點時發出提示音
TAXI_ON=false;local f=CreateFrame("Frame")f:SetScript("OnUpdate",function()
if UnitOnTaxi("player") then
TAXI_ON = true
elseif TAXI_ON then TAXI_ON = false
PlaySound(5495)
end
end)]]


--[重載命令]
SlashCmdList["RELOADUI"] = function() ReloadUI() end
SLASH_RELOADUI1 = "/rl"

--[[ Slash commands 命令 ]]
print("|cFF0055FF[工具]|r |cff3399ffMini|rUI 已加載，重載畫面請輸入/rl")
