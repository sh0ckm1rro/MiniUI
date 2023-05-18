local function defaultcvar()
--玩家名條染色
SetCVar("ShowClassColorInFriendlyNameplate", 1)
SetCVar("ShowClassColorInNameplate", 1)
C_NamePlate.SetNamePlateSelfClickThrough(true)			--禁點自身資源條
SetCVar("alwaysCompareItems", 1)						--自動裝備對比	1:開	0:關
SetCVar("displayFreeBagSlots", 1)						--背包空間	1:開	0:關
SetCVar("cameraDistanceMaxZoomFactor", 2.6)				--最大視角
SetCVar("mapFade", 0)		--移動時大地圖透明	1:開	0:關
SetCVar("autoQuestWatch", 1)							--任務
SetCVar("showQuestTrackingTooltips", 1)					--任務進度游標提示
--SetCVar("floatingCombatTextCombatDamageDirectionalScale", 2)		--傷害數字顯示在血條上方,改數字0123456789
SetCVar("cameraSmoothTrackingStyle", 0)				--引導技能不轉視角
SetCVar("statusText", 1)		--顯示狀態數值	0：只在滑鼠移到上方時顯示	1：永遠顯示 (註：7.0開始載具藍量不能顯示，是遊戲的問題)
--SetCVar("nameplateOtherAtBase", 1)						--血條位置，預設0頭上，1頭上但離怪近，2腳下
SetCVar("xpBarText", 1) 								--經驗條數值顯示	1:開	0:關
SetCVar("nameplateOverlapH", 0.3)	--名條堆疊水平百分比，預設0.8
SetCVar("nameplateOverlapV", 0.5)	--名條堆疊垂直百分比，預設1.1
SetCVar("nameplateShowFriendlyNPCs", 0)		--關閉友方NPC名條
--SetCVar("noBuffDebuffFilterOnTarget", 1)	--顯示目標所有DEBUFF	1:開	0:關
SetCVar("threatShowNumeric", 1)		--目標頭像上的仇恨百分比	1:開	0:關
end 
local frame = CreateFrame("FRAME", "defaultcvar") 
   frame:RegisterEvent("PLAYER_ENTERING_WORLD") 
local function eventHandler(self, event, ...) 
         defaultcvar() 
end 
frame:SetScript("OnEvent", eventHandler)

BossBanner:SetScale(0.8)		--縮小BOSS掉落物


--過圖前滑鼠指向聲望條，過圖後會報錯修正，由NGA大佬oyg123提供解決辦法。
_ReputationParagonFrame_SetupParagonTooltip = ReputationParagonFrame_SetupParagonTooltip;
ReputationParagonFrame_SetupParagonTooltip=function(frame)
   local currentValue, threshold = C_Reputation.GetFactionParagonInfo(frame.factionID);
   if currentValue~=nil and threshold~=nil then
        _ReputationParagonFrame_SetupParagonTooltip(frame)
   end
end