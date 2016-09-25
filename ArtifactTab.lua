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
local btnPos = 0
local lastFrame
local btnList = {}

lastFrame = PlayerTalentFrameTab3

local eventResponseFrame = CreateFrame("Frame", "Helper")
	eventResponseFrame:RegisterEvent("ADDON_LOADED");
	eventResponseFrame:RegisterEvent("BAG_UPDATE");
	eventResponseFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	
	
	local function eventHandler(self, event, arg1 , arg2, arg3, arg4, arg5)
		if (event == "ADDON_LOADED") then
			--PlayerTalentFrame_Refresh()
			scanArtes()
		end
		if (event == "BAG_UPDATE" or "PLAYER_EQUIPMENT_CHANGED") then
			clearList()
			scanArtes()
		end
	end
	
	eventResponseFrame:SetScript("OnEvent", eventHandler);


--[[
local b = CreateFrame("Button", "MyButton", UIParent, "UIPanelButtonTemplate")
	b:SetSize(80 ,22) -- width, height
	b:SetText("Button!")
	b:SetPoint("CENTER")
	b:SetScript("OnClick", function()
		scanArtes()
		b:Hide()
	end)
]]--

function clearList()
	for i=1,#btnList do
		btnList[i]:Hide()
	end
	btnList = {}
end


function scanArtes()
	lastFrame = PlayerTalentFrameTab3
	for container=1,5 do
		for slot=1,32 do
			--texture, count, locked, quality, readable, lootable, link, isFiltered, hasNoValue, itemID = GetContainerItemInfo(container, slot)
			_, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(container, slot)
			if quality == 6 then
				name = GetItemInfo(itemID)
				--print(container.." "..slot.." "..name.." "..quality)
				createArteButton(name, container, slot)
			end			
		end
	end
	createEquipedButton()
end

function createArteButton(name, container, slot)
	buttonArte = CreateFrame("Button",name,PlayerTalentFrame,"UIPanelButtonTemplate")
	buttonArte:SetPoint("LEFT", lastFrame ,"RIGHT", 0, 0)
	--bFontString = buttonArte:CreateFontString()
	buttonArte:SetText(name)
	--h = bFontString:GetStringHeight()
	--w = bFontString:GetStringWidth()
	local lng = name:len()
	buttonArte:SetSize(lng*8,22)
	--buttonArte:SetSize(w,h)
	buttonArte:SetText(name)
	buttonArte:SetScript("OnClick", function()
		SocketContainerItem(container, slot)
	end)
	buttonArte:Show()
	table.insert(btnList, buttonArte)
	lastFrame = buttonArte;	
end

function createEquipedButton()
	local slotId = GetInventorySlotInfo("MainHandSlot")
	local itemId = GetInventoryItemID("player", slotId)
	name, _, quality = GetItemInfo(itemId)
	if quality == 6 then
		buttonArte = CreateFrame("Button",name,PlayerTalentFrame,"UIPanelButtonTemplate")
		buttonArte:SetPoint("LEFT", lastFrame ,"RIGHT", 0, 0)
		buttonArte:SetText(name)
		local lng = name:len()
		buttonArte:SetSize(lng*8,22)
		buttonArte:SetScript("OnClick", function()
			SocketInventoryItem(slotId)
		end)
		buttonArte:Show()
		table.insert(btnList, buttonArte)
		lastFrame = buttonArte;
	end
end