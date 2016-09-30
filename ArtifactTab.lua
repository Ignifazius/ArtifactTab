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
local btnPos = 0
local lastFrame = PlayerTalentFrameTab3
local btnList = {}
local arteList = {}

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
	[128306] = {["name"] = L["Restoration"],["priority"] = 4},	
	-- Paladin
	[128823] = {["name"] = L["Holy"],["priority"] = 1},
	[128867] = {["name"] = L["Protection"],["priority"] = 2}, 
	[128866] = {["name"] = L["Protection"],["priority"] = 2}, 
	[120978] = {["name"] = L["Retribution"],["priority"] = 3}, 	
	-- Rogue
	[128870] = {["name"] = L["Assassination"],["priority"] = 1}, 
	[128872] = {["name"] = L["Outlaw"],["priority"] = 2}, 
	--[134552] = L["Outlaw"],	
	[128476] = {["name"] = L["Sublety"],["priority"] = 3}, 
	-- DH
	[128829] = {["name"] = L["Havoc"],["priority"] = 1}, 
	[128832] = {["name"] = L["Vengeance"],["priority"] = 2}, 	
	-- Warlock
	[128942] = {["name"] = L["Affliction"],	["priority"] = 1}, 
	[128943] = {["name"] = L["Demonology"],["priority"] = 2}, 
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
	[128288] = {["name"] = L["Protection"],["priority"] = 3}, 
	[128289] = {["name"] = L["Protection"],["priority"] = 3}, 
	-- Shaman
	[128935] = {["name"] = L["Elemental"],["priority"] = 1}, 
	[128819] = {["name"] = L["Enhancement"],["priority"] = 2}, 
	[128911] = {["name"] = L["Restoration"],["priority"] = 3}, 
	-- Hunter
	[128861] = {["name"] = L["Beast Mastery"],["priority"] = 1}, 
	[128826] = {["name"] = L["Marksmanship"],["priority"] = 2}, 	
	[128808] = {["name"] = L["Survival"],["priority"] = 3}
}

local eventResponseFrame = CreateFrame("Frame", "Helper")
	eventResponseFrame:RegisterEvent("ADDON_LOADED");
	eventResponseFrame:RegisterEvent("BAG_UPDATE");
	eventResponseFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	--eventResponseFrame:RegisterEvent("PLAYER_ENTERING_WORLD");		
	
local function eventHandler(self, event, arg1 , arg2, arg3, arg4, arg5)
	if (event == "BAG_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED" or event == "ADDON_LOADED") then
		clearLists()
		scanArtes()
		createSortedButtons()
	end
end

eventResponseFrame:SetScript("OnEvent", eventHandler);

function clearLists()
	for i=1,#btnList do
		btnList[i]:Hide()
	end
	btnList = {}
	arteList = {}
end

function scanArtes()
	_, _, classIndex = UnitClass("player");
	if classIndex == 3 then -- hunter
		lastFrame = PlayerTalentFrameTab4
	else
		lastFrame = PlayerTalentFrameTab3
	end
	for container=0,5 do
		for slot=0,32 do
			_, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(container, slot)
			if quality == 6 then
				name = GetItemInfo(itemID)
				table.insert(arteList, createArteContainer("bag", container, slot, itemID))
			end			
		end
	end
	local equippedID = getEquippedItemID()
	if equippedID ~= nil then -- somehow this info is not availabe directly after login... -.-
		table.insert(arteList, createArteContainer("equipped", nil, nil, equippedID))
	end
end

function createArteButton(name, container, slot)
	local buttonArte = createButton(name, lastFrame)
	buttonArte:SetScript("OnClick", function()
		SocketContainerItem(container, slot)
	end)
	buttonArte:Show()
	buttonArte.previousFrame = lastFrame
	table.insert(btnList, buttonArte)
	lastFrame = buttonArte;
end

function createArteContainer(typ, con, sl, id)
	local arte = {
		["type"] = typ,
		["slot"] = sl,
		["container"] = con,
		["id"] = id,
		["priority"] = speccList[id]["priority"], -- best way, using the same priority like the talent tree?
	}
	return arte
end

function createButton(name, frame)
	local b = CreateFrame("Button",name,PlayerTalentFrame)
	b:SetPoint("LEFT", frame ,"RIGHT", -5, 0)
	bFontString = b:CreateFontString()
	bFontString:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
	bFontString:SetText(arteToSpecc(name))
	bFontString:SetAllPoints(b)
	b:SetFontString(bFontString)
	b:SetSize(bFontString:GetWidth()+30,30)--*1.4
	b:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-INACTIVETAB")
	b:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-RealHighlight")
	return b
end

function createEqButton(name, frame)
	local b = CreateFrame("Button",name,PlayerTalentFrame)
	b:SetPoint("LEFT", frame ,"RIGHT", -5, 0)
	bFontString = b:CreateFontString()
	bFontString:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
	bFontString:SetText(arteToSpecc(name))
	--bFontString:SetAllPoints(b)
	bFontString:SetPoint("TOP", b ,"TOP", 0, -30)
	b:SetFontString(bFontString)
	b:SetSize(bFontString:GetWidth()+30,60)--*1.4
	local texture = b:CreateTexture()
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-ACTIVETAB")
	texture:SetPoint("TOP", b ,"TOP", 0, -15)
	texture:SetPoint("LEFT", b ,"LEFT", 0, 0)
	texture:SetPoint("RIGHT", b ,"RIGHT", 0, 0)
	texture:SetPoint("BOTTOM", b ,"BOTTOM", 0, -15)
	--texture:SetAllPoints(b)
	b:SetNormalTexture(texture)
	b:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-RealHighlight")
	return b
end

function getEquippedItemID()
	local slotId = GetInventorySlotInfo("MainHandSlot")
	local itemId = GetInventoryItemID("player", slotId)
	if itemId then -- somehow the ID is nil if the player logs in
		name, _, quality = GetItemInfo(itemId)
		if quality == 6 then
			return itemId
		end
	end
end

function createEquipedButton()
	local slotId = GetInventorySlotInfo("MainHandSlot")
	local itemId = GetInventoryItemID("player", slotId)
	if itemId then -- somehow the ID is nil if the player logs in
		name, _, quality = GetItemInfo(itemId)
		if quality == 6 then
			buttonArte = createEqButton(itemId, lastFrame) --name
			--buttonArte:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-CHARACTER-ACTIVETAB")
			--buttonArte:SetSize(bFontString:GetWidth()+30,60)--*1.4
			--buttonArte:SetPoint("LEFT", lastFrame ,"RIGHT", -5, -30)
			buttonArte:SetScript("OnClick", function()
				SocketInventoryItem(slotId)
			end)
			buttonArte:Show()
			table.insert(btnList, buttonArte)
			lastFrame = buttonArte;
		end
	end
end

function createSortedButtons()
	for i=0,#arteList do -- 0 for fishing
		for j=1, #arteList do
			if arteList[j]["priority"] == i then
				if arteList[j]["type"] == "bag" then
					createArteButton(arteList[j]["id"], arteList[j]["container"], arteList[j]["slot"])
				elseif arteList[j]["type"] == "equipped" then
					createEquipedButton()
				end
			end
		end
	end
end

function arteToSpecc(id)
	local retID = speccList[id]["name"]
	if retID == nil then
		name = GetItemInfo(id)
		return name 
	end
	return retID
end
