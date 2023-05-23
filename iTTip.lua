-- wowinterface / LinkIcon 1.17 (Author: Gello) modified

local function click(self)
	if IsModifiedClick("DRESSUP") and self.link then
		if self.type == "item" then
			DressUpItemLink(self.link)									-- ctrl點擊圖示，試穿裝備
		elseif self.type == "achievement" then
			OpenAchievementFrameToAchievement(self.link)				-- ctrl點擊圖示，打開成就
		end
	end
end

local icon = CreateFrame("Button", nil, ItemRefTooltip)
icon:SetSize(37, 37)
icon:SetPoint("TOPRIGHT", ItemRefTooltip, "TOPLEFT", 0, -3)
icon:SetScript("OnClick", click)
icon.overlay = icon:CreateTexture(nil, "OVERLAY")
icon.overlay:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame")
icon.overlay:SetTexCoord(0, 0.5625, 0, 0.5625)
icon.overlay:SetPoint("CENTER")
icon.overlay:SetSize(47, 47)
icon.overlay:Hide()

function icon.SetIcon(type, id)
	icon:SetNormalTexture(0)
	icon.overlay:Hide()
	icon.type = nil
	icon.link = nil
	if type and type == "item" and id then
		if GetItemInfo(id) and select(10, GetItemInfo(id)) then
			icon:SetNormalTexture(select(10, GetItemInfo(id)))			-- GetItemIcon(id)
			icon.overlay:Hide()
			icon.type = "item"
			icon.link = select(2, GetItemInfo(id))
		end
	elseif type and (type == "spell" or type == "enchant") and id then
		if GetSpellTexture(id) then
			icon:SetNormalTexture(GetSpellTexture(id))					-- select(3, GetSpellInfo(id))
			icon.overlay:Hide()
			icon.type = "spell"
			icon.link = nil												-- GetSpellLink(id)
		end
	elseif type and type == "achievement" and id then
		if GetAchievementInfo(id) and select(10, GetAchievementInfo(id)) then
			icon:SetNormalTexture(select(10, GetAchievementInfo(id)))
			icon.overlay:Show()
			icon.type = "achievement"
			icon.link = id
		end
	end
end

hooksecurefunc("SetItemRef", function(link)
--	print(link)
	local iconType, iconID = link:match("\124?H?(%w+):(%d+)")
	if iconType and iconID then icon.SetIcon(iconType, iconID) end
end)


--- NDui v6.31.0 / TooltipID simplified

local types = {
	spell = SPELLS.."ID:",
	item = ITEMS.."ID:",
	currency = CURRENCY.."ID:",
	Toy = TOY.."ID:",
}

local function AddLineForID(self, id, linkType, noadd)
	if self:IsForbidden() then return end
	for i = 1, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		if not line then break end
		local text = line:GetText()
		if text and text == linkType then return end
	end
	if not noadd then self:AddLine(" ") end
	self:AddDoubleLine(linkType, format("|cffffffff".."%s|r", id))
	self:Show()
end

-- spell
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(self, data)
	if self:IsForbidden() then return end
	if data.id then AddLineForID(self, data.id, types.spell) end
end)

-- aura
hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
	if self:IsForbidden() then return end
	local _, _, _, _, _, _, _, _, _, id = UnitAura(...)
	if id then AddLineForID(self, id, types.spell) end
end)

local function UpdateAuraTip(self, unit, auraInstanceID)
	local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
	if not data then return end
	local id = data.spellId
	if id then AddLineForID(self, id, types.spell) end
end
hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", UpdateAuraTip)
hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", UpdateAuraTip)

-- Items
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(self, data)
	if self:IsForbidden() then return end
	if data.id then AddLineForID(self, data.id, types.item) end
end)

-- currency
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, function(self, data)
	if self:IsForbidden() then return end
	if data.id then AddLineForID(self, data.id, types.currency) end
end)

-- Toys
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, function(self, data)
	if self ~= GameTooltip or self:IsForbidden() then return end
	if data and data.id then
		AddLineForID(self, data.id, types.Toy)
	end
end)
