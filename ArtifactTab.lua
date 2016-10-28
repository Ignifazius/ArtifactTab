--[[
	ArtifactTab is a simple World of Warcraft addon for displaying additional tabs in the talent tab.
    Copyright (C) 2016 Ignifazius

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]	
local _, L = ...;
local ArtifactTabDebug = true;
local initScan = true
local btnPos = 0
local lastFrame = PlayerTalentFrameTab3
local btnList = {}
local arteList = {}
local isReload = false

local speccList = {
	-- Fishing
	[133755] = {["name"] = L["Fishing"], ["priority"] = 0},
	-- DK	
	[128402] = {["name"] = L["Blood"],["priority"] = 1},
	[128403] = {["name"] = L["Unholy"],["priority"] = 2}, 
	[128292] = {["name"] = L["Frost"],["priority"] = 3}, 
	-- Druid	
	[128858] = {["name"] = L["Balance"],["priority"] = 1}, 
	[128860] = {["name"] = L["Feral"],["priority"] = 2}, 
	[128821] = {["name"] = L["Guardian"],["priority"] = 3}, 
	[128306] = {["name"] = L["RestorationD"],["priority"] = 4},	
	-- Paladin
	[128823] = {["name"] = L["Holy"],["priority"] = 1},
	[128867] = {["name"] = L["ProtectionP"],["priority"] = 2}, --off
	[128866] = {["name"] = L["ProtectionP"],["priority"] = 2}, 
	[120978] = {["name"] = L["Retribution"],["priority"] = 3}, 	
	-- Rogue
	[128870] = {["name"] = L["Assassination"],["priority"] = 1}, 
	[128872] = {["name"] = L["Outlaw"],["priority"] = 2}, 
	--[134552] = L["Outlaw"],	
	[128476] = {["name"] = L["Sublety"],["priority"] = 3}, 
	-- DH
	[127829] = {["name"] = L["Havoc"],["priority"] = 1}, 
	[127830] = {["name"] = L["Havoc"],["priority"] = 1}, --off
	[128832] = {["name"] = L["Vengeance"],["priority"] = 2}, 
	[128831] = {["name"] = L["Vengeance"],["priority"] = 2}, --off	
	-- Warlock
	[128942] = {["name"] = L["Affliction"],	["priority"] = 1}, 
	[128943] = {["name"] = L["Demonology"],["priority"] = 2},  --off	
	[137246] = {["name"] = L["Demonology"],["priority"] = 2},
	[128941] = {["name"] = L["Destruction"],["priority"] = 3},
	-- Mage
	[127857] = {["name"] = L["Arcane"],["priority"] = 1}, 
	[128820] = {["name"] = L["Fire"],["priority"] = 2}, 
	[128862] = {["name"] = L["Frost"],["priority"] = 3}, 
	-- Priest
	[128868] = {["name"] = L["Discipline"],["priority"] = 1},
	[128825] = {["name"] = L["Holy"],["priority"] = 2}, 
	[128827] = {["name"] = L["Shadow"],["priority"] = 3}, 
	-- Monk
	[128938] = {["name"] = L["Brewmaster"],["priority"] = 1}, 
	[128937] = {["name"] = L["Mistweaver"],["priority"] = 2},
	[128940] = {["name"] = L["Windwalker"],["priority"] = 3}, 
	-- Warrior
	[128910] = {["name"] = L["Arms"],["priority"] = 1}, 
	[128908] = {["name"] = L["Fury"],["priority"] = 2}, 
	[128288] = {["name"] = L["ProtectionW"],["priority"] = 3}, 
	[128289] = {["name"] = L["ProtectionW"],["priority"] = 3}, --off
	-- Shaman
	[128935] = {["name"] = L["Elemental"],["priority"] = 1}, 
	[128819] = {["name"] = L["Enhancement"],["priority"] = 2}, 
	[128911] = {["name"] = L["RestorationS"],["priority"] = 3}, 
	[128934] = {["name"] = L["RestorationS"],["priority"] = 3}, --off
	-- Hunter
	[128861] = {["name"] = L["Beast Mastery"],["priority"] = 1}, 
	[128826] = {["name"] = L["Marksmanship"],["priority"] = 2}, 	
	[128808] = {["name"] = L["Survival"],["priority"] = 3}
}

local eventResponseFrame = CreateFrame("Frame", "Helper")
	eventResponseFrame:RegisterEvent("ADDON_LOADED");
	eventResponseFrame:RegisterEvent("BAG_UPDATE");
	eventResponseFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	eventResponseFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

local function eventHandler(self, event, arg1 , arg2, arg3, arg4, arg5)
	if (event == "ADDON_LOADED" and arg1 == "Blizzard_TalentUI") then
		ArtifactTab_clearLists()
		ArtifactTab_scanArtes()
		ArtifactTab_createSortedButtons()
		isReload = true;
	elseif (event == "BAG_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED") then
		ArtifactTab_checkIFUpdateIsNeeded()
		--print(event.." "..arg1)
	elseif (event =="PLAYER_ENTERING_WORLD" and isReload) then
		ArtifactTab_clearLists()
		ArtifactTab_scanArtes()
		ArtifactTab_createSortedButtons()
	end
end

eventResponseFrame:SetScript("OnEvent", eventHandler);


function ArtifactTab_clearLists()
	for i=1,#btnList do
		btnList[i]:Hide()
	end
	btnList = {}
	arteList = {}
end

function ArtifactTab_scanArtes()
	_, _, classIndex = UnitClass("player");
	if classIndex == 3 then -- hunter
		lastFrame = PlayerTalentFrameTab4
	else
		lastFrame = PlayerTalentFrameTab3
	end
	for container=0,5 do
		for slot=0,32 do
			_, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(container, slot)
			if quality == 6 and itemID ~= 139390 then -- Artifact research note
				name = GetItemInfo(itemID)
				table.insert(arteList, ArtifactTab_createArteContainer("bag", container, slot, itemID))
			end			
		end
	end
	local equippedID = ArtifactTab_getEquippedItemID()
	if equippedID ~= nil then -- somehow this info is not availabe directly after login... -.-
		table.insert(arteList, ArtifactTab_createArteContainer("equipped", nil, nil, equippedID))
	end
end

function countArtes()
	local count = 0
	for container=0,5 do
		for slot=0,32 do
			_, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(container, slot)
			if quality == 6 and itemID ~= 139390 then -- Artifact research note
				count = count+1
			end			
		end
	end
	local eqID = ArtifactTab_getEquippedItemID()
	if eqID ~= nil then
		_, _, quality = GetItemInfo(eqID)
		if quality == 6 then
			count = count+1
		end
	end
	return count
end

function ArtifactTab_updateAllButtons()
	for i=1,#btnList do
		
	end	
end

function ArtifactTab_checkIFUpdateIsNeeded()
	local updateRequired = false
	if #arteList ~= countArtes() then
		updateRequired = true
	else
		for container=0,5 do
			for slot=0,32 do
				_, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(container, slot)
				if quality == 6 and itemID ~= 139390 then -- Artifact research note
					name = GetItemInfo(itemID)
					--print(#arteList)
					for i=1, #arteList do 
						if arteList[i]["id"] == ArtifactTab_getMainhandArtifactID(itemID) then
							--print(arteList[i]["type"])
							if arteList[i]["type"] == "bag" then
							--print(arteList[i]["slot"].. " "..slot.." | "..arteList[i]["container"].." "..container)
								if arteList[i]["slot"] == slot and arteList[i]["container"] == container then						
									--print("(inv) no update needed")
								else
									--print("(inv) update needed")
									updateRequired = true
								end
							elseif arteList[i]["type"] == "equipped" then
								--print(arteList[i]["id"].." "..ArtifactTab_getEquippedItemID())
								if arteList[i]["id"] == ArtifactTab_getEquippedItemID() then
									--print("(eq) no update needed")
								else
									--print("(eq) update needed")
									updateRequired = true
								end					
							end
						end
					end
				end			
			end
		end
	end
	if updateRequired then
		--print("updating...")
		-- pretty sure there is a better solution than this lazy hotfix
		ArtifactTab_clearLists()
		ArtifactTab_scanArtes()
		ArtifactTab_createSortedButtons()
		-- end of "lazy hotfix"
	end
end

function ArtifactTab_getMainhandArtifactID(id)
	if id == 128289 then -- prot warrior
		return 128288
	elseif id == 128943 then --demo lock
		return 137246
	elseif id == 128866 then --prot pala
		return 128867
	else
		return id
	end
end


function ArtifactTab_createArteContainer(typ, con, sl, id)
	local arte = {
		["type"] = typ,
		["slot"] = sl,
		["container"] = con,
		["id"] = id,
		["priority"] = speccList[id]["priority"], -- best way, using the same priority like the talent tree?
	}
	return arte
end

function ArtifactTab_setActiveButton(button)
	for i=1,#btnList do
		btnList[i]:SetSize(btnList[i]:GetFontString():GetWidth(),30)
		local textureN = btnList[i]:GetNormalTexture()
		textureN:SetTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-INACTIVETAB")
		btnList[i]:SetNormalTexture(textureN)
		textureN:SetAllPoints(btnList[i])
		local highTexN = btnList[i]:GetHighlightTexture()
		highTexN:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-RealHighlight")
		btnList[i]:SetHighlightTexture(highTexN)
		highTexN:SetAllPoints(btnList[i])
		highTexN:SetPoint("TOP", button ,"TOP", 0, -10)		
	end
	button:SetSize(button:GetFontString():GetWidth(),30)
	local texture = button:GetNormalTexture()
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-ACTIVETAB")
	texture:SetPoint("TOP", button ,"TOP", 0, -15)
	texture:SetPoint("LEFT", button ,"LEFT", 0, 0)
	texture:SetPoint("RIGHT", button ,"RIGHT", 0, 0)
	texture:SetPoint("BOTTOM", button ,"BOTTOM", 0, -25)
	button:SetNormalTexture(texture)
	local highTexN = button:GetHighlightTexture()
	highTexN:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-RealHighlight")
	button:SetHighlightTexture(highTexN)
	highTexN:SetAllPoints(button)
	highTexN:SetPoint("BOTTOM", button ,"BOTTOM", 0, -5)
end

function ArtifactTab_createArteButton(name, container, slot)
	local buttonArte = ArtifactTab_createButton(name, lastFrame)
	buttonArte:SetScript("OnClick", function()
		SocketContainerItem(container, slot)
		ArtifactTab_setActiveButton(buttonArte)
	end)
	buttonArte:Show()
	buttonArte.previousFrame = lastFrame
	table.insert(btnList, buttonArte)
	lastFrame = buttonArte;
end


function ArtifactTab_createButton(name, frame)
	local b = CreateFrame("Button",name,PlayerTalentFrame)
	b:SetPoint("LEFT", frame ,"RIGHT", -5, 0)
	bFontString = b:CreateFontString()
	bFontString:SetFont(L["UIFont"], 10, "OUTLINE")
	bFontString:SetText(ArtifactTab_arteToSpecc(name))
	bFontString:SetAllPoints(b)
	b:SetFontString(bFontString)
	b:SetSize(bFontString:GetWidth()+30,30)--*1.4
	local texture = b:CreateTexture()
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-INACTIVETAB")
	texture:SetAllPoints(b)
	b:SetNormalTexture(texture)
	local highTex = b:CreateTexture()
	highTex:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-RealHighlight")
	highTex:SetAllPoints(b)
	b:SetHighlightTexture(highTex)
	return b
end

function ArtifactTab_getEquippedItemID()
	local slotId = GetInventorySlotInfo("MainHandSlot")
	local itemId = GetInventoryItemID("player", slotId)
	if itemId then -- somehow the ID is nil if the player logs in
		name, _, quality = GetItemInfo(itemId)
		if quality == 6 then
			return itemId
		end
	end
end

function ArtifactTab_createEquipedButton()
	local slotId = GetInventorySlotInfo("MainHandSlot")
	local itemId = GetInventoryItemID("player", slotId)
	if itemId then -- somehow the ID is nil if the player logs in
		name, _, quality = GetItemInfo(itemId)
		if quality == 6 then
			buttonArte = ArtifactTab_createButton(itemId, lastFrame) --name
			buttonArte:GetFontString():SetTextColor(1,0.84,0, 1)
			buttonArte:SetScript("OnClick", function()
				SocketInventoryItem(slotId)
				ArtifactTab_setActiveButton(buttonArte)
			end)
			buttonArte:Show()
			table.insert(btnList, buttonArte)
			lastFrame = buttonArte;
		end
	end
end

function ArtifactTab_createSortedButtons()
	for i=0,4 do -- 0 for fishing 0-4 -> 5 priorities, nobody has more than 5 artifacts
		for j=1, #arteList do 
			if arteList[j] ~= nil and arteList[j]["priority"] == i then
				if arteList[j]["type"] == "bag" then
					ArtifactTab_createArteButton(arteList[j]["id"], arteList[j]["container"], arteList[j]["slot"])
				elseif arteList[j]["type"] == "equipped" then
					ArtifactTab_createEquipedButton()
				end
			end
		end
	end
end

function ArtifactTab_arteToSpecc(id)
	local retID = speccList[id]["name"]
	if retID == nil then
		name = GetItemInfo(id)
		return name 
	end
	return retID
end
