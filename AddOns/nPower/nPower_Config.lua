local M = icrowMedia

nPower = {
    position = {'CENTER', UIParent, -87, -62},	-- 位置
    sizeWidth = 200,							-- 宽度
    
    activeAlpha = 1,							-- 战斗中的透明度
    inactiveAlpha = 0,							-- 战斗外的透明度
    emptyAlpha = 0,
    
    valueAbbrev = true,							-- 是否显示短数字(如将16000显示为16.0k)
	valuePercent = true,						-- 是否显示为百分比(仅对法力值有效)
    
    valueFont = M.media.font,					-- 能量值字体
    valueFontSize = 20,							-- 文字大小
    valueFontOutline = true,					-- 是否描边
    valueFontAdjustmentX = 0,					-- 文字横向偏移

    mana = {
        show = true,							-- 是否显示法力值
    },
    
    energy = {
        show = true,							-- 是否显示能量值
        showComboPoints = true,					-- 是否显示连击点
        
        comboColor = {							-- 连击点颜色
            [1] = {r = 1.0, g = 1.0, b = 1.0},
            [2] = {r = 1.0, g = 1.0, b = 1.0},
            [3] = {r = 1.0, g = 1.0, b = 1.0},
            [4] = {r = 0.9, g = 0.7, b = 0.0},
            [5] = {r = 1.0, g = 0.0, b = 0.0},
        },
        
        comboFont = M.media.font,				-- 连击点文字字体
        comboFontSize = 16,						-- 文字大小
        comboFontOutline = true,				-- 是否描边
    },
    
    focus = {
        show = true,							-- 是否显示集中值
    },
    
    rage = {
        show = true,							-- 是否显示怒气
    },
    
    rune = {
        show = true,							-- 是否显示符能
        showRuneCooldown = false,				-- 是否显示符文冷却
        
        runeFont = M.media.font,				-- 符文冷却字体
        runeFontSize = 16,						-- 文字大小
        runeFontOutline = true,					-- 是否描边
    },
}