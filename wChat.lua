local altclickinvite		= true	--Alt鍵點擊邀請
local fontoutline		= true	--字體輪廓
local hidechatcopy		= true	--true:開啟複製聊天


--防超出螢幕
BNToastFrame:SetClampedToScreen(true)

--[[Sticky Channels, 0 off, 1 on 聊天頻道鎖定]]
ChatTypeInfo.WHISPER.sticky = 0
ChatTypeInfo.BN_WHISPER.sticky = 0


--Whisper
  CHAT_WHISPER_INFORM_GET = " 回 %s : "
  CHAT_WHISPER_GET = " %s 說 : "
  CHAT_BN_WHISPER_INFORM_GET = " 回 %s : "
  CHAT_BN_WHISPER_GET = " %s 說 : "
--專業 [附魔+102]
ERR_SKILL_UP_SI = "%s |cff1eff00+ %d|r"
--拾取
LOOT_ITEM = "%s + %s"
LOOT_ITEM_MULTIPLE = "%s + %s x%d"
LOOT_ITEM_SELF = "+ %s"	--拾取
LOOT_ITEM_SELF_MULTIPLE = "+ %s x%d"
LOOT_ITEM_PUSHED_SELF = "+ %s"	--獲得
LOOT_ITEM_PUSHED_SELF_MULTIPLE = "+ %s x%d"
LOOT_MONEY = "|cff00a956+|r |cffffffff%s"
YOU_LOOT_MONEY = "|cff00a956+|r |cffffffff%s"
LOOT_MONEY_SPLIT = "|cff00a956+|r |cffffffff%s"
LOOT_ITEM_CREATED_SELF = "|cff1eff00製造|r + %s"
LOOT_ITEM_CREATED_SELF_MULTIPLE = "|cff1eff00製造|r + %s x%d"
ITEM_SOCKET_BONUS = "|cff1eff00獎勵|r + %s"
--提示AH賣出
ERR_AUCTION_SOLD_S = "|cff1eff00%s|r |cffffffff賣出|r"


--[[ Font outline 字體輪廓 ]]
if fontoutline then
	for i = 1, 10 do
		local cF = _G[format("%s%d", "ChatFrame", i)]
		local font, size = cF:GetFont()
		cF:SetFont(font, size, "OUTLINE")
	end
end
CHAT_FONT_HEIGHTS = {15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30}

--[[Scrolldown Shift+滾輪上/下:置頂/底]]
FloatingChatFrame_OnMouseScroll = function(self, dir)
  if(dir > 0) then
    if(IsShiftKeyDown()) then self:ScrollToTop()
    else
      self:ScrollUp() end
  else
    if(IsShiftKeyDown()) then self:ScrollToBottom()
    else
      self:ScrollDown() end
  end
end

--[[Misc functions 雜項功能（框架大小/移動，方向鍵，編輯框頂端）]]
	SetCVar("chatStyle", "classic")
	for i = 1, 10 do
		local eb =  _G[format("%s%d%s", "ChatFrame", i, "EditBox")]
		local cfs = _G[format("%s%d", "ChatFrame", i)]
			--允許聊天框移動到螢幕上
		cfs:SetClampRectInsets(0,0,0,0)
		eb:SetAltArrowKeyMode(false)
end


--URL Copy 複製網址
if hideurl then
local color = "ffffff"
local pattern = "[wWhH][wWtT][wWtT][\46pP]%S+[^%p%s]"

function string.color(text, color)
	return "|cff"..color..text.."|r"
end

function string.link(text, type, value, color)
	return "|H"..type..":"..tostring(value).."|h"..tostring(text):color(color or "ffffff").."|h"
end

StaticPopupDialogs["LINKME"] = {
	text = "URL COPY",
	button2 = CANCEL,
	hasEditBox = true,
	editBoxWidth = 400,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	whileDead = 1,
	maxLetters = 255,
}

local function f(url)
	return string.link("["..url.."]", "url", url, color)
end

local function hook(self, text, ...)
	self:f(text:gsub(pattern, f), ...)
end

for i = 1, NUM_CHAT_WINDOWS do
	if ( i ~= 2 ) then
		local lframe = _G["ChatFrame"..i]
		lframe.f = lframe.AddMessage
		lframe.AddMessage = hook
	end
end

local ur = ChatFrame_OnHyperlinkShow
function ChatFrame_OnHyperlinkShow(self, link, text, button)
	local type, value = link:match("(%a+):(.+)")
	if ( type == "url" ) then
		local dialog = StaticPopup_Show("LINKME")
		local editbox1 = _G[dialog:GetName().."EditBox"]
		editbox1:SetText(value)
		editbox1:SetFocus()
		editbox1:HighlightText()
		local button = _G[dialog:GetName().."Button2"]

		button:ClearAllPoints()

		button:SetPoint("CENTER", editbox1, "CENTER", 0, -30)
	else
		ur(self, link, text, button)
	end
    end
end


--[[ Chat copy 聊天複製 ]]
if hidechatcopy then
local frame = CreateFrame('Frame', nil, UIParent, "BackdropTemplate")
frame:SetFrameStrata('DIALOG')
frame:SetPoint('LEFT', 3, 10)
frame:SetHeight(400)
frame:SetWidth(500)
frame:Hide()

frame:SetBackdrop({
	bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
	edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
	edgeSize = 16, tileSize = 16, tile = true,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
})
frame:SetBackdropColor(0, 0, 0, 1)

local scrollArea = CreateFrame('ScrollFrame', "wChatScrollFrame", frame, 'UIPanelScrollFrameTemplate')
scrollArea:SetPoint('TOPLEFT', 13, -30)
scrollArea:SetPoint('BOTTOMRIGHT', -30, 13)

local editBox = CreateFrame('EditBox', nil, frame)
editBox:SetMultiLine(true)
editBox:SetMaxLetters(20000)
editBox:EnableMouse(true)
editBox:SetAutoFocus(true)
editBox:SetFontObject(ChatFontNormal)
editBox:SetWidth(450)
editBox:SetHeight(270)
editBox:SetScript('OnEscapePressed', function() frame:Hide() end)

scrollArea:SetScrollChild(editBox)

local close = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
close:SetPoint('TOPRIGHT', 0, -1)

local CopyChat = function(self, chatTab)
	local chatFrame = _G['ChatFrame' .. chatTab:GetID()]
	local numMessages = chatFrame:GetNumMessages()
	if numMessages >= 1 then
		local GetMessageInfo = chatFrame.GetMessageInfo
		local text = GetMessageInfo(chatFrame, 1)
		for index = 2, numMessages do
			text = text .. "\n" .. GetMessageInfo(chatFrame, index)
		end
		frame:Show()
		editBox:SetText(text)
	end
end

hooksecurefunc('FCF_Tab_OnClick', function(self)
	local info = UIDropDownMenu_CreateInfo()
	info.text = "複製聊天"
	info.notCheckable = true
	info.func = CopyChat
	info.arg1 = self
	UIDropDownMenu_AddButton(info)
end)
end


--Alt click invite Alt鍵點擊邀請
if altclickinvite then
           local origSetItemRef = SetItemRef
                 SetItemRef = function(link, text, button)
           local linkType = string.sub(link, 1, 6)
         if IsAltKeyDown() and linkType == "player" then
           local aname = string.match(link, "player:([^:]+)")
                 C_PartyInfo.InviteUnit(aname)
                 return nil
              end
         return origSetItemRef(link,text,button)
     end
end


--TabCHANNEL 切換聊天
function ChatEdit_CustomTabPressed(self)
	if strsub(tostring(self:GetText()), 1, 1) == '/' then return end
	local chatType = self:GetAttribute('chatType')
	local inParty = GetNumSubgroupMembers() > 0
	local inInstance = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance()
	local inRaid = GetNumGroupMembers() > 0 and IsInRaid()
	local inGuild = IsInGuild()
	local setType
	if chatType == 'SAY' then
		setType = inParty and 'PARTY' or inInstance and 'INSTANCE_CHAT' or inRaid and 'RAID' or inGuild and 'GUILD'
	elseif chatType == 'PARTY' then
		setType = inInstance and 'INSTANCE_CHAT' or inRaid and 'RAID' or inGuild and 'GUILD' or 'SAY'
	elseif chatType == 'INSTANCE_CHAT' then
		setType = inGuild and 'GUILD' or 'SAY'
	elseif chatType == 'RAID' then
		setType = inGuild and 'GUILD' or 'SAY'
	elseif chatType == 'GUILD' then
		setType = 'SAY'
	elseif chatType == 'CHANNEL' then
		setType = inParty and 'PARTY' or inInstance and 'INSTANCE_CHAT' or inRaid and 'RAID' or inGuild and 'GUILD' or 'SAY'
	end
	if setType then
		self:SetAttribute('chatType', setType)
		ChatEdit_UpdateHeader(self)
	else
		return
	end
end


--ROLL
local roll = CreateFrame("Button", "rollMacro", UIParent, "SecureActionButtonTemplate")
roll:SetAttribute("*type*", "macro")
roll:SetAttribute("macrotext", "/roll")
--roll:SetWidth(22);roll:SetHeight(22);roll:SetPoint("TOPLEFT",MainMenuBar,"TOPLEFT",100,100)
roll:SetWidth(22);roll:SetHeight(22);roll:SetPoint("TOPLEFT",SELECTED_DOCK_FRAME,"TOPLEFT",-30,-30)
roll:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 6)
	GameTooltip:AddLine("ROLL")
	GameTooltip:Show()
end)
rollText =roll:CreateFontString("ROLLText", "OVERLAY")
rollText:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
rollText:SetJustifyH("CENTER")
rollText:SetWidth(22)
rollText:SetHeight(22)
rollText = roll:CreateTexture()
rollText:SetAllPoints()
rollText:SetTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")


--PawsTooltips 聊天框直接顯示資訊
local function showtooltip(self, linkData)

	local linkType = string.split(":", linkData)
	if linkType == "item"
	or linkType == "spell"
	or linkType == "achievement"
	or linkType == "unit"
	or linkType == "enchant"
	or linkType == "instance"
	or linkType == "raid"
	or linkType == "quest"
	or linkType == "glyph"
	or linkType == "talent" then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(linkData)
	end
end

local function hidetooltip()
	GameTooltip:Hide()
end

local function set0rhookhandler(frame, script, func)
	if frame:GetScript(script) then
	   frame:HookScript(script, func)
	else
		frame:SetScript(script, func)
	end
end

for i = 1, NUM_CHAT_WINDOWS do
	local frame = getglobal("ChatFrame"..i)
	if frame then
		set0rhookhandler(frame, "OnHyperLinkEnter", showtooltip)
		set0rhookhandler(frame, "OnHyperLinkLeave", hidetooltip)
	end
end
