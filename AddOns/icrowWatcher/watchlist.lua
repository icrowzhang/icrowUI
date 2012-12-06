-- thanks to EventAlert for some spell list

local addon, ns = ...
local cfg = ns.Config

ns.Watchlist = {
	-- 全职业
	["ALL"] = {
		{
			Name = "玩家Debuff",
			Type = "debuff", UnitID = "player",
			Direction = "LEFT", Interval = 4,
			IconSize = 54,
			Pos = {"CENTER", UIParent, "CENTER", -91, 9},
			List = {
				77606, -- 黑暗模拟 (死亡骑士)
				87023, -- 灸灼 (法师)
				--36032, -- 奥术充能 (法师)
				124275, -- 轻度醉拳 (武僧)
				124274, -- 中度醉拳 (武僧)
				124273, -- 重度醉拳 (武僧)
				
                -- PVE
				-- 魔古山宝库
				116784, -- 野性火花(受阻者魔封)
				116417, 116574, 116576, 116577, -- 奥术回响(受阻者魔封) *不知道哪个是真的, 待测*
				116161, 116260, -- 灵魂越界(缚灵者戈拉亚) *不知道哪个是真的, 待测*
				116272, -- 放逐(缚灵者戈拉亚)
				
				-- 恐惧之心
				123017, -- 无影击(刀锋领主塔亚克)
				123788, -- 恐怖嚎叫(大女皇夏柯希尔)
			},
		},
	},

	-- 德鲁伊
	["DRUID"] = {
		{
			Name = "玩家Buff",
			Type = "buff", UnitID = "player",
			Direction = "LEFT", Interval = 6,
			IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", -79, -52},
			List = {
				2825, -- 嗜血
				32182, -- 英勇气概
				80353, -- 时间扭曲
				16870, -- 清晰预兆
				16886, -- 自然的优雅
				48517, -- 日蚀			
				48518, -- 月蚀
				48391, -- 枭兽狂乱
				81192, -- 月光淋漓
				93400, -- 坠星
				50334, -- 狂暴(猫&熊)
				52610, -- 野蛮咆哮(猫)
				69369, -- 掠食者的迅捷
				61336, -- 生存本能
				22842, -- 狂暴回复
				106922, -- 乌索克之力
				62606, -- 野蛮防御
				22812, -- 树皮术
				117679, -- 化身: 生命之树
				29166, -- 激活
			},
		},
		{
			Name = "目标Debuff",
			Type = "debuff", UnitID = "target",
			Direction = "RIGHT", Interval = 6,
			IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", 79, -52},
			List = {
				115798, -- 虚弱打击
				33745, -- 割伤
				1079, -- 割裂
				1822, -- 斜掠
				8921, -- 月火术
				93402, -- 日炎术
			},
		},
	},
	
	-- 猎人
	["HUNTER"] = {
		{
			Name = "玩家Buff",
			Type = "buff", UnitID = "player",
			Direction = "LEFT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", -79, -52},
			List = {
				2825, -- 嗜血
				32182, -- 英勇气概
				80353, -- 时间扭曲
				3045, -- 急速射击
				34471, -- 野兽之心
				34720, -- 狩猎刺激
				56453, -- 荷枪实弹
				70728, -- 攻击弱点
				82925, -- 准备,端枪,瞄准... ...
				82926, -- 开火!
			},
		},
		{
			Name = "目标Debuff",
			Type = "debuff", UnitID = "target",
			Direction = "RIGHT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", 79, -52},
			List = {
				118253, -- 毒蛇钉刺
				3674, -- 黑箭
				53301, -- 爆炸射击
			},
		},
	},
	
	-- 法师
	["MAGE"] = {
		{
			Name = "玩家Buff",
			Type = "buff", UnitID = "player",
			Direction = "LEFT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", -79, -52},
			List = {
				2825, -- 嗜血
				32182, -- 英勇气概
				80353, -- 时间扭曲
				12042, -- 奥术强化
				12051, -- 唤醒
				79683, -- 奥术飞弹!
				48107, -- 热力迸发
				48108, -- 炎爆术!
				44544, -- 寒冰指
				57761, -- 冰冷智慧
				110909, -- 操控时间
				116267, -- 咒术吸收(法强提高效果)
				116257, -- 祈愿者之能
				12043, -- 气定神闲
			},
		},
		{
			Name = "目标Debuff",
			Type = "debuff", UnitID = "target",
			Direction = "RIGHT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", 79, -52},
			List = {
				114923, -- 虚空风暴
				112948, -- 寒冰炸弹
				116, -- 寒冰箭
				44457, -- 活体炸弹
				11366, -- 炎爆术
			},
		},
	},
	
	-- 战士
	["WARRIOR"] = {
		{
			Name = "玩家Buff",
			Type = "buff", UnitID = "player",
			Direction = "LEFT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", -79, -52},
			List = {
				2825, -- 嗜血
				32182, -- 英勇气概
				80353, -- 时间扭曲
				871, -- 盾墙
				2565, -- 盾牌格挡			
				12328, -- 横扫攻击
				12975, -- 破釜沉舟
				23920, -- 法术反射
				32216, -- 胜利
				46916, -- 血脉贲张
				50227, -- 剑盾猛攻
				52437, -- 猝死
				55694, -- 狂怒回复
				65156, -- 顺劈斩
				85730, -- 致命平静
				85739, -- 绞肉机
				112048, -- 盾牌屏障
				115945, -- 断筋雕文
				122016, -- 激动
				122510, -- 最后通牒
				125831, -- 血之气息
				131116, -- 怒击!
			},
		},	
		{
			Name = "目标Debuff",
			Type = "debuff", UnitID = "target",
			Direction = "RIGHT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", 79, -52},
			List = {
				115798, -- 虚弱打击
				1160, -- 挫志怒吼
			},
		},
	},
	
	-- 萨满
	["SHAMAN"] = {
		{
			Name = "玩家Buff",
			Type = "buff", UnitID = "player",
			Direction = "LEFT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", -79, -52},
			List = {
				2825, -- 嗜血
				32182, -- 英勇气概
				80353, -- 时间扭曲
				--324, -- 闪电之盾
				16246, -- 节能施法
				30823, -- 萨满之怒
				53390, -- 潮汐奔涌
				--53817, -- 漩涡武器
				77661, -- 灼热烈焰
				77762, -- 熔岩奔腾
				79206, -- 灵魂行者的恩赐
				108271, -- 星界转移
			},
		},
		{
			Name = "目标Debuff",
			Type = "debuff", UnitID = "target",
			Direction = "RIGHT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", 79, -52},
			List = {
				17364, -- 风暴打击
				8050, -- 烈焰震击
				8042, -- 大地震击
				8056, -- 冰霜震击
			},
		},
	},
	
	-- 圣骑士
	["PALADIN"] = {
		{
			Name = "玩家Buff",
			Type = "buff", UnitID = "player",
			Direction = "LEFT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", -79, -52},
			List = {
				2825, -- 嗜血
				32182, -- 英勇气概
				80353, -- 时间扭曲
				498, -- 圣佑术
				642, -- 圣盾术
				31842, -- 神恩术
				20925, -- 圣洁护盾	
				31884, -- 复仇之怒
				31850, -- 炽热防御者
				54149, -- 圣光灌注
				54428, -- 神圣恳求
				59578, -- 战争艺术
				84963, -- 异端裁决
				85416, -- 大十字军
				86659, -- 远古列王守卫(防护)
				88819, -- 破晓
				90174, -- 神圣意志
				31821, -- 虔诚光环
				114039, -- 纯净之手
				114250, -- 无私治愈
				114637, -- 荣耀堡垒
				115654, -- 谴责雕文
				121027, -- 双重审判雕文
				132403, -- 正义盾击
			},
		},
		{
			Name = "目标Debuff",
			Type = "debuff", UnitID = "target",
			Direction = "RIGHT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", 79, -52},
			List = {
				115798, -- 虚弱打击
				31803, -- 谴罚
			},
		},
	},

	-- 牧师
	["PRIEST"] = {
		{
			Name = "玩家Buff",
			Type = "buff", UnitID = "player",
			Direction = "LEFT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", -79, -52},
			List = {
				2825, -- 嗜血
				32182, -- 英勇气概
				80353, -- 时间扭曲
				47585, -- 消散
				59889, -- 争分夺秒
				63735, -- 妙手回春
				81292, -- 心灵尖刺雕文
				81782, -- 真言术:障
				81700, -- 天使长
				81661, -- 福音传播
				114255, -- 光明涌动
				87160, -- 黑暗涌动
				123266, 123267, 124430, -- 神圣洞察(戒律/神圣/暗影)
			},
		},
		{
			Name = "目标Debuff",
			Type = "debuff", UnitID = "target",
			Direction = "RIGHT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", 79, -52},
			List = {
				589, -- 暗言术: 痛
				--2944, -- 噬灵疫病 (据暗牧朋友反映, 现在暗牧不用监视疫病)
				34914, -- 吸血鬼之触
			},
		},
	},

	-- 术士
	["WARLOCK"] = {
		{
			Name = "玩家Buff",
			Type = "buff", UnitID = "player",
			Direction = "LEFT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", -79, -52},
			List = {
				2825, -- 嗜血
				32182, -- 英勇气概
				80353, -- 时间扭曲
				17941, -- 夜幕
				34936, -- 反冲
				80240, -- 浩劫
				88448, -- 恶魔重生
				89937, -- 魔能火花
				117828, -- 爆燃
				122355, -- 熔火之心
			},
		},
		{
			Name = "目标Debuff",
			Type = "debuff", UnitID = "target",
			Direction = "RIGHT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", 79, -52},
			List = {
				172, -- 腐蚀术
				348, -- 献祭
				980, -- 痛楚 (悼念天国的痛苦诅咒)
				30108, -- 痛苦无常
				48181, -- 鬼影缠身
				27243, -- 腐蚀之种
			},
		},
	},
	
	-- 盗贼
	["ROGUE"] = {
		{
			Name = "玩家Buff",
			Type = "buff", UnitID = "player",
			Direction = "LEFT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", -79, -52},
			List = {
				2825, -- 嗜血
				32182, -- 英勇气概
				80353, -- 时间扭曲
				1966, -- 佯攻
				5171, -- 切割
				32645, -- 毒伤
				73651, -- 恢复
				13750, -- 冲动
				121153, -- 盲点
			}
		},
		{
			Name = "目标Debuff",
			Type = "debuff", UnitID = "target",
			Direction = "RIGHT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", 79, -52},
			List = {
				1943, -- 割裂
				89775, -- 出血
				84617, -- 要害打击
			},
		},
	},
	
	-- 死亡骑士
	["DEATHKNIGHT"] = {
		{
			Name = "玩家Buff",
			Type = "buff", UnitID = "player",
			Direction = "LEFT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", -79, -52},
			List = {
				2825, -- 嗜血
				32182, -- 英勇气概
				80353, -- 时间扭曲
				48707, -- 反魔法护罩
				48792, -- 冰封之韧
				81340, -- 末日突降			
				49039, -- 巫妖之躯
				49222, -- 白骨之盾
				51124, -- 杀戮机器
				55233, -- 吸血鬼之血
				59052, -- 冰冻之雾
				81141, -- 赤色天灾
				81256, -- 符文刃舞
				77535, -- 鲜血护盾
				--50421, -- 血之气息
				96171, -- 大墓地的意志
				101568, -- 黑暗援助
			},
		},	
		{
			Name = "目标Debuff",
			Type = "debuff", UnitID = "target",
			Direction = "RIGHT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", 79, -52},
			List = {
				55095, -- 冰霜疫病
				55078, -- 血之疫病
				114866, 130735, 130736, -- 灵魂收割(血/冰/邪)
			},
		},
	},
	
	-- 武僧
	["MONK"] = {
		{
			Name = "玩家Buff",
			Type = "buff", UnitID = "player",
			Direction = "LEFT",Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", -79, -52},
			List = {
				2825, -- 嗜血
				32182, -- 英勇气概
				80353, -- 时间扭曲
				116768, 118864, -- 踏风连击
				128939, 115308, -- 飘渺酒(前者为堆叠效果, 后者为消耗效果. 下同)
				125195, 116740, -- 虎眼酒
				115867, 115294, -- 法力茶
				125359, -- 猛虎之力
				118636, -- 强力金钟罩
				120954, -- 壮胆酒
				115307, -- 酒醒入定
				125174, -- 业报之触
			},
		},	
		{
			Name = "目标Debuff",
			Type = "debuff", UnitID = "target",
			Direction = "RIGHT", Interval = 6,
			Mode = "ICON", IconSize = 30,
			Pos = {"CENTER", UIParent, "CENTER", 79, -52},
			List = {
				115798, -- 虚弱打击
				123727, -- 迷醉酒雾
			},
		},
	},
}