if GetLocale() == "zhCN" then
	HPetLocals = {
			----------Options
			["HPet Options"]				= "宠物品质提示",

			["Loading"]						= "已开启，输入%s进入设置界面",

			["Message"]						= "文字提示",	--ShowMsg
			["MessageTooltip"]				= "进入对战后，聊天窗口列出敌对宠物信息以及收集情况",

			["Sound"]						= "声音提示",		--Sound
			["SoundTooltip"]				= "蓝色/蓝色以上可捕捉宠物发出声音提示。",

			["OnlyInPetInfo"]				= "文字提示位置",
			["OnlyInPetInfoTooltip"]		= "勾选后，文字提示将只跟随宠物对战信息",

			["HighGlow"]					= "宠物头像着色",
			["HighGlowtooltip"]					= "战斗中用品质颜色对宠物头像着色",

			["EnemyAbility"]				= "敌对技能图标",
			["EnemyAbilityTooltip"]			= "宠物对战中显示敌对技能(技能CD),该图标可以移动。",

			["LockEnemyAbility"]			= "锁定敌对技能图标",
			["LockEnemyAbilityTooltip"]		= "解锁或者移动敌对技能图标",

			["EnemyAbilityScale"]			= "敌对技能图标缩放", --EnemyAbScale
			["EnemyAbilityScaleTooltip"]	= "缩放敌对技能图标敌对技能",

			["PetGrowInfo"]					= "显示成长值",	--ShowGrowInfo
			["PetGrowInfoTooltip"]			= "显示成长值",

			["PetGreedInfo"]				= "显示品值",
			["PetGreedInfoTooltip"]			= "新型成长值(需要开启显示成长值)|n跨越品质比较(用于5.1的战斗石)",

			["bottom title"]				= "作者：上官晓雾|n发布：NGA(宠物区)|nID:上官晓雾#5190/zhCN",

			["Breed Point"]					= "品值:",
			["Reset"]						= "重置",
			----------other
			["Only collected"]				= "只收集了",
			["this is"]						= "第%s只",
--- 			["Loading info"]				= "寵物辨別開啟,輸入%s用以設置信息提示",
			["Search Help"]					= "搜索帮助",
			["searchhelp1"]					= "[/hpq s xxx]xxx为宠物任意来源信息",
			["searchhelp2"]					= "[/hpq ss XXX]xxx宠物任意技能信息(可以是技能内的文本)",
			["search key"]					= "搜索关键字为:",
			["search Remove key"]			= "排除关键字为:",
		}
elseif GetLocale() == "zhTW" then
		HPetLocals = {
			----------Options
			["HPet Options"] = "戰寵品質提示",

			["Loading"]						= "已開啟，輸入%s進入設置介面",

			["Message"] = "文字提示", --ShowMsg
			["MessageTooltip"] = "進入對戰後，聊天窗口列出敵對寵物信息以及收集情況",

			["Sound"] = "聲音提示", --Sound
			["SoundTooltip"] = "藍色/藍色以上可捕捉寵物發出聲音提示。",

			["OnlyInPetInfo"]				= "文字提示信息",
			["OnlyInPetInfoTooltip"]		= "勾選后，文字提示信息將只跟隨寵物對戰信息",

			["HighGlow"]					= "寵物頭像上色",

			["EnemyAbility"] = "敵對技能圖標",
			["EnemyAbilityTooltip"] = "寵物對戰中顯示敵對技能(技能CD),该圖標可以移動。",

			["LockEnemyAbility"] = "鎖定敵對技能圖標",
			["LockEnemyAbilityTooltip"] = "解鎖或者移動敵對技能圖標",

			["EnemyAbilityScale"] = "敵對技能圖標縮放", --EnemyAbScale
			["EnemyAbilityScaleTooltip"] = "縮放敵對技能圖標",

			["PetGrowInfo"] = "顯示成長值", --ShowGrowInfo
			["PetGrowInfoTooltip"] = "顯示成長值",

			["PetGreedInfo"] = "顯示品值",
			["PetGreedInfoTooltip"] = "新型成長值(需要開啟顯示成長值)|n跨越品質比較(用於5.1的戰鬥石)",

			["bottom title"] = "作者：上官曉霧|n發布：NGA(寵物區)|nID:上官晓雾#5190/zhCN",

			["Breed Point"]					= "品值:",
			["Reset"]						= "重置",
			----------other
			["Only collected"] = "只收集了",
			["this is"]			= "第%s隻",
			["Search Help"] = "搜索幫助",
			["searchhelp1"] = "[/hpq s xxx]xxx為寵物任意來源信息",
			["searchhelp2"] = "[/hpq ss XXX]xxx寵物任意技能信息(可以是技能內的文本)",
			["search key"] = "搜索關鍵字為:",
			["search Remove key"] = "排除關鍵字為:",
		}
else
	HPetLocals = {
		---------- Options
		["HPet Options"] = "HPetBattleAny",

		["Loading"]						= "is Loaded，type %s to configure",

		["Message"] = "text prompt",
		["MessageTooltip"] = "enter the PetBattle, the chat window lists hostile pet information and the collection of",

		["Sound"] = "sound",
		["SoundTooltip"] = "Rare pet may capture of Sound Alarm.",

		["OnlyInPetInfo"]				= "text prompt position",

		["HighGlow"]					= "color pet unit",

		["EnemyAbility"] = "enemy skill icons",
		["EnemyAbilityTooltip"] = "In PetBattle,Show skills(skills CD) of emeny,Drag the icons can be moved.",

		["LockEnemyAbility"] = "lock enemy skill icons",
		["LockEnemyAbilityTooltip"] = "unlock or move enemy skill icons",

		["EnemyAbilityScale"] = "enemy skill icons icon scaling",
		["EnemyAbilityScaleTooltip"] = "Zoom enemy skill icons",

		["PetGrowInfo"] = "display growth value",
		["PetGrowInfoTooltip"] = "display growth value",

		["PetGreedInfo"] = "display greed value",

		["bottom title"] = "作者：上官曉霧|n發布：NGA(寵物區)|nID:上官晓雾#5190/zhCN",

		["Breed Point"]					= "Breed Point:",
		["Reset"]						= "Reset",
		---------- other
		["Only collected"] = "collect only",
		["this is"]			= "the %s is ",
		["Loading info"] = "the pet identify open input% s to set the message alert",
		["Search Help"] = "Search Help",
		["searchhelp1"] = "[/ hpq s xxx] xxx as a the pet any source of information",
		["searchhelp2"] = "[/ hpq ss XXX] xxx pet any skills (can be skills within the text),",
		["search key"] = "Search for the key word:",
		["search Remove key"] = "Negative keyword:",
	}
end
