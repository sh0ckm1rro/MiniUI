--好友列表染色顯示伺服器
hooksecurefunc("FriendsFrame_UpdateFriendButton", function(friendbutton)
if not friendbutton.id then return end
if friendbutton.buttonType == 3 then return end
if not C_BattleNet.GetFriendAccountInfo(friendbutton.id) then return end
local areaName = C_BattleNet.GetFriendAccountInfo(friendbutton.id).gameAccountInfo.areaName	--區域名
local realmDisplayName = C_BattleNet.GetFriendAccountInfo(friendbutton.id).gameAccountInfo.realmDisplayName	--伺服器
local characterName = C_BattleNet.GetFriendAccountInfo(friendbutton.id).gameAccountInfo.characterName --角色名
local bnname = Ambiguate(C_BattleNet.GetFriendAccountInfo(friendbutton.id).battleTag,"short")	--戰網名
local className = C_BattleNet.GetFriendAccountInfo(friendbutton.id).gameAccountInfo.className	--職業名
--local factionName = C_BattleNet.GetFriendAccountInfo(friendbutton.id).gameAccountInfo.factionName--陣營
local level = C_BattleNet.GetFriendAccountInfo(friendbutton.id).gameAccountInfo.characterLevel
local class

if realmDisplayName and areaName then
friendbutton.info:SetText(areaName.."-"..realmDisplayName)--"|cffCDB7B5".."|r"..
end

if characterName and className and level then
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	if v == className then
		class =RAID_CLASS_COLORS[k].colorStr
	end
end
friendbutton.name:SetText(bnname.."|c"..class.." (等級"..level.." "..characterName..")".."|r")
end

end)