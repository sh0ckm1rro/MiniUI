----------------------------------------------
-- 聊天超鏈接增加物品等級 (支持大祕境鑰匙等級)
-- @Author:M
----------------------------------------------

local Caches = {}

local function ChatItemLevel(Hyperlink)
    if (Caches[Hyperlink]) then
        return Caches[Hyperlink]
    end
    local link = string.match(Hyperlink, "|H(.-)|h")
    local name, _, _, _, _, class, subclass, _, equipSlot = GetItemInfo(link)
    local level = GetDetailedItemLevelInfo(link)
    local yes = true
    if (level) then
        if (equipSlot and string.find(equipSlot, "INVTYPE_")) then
            level = format("%s(%s)", level, _G[equipSlot] or equipSlot)
        elseif (class == ARMOR) then
            level = format("%s(%s)", level, class)
        elseif (subclass and string.find(subclass, RELICSLOT)) then
            level = format("%s(%s)", level, RELICSLOT)
        else
            yes = false
        end
        if (yes) then
            local gem = ""
            if (gem ~= "") then gem = gem.." " end
            Hyperlink = Hyperlink:gsub("|h%[(.-)%]|h", "|h["..level..":"..name.."]|h"..gem)
        end
        Caches[Hyperlink] = Hyperlink
    end
    return Hyperlink
end

local function filter(self, event, msg, ...)
    if not IsAddOnLoaded("TinyInspect") then
        msg = msg:gsub("(|Hitem:%d+:.-|h.-|h)", ChatItemLevel)
    end
    return false, msg, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
-- 解析戰網私聊
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", filter)
-- 副本和副本領袖
    ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", filter)
-- 解析社區聊天內容
    ChatFrame_AddMessageEventFilter("CHAT_MSG_COMMUNITIES_CHANNEL", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", filter)
