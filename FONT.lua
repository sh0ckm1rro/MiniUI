--TrackerFrame 任務
local cfg = {
font = STANDARD_TEXT_FONT,
}
--local function defaultsetting()
QuestTitleFont:SetFont(cfg.font, 20,"")		--任務名稱
QuestFont:SetFont(cfg.font, 18,"")		--任務敘述
QuestFontNormalSmall:SetFont(cfg.font, 18,"")	--完成目標
--end

--字體大小描邊
local function SetFont(obj, optSize)
local fontName, _,fontFlags  = obj:GetFont()
	obj:SetFont(fontName,optSize,"OUTLINE")
	obj:SetShadowOffset(0, 0)
end
SetFont(GameFontNormalSmall, 16)		--ID&快捷列&聊天分頁&公會新聞&預組
SetFont(GameFontNormal, 17)			--任務欄&技能
SetFont(SystemFont_LargeNamePlateFixed,14)--大型名條名稱
SetFont(SystemFont_LargeNamePlate,14)
SetFont(SystemFont_NamePlate,15)
SetFont(SystemFont_NamePlateFixed,15)	--小型名條名稱
SetFont(ErrorFont, 18)			--錯誤字體
SetFont(ObjectiveTrackerFrame.HeaderMenu.Title, 16)		--任務欄收起時字體
