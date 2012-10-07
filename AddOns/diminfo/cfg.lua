local addon, ns = ...
local cfg = CreateFrame("Frame")

-- enable modules
cfg.Bags = true
cfg.BagsPoint = {"bottomleft", UIParent, 250, 7}

cfg.Friends = true
cfg.FriendsPoint = {"bottomleft", UIParent, 87, 7}

cfg.Gold = true
cfg.GoldPoint = {"bottomright", UIParent, -15, 7}

cfg.Guild = true
cfg.GuildPoint = {"bottomleft", UIParent, 170, 7}

cfg.Memory = true
cfg.MemoryPoint = {"bottomleft", UIParent, 15, 7}
cfg.MaxAddOns = 20

cfg.System = true
cfg.SystemPoint = {"bottomright", UIParent, -160, 7}

--Fonts and Colors
cfg.Fonts = {"Fonts\\ROADWAY.ttf", 15, "outline"}
cfg.ColorClass = true

ns.cfg = cfg