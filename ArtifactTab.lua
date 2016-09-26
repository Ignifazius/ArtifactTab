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

local speccList = {
	-- Fishing
	[133755] = L["Fishing"],
	-- DK
	[128292] = L["Frost"],
	[128403] = L["Unholy"],
	[128402] = L["Blood"],
	-- Druid
	[128821] = L["Guardian"],
	[128860] = L["Feral"],
	[128306] = L["Restoration"],
	[128858] = L["Balance"],
	-- Paladin
	[128823] = L["Holy"],
	[120978] = L["Retribution"],
	[128867] = L["Protection"],
	-- Rogue
	[134552] = L["Outlaw"],
	[128870] = L["Assassination"],
	[128476] = L["Sublety"],
	-- DH
	[128832] = L["Vengeance"],
	[128829] = L["Havoc"],
	-- Warlock
	[128941] = L["Destruction"],
	[128943] = L["Demonology"],
	[128942] = L["Affliction"],
	-- Mage
	[128820] = L["Fire"],
	[127528] = L["Arcane"],
	[128862] = L["Frost"],
	-- Priest
	[128825] = L["Holy"],
	[128868] = L["Discipline"],
	[128827] = L["Shadow"],
	-- Monk
	[128938] = L["Brewmaster"],
	[128937] = L["Mistweaver"],
	[128940] = L["Windwalker"],
	-- Warrior
	[128908] = L["Fury"],
	[128910] = L["Arms"],
	[128289] = L["Protection"],
	-- Shaman
	[128935] = L["Elemental"],
	[128911] = L["Restoration"],
	[128819] = L["Enhancement"],
	-- Hunter
	[128861] = L["Beast Mastery"],
	[128826] = L["Marksmanship"],	
	[128808] = L["Survival"],
}

local eventResponseFrame = CreateFrame("Frame", "Helper")
	eventResponseFrame:RegisterEvent("ADDON_LOADED");
	eventResponseFrame:RegisterEvent("BAG_UPDATE");
	eventResponseFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	--eventResponseFrame:RegisterEvent("PLAYER_ENTERING_WORLD");		
	
local function eventHandler(self, event, arg1 , arg2, arg3, arg4, arg5)
	if (event == "ADDON_LOADED") then
		scanArtes()
	end
	if (event == "BAG_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED") then
		clearList()
		scanArtes()
	end
end

eventResponseFrame:SetScript("OnEvent", eventHandler);


function clearList()
	for i=1,#btnList do
		btnList[i]:Hide()
	end
	btnList = {}
end


function scanArtes()
	--print("ping")
	lastFrame = PlayerTalentFrameTab3
	for container=1,5 do
		for slot=1,32 do
			--texture, count, locked, quality, readable, lootable, link, isFiltered, hasNoValue, itemID = GetContainerItemInfo(container, slot)
			_, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(container, slot)
			if quality == 6 then
				name = GetItemInfo(itemID)
				--print(container.." "..slot.." "..name.." "..quality)
				createArteButton(itemID, container, slot) --name
			end			
		end
	end
	createEquipedButton()
end

function createArteButton(name, container, slot)
	buttonArte = createButton(name, lastFrame)
	buttonArte:SetScript("OnClick", function()
		SocketContainerItem(container, slot)
	end)
	buttonArte:Show()
	--PanelTemplates_TabResize(buttonArte, 0);
	--print(PanelTemplates_GetTabWidth(buttonArte))
	table.insert(btnList, buttonArte)
	lastFrame = buttonArte;
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

function createEquipedButton()
	local slotId = GetInventorySlotInfo("MainHandSlot")
	local itemId = GetInventoryItemID("player", slotId)
	if itemId then -- somehow the ID is nil if the player logs in
		name, _, quality = GetItemInfo(itemId)
		if quality == 6 then
			buttonArte = createButton(itemId, lastFrame) --name		
			buttonArte:SetScript("OnClick", function()
				SocketInventoryItem(slotId)
			end)
			buttonArte:Show()
			table.insert(btnList, buttonArte)
			lastFrame = buttonArte;
		end
	end
end

function arteToSpecc(id)
	local retID = speccList[id]
	if retID == nil then
		name = GetItemInfo(id)
		return name 
	end
	return retID
end
