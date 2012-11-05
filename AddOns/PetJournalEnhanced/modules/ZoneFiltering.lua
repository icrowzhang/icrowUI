﻿ZoneFiltering = PetJournalEnhanced:NewModule("ZoneFiltering","AceEvent-3.0")
local LibPetJournal = LibStub("LibPetJournal-2.0")
local zoneIDs = PetJournalEnhanced:GetModule("ZoneIDs")


ZoneFiltering.zoneFixes = {
	["Valley of Four Winds"] = "Valley of the Four Winds",
	["Booty Bay"] = "The Cape of Stranglethorn",
	["Terokkar Forest (Fishing Nodes)"] = "Terokkar Forest",
	["Shattrath"] = "Shattrath City",
	["Un'goro Crater"] = "Un'Goro Crater",
	["Lor'danel"] = "Darkshore",
	["Stormwind"] = "Stormwind City",
	["Jade Forest"] = "The Jade Forest",
}

local function split(self,sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

local function trim(s)
  return s:match'^%s*(.*%S)' or ''
end

function ZoneFiltering:Initialize()
	if not self.initialized then
		self.zoneTree, self.zones2Pets = self:CreateMapping()
		self.initialized = true
	end
end


function ZoneFiltering:GetZoneTree()
	if not self.initialized then
		self:Initialize()
	end
	return self.zoneTree
end

function ZoneFiltering:GetZones2Pets()
	if not self.initialized then
		self:Initialize()
	end
	return self.zones2Pets
end

--returns a list of zones from a sourceTExt
function ZoneFiltering:GetZones(sourceText,id)
	local langauge = GetLocale()
	local zones = {}
	sourceText = string.gsub(sourceText, "|n", "|")
	sourceText = string.gsub(sourceText, "|r", "")
--~ 	sourceText = string.gsub(sourceText, "|cFF%x%x%x%x%x%x","")
	local splits = split(sourceText,"|")
	for i=1,#splits do
		if string.find(splits[i],"宠物对战：") then
			zones = string.match(splits[i], "宠物对战：(.*)")
			zones = split(zones,"、")
		elseif string.find(splits[i],"地区：") then
			zones = string.match(splits[i], "地区：".."(.*)")
			zones = split(zones,"、")
		end
	end
	local tempz = {}
	for i=1,#zones do
		if zones[i] then
			tempz[#tempz+1] = trim(zones[i])
		end
	end
--~ 	if id==412	then print("asd") Ho=tempz;Hsq=zones end
	return tempz
end

--Create a zone tree for the menu system and a list of zones to species id's
function ZoneFiltering:CreateMapping()
	local mapping = self:CreateZoneList()
	local zoneMap = self:ScanPets()
	mapping = self:MergeZoneLists(mapping,zoneMap)
	return mapping,zoneMap
end

--removes unused zones from the zone mapping
function ZoneFiltering:MergeZoneLists(mapping,zoneMap)
	for continent,zones in pairs(mapping) do
		for zone, _ in pairs(zones) do
			if zoneMap[zone] then
				mapping[continent][zone] = true
			else
				mapping[continent][zone] = nil
			end
		end
		if next(zones) == nil then
			mapping[continent] = nil
		end
	end

	local unknown = "未知"
	for zone, _ in pairs(zoneMap) do
		local found = false
		for continent,_ in pairs(mapping) do
			if mapping[continent][zone] then
				found = true
				break;
			end
		end
		if not found then
--~ 		print(zone)
			if not mapping[unknown] then mapping[unknown] ={} end
			mapping[unknown][zone] = true
		end
	end

	return mapping
end

--builds a list of zones for enabling and disabling filtering
--/lb code ZoneFiltering:CreateZoneList()
function ZoneFiltering:CreateZoneList()
	local mapping = {}
	local continentNames = {GetMapContinents()}

	for continentID, zoneIDs in pairs(zoneIDs.continents) do
		local continentName =  continentNames[continentID]


		local zones = {}
		local zonesOverflow = {}
		local breakPoint = #zoneIDs
		if #zoneIDs > 20 then
			breakPoint = floor(#zoneIDs/2)
			local breakCharacter = string.sub(GetMapNameByID(zoneIDs[breakPoint]),1,1)
			for i = breakPoint, #zoneIDs do
				local firstCharactor = string.sub(GetMapNameByID(zoneIDs[i]),1,1)
				if breakCharacter ~= firstCharactor then
					breakPoint = i-1
					break
				end
			end
		end

		for i=1,breakPoint do
			local zoneName = GetMapNameByID(zoneIDs[i])
			zones[zoneName] = true
		end
		for i= breakPoint+1, #zoneIDs do
			local zoneName = GetMapNameByID(zoneIDs[i])
			zonesOverflow[zoneName] = true
		end

		if  breakPoint == #zoneIDs then
			mapping[continentName] = zones
		else
			local breakCharactor = string.sub(GetMapNameByID(zoneIDs[breakPoint]),1,1)
			local nextCharactor = string.char(breakCharactor:byte()+1)
			local firstRange = " A-"..breakCharactor
			local secondRange = " "..nextCharactor.."-Z"
			mapping[continentName..firstRange] = zones
			mapping[continentName..secondRange] = zonesOverflow
		end

	end

	for instanceGroupName, instances in pairs(zoneIDs.instances) do
		mapping[instanceGroupName] = {}
		for i=1, #instances do
			local zoneName = GetMapNameByID(instances[i])
			mapping[instanceGroupName][zoneName] = true
		end
	end

	return mapping
end


--Builds a mapping of zone names to species id's
function ZoneFiltering:ScanPets()
    local zoneMap = {}
	for i,id in LibPetJournal:IterateSpeciesIDs() do
        local name, _, _, _, sourceText = C_PetJournal.GetPetInfoBySpeciesID(id)
			local zones = self:GetZones(sourceText,id)
			for j=1,#zones do
				if not zoneMap[zones[j]] then
					if zones[j] then
					zoneMap[zones[j]] = {}
					end
				end
				table.insert(zoneMap[zones[j]],id)
			end
    end
	return zoneMap
end

