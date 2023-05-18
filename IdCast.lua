--滑鼠提示法術ID和施法者
local cc = {}
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
do
	for class, c in pairs(CUSTOM_CLASS_COLORS) do
		cc[class] = format('|cff%02x%02x%02x', c.r*255, c.g*255, c.b*255)
	end
end


hooksecurefunc(GameTooltip, "SetUnitBuff", function(self,...)
   local id = select(10,UnitBuff(...))
   self:AddLine(id and ' ')
   self:AddDoubleLine("ID:|cffffffff"..id)
   self:Show()
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
   local id = select(10,UnitDebuff(...))
   self:AddLine(id and ' ')
   self:AddDoubleLine("ID:|cffffffff"..id)
   self:Show()
end)

local OnTooltipSetSpell = function(self, ...)
  local id = select(2, self:GetSpell())
  if id then
      self:AddLine(id and ' ')
      self:AddLine("ID:|cffffffff"..id)
      self:Show()
  end
end

hooksecurefunc("SetItemRef", function(link)
	if link then
	local _, id = strsplit(":", link)
	ItemRefTooltip:AddLine(id and ' ')
	ItemRefTooltip:AddLine("ID:|cffffffff"..id)
	ItemRefTooltip:Show()
	end
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
   local id = select(10,UnitAura(...))
   self:AddLine(id and ' ')
      local caster = select(7,UnitAura(...)) and UnitName(select(7,UnitAura(...)))
   if caster then
   local uname, urealm = UnitName(caster)
   local _, uclass = UnitClass(caster)
   if urealm then uname = uname..'-'..urealm end
  self:AddDoubleLine("ID:|cffffffff"..id, (cc[uclass])..caster)
   end
   self:Show()
end)
