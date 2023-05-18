local TradeTabs = CreateFrame("Frame","TradeTabs")
local whitelist = {
	[129] = true, -- 急救 First Aid
	[164] = true, -- 煅造 Blacksmithing 
	[165] = true, -- 製皮 Leatherworking	
	[171] = true, -- 煉金 Alchemy 	
    [182] = true, -- 草藥學 herbalism	
	[186] = true, -- 採礦 Mining	
	[202] = true, -- 工程 Engineering
	[333] = true, -- 附魔 Enchanting 
	[755] = true, -- 珠寶 Jewelcrafting
	[773] = true, -- 銘文 Inscription
	[794] = true, -- 考古 Archaeology
	[356] = true, -- 釣魚 Fishing
	[185] = true, -- 烹飪 Cooking 
	[197] = true, -- 裁縫 Tailoring
    [393] = true, -- 剝皮 skinning
}

local onlyPrimary = {
	[171] = true, --煉金 Alchemy
	[202] = true, --工程 Engineering
}


local items = 67556
local RUNEFORGING = 53428
function TradeTabs:OnEvent(event,...)
	self:UnregisterEvent(event)
	if not IsLoggedIn() then
		self:RegisterEvent(event)
	elseif InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:Initialize()
		
	end
end

local function buildSpellList()
	local profs = {GetProfessions()}
	local tradeSpells = {}
	local extras =  0
	for _,prof in pairs(profs) do
		local name, icon, _, _, numAbilities, spelloffset, skillLine = GetProfessionInfo(prof)  
		if whitelist[skillLine] then
			if onlyPrimary[skillLine] then
				numAbilities = 1
			end
			for i = 1, numAbilities do
				if not IsPassiveSpell(i + spelloffset, BOOKTYPE_PROFESSION) then
					if i > 1 then
						tinsert(tradeSpells, i + spelloffset)
						extras = extras + 1
					else
						tinsert(tradeSpells, #tradeSpells + 1 - extras, i + spelloffset)
					end
				end
			end
		end
	end

	return tradeSpells
end

function TradeTabs:Initialize()
	local parent = ProfessionsFrame
	local tradeSpells = buildSpellList()
	local i = 1
	local prev

	if select(2, UnitClass("player")) == "DEATHKNIGHT" then
		prev = self:CreateTab(i, parent, RUNEFORGING)
		prev:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, -21)
		i = i + 1
	end
	
    local _,_,_,_,cooking = GetProfessions()
	if cooking then
		prev = self:CreateTab(i, parent, items)
		if select(2, UnitClass("player")) == "DEATHKNIGHT" then
			prev:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, -68)
		else
			prev:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, -21)
		end
		prev:SetAttribute('type1','macro')
		prev:SetAttribute('type2','macro')
		prev:SetAttribute('type3','macro')
		prev:SetAttribute('macrotext1', "/use 大廚的帽子")
		prev:SetAttribute('macrotext2', "/cast [@player] 烹飪用火")
		prev:SetAttribute('macrotext3', "/spp\n/run petA:Click()")
		i = i + 1
	end

	for i, slot in ipairs(tradeSpells) do
		local _, spellID = GetSpellBookItemInfo(slot, BOOKTYPE_PROFESSION)
		local tab = self:CreateTab(i, parent, spellID)
		i = i + 1
		local point,relPoint,x,y = "TOPLEFT", "BOTTOMLEFT", 0, -15
		if not prev then
			prev, relPoint, x, y = parent, "TOPRIGHT", 0, -22
		end
		tab:SetPoint(point, prev, relPoint, x, y)
		prev = tab
	end
	self.initialized = true
end

local function onEnter(self) 
	GameTooltip:SetOwner(self,"ANCHOR_RIGHT") GameTooltip:SetText(self.tooltip) 
	self:GetParent():LockHighlight()
end

local function onLeave(self) 
	GameTooltip:Hide()
	self:GetParent():UnlockHighlight()
end   

local function updateSelection(self)
	if IsCurrentSpell(self.spell) then
		self:SetChecked(true)
		self.clickStopper:Show()
	else
		self:SetChecked(false)
		self.clickStopper:Hide()
	end
end

local function createClickStopper(button)
	local f = CreateFrame("Frame",nil,button)

	f:SetAllPoints(button)
	f:EnableMouse(true)
	f:SetScript("OnEnter",onEnter)
	f:SetScript("OnLeave",onLeave)
	
	button.clickStopper = f
	f.tooltip = button.tooltip
	f:Hide()
end


local ENCHANTING_VELLUM = 38682
local C_TradeSkillUI_GetRecipeInfo, C_TradeSkillUI_GetTradeSkillLine = C_TradeSkillUI.GetRecipeInfo, C_TradeSkillUI.GetTradeSkillLine --C_TradeSkillUI.GetProfessionInfoBySkillLineID
local isEnchanting
local tooltipString = "|cffffaa0e%s (%d)"
local function IsRecipeEnchanting(self)
	isEnchanting = nil
	local recipeID = self.selectedRecipeID
	local recipeInfo = recipeID and C_TradeSkillUI_GetRecipeInfo(recipeID)
	if recipeInfo and recipeInfo.alternateVerb then
		local parentSkillLineID = select(6, C_TradeSkillUI_GetTradeSkillLine())
		if parentSkillLineID == 333 then
			isEnchanting = true
			self.CreateButton.tooltip = format(tooltipString, "右鍵：附魔羊皮紙", GetItemCount(ENCHANTING_VELLUM))
		end
	end
end
function QuickEnchanting()
	if not ProfessionsFrame then return end
	hooksecurefunc(ProfessionsFrame.CraftingPage, "ValidateControls", function(self)
		isEnchanting = nil
		local currentRecipeInfo = self.SchematicForm:GetRecipeInfo()
		if currentRecipeInfo and currentRecipeInfo.alternateVerb then
			local professionInfo = ProfessionsFrame:GetProfessionInfo()
			if professionInfo and professionInfo.parentProfessionID == 333 then
				isEnchanting = true
				self.CreateButton.tooltipText = format(tooltipString, "右鍵：附魔羊皮紙", GetItemCount(ENCHANTING_VELLUM))
			end
		end
	end)
	local createButton = ProfessionsFrame.CraftingPage.CreateButton
	createButton:RegisterForClicks("AnyDown", "AnyUp")
	createButton:HookScript("OnClick", function(_, btn)
		if btn == "RightButton" and isEnchanting then
			UseItemByName(ENCHANTING_VELLUM)
		end
	end)
end


function TradeTabs:CreateTab(i, parent, spellID)
	local spell, _, texture = GetSpellInfo(spellID)
	local button = CreateFrame("CheckButton", "TradeTabsTab"..i, parent, "SpellBookSkillLineTabTemplate, SecureActionButtonTemplate")
	button.tooltip = spell
	button.spellID = spellID
	button.spell = spellID
	button:Show()
	button:SetAttribute("type","spell")
	button:SetAttribute("spell",spellID)
	button:RegisterForClicks("AnyDown", "AnyUp")
	button:SetNormalTexture(texture)
	button:SetScript("OnEvent",updateSelection)
	button:RegisterEvent("TRADE_SKILL_SHOW")
	button:RegisterEvent("TRADE_SKILL_CLOSE")
	button:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
	createClickStopper(button)
	updateSelection(button)
	QuickEnchanting()
	return button
end
TradeTabs:RegisterEvent("TRADE_SKILL_SHOW")	
TradeTabs:SetScript("OnEvent",TradeTabs.OnEvent)
TradeTabs:Initialize()


--中鍵：召喚/解散小寵物 (有烹飪用火功能的小寵物)
_G.SLASH_e1="/spp"
local sppa = CreateFrame("Button","petA",UIParent,"SecureActionButtonTemplate")
sppa:SetAttribute("type","macro")
    _G.SlashCmdList.e = function()
	if  not IsShiftKeyDown() and not IsAltKeyDown() and (GetMouseButtonClicked()=="MiddleButton") then
		local Pets = {"小拉格","皮埃爾",}
        local _, P1 = C_PetJournal.FindPetIDByName(Pets[1])
		local _, P2 = C_PetJournal.FindPetIDByName(Pets[2])
		local S = C_PetJournal.GetSummonedPetGUID()
		local icon1 = "\124TInterface\\Icons\\achievement_boss_ragnaros:12\124t"
		local icon2 = "\124TInterface\\Icons\\inv_pet_cookbot:12\124t"
	    if P1 ~= nil and P2 == nil then
		    if InCombatLockdown() then print("|cff99ff00注意：戰鬥中無法召喚小寵物。|r") return end
	        if S~=P1 then
			    C_PetJournal.SummonPetByGUID(P1)
			    print(icon1.."|cff00ccff["..Pets[1].."]|r".." |TInterface/RaidFrame/ReadyCheck-Ready:15|t".."|cff99ff00已召喚。|r")
		    else
			    C_PetJournal.SummonPetByGUID(P1)
		        print(icon1.."|cff00ccff["..Pets[1].."]|r".." |TInterface/RaidFrame/ReadyCheck-NotReady:15|t".."|cffff4500已解散。|r")
		    end
		elseif P1 == nil and P2 ~= nil then
		    if InCombatLockdown() then print("|cff99ff00注意：戰鬥中無法召喚小寵物。|r") return end
	        if S~=P2 then
			    C_PetJournal.SummonPetByGUID(P2)
			    print(icon2.."|cff00ccff["..Pets[2].."]|r".." |TInterface/RaidFrame/ReadyCheck-Ready:15|t".."|cff99ff00已召喚。|r")
		    else
			    C_PetJournal.SummonPetByGUID(P2)
		        print(icon2.."|cff00ccff["..Pets[2].."]|r".." |TInterface/RaidFrame/ReadyCheck-NotReady:15|t".."|cffff4500已解散。|r")
		    end
		elseif P1 ~= nil and P2 ~= nil then
		    if InCombatLockdown() then print("|cff99ff00注意：戰鬥中無法召喚小寵物。|r") return end
	        if S~=P1 then
			    C_PetJournal.SummonPetByGUID(P1)
			    print(icon1.."|cff00ccff["..Pets[1].."]|r".." |TInterface/RaidFrame/ReadyCheck-Ready:15|t".."|cff99ff00已召喚。|r")
		    else
			    C_PetJournal.SummonPetByGUID(P2)
		        print(icon2.."|cff00ccff["..Pets[2].."]|r".." |TInterface/RaidFrame/ReadyCheck-Ready:15|t".."|cff99ff00已召喚。|r")
		    end
		elseif P1 == nil and P2 == nil then
		    if InCombatLockdown() then print("|cff99ff00注意：戰鬥中無法召喚小寵物。|r") return end
        end 
    end	
end	