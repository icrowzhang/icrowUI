-- based on Sora's DBM by Neavo @ ngacn.cc
local M = icrowMedia

-- skin boss functions
local SkinBossTitle=function()
	local anchor=DBMBossHealthDropdown:GetParent()
	if not anchor.styled then
		local header={anchor:GetRegions()}
			if header[1]:IsObjectType("FontString") then
				header[1]:Hide()
				anchor.styled=true	
			end
		header=nil
	end
	anchor=nil
end

local SkinBoss=function()
	local count = 1
	while (_G[format("DBM_BossHealth_Bar_%d", count)]) do
		local bar = _G[format("DBM_BossHealth_Bar_%d", count)]
		local background = _G[bar:GetName().."BarBorder"]
		local progress = _G[bar:GetName().."Bar"]
		local name = _G[bar:GetName().."BarName"]
		local timer = _G[bar:GetName().."BarTimer"]
		local prev = _G[format("DBM_BossHealth_Bar_%d", count-1)]	

		if (count == 1) then
			local _, anch, _ ,_, _ = bar:GetPoint()
			bar:ClearAllPoints()
			if DBM_SavedOptions.HealthFrameGrowUp then
				bar:SetPoint("BOTTOM", anch, "TOP" , 0 , 12)
			else
				bar:SetPoint("TOP", anch, "BOTTOM" , 0, -14)
			end
		else
			bar:ClearAllPoints()
			if DBM_SavedOptions.HealthFrameGrowUp then
				bar:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, 26)
			else
				bar:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -26)
			end
		end

		if not bar.styled then
			bar:SetHeight(5)
			M.CreateBG(bar)
			M.CreateSD(bar)
			background:SetNormalTexture(nil)
			bar.styled=true
		end	

		if not progress.styled then
			progress:SetStatusBarTexture(M.media.statusbar)
			progress.styled=true
		end				
		progress:ClearAllPoints()
		progress:SetPoint("TOPLEFT", bar)
		progress:SetPoint("BOTTOMRIGHT", bar)

		if not name.styled then
			name:ClearAllPoints()
			name:SetPoint("LEFT", bar, "LEFT", 4, 9)
			name:SetFont(M.media.font, 12, "THINOUTLINE")
			name:SetJustifyH("LEFT")
			name.styled=true
		end

		if not timer.styled then
			timer:ClearAllPoints()
			timer:SetPoint("RIGHT", bar, "RIGHT", -4, 9)
			timer:SetFont(M.media.font, 12, "THINOUTLINE")
			timer:SetJustifyH("RIGHT")
			timer.styled=true
		end
		count = count + 1
	end
end

-- main event frame
local Event = CreateFrame("Frame")
Event:RegisterEvent("PLAYER_LOGIN")
Event:SetScript("OnEvent", function()
	if IsAddOnLoaded("DBM-Core") then
		-- skin boss
		hooksecurefunc(DBM.BossHealth,"Show",SkinBossTitle)
		hooksecurefunc(DBM.BossHealth,"AddBoss",SkinBoss)
		hooksecurefunc(DBM.BossHealth,"UpdateSettings",SkinBoss)
		-- skin timer bars
		hooksecurefunc(DBT, "CreateBar", function(self)
			for bar in self:GetBarIterator() do
				if not bar.injected then
					local frame = bar.frame
					local tbar = _G[frame:GetName().."Bar"]
					local spark = _G[frame:GetName().."BarSpark"]
					local texture = _G[frame:GetName().."BarTexture"]
					local icon1 = _G[frame:GetName().."BarIcon1"]
					local icon2 = _G[frame:GetName().."BarIcon2"]
					local name = _G[frame:GetName().."BarName"]
					local timer = _G[frame:GetName().."BarTimer"]

					if not frame.styled then
						frame:SetScale(1)
						frame:SetHeight(5)
						M.CreateBG(frame)
						M.CreateSD(frame)
						frame.styled = true
					end

					if not tbar.styled then
						tbar:SetAllPoints(frame)
						frame.styled = true
					end

					if not spark.killed then
						spark:SetAlpha(0)
						spark:SetTexture(nil)
						spark.killed = true
					end
					
					if not icon1.killed then
						icon1:SetAlpha(0)
						icon1:SetTexture(nil)
						icon1.killed = true
					end
					
					if not icon2.killed then
						icon2:SetAlpha(0)
						icon2:SetTexture(nil)
						icon2.killed = true
					end
					
					if not name.styled then
						name:ClearAllPoints()
						name:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 2, -3.5)
						name:SetFont(M.media.font, 12, "THINOUTLINE")
						name:SetShadowOffset(0, 0)
						name.SetFont = function() end
						name.styled = true
					end

					if not timer.styled then
						timer:ClearAllPoints()
						timer:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -2, -3.5)					
						timer:SetFont(M.media.font, 12, "THINOUTLINE")
						timer:SetShadowOffset(0, 0)
						timer.SetFont = function() end
						timer.styled = true
					end

					frame:Show()
					bar:Update(0)
					bar.injected = true
				end
			end
		end)
		-- options
		DBM_SavedOptions.Enabled = true
		DBT_SavedOptions["DBM"].Scale = 1
		DBT_SavedOptions["DBM"].HugeScale = 1
		DBT_SavedOptions["DBM"].Texture = M.media.statusbar
		DBT_SavedOptions["DBM"].ExpandUpwards = false
		DBT_SavedOptions["DBM"].BarXOffset = 0
		DBT_SavedOptions["DBM"].BarYOffset = 18
		DBT_SavedOptions["DBM"].IconLeft = true
		DBT_SavedOptions["DBM"].Texture = "Interface\\Buttons\\WHITE8x8"
		DBT_SavedOptions["DBM"].IconRight = false
	end
end)