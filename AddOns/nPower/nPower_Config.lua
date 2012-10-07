local M = icrowMedia

nPower = {
    position = {'CENTER', UIParent, -87, -62},	-- λ��
    sizeWidth = 200,							-- ���
    
    activeAlpha = 1,							-- ս���е�͸����
    inactiveAlpha = 0,							-- ս�����͸����
    emptyAlpha = 0,
    
    valueAbbrev = true,							-- �Ƿ���ʾ������(�罫16000��ʾΪ16.0k)
	valuePercent = true,						-- �Ƿ���ʾΪ�ٷֱ�(���Է���ֵ��Ч)
    
    valueFont = M.media.font,					-- ����ֵ����
    valueFontSize = 20,							-- ���ִ�С
    valueFontOutline = true,					-- �Ƿ����
    valueFontAdjustmentX = 0,					-- ���ֺ���ƫ��

    mana = {
        show = true,							-- �Ƿ���ʾ����ֵ
    },
    
    energy = {
        show = true,							-- �Ƿ���ʾ����ֵ
        showComboPoints = true,					-- �Ƿ���ʾ������
        
        comboColor = {							-- ��������ɫ
            [1] = {r = 1.0, g = 1.0, b = 1.0},
            [2] = {r = 1.0, g = 1.0, b = 1.0},
            [3] = {r = 1.0, g = 1.0, b = 1.0},
            [4] = {r = 0.9, g = 0.7, b = 0.0},
            [5] = {r = 1.0, g = 0.0, b = 0.0},
        },
        
        comboFont = M.media.font,				-- ��������������
        comboFontSize = 16,						-- ���ִ�С
        comboFontOutline = true,				-- �Ƿ����
    },
    
    focus = {
        show = true,							-- �Ƿ���ʾ����ֵ
    },
    
    rage = {
        show = true,							-- �Ƿ���ʾŭ��
    },
    
    rune = {
        show = true,							-- �Ƿ���ʾ����
        showRuneCooldown = false,				-- �Ƿ���ʾ������ȴ
        
        runeFont = M.media.font,				-- ������ȴ����
        runeFontSize = 16,						-- ���ִ�С
        runeFontOutline = true,					-- �Ƿ����
    },
}