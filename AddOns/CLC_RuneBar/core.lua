local M = icrowMedia

local class, _ = select(2, UnitClass("player"))
if class ~= "DEATHKNIGHT" then return end

local config = {
	point = {"CENTER", UIParent, "BOTTOMLEFT", 784, 404},
	font = M.media.pixelfont,
}

local curtime
local RUNE_COLOUR = {{1, 0, 0},{0, 0.95, 0},{0, 1, 1},{0.8, 0.1, 1}} --Blood,  Unholy,  Frost,  Death
local RuneTextue = { 
	"Interface\\AddOns\\CLC_RuneBar\\Blood",
	"Interface\\AddOns\\CLC_RuneBar\\Unholy",
	"Interface\\AddOns\\CLC_RuneBar\\Frost",
	"Interface\\AddOns\\CLC_RuneBar\\Death",
}

local function CreateRuneBar()
	frame = CreateFrame('StatusBar', nil, RuneBarHolder)
	frame:SetHeight(80)
	frame:SetWidth(8)
	frame:SetOrientation("VERTICAL")
	frame:SetStatusBarTexture('Interface\\BUTTONS\\WHITE8X8', 'OVERLAY')			
	frame:SetStatusBarColor(0.2, 0.2, 0.2, 0.75)		
	frame:GetStatusBarTexture():SetBlendMode("DISABLE")
	frame:Raise()
	
	M.CreateBG(frame, 0)
	M.CreateSD(frame)
	
	frame.back = frame:CreateTexture(nil, 'BACKGROUND', frame)
	frame.back:SetAllPoints(frame)
	frame.back:SetBlendMode("DISABLE")
	
	frame.Spark = frame:CreateTexture(nil, 'OVERLAY')
	frame.Spark:SetHeight(16)
	frame.Spark:SetWidth(16)
	frame.Spark.c = CreateFrame('Cooldown', nil, frame)
	frame.Spark.c:SetAllPoints(frame)
	frame.Spark.c.lock = false
	return frame
end

local function UpdateRune(i)
	local start, cooldown = GetRuneCooldown(i)
	local r, g, b = unpack(RUNE_COLOUR[GetRuneType(i)])
	local cdtime = start + cooldown - curtime
	
	RuneBars[i]:SetMinMaxValues(0, cooldown)
	RuneBars[i]:SetValue(cdtime)
	RuneBars[i].back:SetTexture(r, g, b, 1)
	RuneBars[i].Spark:SetTexture(RuneTextue[GetRuneType(i)])
	RuneBars[i].Spark:SetPoint("CENTER", RuneBars[i], "BOTTOM", 0, (cdtime <= 0 and 0) or (cdtime < cooldown and (80*cdtime)/cooldown) or 80)
	
	if cdtime > 0 then
		RuneBars[i].Spark.c.lock = false
		RuneBars[i].back:SetTexture(r, g, b, 0.2)
		RuneBars[i]:SetAlpha(0.75)
	end
	
	if (cdtime <= 0) and (not RuneBars[i].Spark.c.lock) then
		RuneBars[i].Spark.c:SetCooldown(0,0)
		RuneBars[i].Spark.c.lock = true
		RuneBars[i].back:SetTexture(r, g, b, 1)
		RuneBars[i]:SetAlpha(1)
	end
end

-- Create main frame
local RuneBarHolder = CreateFrame("Button", "CLCDK_RuneBarHolder", UIParent)
RuneBarHolder:SetHeight(100)
RuneBarHolder:SetWidth(110)
RuneBarHolder:SetPoint(unpack(config.point))
RuneBarHolder:SetFrameStrata("BACKGROUND")
RuneBars = {}

-- OnUpdate function
local function Update()
	curtime = GetTime()	
	for i = 1, 6 do UpdateRune(i) end
end

local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) - elapsed
	if self.elapsed < 0 then
		Update()
		self.elapsed = 0.1
	end
end

-- main event
RuneBarHolder:RegisterEvent("PLAYER_ENTERING_WORLD")
RuneBarHolder:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		RuneBars[1] = CreateRuneBar()
		RuneBars[1]:SetPoint("BottomLeft", RuneBarHolder, "BottomLeft", 6, 10)
		for i = 2, 6 do  
			RuneBars[i] = CreateRuneBar()
			RuneBars[i]:SetPoint("BottomLeft",RuneBars[i-1],"BottomRight", 10, 0)
		end
		self:Hide()
		for i = 1, 6 do RuneBars[i]:Hide() end
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
	elseif event == "PLAYER_REGEN_DISABLED" then
		self:Show()
		for i = 1, 6 do RuneBars[i]:Show() end
		self:SetScript("OnUpdate", OnUpdate)
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:Hide()
		for i = 1, 6 do RuneBars[i]:Hide() end
		self:SetScript("OnUpdate", function() end)
	end
end)