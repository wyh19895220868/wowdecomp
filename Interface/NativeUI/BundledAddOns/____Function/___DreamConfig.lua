
--全局配置文件--请注意 %s %d 之类的不允许更改 只能更改 = 号后面的内容

--------------------------------------------------------------------------------

--主功能按钮是否圆形 若圆形 最好是图标用无边框的
IsRingTipBtn = 0;

--通用按钮背景
NormalBtnIcon = "Interface\\Icons\\BtnNormal";

-- 0: 插件首次显示的资源 顺序写死了排列是从右到左

--折叠按钮
TipBtnLeftFilePath = "Interface\\Icons\\Aleft";
--展开按钮
TipBtnRightFilePath = "Interface\\Icons\\Aright";
--显示在折叠或展开按钮上鼠标指向后显示的文字说明
TipBtnText = "|cFFFF0033点击折叠或展开\n\n可拖动位置\n\n建议放右侧|r\n";
--显示在每个功能鼠标指向后显示的文字说明
OnFuncText = "\n|cFF99FF33单击打开功能|r\n|cFF00CCFF再次单击关闭|r\n|cFF00CCFF按 Esc 键退出|r";
--功能1 的图标和说明文字
FuncType1 = "|cFF00FFFF抽奖|r";
FuncIcon1 = "Interface\\Icons\\F0001";
--功能2 的图标和说明文字
FuncType2 = "|cFF00FFFF签到|r";
FuncIcon2 = "Interface\\Icons\\F0002";
--功能3 的图标和说明文字
FuncType3 = "|cFF00FFFF商城|r";
FuncIcon3 = "Interface\\Icons\\F0003";
--功能4 的图标和说明文字
FuncType4 = "|cFF00FFFF升级|r";
FuncIcon4 = "Interface\\Icons\\F0004";
--功能5 的图标和说明文字
FuncType5 = "|cFF00FFFF升级|r";
FuncIcon5 = "Interface\\Icons\\F0005";
--功能6 的图标和说明文字
FuncType6 = "|cFF00FFFF斗气|r";
FuncIcon6 = "Interface\\Icons\\F0006";
--功能7 的图标和说明文字
FuncType7 = "|cFF00FFFF战斗|r";
FuncIcon7 = "Interface\\Icons\\F0007";
--功能8 的图标和说明文字
FuncType8 = "|cFF00FFFF装备栏|r";
FuncIcon8 = "Interface\\Icons\\F0008";
--功能9 的图标和说明文字
FuncType9 = "|cFF00FFFF天梯|r";
FuncIcon9 = "Interface\\Icons\\F0009";
--功能10 的图标和说明文字
FuncType10 = "|cFF00FFFF卡牌|r";
FuncIcon10 = "Interface\\Icons\\F0010";
--功能11 的图标和说明文字
FuncType11 = "|cFF00FFFF活动|r";
FuncIcon11 = "Interface\\Icons\\F0011";
--功能12 的图标和说明文字
FuncType12 = "|cFF00FFFF活跃度|r";
FuncIcon12 = "Interface\\Icons\\F0012";
--功能13 的图标和说明文字
FuncType13 = "|cFF00FFFF秘境|r";
FuncIcon13 = "Interface\\Icons\\F0013";
--功能14 的图标和说明文字
FuncType14 = "|cFF00FFFF法宝|r";
FuncIcon14 = "Interface\\Icons\\F0014";
--功能15 的图标和说明文字
FuncType15 = "|cFF00FFFF提取|r";
FuncIcon15 = "Interface\\Icons\\F0015";
--功能16 的图标和说明文字
FuncType16 = "|cFF00FFFF双甲斗气|r";
FuncIcon16 = "Interface\\Icons\\F0016";
--功能17 的图标和说明文字
FuncType17 = "|cFF00FFFF新提取|r";
FuncIcon17 = "Interface\\Icons\\F0017";
--功能18 的图标和说明文字
FuncType18 = "|cFF00FFFF传奇生肖|r";
FuncIcon18 = "Interface\\Icons\\F0018";
--功能19 的图标和说明文字
FuncType19 = "|cFF00FFFF战宠合体|r";
FuncIcon19 = "Interface\\Icons\\F0019";
--功能20 的图标和说明文字
FuncType20 = "|cFF00FFFF词条洗练|r";
FuncIcon20 = "Interface\\Icons\\F0020";
--功能21 的图标和说明文字
FuncType21 = "|cFF00FFFF图鉴系统|r";
FuncIcon21 = "Interface\\Icons\\F0021";
--功能22 的图标和说明文字
FuncType22 = "|cFF00FFFF装备锻造|r";
FuncIcon22 = "Interface\\Icons\\F0022";
--功能23 的图标和说明文字
FuncType23 = "|cFF00FFFF神兽翻牌|r";
FuncIcon23 = "Interface\\Icons\\F0023";

-- 1: 抽奖

--主界面背景
NewLuckBIcon = "Interface\\Icons\\LuckBackdrop";
--抽奖的指针图标
VoidIcon = "Interface\\Icons\\LuckVoid";
--抽奖的频率 相当于每次抽奖需要的时间 支持小数点 默认2秒
DmDuration = 0.01;

-- 2: 签到

--主窗口背景
SignBIcon = "Interface\\Icons\\Sign3";
--物品格子的图标
SignItemIcon = "Interface\\Icons\\Sign8";
--额外奖励窗口的背景
ERewardIcon = "Interface\\Icons\\Sign7";
--签到的日历显示窗口背景
DateIcon = "Interface\\Icons\\Sign1";
--已签到的图标
InSIcon = "Interface\\Icons\\Sign10";
--未签到的图标
NoSIcon = "Interface\\Icons\\Sign5";

-- 3: 商城

--主窗口背景
ShopBIcon = "Interface\\Icons\\Shop";
--分页的按钮
ShopSubIcon = "Interface\\Icons\\ShopTab1";
--页面上的9个窗口背景
ShopListIcon = "Interface\\Icons\\ShopListBp";

-- 4: 自选升级

--主窗口背景
ChoiceUpBIcon = "Interface\\Icons\\ItemUp";

-- 5: 随机升级

--主窗口背景
RandomUpBIcon = "Interface\\Icons\\ItemUp";

-- 6: 斗气加点

--主窗口背景
StatBIcon = "Interface\\Icons\\StatRes";

-- 8: 装备栏位

--主窗口背景
EqUpBIcon = "Interface\\Icons\\Eq3";
--左边矩形背景
EqUpLeftIcon = "Interface\\Icons\\Eq2";
--右边矩形背景
EqUpRightIcon = "Interface\\Icons\\Eq1";
--下边矩形背景
EqUpDIcon = "Interface\\Icons\\Eq2";

-- 9: 符文
--未镶嵌插槽图标
RunesIconFile = "Interface\\Icons\\RunesNorma";
--符文技能的前置字符 可留空 ""
RunesSpellTitle = "|cFFFFFF00符文：|r ";

--某些特定字符
SuperRandomStatStr = "|cFFFD3FB8[随机属性]|r\n";
SuperRandomSpellStr = "|cFFFD3FB8[随机技能]|r\n";

CRandomAStr = "\n|cFFFD3FB8[随机附魔]|r";
CRandomBStr = "[|cFF00FFFF附魔:|r] ";

-- 16: 新巅峰双甲
--双甲背景图
SoulIconFile0 = "Interface\\Icons\\Soul-0";
--人物剪影
SoulPlayerIconFile = string.format("Interface\\Icons\\Soul-%u", UnitSex("player"));
--巅峰属性底框
SoulIconFile3 = "Interface\\Icons\\Soul-3";
--巅峰属性说明
SoulIconFile4 = "Interface\\Icons\\Soul-4";
--巅峰文字
SoulIconFile5 = "Interface\\Icons\\Soul-5";

-- 21: 图鉴系统
--图鉴系统背景图
PicGuideFile = "Interface\\Icons\\CPic1";
--图鉴系统提供截取的背景图
PicGuideCoordsFile = "Interface\\Icons\\StoreFrame_Main";
--导航系统标题
PicGuideTitle = "|cffFFC125图鉴系统|r";
--导航条1文字
NavBtnText1 = "|cffFFC125物品图鉴|r";
--导航条2文字
NavBtnText2 = "|cffFFC125生物图鉴|r";
