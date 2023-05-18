--[[Shooter 成就截圖
local Shooter = Shooter or {}

Shooter.frame = CreateFrame("Frame", "Shooter", UIParent)
Shooter.frame:SetFrameStrata("BACKGROUND")

Shooter.frame:SetScript("OnEvent",
  function ()
    C_Timer.After(1, Screenshot)
  end
)

Shooter.frame:RegisterEvent("ACHIEVEMENT_EARNED")
]]

--[[Achievement SS 成就截圖]]
local delay = 1
local time = 0
local frame = CreateFrame("Frame")
frame:Hide()
frame:RegisterEvent("ACHIEVEMENT_EARNED")

frame:SetScript("OnUpdate", function(self, elapsed)
   time = time + elapsed
   if time >= delay then
     Screenshot()
     time = 0
     self:Hide()
   end
end)

frame:SetScript("OnEvent", function(self, event, ...)
   self:Show()
end)