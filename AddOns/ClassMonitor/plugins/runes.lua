-- Runes plugin (based on fRunes by Krevlorne [https://github.com/Krevlorne])
local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end
local UI = Engine.UI

Engine.CreateRunesMonitor = function(name, updatethreshold, autohide, orientation, anchor, width, height, spacing, colors, runemap)
	-- Create the frame
	local cmRunes = CreateFrame("Frame", "Frame_"..name)
	-- Create the runes
	local runes = {}
	for i = 1, 6 do
		local rune = CreateFrame("Frame", name, UI.BattlerHider)
		rune:SetTemplate()
		rune:SetFrameStrata("BACKGROUND")
		rune:Size(width, height)
		if i == 1 then
			rune:Point(unpack(anchor))
		else
			rune:Point("LEFT", runes[i-1], "RIGHT", spacing, 0)
		end
		rune.status = CreateFrame("StatusBar", "cmRunesRuneStatus"..i, rune)
		rune.status:SetStatusBarTexture(UI.NormTex)
		rune.status:SetStatusBarColor(unpack(colors[math.ceil(runemap[i]/2)]))
		rune.status:SetFrameLevel(6)
		rune.status:SetMinMaxValues(0, 10)
		rune.status:Point("TOPLEFT", rune, "TOPLEFT", 2, -2)
		rune.status:Point("BOTTOMRIGHT", rune, "BOTTOMRIGHT", -2, 2)
		rune.status:SetOrientation(orientation)

		tinsert(runes, rune)
	end

	-- Function to update runes
	local function UpdateRune(id, start, duration, finished)
		local rune = runes[id]

		rune.status:SetStatusBarColor(unpack(colors[GetRuneType(runemap[id])]))
		rune.status:SetMinMaxValues(0, duration)

		if finished then
			rune.status:SetValue(duration)
		else
			rune.status:SetValue(GetTime() - start)
		end
	end

	local OnUpdate = CreateFrame("Frame")
	OnUpdate.TimeSinceLastUpdate = 0
	local updateFunc = function(self, elapsed)
		self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

		if self.TimeSinceLastUpdate > updatethreshold then
			local runesReady = 0
			for i = 1, 6 do
				local start, duration, finished = GetRuneCooldown(runemap[i])
				UpdateRune(i, start, duration, finished)
				if finished then runesReady = runesReady + 1 end
			end
			if runesReady == 6 and not InCombatLockdown() then
				OnUpdate:SetScript("OnUpdate", nil)
			end
			self.TimeSinceLastUpdate = 0
		end
	end
	OnUpdate:SetScript("OnUpdate", updateFunc)

	cmRunes:RegisterEvent("PLAYER_REGEN_DISABLED")
	cmRunes:RegisterEvent("PLAYER_REGEN_ENABLED")
	cmRunes:RegisterEvent("PLAYER_ENTERING_WORLD")
	cmRunes:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_DISABLED" then
			if autohide then
				UIFrameFadeIn(self, (0.3 * (1-self:GetAlpha())), self:GetAlpha(), 1)
			end
			OnUpdate:SetScript("OnUpdate", updateFunc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			if autohide then
				UIFrameFadeOut(self, (0.3 * (0+self:GetAlpha())), self:GetAlpha(), 0)
			end
			--OnUpdate:SetScript("OnUpdate", nil)
		elseif event == "PLAYER_ENTERING_WORLD" then
			RuneFrame:ClearAllPoints()
			if not InCombatLockdown() then
				if autohide then
					cmRunes:SetAlpha(0)
				else
					cmRunes:SetAlpha(1)
				end
			end
		end
	end)

	-- Hide blizzard runeframe
	-- RuneFrame:Hide()
	-- RuneFrame:SetScript("OnShow", function(self)
		-- self:Hide()
	-- end)
	RuneFrame:Kill()

	return runes[1]
end