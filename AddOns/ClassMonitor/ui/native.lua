local ADDON_NAME, Engine = ...
local L = Engine.Locales
local UI = Engine.UI
local M = icrowMedia

if Engine.Enabled then return end -- UI already found
-- No specific UI found, use native one

Engine.Enabled = true

----------------------------------
-- Create a pseudo Tukui look&feel
----------------------------------

-- Credits to Tukz
local backdropcolor = { .1,.1,.1 }
local bordercolor = { .6,.6,.6 }
local blank = [[Interface\AddOns\ClassMonitor\medias\blank]]
local normTex = [[Interface\AddOns\ClassMonitor\medias\normTex]]
local normalFont = ChatFontNormal:GetFont()
local ufFont = ChatFontNormal:GetFont()

local floor = math.floor
local texture = blank
local backdropr, backdropg, backdropb, backdropa, borderr, borderg, borderb = 0, 0, 0, 1, 0, 0, 0

--local mult = 1
local resolution = GetCVar("gxResolution")
local uiscale = min(2, max(.64, 768/string.match(resolution, "%d+x(%d+)")))
local mult = 768 / string.match(GetCVar("gxResolution"), "%d+x(%d+)") / uiscale
--print(tostring(mult).."  "..tostring(resolution).."  "..tostring(uiscale))
local Scale = function(x)
	return mult*math.floor(x/mult+.5)
end

local function Size(frame, width, height)
	frame:SetSize(Scale(width), Scale(height or width))
end

local function Width(frame, width)
	frame:SetWidth(Scale(width))
end

local function Height(frame, height)
	frame:SetHeight(Scale(height))
end

local function Point(obj, arg1, arg2, arg3, arg4, arg5)
	-- anyone has a more elegant way for this?
	if type(arg1)=="number" then arg1 = Scale(arg1) end
	if type(arg2)=="number" then arg2 = Scale(arg2) end
	if type(arg3)=="number" then arg3 = Scale(arg3) end
	if type(arg4)=="number" then arg4 = Scale(arg4) end
	if type(arg5)=="number" then arg5 = Scale(arg5) end

	obj:SetPoint(arg1, arg2, arg3, arg4, arg5)
end

local function SetTemplate(f, t, tex)
	local bg = M.CreateBG(f)
	local sd = M.CreateSD(f)
	bg:Point("TOPLEFT", f, 1, -1)
	bg:Point("BOTTOMRIGHT", f, -1, 1)
	sd:Point("TOPLEFT", f, -2, 2)
	sd:Point("BOTTOMRIGHT", f, 2, -2)
end

local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = noop
	object:Hide()
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.Size then mt.Size = Size end
	if not object.Width then mt.Width = Width end
	if not object.Height then mt.Height = Height end
	if not object.Point then mt.Point = Point end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.Kill then mt.Kill = Kill end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end

-- Hider Secure (mostly used to hide stuff while in pet battle)  ripped from Tukui
local petBattleHider = CreateFrame("Frame", "ClassMonitorPetBattleHider", UIParent, "SecureHandlerStateTemplate")
petBattleHider:SetAllPoints(UIParent)
RegisterStateDriver(petBattleHider, "visibility", "[petbattle] hide; show")

local ResourceColor = {
	["MANA"] = {0.00, 0.00, 1.00},
	["RAGE"] = {1.00, 0.00, 0.00},
	["FOCUS"] = {1.00, 0.50, 0.25},
	["ENERGY"] = {1.00, 1.00, 0.00},
	["RUNES"] = {0.50, 0.50, 0.50},
	["RUNIC_POWER"] = {0.00, 0.82, 1.00},
	["AMMOSLOT"] = {0.80, 0.60, 0.00},
	["FUEL"] = {0.00, 0.55, 0.50},
	["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
	["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17}
}

--
UI.BorderColor = bordercolor
UI.BattlerHider = petBattleHider
UI.NormTex = normTex
UI.MyClass = select(2, UnitClass("player"))
UI.MyName = UnitName("player")

UI.SetFontString = function(parent, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(ufFont, 16, "OUTLINE")
	fs:SetJustifyH("LEFT")
	return fs
end

UI.ClassColor = function(className)
	local class = className or UI.MyClass
	return { RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b}
end

UI.PowerColor = function(resourceName)
	return ResourceColor[resourceName]
end

UI.HealthColor = function(unit)
	local color = {1, 1, 1, 1}
	if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = {.6,.6,.6}
	elseif not UnitIsConnected(unit) then
		color = {.6, .6, .6}
	elseif UnitIsPlayer(unit) or (UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local class = select(2, UnitClass(unit))
		color = { RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b}
	elseif UnitReaction(unit, "player") then
		color = { 218/255, 197/255, 92/255 } -- TODO
	end
	return color
end

local AllowFrameMoving = {}
UI.CreateMover = function(name, width, height, anchor, text)
	local mover = CreateFrame("Frame", name, UIParent)
	mover:SetTemplate()
	mover:SetBackdropBorderColor(1, 0, 0, 1)
	mover:SetFrameStrata("HIGH")
	mover:SetMovable(true)
	mover:Size(width, height)
	mover:Point(unpack(anchor))

	mover.text = UI.SetFontString(mover, 12)
	mover.text:SetPoint("CENTER")
	mover.text:SetText(text)
	mover.text.Show = function() mover:Show() end
	mover.text.Hide = function() mover:Hide() end
	mover:Hide()

	tinsert(AllowFrameMoving, mover)

	return mover
end

local enable = true
local origa1, origf, origa2, origx, origy
local function Move()
	for i = 1, getn(AllowFrameMoving) do
		if AllowFrameMoving[i] then
			if enable then
				AllowFrameMoving[i]:EnableMouse(true)
				AllowFrameMoving[i]:RegisterForDrag("LeftButton", "RightButton")
				AllowFrameMoving[i]:SetScript("OnDragStart", function(self) 
					origa1, origf, origa2, origx, origy = AllowFrameMoving[i]:GetPoint() 
					self.moving = true 
					self:SetUserPlaced(true) 
					self:StartMoving() 
				end)
				AllowFrameMoving[i]:SetScript("OnDragStop", function(self) 
					self.moving = false 
					self:StopMovingOrSizing() 
				end)
				if AllowFrameMoving[i].text then 
					AllowFrameMoving[i].text:Show() 
				end
			else
				AllowFrameMoving[i]:EnableMouse(false)
				if AllowFrameMoving[i].moving == true then
					AllowFrameMoving[i]:StopMovingOrSizing()
					AllowFrameMoving[i]:ClearAllPoints()
					AllowFrameMoving[i]:SetPoint(origa1, origf, origa2, origx, origy)
				end
				if AllowFrameMoving[i].text then
					AllowFrameMoving[i].text:Hide()
				end
				AllowFrameMoving[i].moving = false
			end
		end
	end
	enable = not enable
end

SLASH_CLASSMONITOR1 = "/cm"
SLASH_CLASSMONITOR2 = "/classmonitor"

local function SlashHandlerShowHelp()
	print(string.format(L.classmonitor_help_use, SLASH_CLASSMONITOR1, SLASH_CLASSMONITOR2))
	print(string.format(L.classmonitor_help_move, SLASH_CLASSMONITOR1))
end

local function SlashHandlerMove(args)
	Move()
	if not enable then
		print(string.format(L.classmonitor_command_stopmoving, SLASH_CLASSMONITOR1))
	end
end

SlashCmdList["CLASSMONITOR"] = function(cmd)
	local switch = cmd:match("([^ ]+)")
	local args = cmd:match("[^ ]+ (.+)")
	if switch == "move" then
		SlashHandlerMove(args)
	else
		SlashHandlerShowHelp()
	end
end