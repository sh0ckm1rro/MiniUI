local altclickinvite		= true	--Alt鍵點擊邀請
local fontoutline		= true	--字體輪廓
local hidechatcopy		= true	--true:開啟複製聊天


--防超出螢幕
BNToastFrame:SetClampedToScreen(true)

--[[Sticky Channels, 0 off, 1 on 聊天頻道鎖定]]
ChatTypeInfo.WHISPER.sticky = 0
ChatTypeInfo.BN_WHISPER.sticky = 0


--[[ Font outline 字體輪廓 ]]
if fontoutline then 
	for i = 1, 10 do
		local cF = _G[format("%s%d", "ChatFrame", i)]
		local font, size = cF:GetFont()
		cF:SetFont(font, size, "OUTLINE")
	end
end


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


-- PawsTooltips 聊天框顯示物品資訊
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

--顯示圖示
local TypeIcons = {
	['spell'] = function(id) return select(3, GetSpellInfo(id)) end,
	['item'] = GetItemIcon,
	['achievement'] = function(id) return select(10, GetAchievementInfo(id)) end,
}

local _icon_link = ' |T%s:12:12:0:0|t%s'
local function iconify(link)
	local type, id = link:match('|H(%w+):(%w+)')
	local icon = TypeIcons[type] and TypeIcons[type](id)
	return icon and _icon_link:format(icon, link) or link
end
