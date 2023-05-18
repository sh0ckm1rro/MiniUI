--AutoDismount 自動下馬
local suppress
local MOUNTERRORS = {
  [SPELL_FAILED_NOT_MOUNTED] = true,
  [ERR_NOT_WHILE_MOUNTED] = true,
  [ERR_ATTACK_MOUNTED] = true,
  [ERR_TAXIPLAYERALREADYMOUNTED] = true,
  [SPELL_FAILED_NOT_FLYING] = true,
  [ERR_PETBATTLE_NOT_WHILE_FLYING] = true,
}

local f = CreateFrame("frame")
f.OnUpdate = function(self, elapsed)
  if suppress then
    suppress = nil
    f:SetScript("OnUpdate", nil)
    return
  end
  Dismount()
  f:SetScript("OnUpdate", nil)
end

f.OnEvent = function(self, event, ...)
  if event == "UNIT_SPELLCAST_FAILED" then
    local _, _, _, _, id = ...
    if id == 129356 or id == 110668 or id == 136738 or id == 126065 or id == 130830 or id == 137462 or id == 121951 then -- Overcome by Anger, Fleet Winds, Wild Energy, Consuming Rune, Gross!, Lightning Strike, Blanche's Elixir of Replenishment
      suppress = IsMounted() or IsFlying()
    end
  end
  local _, errorName = ...
  -- not an error message we care about or we are flying and don't have flight auto-dismount option checked, return immediately.
  if not MOUNTERRORS[errorName] or IsFlying() and not GetCVarBool("autoDismountFlying") then
    return
  end
  f:SetScript("OnUpdate", f.OnUpdate) -- dismount on next frame
end

f:RegisterEvent("UI_ERROR_MESSAGE")
f:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
f:SetScript("OnEvent", f.OnEvent)
