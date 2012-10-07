  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  -----------------------------
  -- MEDIA
  -----------------------------
  cfg.auratex = "Interface\\Addons\\m_Buffs\\iconborder" 
  cfg.font = "Fonts\\Myriad.ttf"
  
  -----------------------------
  -- CONFIG
  -----------------------------
  cfg.iconsize = 30 									-- Buffs and debuffs size
  cfg.disable_timers = false							-- Disable buffs/debuffs timers
  cfg.timefontsize = 14									-- Time font size
  cfg.countfontsize = 14								-- Count font size
  cfg.spacing = 6										-- Spacing between icons
  cfg.timeYoffset = -14									-- Verticall offset value for time text field
  cfg.BUFFpos = {"TOPRIGHT","Minimap", "TOPLEFT", -10, 0} 		-- Buffs position
  cfg.DEBUFFpos = {"TOPRIGHT", "Minimap", "BOTTOMLEFT", -10, -6}	-- Debuffs position
  
  -- HANDOVER
  ns.cfg = cfg
