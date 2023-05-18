--SellRepair 自動賣灰修裝
local sellgrays	= 1	--自動賣灰裝(1:是 0:否)
local autorepair	= 1	--自動修裝備(1:是 0:否)
local UseGuildBank	= 0	--使用公會會費修裝(1:是 0:否)

local f = CreateFrame("Frame")
f:RegisterEvent("MERCHANT_SHOW")
f:SetScript("OnEvent", function()
	if sellgrays then
	local p,N,c,n=0
		for bag = 0, 4 do
			for slot = 1, C_Container.GetContainerNumSlots(bag) do
			n = C_Container.GetContainerItemLink(bag, slot)
				if n and string.find(n,"9d9d9d") then
					N={GetItemInfo(n)}
					c=GetItemCount(n) p=p+(N[11]*c)C_Container.UseContainerItem(bag, slot)
					print("賣："..n)
				end
			end
		end
		--[[if p~=0 then
			print("|cffffff00共售出：|r" ..GetMoneyString(p, true))
		end]]
	end

	if (autorepair and CanMerchantRepair()) then
		cost, repair = GetRepairAllCost()
		if cost>0 then
			if repair then
			local str = GetMoneyString(cost)
			if UseGuildBank == 1 and IsInGuild() and CanGuildBankRepair() and (GetGuildBankWithdrawMoney() >= cost) and (GetGuildBankMoney() >= cost) then
				RepairAllItems(1)
				str = "公款修理："..str
			elseif GetMoney() >= cost then
				RepairAllItems()
				str = "自費修理："..str
			else
				str = "餘額不足！需要："..str
			end
			print("|cffffff00"..str.."|r")
			end
		end
	end
end)
