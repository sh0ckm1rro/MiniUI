-- 人物面板裝備耐久 Author: M
hooksecurefunc("PaperDollItemSlotButton_Update", function(self)
	local id = self:GetID()
	if (id == 4 or id > 17) then return end
	if (not self.durabString) then
		local fontAdjust = GetLocale():sub(1,2) == "zh" and 0 or -3
		self.durabString = self:CreateFontString(nil, "OVERLAY")
		self.durabString:SetFont(STANDARD_TEXT_FONT, 12+fontAdjust, "OUTLINE")
		if AzeriteTooltip and (id == 1 or id == 3 or id == 5) then
			self.durabString:SetPoint("BOTTOM", 45 ,0)
		else
			--self.durabString:SetPoint("BOTTOM")
			self.durabString:SetPoint("Center")
		end
		self.durabString:SetText("")
	end
	local durability, maxDurability = GetInventoryItemDurability(id)
	if (durability and maxDurability) then
		local durabPercent = durability / maxDurability
		self.durabString:SetText(format("%d%%", durabPercent * 100))
		self.durabString:SetTextColor(1-durabPercent, durabPercent, 0)
	end
end)



--[[裝等顯示 (觀察視窗)
local slot = {"Head","Neck","Shoulder","Shirt","Chest","Waist","Legs","Feet","Wrist","Hands","Finger0","Finger1","Trinket0","Trinket1","Back","MainHand","SecondaryHand","Tabard"}

local ilv = {}

local function createIlvText(slotName)
   if not ilv[slotName] then
      local fs = _G[slotName]:CreateFontString(nil, "OVERLAY")
      --fs:SetPoint("BOTTOMLEFT", _G[slotName], "BOTTOMLEFT", 0, 0)
	  fs:SetPoint("TOP", _G[slotName], "TOP", 0, -1)
      fs:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
      ilv[slotName] = fs
   end
end

for k, v in pairs(slot) do createIlvText("Character"..v.."Slot") end

local function checkItem(unit, frame)
   if unit then
      for k, v in pairs(slot) do
         local itemLink = GetInventoryItemLink(unit, k)
         if itemLink then
            local _,_,itemQuality,itemLv = GetItemInfo(itemLink)
            local r,g,b = GetItemQualityColor(itemQuality)
            ilv[frame..v.."Slot"]:SetText(itemLv)
            ilv[frame..v.."Slot"]:SetTextColor(r,g,b)
         else
            ilv[frame..v.."Slot"]:SetText()
         end
      end
   end
end


_G["CharacterFrame"]:HookScript("OnShow", function(self)
   checkItem("player", "Character")
   self:RegisterEvent("UNIT_MODEL_CHANGED")
end)

_G["CharacterFrame"]:HookScript("OnHide", function(self)
   self:UnregisterEvent("UNIT_MODEL_CHANGED")
end)

_G["CharacterFrame"]:HookScript("OnEvent", function(self, event)
   if event == "UNIT_MODEL_CHANGED" then checkItem("player", "Character") end
end)

local F = CreateFrame("Frame")
   F:RegisterEvent("ADDON_LOADED")
   F:SetScript("OnEvent", function(self, event, addon)
      if addon == "Blizzard_InspectUI" then
         self:UnregisterEvent("ADDON_LOADED")
         self:SetScript("OnEvent", nil)

         for k, v in pairs(slot) do createIlvText("Inspect"..v.."Slot") end
         checkItem(_G["InspectFrame"].unit, "Inspect")

         _G["InspectFrame"]:HookScript("OnShow", function()
            self:RegisterEvent("INSPECT_READY")
            self:RegisterEvent("UNIT_MODEL_CHANGED")
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:SetScript("OnEvent", function() checkItem(_G["InspectFrame"].unit, "Inspect") end)
         end)

         _G["InspectFrame"]:HookScript("OnHide", function()
            self:UnregisterEvent("PLAYER_TARGET_CHANGED")
            self:UnregisterEvent("UNIT_MODEL_CHANGED")
            self:UnregisterEvent("INSPECT_READY")
            self:SetScript("OnEvent", nil)
         end)

      end
   end)
]]
