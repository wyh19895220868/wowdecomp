---@diagnostic disable: missing-parameter

MaxGuidIndex = 100000000;

-- 【新增】定义随机属性/技能文本，清理开头空格
SuperRandomStatStr = "|cFFFD3FB8★★★[追加属性]★★★|r\n";
SuperRandomSpellStr = "|cFFFD3FB8★★★[追加技能]★★★|r\n";
RunesSpellTitle = "|cFF05E105★【符文技能】★|r："; -- 补充缺失的符文技能标题变量
CRandomAStr = "|cFFFD3FB8★★★[随机附魔]★★★|r";
RunesIconFile = "Interface\\Icons\\ico9";

local TipWidth = 464; --修改框架长度 58 * 8
Dream_ItemSeriesMode = Dream_ItemSeriesMode or "legacy"; -- 默认采用 legacy 模式
local function Dream_IsTemplateItemSeriesEnabled()
	return Dream_ItemSeriesMode == "template";
end

Zs_GuidLowStoreData = Zs_GuidLowStoreData or { AtGuidData = {}, EnchantData = {},AtRunesData = {},ItemEnchAtCountData = {},DevelopData = {},AllModuleData = {},AllModuleLocationData = {},CacheIdData = {},};
Zs_EntryIdStoreData = Zs_EntryIdStoreData or { ItemLimitData1 = {}, ItemLimitData2 = {},ItemLimitData3 = {},ItemLimitData4 = {},ItemUseLimitData1 = {},ItemUseLimitData2 = {},BigItemStatData = {},CacheIdData = {},};

local Dream_ItemTooltipDebugEnabled = false;
local Dream_ItemTooltipDebugLast = {};
local Dream_TooltipRequestPending = {
	GuidLow = {},
	EntryId = {},
	AllModuleGuid = {},
	AllModuleLocation = {},
};
local Dream_TooltipRequestPendingTimeout = 1.0;
local Dream_TooltipRequestCooldown = {
	GuidLow = {},
};
local Dream_TooltipRequestCooldownTimeout = 10.0;
local Dream_TooltipNoGuidData = {};
local Dream_TooltipNoGuidTimeout = 3.0;
local Dream_ItemTemplateRequestAt = {};
local Dream_ItemTemplateRequestTimeout = 30.0;
local Dream_TooltipWarmQueue = {};
local Dream_TooltipWarmQueueKeys = {};
local Dream_TooltipWarmElapsed = 0;
local Dream_TooltipWarmFullScanAt = nil;
local Dream_TooltipWarmHooksInstalled = false;
local Dream_TooltipRequestedItemIdByGuid = {};

local function Dream_EnsureTooltipStoreData()
	if not Zs_GuidLowStoreData then Zs_GuidLowStoreData = {}; end
	if not Zs_EntryIdStoreData then Zs_EntryIdStoreData = {}; end
	if not Zs_GuidLowStoreData.AtGuidData then Zs_GuidLowStoreData.AtGuidData = {}; end
	if not Zs_GuidLowStoreData.EnchantData then Zs_GuidLowStoreData.EnchantData = {}; end
	if not Zs_GuidLowStoreData.AtRunesData then Zs_GuidLowStoreData.AtRunesData = {}; end
	if not Zs_GuidLowStoreData.ItemEnchAtCountData then Zs_GuidLowStoreData.ItemEnchAtCountData = {}; end
	if not Zs_GuidLowStoreData.DevelopData then Zs_GuidLowStoreData.DevelopData = {}; end
	if not Zs_GuidLowStoreData.AllModuleData then Zs_GuidLowStoreData.AllModuleData = {}; end
	if not Zs_GuidLowStoreData.AllModuleLocationData then Zs_GuidLowStoreData.AllModuleLocationData = {}; end
	if not Zs_GuidLowStoreData.CacheIdData then Zs_GuidLowStoreData.CacheIdData = {}; end
	if not Zs_EntryIdStoreData.ItemLimitData1 then Zs_EntryIdStoreData.ItemLimitData1 = {}; end
	if not Zs_EntryIdStoreData.ItemLimitData2 then Zs_EntryIdStoreData.ItemLimitData2 = {}; end
	if not Zs_EntryIdStoreData.ItemLimitData3 then Zs_EntryIdStoreData.ItemLimitData3 = {}; end
	if not Zs_EntryIdStoreData.ItemLimitData4 then Zs_EntryIdStoreData.ItemLimitData4 = {}; end
	if not Zs_EntryIdStoreData.ItemUseLimitData1 then Zs_EntryIdStoreData.ItemUseLimitData1 = {}; end
	if not Zs_EntryIdStoreData.ItemUseLimitData2 then Zs_EntryIdStoreData.ItemUseLimitData2 = {}; end
	if not Zs_EntryIdStoreData.BigItemStatData then Zs_EntryIdStoreData.BigItemStatData = {}; end
	if not Zs_EntryIdStoreData.CacheIdData then Zs_EntryIdStoreData.CacheIdData = {}; end
	if not Dream_TooltipRequestPending then Dream_TooltipRequestPending = {}; end
	if not Dream_TooltipRequestPending.GuidLow then Dream_TooltipRequestPending.GuidLow = {}; end
	if not Dream_TooltipRequestPending.EntryId then Dream_TooltipRequestPending.EntryId = {}; end
	if not Dream_TooltipRequestPending.AllModuleGuid then Dream_TooltipRequestPending.AllModuleGuid = {}; end
	if not Dream_TooltipRequestPending.AllModuleLocation then Dream_TooltipRequestPending.AllModuleLocation = {}; end
	if not Dream_TooltipRequestCooldown then Dream_TooltipRequestCooldown = {}; end
	if not Dream_TooltipRequestCooldown.GuidLow then Dream_TooltipRequestCooldown.GuidLow = {}; end
	if not Dream_TooltipNoGuidData then Dream_TooltipNoGuidData = {}; end
end

local function Dream_ClearGuidStoreData(GuidLow)
	if (not GuidLow or GuidLow <= 0) then
		return;
	end

	Dream_TooltipRequestedItemIdByGuid[GuidLow] = nil;
	Zs_GuidLowStoreData.AtGuidData[GuidLow] = nil;
	Zs_GuidLowStoreData.EnchantData[GuidLow] = nil;
	Zs_GuidLowStoreData.AtRunesData[GuidLow] = nil;
	Zs_GuidLowStoreData.ItemEnchAtCountData[GuidLow] = nil;
	Zs_GuidLowStoreData.DevelopData[GuidLow] = nil;
	Zs_GuidLowStoreData.AllModuleData[GuidLow] = nil;
	Zs_GuidLowStoreData.CacheIdData[GuidLow] = nil;
	Dream_TooltipNoGuidData[GuidLow] = nil;
	Dream_TooltipRequestPending.GuidLow[GuidLow] = nil;
	Dream_TooltipRequestCooldown.GuidLow[GuidLow] = nil;
end

local function Dream_HasGuidCacheId(GuidLow, ItemId)
	if (not GuidLow or GuidLow <= 0 or not ItemId) then
		return false;
	end

	local CachedItemId = tonumber(Zs_GuidLowStoreData.CacheIdData[GuidLow]);
	if (CachedItemId and CachedItemId == ItemId) then
		return true;
	end

	if (CachedItemId and CachedItemId ~= ItemId) then
		Dream_ClearGuidStoreData(GuidLow);
	end

	return false;
end

local function Dream_MarkGuidCacheId(GuidLow, ItemId)
	if (GuidLow and GuidLow > 0 and ItemId and ItemId > 0) then
		Zs_GuidLowStoreData.CacheIdData[GuidLow] = ItemId;
	end
end

local function Dream_HasEntryCacheId(ItemId)
	return (ItemId and ItemId > 0 and Zs_EntryIdStoreData.CacheIdData[ItemId] == true) or false;
end

local function Dream_MarkEntryCacheId(ItemId)
	if (ItemId and ItemId > 0) then
		Zs_EntryIdStoreData.CacheIdData[ItemId] = true;
	end
end

local Dream_TooltipSpellDescriptionCache = {};

local function Dream_GetCachedSpellDescription(SpellId)
	SpellId = tonumber(SpellId);
	if (not SpellId or SpellId == 0) then
		return "";
	end

	local CachedDescription = Dream_TooltipSpellDescriptionCache[SpellId];
	if (CachedDescription) then
		return CachedDescription;
	end

	local Description = GetSpellDescription and GetSpellDescription(SpellId) or "";
	if (Description and Description ~= "") then
		Dream_TooltipSpellDescriptionCache[SpellId] = Description;
		return Description;
	end

	return "";
end

local function Dream_GetSpellDisplayText(SpellId)
	SpellId = tonumber(SpellId);
	if (not SpellId or SpellId == 0) then
		return "";
	end

	local Description = Dream_GetCachedSpellDescription(SpellId);
	local SpellName = GetSpellInfo and select(1, GetSpellInfo(SpellId)) or "";
	if (Description ~= "") then
		return Description;
	end
	if (SpellName and SpellName ~= "") then
		return SpellName;
	end
	return "技能ID: " .. tostring(SpellId);
end

if (RegisterAddonMessagePrefix) then
	RegisterAddonMessagePrefix("UITQ");
elseif (C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix) then
	C_ChatInfo.RegisterAddonMessagePrefix("UITQ");
end

local function Dream_ItemTooltipShort(Value, Limit)
	local Text = tostring(Value or "");
	Limit = Limit or 230;
	if (string.len(Text) > Limit) then
		return string.sub(Text, 1, Limit) .. "...";
	end
	return Text;
end

local function Dream_ItemTooltipBool(Value)
	return Value and "1" or "0";
end

local function Dream_ItemTooltipPendingGet(PendingTable, Key)
	local Now = (GetTime and GetTime()) or 0;
	local Time = PendingTable[Key];
	if (not Time) then
		return false;
	end

	if ((Now - Time) > Dream_TooltipRequestPendingTimeout) then
		PendingTable[Key] = nil;
		return false;
	end

	return true;
end

local function Dream_ItemTooltipPendingSet(PendingTable, Key)
	if (Key and Key ~= 0) then
		PendingTable[Key] = (GetTime and GetTime()) or 0;
	end
end

local function Dream_ItemTooltipPendingClear(PendingTable, Key)
	if (Key) then
		PendingTable[Key] = nil;
	end
end

local function Dream_ItemTooltipCooldownGet(CooldownTable, Key)
	local Now = (GetTime and GetTime()) or 0;
	local Time = CooldownTable[Key];
	if (not Time) then
		return false;
	end

	if ((Now - Time) > Dream_TooltipRequestCooldownTimeout) then
		CooldownTable[Key] = nil;
		return false;
	end

	return true;
end

local function Dream_ItemTooltipCooldownSet(CooldownTable, Key)
	if (Key and Key ~= 0) then
		CooldownTable[Key] = (GetTime and GetTime()) or 0;
	end
end

local function Dream_ItemTooltipNoGuidGet(GuidLow)
	if (not GuidLow or GuidLow == 0 or not Dream_TooltipNoGuidData) then
		return false;
	end

	local Time = Dream_TooltipNoGuidData[GuidLow];
	if (not Time) then
		return false;
	end

	if (type(Time) ~= "number") then
		Dream_TooltipNoGuidData[GuidLow] = nil;
		return false;
	end

	local Now = (GetTime and GetTime()) or 0;
	if ((Now - Time) > Dream_TooltipNoGuidTimeout) then
		Dream_TooltipNoGuidData[GuidLow] = nil;
		return false;
	end

	return true;
end

local function Dream_ItemTooltipNoGuidSet(GuidLow)
	if (GuidLow and GuidLow ~= 0) then
		Dream_TooltipNoGuidData[GuidLow] = (GetTime and GetTime()) or 0;
	end
end

local function Dream_ItemTooltipNoGuidClear(GuidLow)
	if (GuidLow and Dream_TooltipNoGuidData) then
		Dream_TooltipNoGuidData[GuidLow] = nil;
	end
end

local function Dream_ItemTooltipDebug(Stage, ItemId, GuidLow, Extra)
	if (not Dream_ItemTooltipDebugEnabled or not Dream_SendData) then
		return;
	end

	local Msg = "stage=" .. tostring(Stage or "nil") ..
		" item=" .. tostring(ItemId or 0) ..
		" guid=" .. tostring(GuidLow or 0);
	if (Extra and Extra ~= "") then
		Msg = Msg .. " " .. Extra;
	end

	local Now = (GetTime and GetTime()) or 0;
	local Key = Msg;
	if (Dream_ItemTooltipDebugLast[Key] and (Now - Dream_ItemTooltipDebugLast[Key]) < 0.8) then
		return;
	end

	Dream_ItemTooltipDebugLast[Key] = Now;
	Dream_SendData("TooltipDebug", Dream_ItemTooltipShort(Msg));
end

local CheckStr = "^需要等级%s+%d"; --不可改动

--检查1
function IsShowGuidLowData(GuidLow, ItemId)
	Dream_EnsureTooltipStoreData();
	local RuneData = Zs_GuidLowStoreData.AtRunesData[GuidLow];
	if (RuneData and ItemId and (not RuneData.ItemId or RuneData.ItemId ~= ItemId)) then
		Zs_GuidLowStoreData.AtRunesData[GuidLow] = nil;
	end
	return (Zs_GuidLowStoreData.AtGuidData[GuidLow] or Zs_GuidLowStoreData.AtRunesData[GuidLow] or Zs_GuidLowStoreData.EnchantData[GuidLow] or Zs_GuidLowStoreData.DevelopData[GuidLow] or Zs_GuidLowStoreData.ItemEnchAtCountData[GuidLow] or Zs_GuidLowStoreData.AllModuleData[GuidLow]);
end

--检查2
function IsShowGEntryIdData(ItemId)
	Dream_EnsureTooltipStoreData();
	return (Zs_EntryIdStoreData.ItemLimitData1[ItemId] or Zs_EntryIdStoreData.ItemLimitData2[ItemId] or Zs_EntryIdStoreData.ItemLimitData3[ItemId] or Zs_EntryIdStoreData.ItemLimitData4[ItemId] or Zs_EntryIdStoreData.ItemUseLimitData1[ItemId] or Zs_EntryIdStoreData.ItemUseLimitData2[ItemId] or Zs_EntryIdStoreData.BigItemStatData[ItemId]);
end

function IsShowBigItemStatData(ItemId)
	Dream_EnsureTooltipStoreData();
	return (Zs_EntryIdStoreData.BigItemStatData and Zs_EntryIdStoreData.BigItemStatData[ItemId]);
end

local Dream_WeaponEquipLocations = {
	["INVTYPE_WEAPON"] = true,
	["INVTYPE_2HWEAPON"] = true,
	["INVTYPE_WEAPONMAINHAND"] = true,
	["INVTYPE_WEAPONOFFHAND"] = true,
	["INVTYPE_RANGED"] = true,
	["INVTYPE_RANGEDRIGHT"] = true,
	["INVTYPE_THROWN"] = true,
};
local Dream_WeaponItemCache = {};

local function Dream_IsWeaponItem(ItemId)
	if (not ItemId or not GetItemInfo) then
		return nil;
	end

	local Cached = Dream_WeaponItemCache[ItemId];
	if (Cached ~= nil) then
		return Cached;
	end

	local ItemName, _, _, _, _, ItemType, _, _, EquipLoc = Dream_GetItemInfoOnce(ItemId);
	if (not ItemName) then
		return nil;
	end

	local WeaponClassName = _G.ITEM_CLASS_2;
	local IsWeaponType = (not WeaponClassName or not ItemType or ItemType == WeaponClassName or ItemType == "武器");
	local IsWeapon = (IsWeaponType and Dream_WeaponEquipLocations[EquipLoc]) and true or false;
	Dream_WeaponItemCache[ItemId] = IsWeapon;
	return IsWeapon;
end

local function Dream_IsWeaponDamageRangeText(St)
	if (not St or string.find(St, "法术") or string.find(St, "^装备：")) then
		return false;
	end

	local Text = tostring(St);
	Text = string.gsub(Text, "|c%x%x%x%x%x%x%x%x", "");
	Text = string.gsub(Text, "|r", "");
	Text = string.gsub(Text, "^%s+", "");
	Text = string.gsub(Text, "%s+$", "");
	if (string.find(Text, "^[%+%-]?[%d%.]+.-[%-%~]%s*[%+%-]?[%d%.]+.-伤害")) then
		return true;
	end

	return string.find(Text, "^[%+%-]?[%d%.]+.-点伤害%s*$") ~= nil;
end

local function Dream_TooltipHasWeaponDamageLine(Self, ItemId)
	if (not Self) then
		return false;
	end

	for i = 1, Self:NumLines() do
		local GLine = _G[Self:GetName() .. "TextLeft" .. i];
		local St = GLine and GLine:GetText();
		if (Dream_IsWeaponDamageRangeText(St)) then
			return true;
		end
	end

	return false;
end

local function Dream_TooltipIsLoadingItem(Tooltip)
	if (not Tooltip or not Tooltip.NumLines or not Tooltip.GetName or not Tooltip:GetName()) then
		return false;
	end

	for i = 1, Tooltip:NumLines() do
		local Line = _G[Tooltip:GetName() .. "TextLeft" .. i];
		local Text = Line and Line:GetText();
		if (Text and string.find(Text, "正在获取物品信息", 1, true)) then
			return true;
		end
	end

	return false;
end

local function Dream_GetInspectTooltipItemId(Tooltip)
	if (not Tooltip or not Tooltip.GetOwner or not GetInventoryItemLink) then
		return nil;
	end

	local Owner = Tooltip:GetOwner();
	local Parent = Owner and Owner.GetParent and Owner:GetParent() or nil;
	local ParentName = Parent and Parent.GetName and Parent:GetName() or "";
	if (ParentName ~= "InspectPaperDollFrame" or not Owner.GetID) then
		return nil;
	end

	local Slot = Owner:GetID();
	if (not Slot or Slot <= 0) then
		return nil;
	end

	local Unit = (InspectFrame and InspectFrame.unit) or "target";
	local ItemLink = GetInventoryItemLink(Unit, Slot);
	local ItemId = ItemLink and string.match(ItemLink, "item:(%d+)");
	return tonumber(ItemId);
end

local function Dream_RequestLoadingItemTemplate(Tooltip, ItemId)
	-- The native item tooltip already owns the item-cache request. Calling
	-- GetItemInfo here while it is still loading creates another DBCACHECALLBACK.
	-- Wait for OnTooltipSetItem after the client has finished loading instead.
	return false;
end

local function Dream_IsItemTemplateReady(ItemId, Tooltip)
	if (not ItemId) then
		return false;
	end

	if (Tooltip and Tooltip.NumLines and Tooltip.GetName) then
		if (Tooltip:NumLines() == 0) then
			return false;
		end
		if (Dream_TooltipIsLoadingItem(Tooltip)) then
			Dream_RequestLoadingItemTemplate(Tooltip, ItemId);
			return false;
		end
	end

	return true;
end

local function Dream_IsFrozenGuidCached(GuidLow, ItemId)
	return (GuidLow and GuidLow > 0 and ItemId and ItemId > 0 and
		FrozenCore_IsGuidCached and FrozenCore_IsGuidCached(GuidLow, ItemId)) and true or false;
end

local function Dream_IsTooltipReadyOrFrozen(ItemId, GuidLow, Tooltip)
	return Dream_IsFrozenGuidCached(GuidLow, ItemId) or Dream_IsItemTemplateReady(ItemId, Tooltip);
end

local function Dream_NeedBigItemStoreData(Self, ItemId)
	if (not ItemId or not IsShowBigItemStatData(ItemId)) then
		return true;
	end

	local BigStat = Zs_EntryIdStoreData.BigItemStatData[ItemId];
	local function IsLegacyWeaponDamageCap(Value)
		Value = tostring(Value or ""):gsub(",", "");
		return Value == "2147483520" or Value == "2147483647" or Value == "2147483648";
	end
	if (Dream_TooltipHasWeaponDamageLine(Self, ItemId) and
		(not BigStat.WeaponChecked or not BigStat.DmgMin or not BigStat.DmgMax or
			BigStat.DmgMin == "" or BigStat.DmgMax == "" or
			BigStat.DmgMin == "nullptr" or BigStat.DmgMax == "nullptr" or
			IsLegacyWeaponDamageCap(BigStat.DmgMin) or IsLegacyWeaponDamageCap(BigStat.DmgMax))) then
		return true;
	end

	return false;
end

local function Dream_HasFullGuidWeaponData(GuidData)
	local Min = tostring(GuidData and GuidData.MinDmg or ""):gsub(",", "");
	local Max = tostring(GuidData and GuidData.MaxDmg or ""):gsub(",", "");
	return Min ~= "" and Min ~= "nullptr" and Min ~= "0" and Min ~= "0.0" and
		Max ~= "" and Max ~= "nullptr" and Max ~= "0" and Max ~= "0.0";
end

local function Dream_SplitKeepEmpty(Text, Sep)
	local List = {};
	Text = tostring(Text or "");
	Sep = Sep or ":";
	local Start = 1;
	while true do
		local Pos = string.find(Text, Sep, Start, true);
		if (not Pos) then
			table.insert(List, string.sub(Text, Start));
			break
		end
		table.insert(List, string.sub(Text, Start, Pos - 1));
		Start = Pos + string.len(Sep);
	end
	return List;
end

local function Dream_UrlDecodeAddonField(Text)
	Text = tostring(Text or "");
	Text = string.gsub(Text, "%%(%x%x)", function(Hex)
		return string.char(tonumber(Hex, 16));
	end);
	return Text;
end

local function Dream_IsModuleText(Value)
	return (Value and Value ~= "" and Value ~= "nullptr" and Value ~= "0");
end

local function Dream_SendIdentificationQuery(ItemId, GuidLow, Bag, Slot)
	if (not Dream_IsTemplateItemSeriesEnabled() or not ItemId) then
		return;
	end

	local Msg = nil;
	if (GuidLow and GuidLow > 0) then
		Msg = "QUERY:" .. tostring(ItemId) .. ":" .. tostring(GuidLow);
	elseif (Bag ~= nil and Slot ~= nil) then
		Msg = "QUERY:" .. tostring(Bag) .. ":" .. tostring(Slot) .. ":" .. tostring(ItemId);
	else
		return;
	end

	if (C_ChatInfo and C_ChatInfo.SendAddonMessage) then
		C_ChatInfo.SendAddonMessage("UITQ", Msg, "WHISPER", UnitName("player"));
	else
		SendAddonMessage("UITQ", Msg, "WHISPER", UnitName("player"));
	end
end

local function Dream_ParseIdentificationDisplay(DisplayData)
	if (not Dream_IsModuleText(DisplayData)) then
		return nil;
	end

	local Parts = Dream_SplitKeepEmpty(DisplayData, "|");
	if (Parts[1] ~= "IDDISP") then
		return nil;
	end

	return {
		QualityColor = Dream_UrlDecodeAddonField(Parts[2]),
		Prefix = Dream_UrlDecodeAddonField(Parts[3]),
		Suffix = Dream_UrlDecodeAddonField(Parts[4]),
		NameColors = Dream_UrlDecodeAddonField(Parts[5]),
		BottomDescription = Dream_UrlDecodeAddonField(Parts[6]),
		Level = tonumber(Parts[7]) or 0,
	};
end

local function Dream_ParseQualityColor(Value)
	local Text = tostring(Value or "");
	local ColorCode, CustomName = string.match(Text, "^|c(%x%x%x%x%x%x%x%x)(.*)$");
	if (not ColorCode) then
		ColorCode, CustomName = string.match(Text, "^(%x%x%x%x%x%x%x%x)(.*)$");
	end
	if (not ColorCode) then
		local RgbCode;
		RgbCode, CustomName = string.match(Text, "^(%x%x%x%x%x%x)(.*)$");
		if (RgbCode) then ColorCode = "FF" .. RgbCode; end
	end
	if (not ColorCode) then return nil, nil; end
	CustomName = string.gsub(CustomName or "", "|r$", "");
	return ColorCode, CustomName;
end

local function Dream_IsHuanjingDataText(Value)
	if (not Dream_IsModuleText(Value)) then
		return false;
	end

	local Text = tostring(Value or "");
	return string.find(Text, "^[xX%*%+%-]%s*,%s*%d+") or string.find(Text, "^%-?%d+|");
end

local function Dream_FormatModuleAttributeNumber(Value)
	local Text = tostring(Value or "0");
	local IntegerPart = string.match(Text, "^(%d+)%.%d+$");
	if (IntegerPart) then
		Text = IntegerPart;
	end

	if (Dream_FormatChineseNumber) then
		Text = Dream_FormatChineseNumber(Text);
	end

	if (Dream_FormatTooltipNumberText) then
		Text = Dream_FormatTooltipNumberText(Text);
	end

	return Text;
end

local Dream_ModuleStatNames = {
	[0] = "法力值",
	[1] = "生命值",
	[2] = "护甲",
	[3] = "敏捷",
	[4] = "力量",
	[5] = "智力",
	[6] = "精神",
	[7] = "耐力",
	[12] = "防御等级",
	[13] = "躲闪等级",
	[14] = "招架等级",
	[15] = "格挡等级",
	[16] = "近战命中等级", [17] = "远程命中等级", [18] = "法术命中等级",
	[19] = "近战暴击等级", [20] = "远程暴击等级", [21] = "法术暴击等级",
	[22] = "近战命中回避等级", [23] = "远程命中回避等级", [24] = "法术命中回避等级",
	[25] = "近战致命一击回避等级", [26] = "远程致命一击回避等级", [27] = "法术致命一击回避等级",
	[28] = "近战急速等级", [29] = "远程急速等级", [30] = "法术急速等级",
	[31] = "命中等级",
	[32] = "暴击等级",
	[33] = "命中回避等级", [34] = "致命一击回避等级",
	[35] = "韧性等级",
	[36] = "急速等级",
	[37] = "精准等级",
	[38] = "攻击强度",
	[39] = "远程强度",
	[40] = "形态攻击强度", [41] = "法术治疗", [42] = "法术伤害",
	[43] = "法力恢复",
	[44] = "护甲穿透",
	[45] = "法术强度",
	[46] = "生命恢复",
	[47] = "法术穿透",
	[48] = "格挡值",
	[120] = "武器速度", [121] = "武器伤害", [122] = "每秒伤害",
	[123] = "神圣最小伤害", [124] = "神圣最大伤害", [125] = "火焰最小伤害", [126] = "火焰最大伤害",
	[127] = "自然最小伤害", [128] = "自然最大伤害", [129] = "冰霜最小伤害", [130] = "冰霜最大伤害",
	[131] = "暗影最小伤害", [132] = "暗影最大伤害", [133] = "奥术最小伤害", [134] = "奥术最大伤害",
	[135] = "护甲", [136] = "格挡值", [137] = "物品等级",
	[150] = "神圣抗性", [151] = "火焰抗性", [152] = "自然抗性", [153] = "冰霜抗性", [154] = "暗影抗性", [155] = "奥术抗性",
	[200] = "PVP物理伤害%", [201] = "PVP物理伤害", [202] = "PVP魔法伤害%", [203] = "PVP魔法伤害",
	[204] = "PVP治疗效果%", [205] = "PVP治疗效果", [206] = "PVP物理减伤%", [207] = "PVP物理减伤",
	[208] = "PVP魔法减伤%", [209] = "PVP魔法减伤", [210] = "PVP受到治疗%", [211] = "PVP受到治疗",
	[212] = "PVP吸血%", [213] = "PVP吸血", [214] = "PVP魔法暴伤%", [215] = "PVP魔法暴伤",
	[216] = "PVP物理暴伤%", [217] = "PVP物理暴伤", [218] = "PVP物理反弹%", [219] = "PVP物理反弹",
	[220] = "PVP魔法反弹%", [221] = "PVP魔法反弹", [222] = "PVP真实伤害%",
	[223] = "PVP魔法暴伤减免", [224] = "PVP魔法暴伤减免%", [225] = "PVP物理暴伤减免", [226] = "PVP物理暴伤减免%",
	[227] = "PVP固定切割", [228] = "PVP固定切割几率%", [229] = "PVP百分比切割", [230] = "PVP百分比切割几率%",
	[300] = "PVE物理伤害", [301] = "PVE物理伤害%", [302] = "PVE魔法伤害", [303] = "PVE魔法伤害%",
	[304] = "PVE治疗效果", [305] = "PVE治疗效果%", [306] = "PVE物理减伤", [307] = "PVE物理减伤%",
	[308] = "PVE魔法减伤", [309] = "PVE魔法减伤%", [310] = "PVE受到治疗", [311] = "PVE受到治疗%",
	[312] = "PVE吸血", [313] = "PVE吸血%", [314] = "PVE魔法暴伤", [315] = "PVE魔法暴伤%",
	[316] = "PVE物理暴伤", [317] = "PVE物理暴伤%", [318] = "PVE物理反弹", [319] = "PVE物理反弹%",
	[320] = "PVE魔法反弹", [321] = "PVE魔法反弹%", [322] = "PVE真实伤害",
	[323] = "PVE魔法暴伤减免%", [324] = "PVE魔法暴伤减免", [325] = "PVE物理暴伤减免%", [326] = "PVE物理暴伤减免",
	[327] = "PVE固定切割", [328] = "PVE固定切割几率%", [329] = "PVE百分比切割%", [330] = "PVE百分比切割几率%",
	[400] = "经验获取%", [401] = "掉宝几率%", [402] = "多倍掉宝倍率", [403] = "多倍掉宝几率%",
};

local Dream_ModuleStatColors = {
	[0] = "0000FF",
	[1] = "FF0000",
	[2] = "FFFFFF",
	[3] = "00FF00",
	[4] = "FF0000",
	[5] = "FF00FF",
	[6] = "FFFF00",
	[7] = "0000FF",
	[12] = "FFFF00",
	[13] = "00FF00",
	[14] = "00FFFF",
	[15] = "FF8800",
	[31] = "FFFFFF",
	[32] = "FF0000",
	[35] = "FF00FF",
	[36] = "00FFFF",
	[37] = "FFAA00",
	[38] = "FF0000",
	[39] = "FF0000",
	[43] = "0000FF",
	[44] = "FF0000",
	[45] = "FF00FF",
	[46] = "FF0000",
	[47] = "FF00FF",
	[48] = "FF8800",
};

local function Dream_GetModuleStatName(SType)
	return Dream_ModuleStatNames[SType] or ((GetStatStr and GetStatStr(SType)) or ("属性" .. tostring(SType)));
end

local function Dream_GetModuleStatColor(SType)
	return Dream_ModuleStatColors[SType] or "00FF00";
end

local function Dream_GetHuanjingMultiplierSuffix(ModuleData)
	if (not ModuleData or not Dream_IsModuleText(ModuleData.HuanjingData)) then
		return "";
	end

	local MainPart = Dream_SplitKeepEmpty(ModuleData.HuanjingData, "|")[1] or "";
	local Mode, Value = string.match(MainPart, "^%s*([^,%s]+)%s*,%s*([^,%s]+)");
	if (not Mode or not Value) then
		return "";
	end

	if (Value == "0" or Value == "" or Value == "nullptr") then
		return "";
	end

	if (Mode == "x" or Mode == "X" or Mode == "*") then
		return " |cFFFD3FB8倍率x" .. tostring(Value) .. "|r";
	end

	if (Mode == "+") then
		return " |cFFFD3FB8倍率+" .. tostring(Value) .. "|r";
	end

	return "";
end

local function Dream_BuildCompactAttributeModuleLines(DataText, ExtraSuffix)
	if (not Dream_IsModuleText(DataText)) then
		return "";
	end

	ExtraSuffix = ExtraSuffix or "";
	local Lines = {};
	local Items = Dream_SplitKeepEmpty(DataText, ",");
	for i = 1, #Items do
		local SType, SValue = string.match(Items[i], "^%s*(-?%d+)%s+([^,%s]+)");
		SType = tonumber(SType);
		if (SType and SValue and SType ~= -1 and Dream_IsPositiveIntegerText(SValue)) then
			local StatName = Dream_GetModuleStatName(SType);
			if (StatName ~= "") then
				local Color = Dream_GetModuleStatColor(SType);
				table.insert(Lines, "|cFFFFFF00+ " .. Dream_FormatModuleAttributeNumber(SValue) .. "|r |cFF" .. Color .. "[" .. StatName .. "]|r" .. ExtraSuffix);
			end
		end
	end

	if (#Lines == 0) then
		return "";
	end

	return table.concat(Lines, "\n") .. "\n";
end

local function Dream_BuildAttributeModuleLines(DataText)
	if (not Dream_IsModuleText(DataText)) then
		return "";
	end

	local Out = "";
	local Items = Dream_SplitKeepEmpty(DataText, ",");
	for i = 1, #Items do
		local SType, SValue = string.match(Items[i], "^%s*(-?%d+)%s+([^,%s]+)");
		SType = tonumber(SType);
		if (SType and SValue and SType ~= -1) then
			Out = Out .. AutoPullStr(SType, SValue, 0) .. "\n";
		end
	end
	return Out;
end

local function Dream_BuildSkillModuleLines(DataText)
	if (not Dream_IsModuleText(DataText)) then
		return "";
	end

	local Out = "";
	local Items = Dream_SplitKeepEmpty(DataText, ",");
	for i = 1, #Items do
		local Fields = Dream_SplitKeepEmpty(Items[i], "|");
		local SpellId = tonumber(Fields[1]);
		local Display = Fields[2];
		if (Dream_IsModuleText(Display)) then
			Out = Out .. "|cFF05E105装备： " .. Display .. "|r\n";
		elseif (SpellId and SpellId ~= 0) then
			Out = Out .. "|cFF05E105装备： " .. Dream_GetSpellDisplayText(SpellId) .. "|r\n";
		end
	end
	return Out;
end

local function Dream_BuildSetModuleLines(DataText)
	if (not Dream_IsModuleText(DataText)) then
		return "";
	end

	local Parts = Dream_SplitKeepEmpty(DataText, ":");
	local SetId = tonumber(Parts[1]) or 0;
	if (SetId == 0) then
		return "";
	end

	local Out = "";
	if (Dream_IsModuleText(Parts[2])) then
		Out = Out .. "|cFFFFD200" .. Parts[2] .. "|r\n";
	else
		Out = Out .. "|cFFFFD200套装编号 " .. tostring(SetId) .. "|r\n";
	end

	if (Dream_IsModuleText(Parts[3])) then
		Out = Out .. Dream_BuildAttributeModuleLines(Parts[3]);
	end

	if (Dream_IsModuleText(Parts[4])) then
		local Effects = Dream_SplitKeepEmpty(Parts[4], ",");
		for i = 1, #Effects do
			local Count, Desc = string.match(Effects[i], "^(%d+)|(.+)$");
			if (Desc) then
				Out = Out .. "|cFF05E105(" .. Count .. "件) " .. Desc .. "|r\n";
			else
				Out = Out .. "|cFF05E105" .. Effects[i] .. "|r\n";
			end
		end
	end

	return Out;
end

local function Dream_BuildRuneModuleLines(DataText)
	if (not Dream_IsModuleText(DataText)) then
		return "";
	end

	local Parts = Dream_SplitKeepEmpty(DataText, "|");
	local SlotCount = tonumber(Parts[1]) or 0;
	local SlotIdsText = Parts[2] or "";
	local RuneItems = Parts[3] or "";
	if (SlotCount <= 0) then
		return "";
	end

	local Out = "|cFF05E105符文槽位: " .. tostring(SlotCount) .. "|r\n";
	SlotIdsText = string.gsub(SlotIdsText, ",", "#");
	RuneItems = string.gsub(RuneItems, ",", "#");
	local SlotIds = Dream_SplitKeepEmpty(SlotIdsText, "#");
	local Items = Dream_SplitKeepEmpty(RuneItems, "#");

	local MaxSlots = SlotCount;
	if (MaxSlots > 20) then
		MaxSlots = 20;
	end
	for i = 1, MaxSlots do
		local SlotId = tonumber(SlotIds[i]) or i;
		local ItemId = tonumber(Items[i]) or 0;
		if (ItemId > 0) then
			Out = Out .. "|cFF05E105[" .. tostring(SlotId) .. "] " .. DreamGetItemLink(ItemId) .. "|r\n";
		else
			Out = Out .. "|cFF808080[" .. tostring(SlotId) .. "] 空|r\n";
		end
	end
	return Out;
end

local function Dream_BuildPercentAttributeModuleLines(DataText)
	if (not Dream_IsModuleText(DataText)) then
		return "";
	end

	local Out = "";
	local Items = Dream_SplitKeepEmpty(DataText, ",");
	for i = 1, #Items do
		local SType, SValue = string.match(Items[i], "^%s*(-?%d+)%s+([^,%s]+)");
		SType = tonumber(SType);
		if (SType and SValue and SType ~= -1 and Dream_IsPositiveIntegerText(SValue)) then
			local StatName = Dream_GetModuleStatName(SType);
			if (StatName ~= "") then
				Out = Out .. "|cFF05E105+" .. Dream_FormatModuleAttributeNumber(SValue) .. "% " .. StatName .. "|r\n";
			end
		end
	end

	return Out;
end

local function Dream_BuildEnhancementModuleLines(DataText)
	if (not Dream_IsModuleText(DataText)) then
		return "";
	end

	local Parts = Dream_SplitKeepEmpty(DataText, "|");
	local Level = tonumber(Parts[1]) or 0;
	local Attrs = Parts[2] or "";
	local Out = "|cFF05E105当前强化等级: +" .. tostring(Level) .. "|r\n";

	if (Dream_IsModuleText(Attrs)) then
		Out = Out .. Dream_BuildAttributeModuleLines(Attrs);
	end

	return Out;
end

local function Dream_BuildGrowthModuleLines(DataText)
	if (not Dream_IsModuleText(DataText)) then
		return "";
	end

	local Parts = Dream_SplitKeepEmpty(DataText, "|");
	local Level = tonumber(Parts[1]) or 0;
	local CurrentExp = Parts[2] or "0";
	local RequiredExp = Parts[3] or "0";
	local Attrs = Parts[4] or "";
	local PercentAttrs = Parts[5] or "";
	local NextExpText = (tonumber(RequiredExp) or 0) == 0 and "满级" or Dream_FormatModuleAttributeNumber(RequiredExp);
	local Out = "|cFF05E105当前成长等级: " .. tostring(Level) .. "|r\n";
	Out = Out .. "|cFF05E105成长经验: 当前<" .. Dream_FormatModuleAttributeNumber(CurrentExp) .. "> 下一级<" .. NextExpText .. ">|r\n";

	if (Dream_IsModuleText(Attrs)) then
		Out = Out .. Dream_BuildAttributeModuleLines(Attrs);
	end

	if (Dream_IsModuleText(PercentAttrs)) then
		Out = Out .. Dream_BuildPercentAttributeModuleLines(PercentAttrs);
	end

	return Out;
end

local function Dream_AddModuleSection(Out, Title, Body)
	if (not Dream_IsModuleText(Body)) then
		return Out;
	end
	return Out .. "|cFFFD3FB8★★★[" .. Title .. "]★★★|r\n" .. Body;
end

local function Dream_BuildAllModuleTooltipText(ModuleData)
	if (not ModuleData) then
		return "";
	end

	local Out = "";
	local HuanjingMultiplierSuffix = Dream_GetHuanjingMultiplierSuffix(ModuleData);
	Out = Dream_AddModuleSection(Out, "追加属性", Dream_BuildCompactAttributeModuleLines(ModuleData.AdditionalAttributes, HuanjingMultiplierSuffix));
	Out = Dream_AddModuleSection(Out, "追加技能", Dream_BuildSkillModuleLines(ModuleData.SkillsData));
	Out = Dream_AddModuleSection(Out, "追加套装", Dream_BuildSetModuleLines(ModuleData.SetData));
	Out = Dream_AddModuleSection(Out, "追加强化", Dream_BuildEnhancementModuleLines(ModuleData.EnhancementData));
	Out = Dream_AddModuleSection(Out, "追加成长", Dream_BuildGrowthModuleLines(ModuleData.GrowthData));

	return Out;
end

local function Dream_RemoveModuleSection(Text, Title)
	Text = tostring(Text or "");
	local StartMarker = "★★★[" .. tostring(Title or "") .. "]★★★";
	local Start = string.find(Text, StartMarker, 1, true);
	if (not Start) then
		return Text;
	end

	local SectionTitles = { "追加属性", "追加技能", "追加套装", "追加符文", "追加强化", "追加成长", "随机附魔" };
	local NextStart = nil;
	for Index = 1, #SectionTitles do
		local Marker = "★★★[" .. SectionTitles[Index] .. "]★★★";
		local Position = string.find(Text, Marker, Start + string.len(StartMarker), true);
		if (Position and (not NextStart or Position < NextStart)) then
			NextStart = Position;
		end
	end

	if (NextStart) then
		return string.sub(Text, 1, Start - 1) .. string.sub(Text, NextStart);
	end
	return string.sub(Text, 1, Start - 1);
end

local function Dream_BuildRandomEnchantSection(GuidLow)
	if (not GuidLow or GuidLow <= 0 or not Zs_GuidLowStoreData.EnchantData or not Zs_GuidLowStoreData.EnchantData[GuidLow]) then
		return "";
	end

	local Out = "";
	local EnchantData = Zs_GuidLowStoreData.EnchantData[GuidLow];
	for i = 1, #EnchantData do
		local EnchStr = GetEnchantDes(EnchantData[i]);
		if (Dream_IsModuleText(EnchStr)) then
			EnchStr = tostring(EnchStr or "");
			EnchStr = string.gsub(EnchStr, "^(|c%x%x%x%x%x%x%x%x)%s+", "%1");
			EnchStr = string.gsub(EnchStr, "^%s+", "");
			if (EnchStr ~= "") then
				Out = Out .. "|cFF05E105[" .. tostring(i) .. "] " .. EnchStr .. "|r\n";
			end
		end
	end

	if (Out == "") then
		return "";
	end

	return CRandomAStr .. "\n" .. Out;
end

local function Dream_InsertRandomEnchantAfterAdditional(Text, GuidLow)
	local RandomText = Dream_BuildRandomEnchantSection(GuidLow);
	if (RandomText == "") then
		return Text or "";
	end

	Text = tostring(Text or "");
	if (Text == "") then
		return RandomText;
	end

	local AdditionalPos = string.find(Text, "★★★[追加属性]★★★", 1, true);
	if (not AdditionalPos) then
		if (string.sub(Text, -1) ~= "\n") then
			Text = Text .. "\n";
		end
		return Text .. RandomText;
	end

	local InsertPos = nil;
	local SectionTitles = { "追加技能", "追加套装", "追加符文", "追加强化", "追加成长" };
	for i = 1, #SectionTitles do
		local SectionPos = string.find(Text, "★★★[" .. SectionTitles[i] .. "]★★★", AdditionalPos + 1, true);
		if (SectionPos and (not InsertPos or SectionPos < InsertPos)) then
			InsertPos = SectionPos;
		end
	end

	if (not InsertPos) then
		if (string.sub(Text, -1) ~= "\n") then
			Text = Text .. "\n";
		end
		return Text .. RandomText;
	end

	local LineStart = 1;
	local SearchStart = 1;
	while true do
		local NewlinePos = string.find(Text, "\n", SearchStart, true);
		if (not NewlinePos or NewlinePos >= InsertPos) then
			break
		end
		LineStart = NewlinePos + 1;
		SearchStart = NewlinePos + 1;
	end

	return string.sub(Text, 1, LineStart - 1) .. RandomText .. string.sub(Text, LineStart);
end

local function Dream_BuildItemDescriptionText(ItemId, ModuleData)
	local Out = "";
	if (Dream_ItemSubNameData and Dream_IsModuleText(Dream_ItemSubNameData[ItemId]) and Dream_ItemSubNameData[ItemId] ~= " ") then
		Out = Out .. "|cFFB0E0FF" .. Dream_ItemSubNameData[ItemId] .. "|r\n";
	end
	if (ModuleData and ModuleData.Display and Dream_IsModuleText(ModuleData.Display.BottomDescription)) then
		Out = Out .. "|cFFB0E0FF" .. ModuleData.Display.BottomDescription .. "|r\n";
	end
	return Out;
end

local function Dream_AddFinalItemDescription(Tip, ItemId, ModuleData)
	if (not Tip or not ItemId) then
		return false;
	end

	local Text = Dream_BuildItemDescriptionText(ItemId, ModuleData);
	if (Text == "") then
		return false;
	end

	local Key = tostring(ItemId) .. ":" .. Text;
	if (Tip.Dream_LastItemDescriptionKey == Key) then
		return false;
	end
	Tip.Dream_LastItemDescriptionKey = Key;
	Tip:AddLine("\n" .. Text, 0.69, 0.88, 1.0, true);
	return true;
end

local function Dream_ParseAllModuleData(Msg)
	local Parts = Dream_SplitKeepEmpty(Msg, ":");
	if (Parts[1] ~= "ALL_MODULE_DATA") then
		return nil;
	end

	local Index = 2;
	local Bag = nil;
	local Slot = nil;
	local ItemId = 0;
	local GuidLow = 0;
	if (#Parts >= 15 and tonumber(Parts[4]) and tonumber(Parts[5])) then
		Bag = tonumber(Parts[2]);
		Slot = tonumber(Parts[3]);
		ItemId = tonumber(Parts[4]) or 0;
		GuidLow = tonumber(Parts[5]) or 0;
		Index = 6;
	else
		ItemId = tonumber(Parts[2]) or 0;
		GuidLow = tonumber(Parts[3]) or 0;
		Index = 4;
	end

	local Data = {
		Bag = Bag,
		Slot = Slot,
		ItemId = ItemId,
		GuidLow = GuidLow,
		BaseAttributes = Parts[Index] or "",
		AdditionalAttributes = Parts[Index + 1] or "",
		IdentificationDisplay = Parts[Index + 2] or "",
		GrowthData = Parts[Index + 3] or "",
		EnhancementData = Parts[Index + 4] or "",
		SkillsData = Parts[Index + 5] or "",
		RuneData = Parts[Index + 6] or "",
		SetData = "",
		HuanjingData = "",
		PendingIdentifyData = "",
		TemplateStatsData = "",
	};

	local Remaining = {};
	for i = Index + 7, #Parts do
		table.insert(Remaining, Parts[i]);
	end

	for i = #Remaining, 1, -1 do
		if (string.find(Remaining[i] or "", "^TPL64|")) then
			Data.TemplateStatsData = Remaining[i];
			table.remove(Remaining, i);
			break
		end
	end

	for i = #Remaining, 1, -1 do
		if (string.find(Remaining[i] or "", "^PENDID|")) then
			Data.PendingIdentifyData = Remaining[i];
			table.remove(Remaining, i);
			break
		end
	end

	if (#Remaining > 0 and Dream_IsHuanjingDataText(Remaining[#Remaining])) then
		Data.HuanjingData = Remaining[#Remaining];
		table.remove(Remaining, #Remaining);
	end

	Data.SetData = table.concat(Remaining, ":");
	Data.Display = Dream_ParseIdentificationDisplay(Data.IdentificationDisplay);

	return Data;
end

local function Dream_HasRenderableAllModuleData(ModuleData)
	if (not ModuleData) then
		return false;
	end

	return Dream_IsModuleText(ModuleData.BaseAttributes)
		or Dream_IsModuleText(ModuleData.AdditionalAttributes)
		or Dream_IsModuleText(ModuleData.IdentificationDisplay)
		or Dream_IsModuleText(ModuleData.GrowthData)
		or Dream_IsModuleText(ModuleData.EnhancementData)
		or Dream_IsModuleText(ModuleData.SkillsData)
		or Dream_IsModuleText(ModuleData.RuneData)
		or Dream_IsModuleText(ModuleData.SetData)
		or Dream_IsModuleText(ModuleData.HuanjingData)
		or Dream_IsModuleText(ModuleData.PendingIdentifyData)
		or Dream_IsModuleText(ModuleData.TemplateStatsData);
end

local function Dream_ParseItemLinkStoreKey(ItemLink)
	if (not ItemLink) then
		return nil, 0, nil;
	end

	local Link = (Dream_NormalizeHyperlink and Dream_NormalizeHyperlink(ItemLink)) or ItemLink;
	local Sp = string.match(Link, "item[%-?%d:]+");
	if (not Sp) then
		return nil, 0, nil;
	end

	local _, ItemIdStr, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", Sp);
	local ItemId = tonumber(ItemIdStr);
	local GuidLowNum = tonumber(ItemGuidLow) or 0;
	local GuidLow = 0;
	if (GuidLowNum > MaxGuidIndex) then
		GuidLow = GuidLowNum - MaxGuidIndex;
	end
	GuidLow = GuidLow > 0 and GuidLow or 0;

	return ItemId, GuidLow, ItemIdStr;
end

-- FrozenCore uses the same custom item-link parser to associate owned GUIDs
-- with the current character without duplicating equipment payloads.
function FrozenCore_GetItemGuidFromLink(ItemLink)
	local _, GuidLow = Dream_ParseItemLinkStoreKey(ItemLink);
	return GuidLow;
end

--判断附魔
function IsEnchantItem(GuidLow)
	if (not Zs_GuidLowStoreData.EnchantData) then
		return false;
	end
	if (not Zs_GuidLowStoreData.EnchantData[GuidLow]) then
		return false;
	end

	for i = 1, #Zs_GuidLowStoreData.EnchantData[GuidLow] do
		if (Zs_GuidLowStoreData.EnchantData[GuidLow][i] ~= "0") then
			return true;
		end
	end

	return false;
end

--判断附魔最大
function IsMaxNumEnchant(GuidLow)
	if (not Zs_GuidLowStoreData.EnchantData) then
		return false;
	end
	if (not Zs_GuidLowStoreData.EnchantData[GuidLow]) then
		return false;
	end

	for i = 1, #Zs_GuidLowStoreData.EnchantData[GuidLow] do
		if (tonumber(Zs_GuidLowStoreData.EnchantData[GuidLow][i]) and tonumber(Zs_GuidLowStoreData.EnchantData[GuidLow][i]) > 65535) then
			return true;
		end
	end

	return false;
end

--取说明
function GetEnchantDes(EnchantId)
	if (not Dream_EnchantmentDes) then
		return "0";
	end

	if (not Dream_EnchantmentDes[EnchantId]) then
		return "0";
	end

	return Dream_EnchantmentDes[EnchantId];
end

--排除
function InAuctionOrMailFrame(Owner)
	if (not Owner or not Owner.GetName) then
		return false;
	end

	local OwnerName = Owner:GetName();
	if (type(OwnerName) ~= "string") then
		return false;
	end

	return (string.find(OwnerName, "Auctions", 1, true))
		or (string.find(OwnerName, "BrowseButton", 1, true))
		or (string.find(OwnerName, "MailItem", 1, true));
end

-----------------------------------------符文组件 初始化5个Tip的子类组件 预创建----------------------------------------------------------------------------
local RunesCount = 8;     --不可改动 最大8个符文
local RunesIconSize = 36; --不可改动 纹理大小
local Duration = 4;
local Degrees = -360;
local ItemRefTooltipTextures = {}; --纹理控件
local GameTooltipTextures = {};
local ShoppingTooltip1Textures = {};
local ShoppingTooltip2Textures = {};
local ShoppingTooltip3Textures = {};

local function Dream_FormatTooltipLargeNumbers(Self)
	if (not Self or not Dream_FormatTooltipNumberText) then
		return;
	end

	local function FormatVisibleText(Text)
		local Markup = {};
		local function Protect(Value)
			table.insert(Markup, Value);
			return "\001" .. tostring(#Markup) .. "\002";
		end

		Text = tostring(Text or "");
		Text = string.gsub(Text, "|H.-|h.-|h", Protect);
		Text = string.gsub(Text, "|T.-|t", Protect);
		Text = string.gsub(Text, "|c%x%x%x%x%x%x%x%x", Protect);
		Text = string.gsub(Text, "|r", Protect);
		Text = Dream_FormatTooltipNumberText(Text);
		Text = string.gsub(Text, "\001(%d+)\002", function(Index)
			return Markup[tonumber(Index)] or "";
		end);
		return Text;
	end

	for i = 1, Self:NumLines() do
		local LeftLine = _G[Self:GetName() .. "TextLeft" .. i];
		if (LeftLine and LeftLine:GetText()) then
			local OldText = LeftLine:GetText();
			local NewText = FormatVisibleText(OldText);
			if (NewText ~= OldText) then
				LeftLine:SetText(NewText);
			end
		end

		local RightLine = _G[Self:GetName() .. "TextRight" .. i];
		if (RightLine and RightLine:GetText()) then
			local OldText = RightLine:GetText();
			local NewText = FormatVisibleText(OldText);
			if (NewText ~= OldText) then
				RightLine:SetText(NewText);
			end
		end
	end
end

local function Dream_SetStableTooltipWidth(Self, Width)
	Width = tonumber(Width) or 0;
	if (not Self or Width <= 0) then
		return;
	end
	if (not Self.Dream_EquipmentTooltipWidth or math.abs(Self.Dream_EquipmentTooltipWidth - Width) > 0.1) then
		Self:SetWidth(Width);
		Self.Dream_EquipmentTooltipWidth = Width;
	end
end

local Dream_BigItemStatLineRules = {
	[0] = { Pattern = "^%+[%d%.]+.*法力值", Render = function(Value) return "+"..Value.." 法力值"; end },
	[1] = { Pattern = "^%+[%d%.]+.*生命值", Render = function(Value) return "+"..Value.." 生命值"; end },
	[2] = { Pattern = "^[%d%.]+.*护甲", Render = function(Value) return Value.."点护甲"; end },
	[3] = { Pattern = "^%+[%d%.]+.*敏捷", Render = function(Value) return "+"..Value.." 敏捷"; end },
	[4] = { Pattern = "^%+[%d%.]+.*力量", Render = function(Value) return "+"..Value.." 力量"; end },
	[5] = { Pattern = "^%+[%d%.]+.*智力", Render = function(Value) return "+"..Value.." 智力"; end },
	[6] = { Pattern = "^%+[%d%.]+.*精神", Render = function(Value) return "+"..Value.." 精神"; end },
	[7] = { Pattern = "^%+[%d%.]+.*耐力", Render = function(Value) return "+"..Value.." 耐力"; end },
	[12] = { Pattern = "^装备： 防御等级提高[%d%.]+", Render = function(Value) return "装备： 防御等级提高"..Value.."。"; end },
	[13] = { Pattern = "^装备： 使你的躲闪等级提高[%d%.]+", Render = function(Value) return "装备： 使你的躲闪等级提高"..Value.."。"; end },
	[14] = { Pattern = "^装备： 使你的招架等级提高[%d%.]+", Render = function(Value) return "装备： 使你的招架等级提高"..Value.."。"; end },
	[15] = { Pattern = "^装备： 使你的盾牌格挡等级提高[%d%.]+", Render = function(Value) return "装备： 使你的盾牌格挡等级提高"..Value.."。"; end },
	[16] = { Pattern = "^装备： 近战命中等级提高[%d%.]+", Render = function(Value) return "装备： 近战命中等级提高"..Value.."。"; end },
	[17] = { Pattern = "^装备： 远程命中等级提高[%d%.]+", Render = function(Value) return "装备： 远程命中等级提高"..Value.."。"; end },
	[18] = { Pattern = "^装备： 法术命中等级提高[%d%.]+", Render = function(Value) return "装备： 法术命中等级提高"..Value.."。"; end },
	[19] = { Pattern = "^装备： 近战.*击等级提高[%d%.]+", Render = function(Value) return "装备： 近战暴击等级提高"..Value.."。"; end },
	[20] = { Pattern = "^装备： 远程.*击等级提高[%d%.]+", Render = function(Value) return "装备： 远程暴击等级提高"..Value.."。"; end },
	[21] = { Pattern = "^装备： 法术.*击等级提高[%d%.]+", Render = function(Value) return "装备： 法术暴击等级提高"..Value.."。"; end },
	[22] = { Pattern = "^装备： 近战命中躲闪等级提高[%d%.]+", Render = function(Value) return "装备： 近战命中躲闪等级提高"..Value.."。"; end },
	[23] = { Pattern = "^装备： 远程命中躲闪等级提高[%d%.]+", Render = function(Value) return "装备： 远程命中躲闪等级提高"..Value.."。"; end },
	[24] = { Pattern = "^装备： 法术命中躲闪等级提高[%d%.]+", Render = function(Value) return "装备： 法术命中躲闪等级提高"..Value.."。"; end },
	[25] = { Pattern = "^装备： 近战.*击躲闪等级提高[%d%.]+", Render = function(Value) return "装备： 近战暴击躲闪等级提高"..Value.."。"; end },
	[26] = { Pattern = "^装备： 远程.*击躲闪等级提高[%d%.]+", Render = function(Value) return "装备： 远程暴击躲闪等级提高"..Value.."。"; end },
	[27] = { Pattern = "^装备： 法术.*击躲闪等级提高[%d%.]+", Render = function(Value) return "装备： 法术暴击躲闪等级提高"..Value.."。"; end },
	[28] = { Pattern = "^装备： 近战急速等级提高[%d%.]+", Render = function(Value) return "装备： 近战急速等级提高"..Value.."。"; end },
	[29] = { Pattern = "^装备： 远程急速等级提高[%d%.]+", Render = function(Value) return "装备： 远程急速等级提高"..Value.."。"; end },
	[30] = { Pattern = "^装备： 法术急速等级提高[%d%.]+", Render = function(Value) return "装备： 法术急速等级提高"..Value.."。"; end },
	[31] = { Pattern = "^装备： 命中等级提高[%d%.]+", Render = function(Value) return "装备： 命中等级提高"..Value.."。"; end },
	[32] = { Pattern = "^装备： .*击等级提高[%d%.]+", Render = function(Value) return "装备： 暴击等级提高"..Value.."。"; end },
	[33] = { Pattern = "^装备： 命中躲闪等级提高[%d%.]+", Render = function(Value) return "装备： 命中躲闪等级提高"..Value.."。"; end },
	[34] = { Pattern = "^装备： .*击躲闪等级提高[%d%.]+", Render = function(Value) return "装备： 暴击躲闪等级提高"..Value.."。"; end },
	[35] = { Pattern = "^装备： 韧性等级提高[%d%.]+", Render = function(Value) return "装备： 韧性等级提高"..Value.."。"; end },
	[36] = { Pattern = "^装备： 急速等级提高[%d%.]+", Render = function(Value) return "装备： 急速等级提高"..Value.."。"; end },
	[37] = { Pattern = "^装备： 使你的精准等级提高[%d%.]+", Render = function(Value) return "装备： 使你的精准等级提高"..Value.."。"; end },
	[38] = { Pattern = "^装备： 攻击强度提高[%d%.]+", Render = function(Value) return "装备： 攻击强度提高"..Value.."点。"; end },
	[39] = { Pattern = "^装备： 远程攻击强度提高[%d%.]+", Render = function(Value) return "装备： 远程攻击强度提高"..Value.."点。"; end },
	[40] = { Pattern = "^装备： 猎豹、熊、巨熊、枭兽形态攻击强度[%d%.]+", Render = function(Value) return "装备： 猎豹、熊、巨熊、枭兽形态攻击强度"..Value.."。"; end },
	[41] = { Pattern = "^装备： 法术和魔法效果的治疗量提高最多[%d%.]+", Render = function(Value) return "装备： 法术和魔法效果的治疗量提高最多"..Value.."。"; end },
	[42] = { Pattern = "^装备： 法术和魔法效果的伤害量提高最多[%d%.]+", Render = function(Value) return "装备： 法术和魔法效果的伤害量提高最多"..Value.."。"; end },
	[43] = { Pattern = "^装备： 每5秒回复[%d%.]+", Render = function(Value) return "装备： 每5秒回复"..Value.."点法力值。"; end },
	[44] = { Pattern = "^装备： 使你的护甲穿透等级提高[%d%.]+", Render = function(Value) return "装备： 使你的护甲穿透等级提高"..Value.."。"; end },
	[45] = { Pattern = "^装备： 法术强度提高[%d%.]+", Render = function(Value) return "装备： 法术强度提高"..Value.."点。"; end },
	[46] = { Pattern = "^装备： 每5秒恢复[%d%.]+", Render = function(Value) return "装备： 每5秒恢复"..Value.."点生命值。"; end },
	[47] = { Pattern = "^装备： 法术穿透提高[%d%.]+", Render = function(Value) return "装备： 法术穿透提高"..Value.."。"; end },
	[48] = { Pattern = "^装备： 使你的盾牌格挡值提高[%d%.]+", Render = function(Value) return "装备： 使你的盾牌格挡值提高"..Value.."。"; end },
};

local Dream_BigItemStatLineRuleOrder = {
	2, 0, 1, 3, 4, 5, 6, 7,
	12, 13, 14, 15, 16, 17, 18,
	19, 20, 21, 22, 23, 24, 25, 26, 27,
	28, 29, 30, 31, 33, 34, 35, 36, 37,
	39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
	38, 32,
};

local function Dream_BuildBigItemStatMap(BigStat)
	if (not BigStat or BigStat.StatMap) then
		return;
	end

	BigStat.StatMap = {};
	local Types = Dream_Split(BigStat.TStore or "", "#");
	local Values = Dream_Split(BigStat.VStore or "", "#");
	for X = 1, #Types do
		local SType = tonumber(Types[X]);
		local SValue = Values[X] or "0";
		if (SType and Dream_IsPositiveIntegerText(SValue)) then
			BigStat.StatMap[SType] = SValue;
		end
	end
end

local Dream_BigItemGuidAttrIndex = {
	[3] = 1,
	[4] = 2,
	[5] = 3,
	[6] = 4,
	[7] = 5,
	[38] = 6,
	[45] = 7,
};

local function Dream_IsGuidSuperRandomItem(GuidData)
	return (GuidData and GuidData.IsSuperRandom == true);
end

local function Dream_GetGuidAttrMultiplier(GuidData, SType)
	local Index = Dream_BigItemGuidAttrIndex[SType];
	if (not Dream_IsGuidSuperRandomItem(GuidData) or not Index or not GuidData._Attris) then
		return "1";
	end

	local Attris = Dream_Split(GuidData._Attris, "#");
	local Multiplier = tostring(Attris[Index] or "1"):gsub(",", ""):match("^%+?(%d+)$") or "1";
	Multiplier = Multiplier:gsub("^0+", "");
	if (Multiplier == "" or Multiplier == "0") then
		return "1";
	end

	return Multiplier;
end

local function Dream_GetGuidAdjustedBigItemStatValue(SValue, SType, GuidData)
	local Multiplier = Dream_GetGuidAttrMultiplier(GuidData, SType);
	if (Multiplier ~= "1" and Dream_MultiplyIntegerTextByIntegerText) then
		return Dream_MultiplyIntegerTextByIntegerText(SValue, Multiplier);
	end

	return SValue;
end

local function Dream_FormatBigItemNumber(Value)
	local Text = tostring(Value or "0");
	local IntegerPart = string.match(Text, "^(%d+)%.%d+$");
	if (IntegerPart) then
		Text = IntegerPart;
	end

	local Result = Dream_FormatChineseNumber(Text);
	Result = Dream_FormatTooltipNumberText(Result);
	Result = Result:gsub("万万", "万");
	Result = Result:gsub("亿亿", "亿");
	Result = Result:gsub("兆兆", "兆");
	Result = Result:gsub("京京", "京");
	return Result;
end

local function Dream_AddPositiveIntegerText(Left, Right)
	local A = tostring(Left or "0"):gsub(",", ""):match("^%+?(%d+)$") or "0";
	local B = tostring(Right or "0"):gsub(",", ""):match("^%+?(%d+)$") or "0";
	local Carry = 0;
	local Out = {};
	local I = string.len(A);
	local J = string.len(B);
	while (I > 0 or J > 0 or Carry > 0) do
		local ADigit = (I > 0) and tonumber(string.sub(A, I, I)) or 0;
		local BDigit = (J > 0) and tonumber(string.sub(B, J, J)) or 0;
		local Sum = ADigit + BDigit + Carry;
		table.insert(Out, 1, tostring(Sum % 10));
		Carry = math.floor(Sum / 10);
		I = I - 1;
		J = J - 1;
	end

	local Text = table.concat(Out):gsub("^0+", "");
	return (Text == "") and "0" or Text;
end

local function Dream_ApplyNativeTemplateStats(ModuleData)
	if (not ModuleData or not ModuleData.ItemId or ModuleData.ItemId <= 0 or
		not string.find(ModuleData.TemplateStatsData or "", "^TPL64|")) then
		return false;
	end

	local Fields = Dream_SplitKeepEmpty(ModuleData.TemplateStatsData, "|");
	local Types = {};
	local Values = {};
	for _, Stat in ipairs(Dream_Split(Fields[2] or "", ",")) do
		local StatType, StatValue = string.match(Stat, "^(%d+)%s+([%+%-]?%d+)$");
		if (StatType and StatValue and Dream_IsPositiveIntegerText(StatValue)) then
			table.insert(Types, StatType);
			table.insert(Values, StatValue);
		end
	end

	local DamageMin = "0";
	local DamageMax = "0";
	for _, Damage in ipairs(Dream_Split(Fields[4] or "", ",")) do
		local Min, Max = string.match(Damage, "^%s*([%+%-]?%d+)%s+([%+%-]?%d+)%s+");
		if (Min and Max and Dream_IsPositiveIntegerText(Min) and Dream_IsPositiveIntegerText(Max)) then
			DamageMin = Dream_AddPositiveIntegerText(DamageMin, Min);
			DamageMax = Dream_AddPositiveIntegerText(DamageMax, Max);
		end
	end

	local OldStat = Zs_EntryIdStoreData.BigItemStatData[ModuleData.ItemId] or {};
	Zs_EntryIdStoreData.BigItemStatData[ModuleData.ItemId] = {
		TStore = table.concat(Types, "#"),
		VStore = table.concat(Values, "#"),
		DmgMin = (DamageMin ~= "0") and DamageMin or OldStat.DmgMin,
		DmgMax = (DamageMax ~= "0") and DamageMax or OldStat.DmgMax,
		DPS = OldStat.DPS,
		WeaponChecked = (DamageMin ~= "0" or DamageMax ~= "0") and true or OldStat.WeaponChecked,
	};
	Dream_MarkEntryCacheId(ModuleData.ItemId);
	Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.EntryId, ModuleData.ItemId);
	return true;
end

local function Dream_BuildModuleBaseAttributeMap(ModuleData)
	if (not ModuleData or not Dream_IsModuleText(ModuleData.BaseAttributes)) then
		return nil;
	end

	if (ModuleData.BaseAttributeMap) then
		return ModuleData.BaseAttributeMap;
	end

	local Map = {};
	local Items = Dream_SplitKeepEmpty(ModuleData.BaseAttributes, ",");
	for i = 1, #Items do
		local SType, SValue = string.match(Items[i], "^%s*(-?%d+)%s+([^,%s]+)");
		SType = tonumber(SType);
		if (SType and SValue and SType ~= -1 and Dream_IsPositiveIntegerText(SValue)) then
			Map[SType] = Dream_AddPositiveIntegerText(Map[SType], SValue);
		end
	end

	ModuleData.BaseAttributeMap = Map;
	return Map;
end

local function Dream_BuildModuleBaseRemainderLines(ModuleData, AppliedMap)
	local BaseMap = Dream_BuildModuleBaseAttributeMap(ModuleData);
	if (not BaseMap) then
		return "";
	end

	local Out = "";
	local HuanjingMultiplierSuffix = Dream_GetHuanjingMultiplierSuffix(ModuleData);
	for _, SType in ipairs(Dream_BigItemStatLineRuleOrder) do
		if (BaseMap[SType] and (not AppliedMap or not AppliedMap[SType])) then
			local Rule = Dream_BigItemStatLineRules[SType];
			if (Rule and Rule.Render) then
				Out = Out .. Rule.Render(Dream_FormatBigItemNumber(BaseMap[SType])) .. HuanjingMultiplierSuffix .. "\n";
			end
		end
	end

	return Out;
end

local function Dream_AddModuleTooltipBlock(Tip, Text)
	if (not Tip or not Dream_IsModuleText(Text)) then
		return false;
	end

	Tip:AddLine("\n" .. Text, 1, 1, 1, true);
	return true;
end

local function Dream_AddEquipmentTooltipBlock(Tip, AnchorLine, Text)
	if (not Tip or not Dream_IsModuleText(Text)) then
		return false;
	end

	if (AnchorLine and AnchorLine.GetText) then
		local OriginalText = AnchorLine:GetText() or "";
		AnchorLine:SetText(OriginalText .. "\n" .. Text);
		AnchorLine:SetWidth(Tip:GetWidth());
		return true;
	end

	return Dream_AddModuleTooltipBlock(Tip, Text);
end

local function Dream_BuildModuleBaseAttributeLineList(ModuleData)
	local BaseMap = Dream_BuildModuleBaseAttributeMap(ModuleData);
	if (not BaseMap) then
		return nil;
	end

	if (ModuleData.BaseAttributeLineList) then
		return ModuleData.BaseAttributeLineList;
	end

	local Lines = {};
	local HuanjingMultiplierSuffix = Dream_GetHuanjingMultiplierSuffix(ModuleData);
	for _, SType in ipairs(Dream_BigItemStatLineRuleOrder) do
		local SValue = BaseMap[SType];
		local Rule = Dream_BigItemStatLineRules[SType];
		if (SValue and Rule and Rule.Render) then
			table.insert(Lines, {
				SType = SType,
				Text = Rule.Render(Dream_FormatBigItemNumber(SValue)) .. HuanjingMultiplierSuffix,
			});
		end
	end

	ModuleData.BaseAttributeLineList = Lines;
	return Lines;
end

local function Dream_StripTooltipColorCodes(St)
	local Text = tostring(St or "");
	Text = string.gsub(Text, "|c%x%x%x%x%x%x%x%x", "");
	Text = string.gsub(Text, "|r", "");
	Text = string.gsub(Text, "^%s+", "");
	Text = string.gsub(Text, "%s+$", "");
	return Text;
end

local function Dream_NormalizeRandomEnchantText(St)
	local Text = Dream_StripTooltipColorCodes(St);
	Text = string.gsub(Text, "|n", "\n");
	Text = string.gsub(Text, "%s+", "");
	return Text;
end

local function Dream_TrimRandomEnchantLeadingSpace(St)
	local Text = tostring(St or "");
	-- 官方物品提示会给部分“+属性”附魔文本加行首空白；保留颜色码，只移除该缩进。
	Text = string.gsub(Text, "^(|c%x%x%x%x%x%x%x%x)%s+", "%1");
	Text = string.gsub(Text, "^%s+", "");
	return Text;
end

local function Dream_AlignRandomEnchantLine(Self, GLine)
	if (not Self or not GLine or GLine.Dream_RandomEnchantAligned) then
		return;
	end

	local TooltipLeft = Self:GetLeft();
	local LineLeft = GLine:GetLeft();
	local Point, RelativeTo, RelativePoint, XOffset, YOffset = GLine:GetPoint(1);
	if (not TooltipLeft or not LineLeft or not Point) then
		return;
	end

	-- 官方附魔行带有独立的横向缩进；保留原有纵向锚点，只向左校正一次。
	GLine:ClearAllPoints();
	GLine:SetPoint(Point, RelativeTo, RelativePoint, (XOffset or 0) + (TooltipLeft + 10) - LineLeft, YOffset or 0);
	GLine.Dream_RandomEnchantAligned = true;
end

local function Dream_ClearOfficialRandomEnchantLines(Self, GuidLow)
	if (not Self or not Self:GetName() or not IsEnchantItem(GuidLow)) then
		return false;
	end

	local EnchantTexts = {};
	for i = 1, #Zs_GuidLowStoreData.EnchantData[GuidLow] do
		local EnchStr = GetEnchantDes(Zs_GuidLowStoreData.EnchantData[GuidLow][i]);
		if (EnchStr ~= "0") then
			EnchantTexts[Dream_NormalizeRandomEnchantText(EnchStr)] = true;
		end
	end

	local Cleared = false;
	for i = 1, Self:NumLines() do
		local GLine = _G[Self:GetName() .. "TextLeft" .. i];
		local Text = GLine and GLine:GetText();
		if (Text and EnchantTexts[Dream_NormalizeRandomEnchantText(Text)]) then
			GLine:SetText("");
			Cleared = true;
		end
	end

	return Cleared;
end

-- Random enchant lines use the same "+value" format as base attributes.
-- Keep them out of the base-attribute anchor calculation so the custom
-- random-enchant section is placed after the actual last base value.
local function Dream_IsRandomEnchantLine(GuidLow, Text)
	if (not GuidLow or GuidLow <= 0 or not Text or not IsEnchantItem(GuidLow)) then
		return false;
	end

	local Normalized = Dream_NormalizeRandomEnchantText(Text);
	for i = 1, #Zs_GuidLowStoreData.EnchantData[GuidLow] do
		local EnchStr = GetEnchantDes(Zs_GuidLowStoreData.EnchantData[GuidLow][i]);
		if (EnchStr ~= "0" and Normalized == Dream_NormalizeRandomEnchantText(EnchStr)) then
			return true;
		end
	end

	return false;
end

local function Dream_IsOfficialModuleBaseReplaceLine(St)
	local Text = Dream_StripTooltipColorCodes(St);
	if (Text == "") then
		return false;
	end

	if (string.find(Text, "^[%d%.]+.*护甲")) then
		return true;
	end

	if (string.find(Text, "^%+[%d%.]+")) then
		return true;
	end

	for _, SType in ipairs(Dream_BigItemStatLineRuleOrder) do
		local Rule = Dream_BigItemStatLineRules[SType];
		if (Rule and Rule.Pattern and string.find(Text, Rule.Pattern)) then
			return true;
		end
	end

	return false;
end

local function Dream_ReplaceModuleBaseAttributeLine(St, ModuleData, AppliedMap, State)
	if (not Dream_IsOfficialModuleBaseReplaceLine(St)) then
		return nil;
	end

	local Lines = Dream_BuildModuleBaseAttributeLineList(ModuleData);
	if (not Lines or #Lines == 0) then
		Dream_ItemTooltipDebug("base_replace_no_lines", State and State.ItemId or 0, State and State.GuidLow or 0, "text=" .. Dream_ItemTooltipShort(St, 60) .. " base=" .. Dream_ItemTooltipShort(ModuleData and ModuleData.BaseAttributes or "nil", 80));
		return nil;
	end

	if (not State) then
		State = {};
	end

	if (State.BlockApplied) then
		Dream_ItemTooltipDebug("base_replace_clear", State.ItemId or 0, State.GuidLow or 0, "text=" .. Dream_ItemTooltipShort(St, 60));
		return "";
	end

	State.BlockApplied = true;

	local Out = "";
	for i = 1, #Lines do
		local LineData = Lines[i];
		if (LineData and LineData.Text) then
			if (Out ~= "") then
				Out = Out .. "\n";
			end
			Out = Out .. LineData.Text;
			if (AppliedMap and LineData.SType) then
				AppliedMap[LineData.SType] = true;
			end
		end
	end

	Dream_ItemTooltipDebug("base_replace_apply", State.ItemId or 0, State.GuidLow or 0, "count=" .. tostring(#Lines) .. " text=" .. Dream_ItemTooltipShort(Out, 120));
	return Out;
end

local function Dream_IsWeaponDpsLine(St)
	if (not St) then
		return false;
	end

	local Text = tostring(St);
	Text = string.gsub(Text, "|c%x%x%x%x%x%x%x%x", "");
	Text = string.gsub(Text, "|r", "");
	Text = string.gsub(Text, "^%s+", "");
	return string.find(Text, "^每秒伤害") or string.find(Text, "^%(每秒伤害") or string.find(Text, "（每秒伤害", 1, true) == 1;
end

local function Dream_IsWeaponDamageRangeLine(St)
	return Dream_IsWeaponDamageRangeText(St);
end

local function Dream_GetGuidPutModText(SValue, GuidData)
	if (not Dream_IsGuidSuperRandomItem(GuidData) or not Dream_ScaleNumberTextByFloat) then
		return "";
	end

	local PutMod = tonumber(GuidData.PutMod) or 0;
	if (PutMod == 0) then
		return "";
	end

	local PutValue = Dream_ScaleNumberTextByFloat(SValue, PutMod, 0);
	if (PutValue == "0") then
		return "";
	end

	return " |cFFFD3FB8[+" .. Dream_FormatBigItemNumber(PutValue) .. "]|r";
end

local function Dream_AppendGuidPutModText(Text, SValue, GuidData)
	local PutText = Dream_GetGuidPutModText(SValue, GuidData);
	if (PutText == "") then
		return Text;
	end

	if (string.find(Text, "。$")) then
		return string.gsub(Text, "。$", PutText .. "。");
	end

	return Text .. PutText;
end

local function Dream_ReplaceBigItemOfficialLine(St, BigStat, GuidData, IsWeaponItem)
	if (not St or not BigStat) then
		return nil;
	end

	if (IsWeaponItem and BigStat.DmgMin and BigStat.DmgMin ~= "nullptr" and BigStat.DmgMin ~= "" and BigStat.DmgMax and BigStat.DmgMax ~= "nullptr" and BigStat.DmgMax ~= "") then
		if (Dream_IsWeaponDpsLine(St)) then
			return "（每秒伤害"..Dream_FormatBigItemNumber(BigStat.DPS or "0").."）";
		elseif (Dream_IsWeaponDamageRangeLine(St)) then
			return Dream_FormatBigItemNumber(BigStat.DmgMin).." - "..Dream_FormatBigItemNumber(BigStat.DmgMax).."点伤害";
		end
	end

	Dream_BuildBigItemStatMap(BigStat);
	if (not BigStat.StatMap) then
		return nil;
	end

	for _, SType in ipairs(Dream_BigItemStatLineRuleOrder) do
		local Rule = Dream_BigItemStatLineRules[SType];
		local SValue = BigStat.StatMap[SType];
		if (SValue and Rule.Pattern and string.find(St, Rule.Pattern)) then
			local Text = Rule.Render(Dream_FormatBigItemNumber(Dream_GetGuidAdjustedBigItemStatValue(SValue, SType, GuidData)));
			return Dream_AppendGuidPutModText(Text, SValue, GuidData);
		end
	end

	return nil;
end

local function Dream_HasGuidWeaponNumber(Value)
	local Text = tostring(Value or "");
	return (Text ~= "" and Text ~= "nullptr" and Text ~= "0" and Text ~= "0.0");
end

local function Dream_FormatGuidWeaponNumber(Value, PutMod, Decimals)
	local Text = tostring(Value or "0");
	if (PutMod and PutMod ~= 0 and Dream_ScaleNumberTextByFloat) then
		Text = Dream_ScaleNumberTextByFloat(Text, PutMod + 1.0, Decimals);
	end
	return Dream_FormatBigItemNumber(Text);
end

local function Dream_ReplaceGuidItemWeaponLine(St, GuidData, IsWeaponItem)
	if (not IsWeaponItem or not St or not GuidData or not Dream_HasGuidWeaponNumber(GuidData.MinDmg) or not Dream_HasGuidWeaponNumber(GuidData.MaxDmg)) then
		return nil;
	end

	local PutMod = Dream_IsGuidSuperRandomItem(GuidData) and (tonumber(GuidData.PutMod) or 0) or 0;
	if (Dream_IsWeaponDpsLine(St)) then
		local DpsText = Dream_FormatGuidWeaponNumber(GuidData.DPS or "0", PutMod, 1);
		if (PutMod ~= 0) then
			DpsText = "|cFFFD3FB8" .. DpsText .. "|r";
		end
		return "（每秒伤害" .. DpsText .. "）";
	elseif (Dream_IsWeaponDamageRangeLine(St)) then
		local DmgMinText = Dream_FormatGuidWeaponNumber(GuidData.MinDmg, PutMod, 0);
		local DmgMaxText = Dream_FormatGuidWeaponNumber(GuidData.MaxDmg, PutMod, 0);
		if (PutMod ~= 0) then
			DmgMinText = "|cFFFD3FB8" .. DmgMinText .. "|r";
			DmgMaxText = "|cFFFD3FB8" .. DmgMaxText .. "|r";
		end
		return DmgMinText .. " - " .. DmgMaxText .. "点伤害";
	end

	return nil;
end

local function Dream_BuildGuidExtraTooltipText(GuidData)
	if (not Dream_IsGuidSuperRandomItem(GuidData)) then
		return "";
	end

	local OnStr = "";
	local STypeStr = GuidData.TStore;
	local SValueStr = GuidData.VStore;
	local PutMod = GuidData.PutMod;
	if (STypeStr and SValueStr and IsSTypeIn(STypeStr)) then
		OnStr = OnStr .. string.gsub(SuperRandomStatStr, "^%s+", "");
		local Args = Dream_Split(STypeStr, "#");
		local Arg = Dream_Split(SValueStr, "#");
		for X = 1, #Args do
			local SType = tonumber(Args[X]);
			local SValue = Arg[X] or "0";
			if (SType ~= -1 and Dream_IsPositiveIntegerText(SValue)) then
				OnStr = OnStr .. AutoPullStr(SType, SValue, PutMod) .. "\n";
			end
		end
	end

	local AsSpellStr = GuidData.AsSpell;
	if (AsSpellStr and IsSpellIn(AsSpellStr)) then
		OnStr = OnStr .. string.gsub(SuperRandomSpellStr, "^%s+", "");
		local Ar = Dream_Split(AsSpellStr, "#");
		for E = 1, #Ar do
			local SpellId = tonumber(Ar[E]);
			if (SpellId ~= 0) then
				OnStr = OnStr .. "|cFF05E105装备： " .. Dream_GetSpellDisplayText(SpellId) .. "\n";
			end
		end
	end

	return OnStr;
end

local function Dream_IsOfficialBasePropertyLine(St)
	if (not St) then
		return false;
	end

	if (string.find(St, "^耐久度")) then
		return true;
	end

	if (Dream_IsWeaponDpsLine(St)) then
		return true;
	end

	if (Dream_IsWeaponDamageRangeLine(St)) then
		return true;
	end

	if (string.find(St, "^[%d%.]+.*护甲")) then
		return true;
	end

	if (string.find(St, "^%+[%d%.]+")) then
		return true;
	end

	return false;
end

local function Dream_GetAllModuleTooltipKey(ModuleData, ItemId)
	if (not ModuleData) then
		return nil;
	end

	local DataKey = tostring(ModuleData.BaseAttributes or "") .. "|" ..
		tostring(ModuleData.AdditionalAttributes or "") .. "|" ..
		tostring(ModuleData.SkillsData or "") .. "|" ..
		tostring(ModuleData.RuneData or "") .. "|" ..
		tostring(ModuleData.SetData or "") .. "|" ..
		tostring(ModuleData.HuanjingData or "") .. "|" ..
		tostring(ModuleData.IdentificationDisplay or "");

	if (ModuleData.GuidLow and ModuleData.GuidLow > 0) then
		return tostring(ModuleData.GuidLow) .. ":" .. tostring(ModuleData.ItemId or ItemId or 0) .. ":" .. DataKey;
	end

	if (ModuleData.Bag ~= nil and ModuleData.Slot ~= nil) then
		return tostring(ModuleData.Bag) .. ":" .. tostring(ModuleData.Slot) .. ":" .. tostring(ModuleData.ItemId or ItemId or 0) .. ":" .. DataKey;
	end

	return nil;
end

local function Dream_GetAllModuleLocationKey(Bag, Slot, ItemId)
	if (Bag == nil or Slot == nil or not ItemId) then
		return nil;
	end

	return tostring(Bag) .. ":" .. tostring(Slot) .. ":" .. tostring(ItemId);
end

local function Dream_GetTooltipClientLocation(Self)
	if (not Self or not Self.GetOwner) then
		return nil, nil;
	end

	local Owner = Self:GetOwner();
	if (not Owner) then
		return nil, nil;
	end

	local OwnerName = (Owner.GetName and Owner:GetName()) or "";
	local Slot = (Owner.GetID and Owner:GetID()) or nil;
	if (not Slot) then
		return nil, nil;
	end

	local Parent = (Owner.GetParent and Owner:GetParent()) or nil;
	local ParentName = (Parent and Parent.GetName and Parent:GetName()) or "";
	if (ParentName and string.find(ParentName, "ContainerFrame", 1, true)) then
		local Bag = (Parent.GetID and Parent:GetID()) or 0;
		return Bag, Slot;
	end

	if (OwnerName and string.find(OwnerName, "SoulItemButtons", 1, true)) then
		return 254, Slot;
	end

	if (OwnerName and string.find(OwnerName, "Slot", 1, true)) then
		return 255, Slot;
	end

	return nil, nil;
end

local function Dream_GetTooltipGuidLow(Self, GuidLow)
	if (GuidLow and GuidLow > 0) then
		return GuidLow;
	end
	if (not Self or not Self.GetOwner) then
		return 0;
	end

	local Owner = Self:GetOwner();
	local OwnerName = (Owner and Owner.GetName and Owner:GetName()) or "";
	if (OwnerName and string.find(OwnerName, "SoulItemButtons", 1, true)) then
		return tonumber(Owner.ItemGuid) or 0;
	end

	return 0;
end

local function Dream_GetTooltipItemId(Self)
	if (not Self) then
		return nil, nil;
	end

	local _, ItemLink = Self:GetItem();
	if (not ItemLink) then
		return nil, nil;
	end

	local ItemId = Dream_ParseItemLinkStoreKey(ItemLink);
	if (not ItemId) then
		return nil, ItemLink;
	end

	return ItemId, ItemLink;
end

local function Dream_RequestItemStoreData(ItemId, GuidLow, ItemIdStr, Bag, Slot, Tooltip, ForceGuidRequest)
	Dream_EnsureTooltipStoreData();
	if (not ItemId or ItemId <= 0) then
		return false;
	end

	local LocationKey = Dream_GetAllModuleLocationKey(Bag, Slot, ItemId);
	local GuidData = (GuidLow and GuidLow > 0 and Zs_GuidLowStoreData.AtGuidData[GuidLow]) or nil;
	local RuneData = (GuidLow and GuidLow > 0 and Zs_GuidLowStoreData.AtRunesData[GuidLow]) or nil;
	if (GuidData and GuidData.ItemId and GuidData.ItemId ~= ItemId) then
		Dream_ClearGuidStoreData(GuidLow);
		GuidData = nil;
	end
	if (RuneData and RuneData.ItemId and RuneData.ItemId ~= ItemId) then
		Dream_ClearGuidStoreData(GuidLow);
		RuneData = nil;
	end

	local HasGuidCache = Dream_HasGuidCacheId(GuidLow, ItemId);
	-- FrozenCore hydrates the current GUID record from SavedVariables before
	-- Tooltip rendering. Treat that record as a hit and avoid hover-time I/O.
	if (not HasGuidCache and FrozenCore_IsGuidCached and FrozenCore_IsGuidCached(GuidLow, ItemId)) then
		HasGuidCache = true;
	end
	local HasAllModuleData = (GuidLow and GuidLow > 0 and Zs_GuidLowStoreData.AllModuleData[GuidLow]) or nil;
	local HasAllModuleLocationData = (LocationKey and Zs_GuidLowStoreData.AllModuleLocationData[LocationKey]) or nil;
	local HasEntryData = Dream_HasEntryCacheId(ItemId) or IsShowGEntryIdData(ItemId);
	local BigStat = Zs_EntryIdStoreData.BigItemStatData[ItemId];
	local GuidPending = (GuidLow and GuidLow > 0 and Dream_ItemTooltipPendingGet(Dream_TooltipRequestPending.GuidLow, GuidLow)) or false;
	local GuidCooldown = (GuidLow and GuidLow > 0 and Dream_ItemTooltipCooldownGet(Dream_TooltipRequestCooldown.GuidLow, GuidLow)) or false;
	local GuidNoData = (GuidLow and GuidLow > 0 and Dream_ItemTooltipNoGuidGet(GuidLow)) or false;
	local EntryPending = Dream_ItemTooltipPendingGet(Dream_TooltipRequestPending.EntryId, ItemId);
	if (ForceGuidRequest) then
		HasGuidCache = false;
		HasAllModuleData = nil;
		HasAllModuleLocationData = nil;
		HasEntryData = false;
		GuidPending = false;
		GuidCooldown = false;
		GuidNoData = false;
	end

	-- FrozenCore validates the server-issued version before requesting the old
	-- payload.  A hit is answered without equipment data; a miss reuses the
	-- existing GetGuidLowStoreData response and updates the GUID/cache mapping.
	local FrozenCoreCheckSent = false;
	if (GuidLow and GuidLow > 0 and FrozenCore_DisableLegacyTooltipRequests and
		(not GuidNoData or ForceGuidRequest) and
		(ForceGuidRequest or (not GuidPending and not GuidCooldown)) and
		FrozenCore_RequestGuidCache) then
		Dream_ItemTooltipPendingSet(Dream_TooltipRequestPending.GuidLow, GuidLow);
		Dream_ItemTooltipCooldownSet(Dream_TooltipRequestCooldown.GuidLow, GuidLow);
		Dream_TooltipRequestedItemIdByGuid[GuidLow] = ItemId;
		FrozenCore_RequestGuidCache(GuidLow, ItemId);
		FrozenCoreCheckSent = true;
	end

	-- Legacy hover requests are disabled once FrozenCore is active. Its login
	-- and bag scans use the same protocol to warm the cache asynchronously.
	if (not FrozenCoreCheckSent and GuidLow and GuidLow > 0 and not HasGuidCache and not GuidNoData and not GuidPending and not GuidCooldown and
		(not FrozenCore_DisableLegacyTooltipRequests or FrozenCore_AllowLegacyRequest)) then
		Dream_ItemTooltipPendingSet(Dream_TooltipRequestPending.GuidLow, GuidLow);
		Dream_ItemTooltipCooldownSet(Dream_TooltipRequestCooldown.GuidLow, GuidLow);
		Dream_TooltipRequestedItemIdByGuid[GuidLow] = ItemId;
	NativeUITooltipQuery(ItemId, GuidLow);
	end

	if (Dream_IsTemplateItemSeriesEnabled()) then
		if (GuidLow and GuidLow > 0 and not HasAllModuleData and not Dream_ItemTooltipPendingGet(Dream_TooltipRequestPending.AllModuleGuid, GuidLow)) then
			Dream_ItemTooltipPendingSet(Dream_TooltipRequestPending.AllModuleGuid, GuidLow);
			Dream_SendIdentificationQuery(ItemId, GuidLow);
		elseif (GuidLow == 0 and LocationKey and not HasAllModuleLocationData and not Dream_ItemTooltipPendingGet(Dream_TooltipRequestPending.AllModuleLocation, LocationKey)) then
			Dream_ItemTooltipPendingSet(Dream_TooltipRequestPending.AllModuleLocation, LocationKey);
			Dream_SendIdentificationQuery(ItemId, 0, Bag, Slot);
		end
	end

	local NeedEntryData = false;
	if (ItemIdStr and (not HasEntryData or Dream_NeedBigItemStoreData(Tooltip, ItemId))) then
		NeedEntryData = true;
		if (not EntryPending) then
			Dream_ItemTooltipPendingSet(Dream_TooltipRequestPending.EntryId, ItemId);
			NativeUITooltipQuery(ItemId, GuidLow or 0);
		end
	end

	return NeedEntryData;
end

function Dream_RequestItemTooltipStoreDataNow(ItemLink, Bag, Slot, GuidLowOverride, ForceGuidRequest)
	Dream_EnsureTooltipStoreData();
	if (not ItemLink) then
		return false;
	end

	local ItemId, GuidLow, ItemIdStr = Dream_ParseItemLinkStoreKey(ItemLink);
	if (not ItemId or ItemId <= 0) then
		return false;
	end

	GuidLowOverride = tonumber(GuidLowOverride) or 0;
	if (GuidLowOverride > 0) then
		GuidLow = GuidLowOverride;
	end
	if (Bag == 254 and GuidLowOverride > 0 and FrozenCore_MarkOwnedGuid) then
		FrozenCore_MarkOwnedGuid(GuidLowOverride);
	end

	return Dream_RequestItemStoreData(ItemId, GuidLow, ItemIdStr, Bag, Slot, nil, ForceGuidRequest);
end

local function Dream_RequestTooltipItemStoreData(Self)
	Dream_EnsureTooltipStoreData();
	if (not Self) then
		return nil, 0, false;
	end

	local _, ItemLink = Self:GetItem();
	if (not ItemLink) then
		return nil, 0, false;
	end

	local ItemId, GuidLow, ItemIdStr = Dream_ParseItemLinkStoreKey(ItemLink);
	if (not ItemId) then
		return nil, 0, false;
	end
	GuidLow = Dream_GetTooltipGuidLow(Self, GuidLow);

	local Bag, Slot = Dream_GetTooltipClientLocation(Self);
	local NeedEntryData = Dream_RequestItemStoreData(ItemId, GuidLow, ItemIdStr, Bag, Slot, Self);
	return ItemId, GuidLow, NeedEntryData;
end

local function Dream_QueueItemStoreRequest(ItemLink, Bag, Slot, GuidLowOverride, ForceGuidRequest)
	if (not ItemLink) then
		return;
	end

	local ItemId, GuidLow, ItemIdStr = Dream_ParseItemLinkStoreKey(ItemLink);
	if (not ItemId or ItemId <= 0) then
		return;
	end
	GuidLowOverride = tonumber(GuidLowOverride) or 0;
	if (GuidLowOverride > 0) then
		GuidLow = GuidLowOverride;
	end

	local Key = tostring(GuidLow or 0) .. ":" .. tostring(Bag or "nil") .. ":" .. tostring(Slot or "nil") .. ":" .. tostring(ItemId) .. ":" .. (ForceGuidRequest and "force" or "cache");
	if (Dream_TooltipWarmQueueKeys[Key]) then
		return;
	end

	Dream_TooltipWarmQueueKeys[Key] = true;
	table.insert(Dream_TooltipWarmQueue, { Link = ItemLink, ItemId = ItemId, GuidLow = GuidLow, ItemIdStr = ItemIdStr, Bag = Bag, Slot = Slot, Key = Key, ForceGuidRequest = ForceGuidRequest and true or false });
end

function Dream_QueueItemTooltipStoreRequest(ItemLink, Bag, Slot, GuidLow, ForceGuidRequest)
	Dream_QueueItemStoreRequest(ItemLink, Bag, Slot, GuidLow, ForceGuidRequest);
end

local function Dream_ScanOpenItemLocations()
	Dream_EnsureTooltipStoreData();

	for Slot = 1, 19 do
		local ItemLink = GetInventoryItemLink and GetInventoryItemLink("player", Slot);
		Dream_QueueItemStoreRequest(ItemLink, 255, Slot);
	end

	for Bag = 0, 4 do
		local NumSlots = GetContainerNumSlots and GetContainerNumSlots(Bag) or 0;
		for Slot = 1, NumSlots do
			local ItemLink = GetContainerItemLink and GetContainerItemLink(Bag, Slot);
			Dream_QueueItemStoreRequest(ItemLink, Bag, Slot);
		end
	end
end

local function Dream_ProcessItemStoreWarmQueue(Elapsed)
	Dream_TooltipWarmElapsed = Dream_TooltipWarmElapsed + (Elapsed or 0);
	if (Dream_TooltipWarmElapsed < 0.03) then
		return;
	end
	Dream_TooltipWarmElapsed = 0;

	local Request = table.remove(Dream_TooltipWarmQueue, 1);
	if (not Request) then
		return;
	end
	Dream_TooltipWarmQueueKeys[Request.Key] = nil;
	Dream_RequestItemStoreData(Request.ItemId, Request.GuidLow, Request.ItemIdStr, Request.Bag, Request.Slot, nil, Request.ForceGuidRequest);
end

local function Dream_StartItemStoreWarmScan()
	if (FrozenCore_DisableLegacyTooltipRequests) then
		return;
	end

	local Now = (GetTime and GetTime()) or 0;
	if (Dream_TooltipWarmFullScanAt and (Now - Dream_TooltipWarmFullScanAt) < 0.5) then
		return;
	end
	Dream_TooltipWarmFullScanAt = Now;
	Dream_ScanOpenItemLocations();
end

local function Dream_InstallItemStoreWarmHooks()
	if (Dream_TooltipWarmHooksInstalled) then
		return;
	end
	Dream_TooltipWarmHooksInstalled = true;

	local HookFunction = function(Name)
		if (hooksecurefunc and type(_G[Name]) == "function") then
			hooksecurefunc(Name, Dream_StartItemStoreWarmScan);
		end
	end;
	HookFunction("OpenBackpack");
	HookFunction("OpenBag");
	HookFunction("OpenAllBags");
	HookFunction("ToggleBackpack");
	HookFunction("ToggleBag");
	HookFunction("ToggleCharacter");
	HookFunction("CharacterFrame_Show");

	local Frames = { CharacterFrame, PaperDollFrame, BackpackFrame, BankFrame, ContainerFrame1, ContainerFrame2, ContainerFrame3, ContainerFrame4, ContainerFrame5 };
	for _, Frame in ipairs(Frames) do
		if (Frame and Frame.HookScript) then
			Frame:HookScript("OnShow", Dream_StartItemStoreWarmScan);
		end
	end
end

local function Dream_GetTooltipAllModuleData(Self, ItemId, GuidLow)
	Dream_EnsureTooltipStoreData();

	local ModuleData = (GuidLow and GuidLow > 0 and Zs_GuidLowStoreData.AllModuleData) and Zs_GuidLowStoreData.AllModuleData[GuidLow] or nil;
	if (ModuleData) then
		return ModuleData;
	end

	local Bag, Slot = Dream_GetTooltipClientLocation(Self);
	local LocationKey = Dream_GetAllModuleLocationKey(Bag, Slot, ItemId);
	return (LocationKey and Zs_GuidLowStoreData.AllModuleLocationData) and Zs_GuidLowStoreData.AllModuleLocationData[LocationKey] or nil;
end

local function Dream_ApplyBigItemStatLines(Self)
	if (not Self) then
		return;
	end
	if (Dream_TooltipIsLoadingItem(Self)) then
		return;
	end

	local _, ItemLink = Self:GetItem();
	local ItemId, GuidLow = Dream_ParseItemLinkStoreKey(ItemLink);
	GuidLow = Dream_GetTooltipGuidLow(Self, GuidLow);

	local BigStat = ItemId and Zs_EntryIdStoreData.BigItemStatData[ItemId];
	local GuidData = GuidLow and Zs_GuidLowStoreData.AtGuidData[GuidLow];
	local ModuleData = Dream_GetTooltipAllModuleData(Self, ItemId, GuidLow);
	if (ModuleData and Dream_IsModuleText(ModuleData.BaseAttributes)) then
		Dream_ItemTooltipDebug("apply_skip_module_base", ItemId, GuidLow, "base=1");
		return;
	end

	if (not BigStat) then
		if (Dream_TooltipHasWeaponDamageLine(Self, ItemId)) then
			Dream_ItemTooltipDebug("apply_no_big", ItemId, 0, "lines=" .. tostring(Self:NumLines()));
		end
		return;
	end

	Dream_ItemTooltipDebug("apply_begin", ItemId, 0, "weaponChecked=" .. Dream_ItemTooltipBool(BigStat.WeaponChecked) .. " dmgMin=" .. Dream_ItemTooltipShort(BigStat.DmgMin, 18) .. " dmgMax=" .. Dream_ItemTooltipShort(BigStat.DmgMax, 18));
	local IsWeaponItem = Dream_IsWeaponItem(ItemId) == true;
	if (not IsWeaponItem) then
		IsWeaponItem = Dream_TooltipHasWeaponDamageLine(Self, ItemId);
	end
	local WeaponDamageLineApplied = false;
	local WeaponDpsLineApplied = false;
	for i = 1, Self:NumLines() do
		local GLine = _G[Self:GetName() .. "TextLeft" .. i];
		if (GLine and GLine:GetText()) then
			local St = GLine:GetText();
			local IsWeaponDamageLine = Dream_IsWeaponDamageRangeLine(St);
			local IsWeaponDpsLine = Dream_IsWeaponDpsLine(St);
			if ((IsWeaponDamageLine and WeaponDamageLineApplied) or (IsWeaponDpsLine and WeaponDpsLineApplied)) then
				GLine:SetText("");
			else
				local BigItemText = nil;
				if (not ((IsWeaponDamageLine or IsWeaponDpsLine) and Dream_HasFullGuidWeaponData(GuidData))) then
					BigItemText = Dream_ReplaceBigItemOfficialLine(St, BigStat, GuidData, IsWeaponItem);
				end
				if (BigItemText) then
					Dream_ItemTooltipDebug("replace_line", ItemId, 0, "line=" .. tostring(i) .. " text=" .. Dream_ItemTooltipShort(BigItemText, 80));
					GLine:SetText(BigItemText);
					if (IsWeaponDamageLine) then
						WeaponDamageLineApplied = true;
					elseif (IsWeaponDpsLine) then
						WeaponDpsLineApplied = true;
					end
				end
			end
		end
	end
end

for i = 1, RunesCount do
	ItemRefTooltipTextures[i] = ItemRefTooltip:CreateTexture("ItemRefTooltipTextures" .. i);
	ItemRefTooltipTextures[i]:SetSize(RunesIconSize, RunesIconSize);
	ItemRefTooltipTextures[i]:SetTexture(RunesIconFile);

	local ItemRefTooltipGroup = ItemRefTooltipTextures[i]:CreateAnimationGroup();
	ItemRefTooltipTextures[i].AnimationGroup = ItemRefTooltipGroup;
	ItemRefTooltipGroup:SetLooping("REPEAT");
	ItemRefTooltipTextures[i].Animation = ItemRefTooltipGroup:CreateAnimation("Rotation", "ItemRefTooltipAnimation" .. i);
	ItemRefTooltipTextures[i].Animation:SetSmoothing("NONE");
	ItemRefTooltipTextures[i].Animation:SetDuration(Duration);
	ItemRefTooltipTextures[i].Animation:SetDegrees(Degrees);

	ItemRefTooltipTextures[i].IconTexts = ItemRefTooltip:CreateFontString("ItemRefTooltipIconTexts" .. i);
	ItemRefTooltipTextures[i].IconTexts:SetFont(Dream_GameFont, 12);
	ItemRefTooltipTextures[i].IconTexts:SetAllPoints(ItemRefTooltipTextures[i]);
	ItemRefTooltipTextures[i].IconTexts:SetText("");

	ItemRefTooltipTextures[i].ItemName = ItemRefTooltip:CreateFontString("ItemRefTooltipItemName" .. i);
	ItemRefTooltipTextures[i].ItemName:SetFont(Dream_GameFont, 12);
	ItemRefTooltipTextures[i].ItemName:SetPoint("BOTTOM", ItemRefTooltipTextures[i], 0, -12);
	ItemRefTooltipTextures[i].ItemName:SetText("");

	GameTooltipTextures[i] = GameTooltip:CreateTexture("GameTooltipTextures" .. i);
	GameTooltipTextures[i]:SetSize(RunesIconSize, RunesIconSize);
	GameTooltipTextures[i]:SetTexture(RunesIconFile);

	local GameTooltipGroup = GameTooltipTextures[i]:CreateAnimationGroup();
	GameTooltipTextures[i].AnimationGroup = GameTooltipGroup;
	GameTooltipGroup:SetLooping("REPEAT");
	GameTooltipTextures[i].Animation = GameTooltipGroup:CreateAnimation("Rotation", "GameTooltipAnimation" .. i);
	GameTooltipTextures[i].Animation:SetSmoothing("NONE");
	GameTooltipTextures[i].Animation:SetDuration(Duration);
	GameTooltipTextures[i].Animation:SetDegrees(Degrees);

	GameTooltipTextures[i].IconTexts = GameTooltip:CreateFontString("GameTooltipIconTexts" .. i);
	GameTooltipTextures[i].IconTexts:SetFont(Dream_GameFont, 12);
	GameTooltipTextures[i].IconTexts:SetAllPoints(GameTooltipTextures[i]);
	GameTooltipTextures[i].IconTexts:SetText("");

	GameTooltipTextures[i].ItemName = GameTooltip:CreateFontString("GameTooltipItemName" .. i);
	GameTooltipTextures[i].ItemName:SetFont(Dream_GameFont, 12, "OUTLINE");
	GameTooltipTextures[i].ItemName:SetPoint("BOTTOM", GameTooltipTextures[i], 0, -12);
	GameTooltipTextures[i].ItemName:SetText("");

	ShoppingTooltip1Textures[i] = ShoppingTooltip1:CreateTexture("ShoppingTooltip1Textures" .. i);
	ShoppingTooltip1Textures[i]:SetSize(RunesIconSize, RunesIconSize);
	ShoppingTooltip1Textures[i]:SetTexture(RunesIconFile);

	local ShoppingTooltip1Group = ShoppingTooltip1Textures[i]:CreateAnimationGroup();
	ShoppingTooltip1Textures[i].AnimationGroup = ShoppingTooltip1Group;
	ShoppingTooltip1Group:SetLooping("REPEAT");
	ShoppingTooltip1Textures[i].Animation = ShoppingTooltip1Group:CreateAnimation("Rotation",
		"ShoppingTooltip1Animation" .. i);
	ShoppingTooltip1Textures[i].Animation:SetSmoothing("NONE");
	ShoppingTooltip1Textures[i].Animation:SetDuration(Duration);
	ShoppingTooltip1Textures[i].Animation:SetDegrees(Degrees);

	ShoppingTooltip1Textures[i].IconTexts = ShoppingTooltip1:CreateFontString("ShoppingTooltip1IconTexts" .. i);
	ShoppingTooltip1Textures[i].IconTexts:SetFont(Dream_GameFont, 12);
	ShoppingTooltip1Textures[i].IconTexts:SetAllPoints(ShoppingTooltip1Textures[i]);
	ShoppingTooltip1Textures[i].IconTexts:SetText("");

	ShoppingTooltip1Textures[i].ItemName = ShoppingTooltip1:CreateFontString("ShoppingTooltip1ItemName" .. i);
	ShoppingTooltip1Textures[i].ItemName:SetFont(Dream_GameFont, 12);
	ShoppingTooltip1Textures[i].ItemName:SetPoint("BOTTOM", ShoppingTooltip1Textures[i], 0, -12);
	ShoppingTooltip1Textures[i].ItemName:SetText("");

	ShoppingTooltip2Textures[i] = ShoppingTooltip2:CreateTexture("ShoppingTooltip2Textures" .. i);
	ShoppingTooltip2Textures[i]:SetSize(RunesIconSize, RunesIconSize);
	ShoppingTooltip2Textures[i]:SetTexture(RunesIconFile);

	local ShoppingToo2tip1Group = ShoppingTooltip2Textures[i]:CreateAnimationGroup();
	ShoppingTooltip2Textures[i].AnimationGroup = ShoppingToo2tip1Group;
	ShoppingToo2tip1Group:SetLooping("REPEAT");
	ShoppingTooltip2Textures[i].Animation = ShoppingToo2tip1Group:CreateAnimation("Rotation",
		"ShoppingTooltip2Animation" .. i);
	ShoppingTooltip2Textures[i].Animation:SetSmoothing("NONE");
	ShoppingTooltip2Textures[i].Animation:SetDuration(Duration);
	ShoppingTooltip2Textures[i].Animation:SetDegrees(Degrees);

	ShoppingTooltip2Textures[i].IconTexts = ShoppingTooltip2:CreateFontString("ShoppingTooltip2IconTexts" .. i);
	ShoppingTooltip2Textures[i].IconTexts:SetFont(Dream_GameFont, 12);
	ShoppingTooltip2Textures[i].IconTexts:SetAllPoints(ShoppingTooltip2Textures[i]);
	ShoppingTooltip2Textures[i].IconTexts:SetText("");

	ShoppingTooltip2Textures[i].ItemName = ShoppingTooltip2:CreateFontString("ShoppingTooltip2ItemName" .. i);
	ShoppingTooltip2Textures[i].ItemName:SetFont(Dream_GameFont, 12);
	ShoppingTooltip2Textures[i].ItemName:SetPoint("BOTTOM", ShoppingTooltip2Textures[i], 0, -12);
	ShoppingTooltip2Textures[i].ItemName:SetText("");

	ShoppingTooltip3Textures[i] = ShoppingTooltip3:CreateTexture("ShoppingTooltip3Textures" .. i);
	ShoppingTooltip3Textures[i]:SetSize(RunesIconSize, RunesIconSize);
	ShoppingTooltip3Textures[i]:SetTexture(RunesIconFile);

	local ShoppingToo3tip1Group = ShoppingTooltip3Textures[i]:CreateAnimationGroup();
	ShoppingTooltip3Textures[i].AnimationGroup = ShoppingToo3tip1Group;
	ShoppingToo3tip1Group:SetLooping("REPEAT");
	ShoppingTooltip3Textures[i].Animation = ShoppingToo3tip1Group:CreateAnimation("Rotation",
		"ShoppingTooltip3Animation" .. i);
	ShoppingTooltip3Textures[i].Animation:SetSmoothing("NONE");
	ShoppingTooltip3Textures[i].Animation:SetDuration(Duration);
	ShoppingTooltip3Textures[i].Animation:SetDegrees(Degrees);

	ShoppingTooltip3Textures[i].IconTexts = ShoppingTooltip3:CreateFontString("ShoppingTooltip3IconTexts" .. i);
	ShoppingTooltip3Textures[i].IconTexts:SetFont(Dream_GameFont, 12);
	ShoppingTooltip3Textures[i].IconTexts:SetAllPoints(ShoppingTooltip3Textures[i]);
	ShoppingTooltip3Textures[i].IconTexts:SetText("");

	ShoppingTooltip3Textures[i].ItemName = ShoppingTooltip3:CreateFontString("ShoppingTooltip3ItemName" .. i);
	ShoppingTooltip3Textures[i].ItemName:SetFont(Dream_GameFont, 12);
	ShoppingTooltip3Textures[i].ItemName:SetPoint("BOTTOM", ShoppingTooltip3Textures[i], 0, -12);
	ShoppingTooltip3Textures[i].ItemName:SetText("");
end

------------------------------------------------------------------------------------------------------------------------------------

local function Dream_ClearRuneTooltipTextures(Self)
	if (not Self or not Self.GetName) then
		return;
	end

	for K = 1, RunesCount do
		local AtTexture = _G[Self:GetName() .. "Textures" .. K];
		if (AtTexture) then
			if (AtTexture.AnimationGroup and AtTexture.AnimationGroup.Stop) then
				AtTexture.AnimationGroup:Stop();
			elseif (AtTexture.Animation and AtTexture.Animation.Stop) then
				AtTexture.Animation:Stop();
			end
			if (AtTexture.IconTexts) then AtTexture.IconTexts:SetText(""); end
			if (AtTexture.ItemName) then AtTexture.ItemName:SetText(""); end
			AtTexture:ClearAllPoints();
			AtTexture:Hide();
		end
	end
end

local function Dream_ResetRuneTooltip(Self, PreserveFrozenSnapshot)
	Dream_ClearRuneTooltipTextures(Self);
	if (Self) then
		if (not PreserveFrozenSnapshot) then
			Self.Dream_RuneCombinationKey = nil;
			Self.Dream_EquipmentTooltipWidth = nil;
			Self.Dream_LastItemDescriptionKey = nil;
			Self.Dream_ItemIdLineAdded = nil;
			Self.Dream_LastLegacyDataKey = nil;
			Self.Dream_LastAllModuleTooltipKey = nil;
			Self.Dream_FrozenSnapshotKey = nil;
			Self.Dream_LastTooltipItemId = nil;
		end
	end
end

local function Dream_TooltipHasCustomModuleSection(Self)
	if (not Self or not Self.GetName or not Self.NumLines) then
		return false;
	end

	local Markers = { "追加属性", "追加技能", "追加套装", "追加符文", "追加强化", "追加成长", "随机附魔" };
	for LineIndex = 1, Self:NumLines() do
		local Line = _G[Self:GetName() .. "TextLeft" .. LineIndex];
		local Text = Line and Line:GetText() or "";
		for MarkerIndex = 1, #Markers do
			if (Text ~= "" and string.find(Text, Markers[MarkerIndex], 1, true)) then
				return true;
			end
		end
	end
	return false;
end

local function Dream_BuildRuneCombinationText(RuneData)
	if (not RuneData) then
		return "";
	end

	local GName = RuneData.GName;
	if (not GName or GName == "" or GName == "nullptr") then
		return "";
	end

	local Out = GName;

	-- GListStore 的第一个技能是整套符文之语的汇总效果，后续技能是拆分属性。
	if (not RuneData.GListStore or RuneData.GListStore == "nullptr") then
		return Out;
	end

	local GroupSpells = Dream_Split(RuneData.GListStore, "#");
	for Index = 1, #GroupSpells do
		local SpellId = tonumber(GroupSpells[Index]);
		if (SpellId and SpellId ~= 0) then
			return Out .. "\n" .. RunesSpellTitle .. "|cFF05E105" .. Dream_GetSpellDisplayText(SpellId) .. "|r";
		end
	end

	return Out;
end

local function Dream_ShowRuneTooltipTextures(Self, GuidLow)
	-- 符文已是单独物品，装备提示不再画符文孔。
	Dream_ClearRuneTooltipTextures(Self);
end

-- A rune is a separate item record from the equipment itself. Refresh only
-- the open tooltip that contains the received rune ID after the native item
-- cache has completed; never rebuild its hyperlink.
function Dream_OnRuneItemInfoReceived(ItemId)
	ItemId = tonumber(ItemId) or 0;
	if (ItemId <= 0) then
		return;
	end

	local Tips = { ItemRefTooltip, GameTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3 };
	for Index = 1, #Tips do
		local Tip = Tips[Index];
		if (Tip and Tip:IsShown()) then
			local _, ItemLink = Tip:GetItem();
			local _, GuidLow = Dream_ParseItemLinkStoreKey(ItemLink);
			GuidLow = Dream_GetTooltipGuidLow(Tip, GuidLow);
			local RuneData = GuidLow and Zs_GuidLowStoreData.AtRunesData[GuidLow];
			if (RuneData) then
				local RuneItems = Dream_Split(RuneData.ItemStore or "", "#");
				for RuneIndex = 1, #RuneItems do
					if (tonumber(RuneItems[RuneIndex]) == ItemId) then
						Dream_ShowRuneTooltipTextures(Tip, GuidLow);
						break;
					end
				end
			end
		end
	end
end

local function Dream_ShowItemIdOnTitle(Self, ItemId)
	if (not Self or not Self.GetName or not Self:GetName() or not ItemId) then
		return;
	end

	local RightLine = _G[Self:GetName() .. "TextRight1"];
	if (RightLine) then
		RightLine:SetText("ID: " .. tostring(ItemId));
		RightLine:SetTextColor(1, 1, 1);
		RightLine:Show();
	end
end

local function Dream_AddItemIdLine(Self, ItemIdStr)
	if (not Self or not ItemIdStr or ItemIdStr == "") then
		return;
	end
	if (Self.Dream_ItemIdLineAdded == tostring(ItemIdStr)) then
		return;
	end
	Self:AddLine("\n");
	Self:AddDoubleLine("物品编号", tostring(ItemIdStr));
	Self.Dream_ItemIdLineAdded = tostring(ItemIdStr);
end

local function Dream_ApplyFrozenTooltipSnapshot(Self, GuidLow, ItemId)
	if (not Self or not Dream_IsFrozenGuidCached(GuidLow, ItemId) or not FrozenCore_GetSnapshot) then
		return false;
	end

	local Snapshot, CacheId = FrozenCore_GetSnapshot(GuidLow, ItemId);
	if (not Snapshot) then
		return false;
	end

	local SnapshotKey = tostring(GuidLow) .. ":" .. tostring(ItemId) .. ":" .. tostring(CacheId or "");
	if (Self.Dream_FrozenSnapshotKey == SnapshotKey) then
		return true;
	end

	if (Self.ClearLines) then
		Self:ClearLines();
	end

	local Lines = Snapshot.TooltipLines;
	local CustomSnapshotMarkers = {
		"追加属性", "追加技能", "追加套装", "追加符文", "追加强化", "追加成长", "随机附魔",
	};
	for _, Line in pairs(Lines or {}) do
		local LeftText = Line and tostring(Line.Left or "") or "";
		local RightText = Line and tostring(Line.Right or "") or "";
		for MarkerIndex = 1, #CustomSnapshotMarkers do
			if (string.find(LeftText, CustomSnapshotMarkers[MarkerIndex], 1, true) or
				string.find(RightText, CustomSnapshotMarkers[MarkerIndex], 1, true)) then
				-- Older FrozenCore records were captured after custom rendering.
				-- Do not replay them; the native tooltip remains the source and
				-- custom sections are rendered once by this addon.
				return false;
			end
		end
	end
	local MaxLine = 0;
	for Index in pairs(Lines or {}) do
		if (tonumber(Index) and tonumber(Index) > MaxLine) then
			MaxLine = tonumber(Index);
		end
	end

	if (Lines and MaxLine > 0) then
		for Index = 1, MaxLine do
			local Line = Lines[Index];
			if (Line) then
				if (Line.Left and Line.Right and Line.Right ~= "") then
					Self:AddDoubleLine(Line.Left, Line.Right);
				elseif (Line.Left and Line.Left ~= "") then
					Self:AddLine(Line.Left);
				elseif (Line.Right and Line.Right ~= "") then
					Self:AddLine(Line.Right);
				end
			end
		end
	else
		local GuidData = Zs_GuidLowStoreData.AtGuidData[GuidLow];
		local ItemName = Dream_GetItemInfoOnce(ItemId);
		Self:AddLine(ItemName or ("物品 " .. tostring(ItemId)));
		if (GuidData) then
			local GuidText = Dream_BuildGuidExtraTooltipText(GuidData);
			if (GuidText ~= "") then
				Self:AddLine(GuidText, 1, 1, 1, true);
			end
		end
		local ModuleData = Zs_GuidLowStoreData.AllModuleData[GuidLow];
		local ModuleText = Dream_BuildAllModuleTooltipText(ModuleData);
		if (ModuleText ~= "") then
			Self:AddLine(ModuleText, 1, 1, 1, true);
		end
	end

	Self.Dream_FrozenSnapshotKey = SnapshotKey;
	return Self:NumLines() > 0;
end

function OnItemGlobalTooltipShow(Self)
	Dream_EnsureTooltipStoreData();
	Dream_ClearRuneTooltipTextures(Self);

	local _, ItemLink = Self:GetItem();
	if (ItemLink) then
		-- 【新增：核心对齐逻辑】
        -- 1. 清除Tooltip内边距（消除边缘空白）
        --Self:SetPadding(0, 0, 0, 0);
        -- 2. 遍历所有文本行，强制左对齐
        --[[for i = 1, Self:NumLines() do
            local textLine = _G[Self:GetName() .. "TextLeft" .. i];
            if (textLine) then
                textLine:SetJustifyH("LEFT"); -- 强制左对齐
                textLine:SetSpacing(0); -- 清除行内间距
                textLine:SetWidth(Self:GetWidth()); -- 适配Tooltip宽度
            end
        end]]
		
		local ItemId, GuidLow, ItemIdStr = Dream_ParseItemLinkStoreKey(ItemLink);
		if (not ItemId) then
			return;
		end
		GuidLow = Dream_GetTooltipGuidLow(Self, GuidLow);
		local HasFrozenSnapshot = Dream_IsFrozenGuidCached(GuidLow, ItemId);
		local StableWidth = 360;
		Dream_SetStableTooltipWidth(Self, StableWidth);
		-- FrozenCore is a data cache only. Never replay its TooltipLines while
		-- the native client is resolving the item; ClearLines() in that replay
		-- path causes the rune skill line to blink.
		if (Dream_TooltipIsLoadingItem(Self)) then
			return;
		end
		if (Dream_TooltipHasCustomModuleSection(Self)) then
			-- FrozenCore/native cache resolution can fire OnShow more than once
			-- for the same item. The module section is already present, so do not
			-- append it again or resize the Tooltip.
			Dream_ShowRuneTooltipTextures(Self, GuidLow);
			return;
		end
	if (not HasFrozenSnapshot and not Dream_IsItemTemplateReady(ItemId, Self)) then
		return;
	end
	-- Capture the native tooltip before this addon appends random stats,
	-- skills, runes, or other module sections. FrozenCore snapshots must never
	-- contain addon-rendered lines.
	if (not HasFrozenSnapshot and not Dream_TooltipIsLoadingItem(Self) and FrozenCore_CaptureTooltipSnapshot) then
		FrozenCore_CaptureTooltipSnapshot(GuidLow, ItemId, Self);
	end
	Dream_ShowItemIdOnTitle(Self, ItemId);
		Dream_AddItemIdLine(Self, ItemIdStr);
		Dream_ItemTooltipDebug("show_begin", ItemId, GuidLow, "lines=" .. tostring(Self:NumLines()));

		local _, _, NeedTooltipData = Dream_RequestTooltipItemStoreData(Self);
		Dream_ShowRuneTooltipTextures(Self, GuidLow);
		local ModuleData = (GuidLow and Zs_GuidLowStoreData.AllModuleData) and Zs_GuidLowStoreData.AllModuleData[GuidLow] or nil;
		if (not ModuleData) then
			local Bag, Slot = Dream_GetTooltipClientLocation(Self);
			local LocationKey = Dream_GetAllModuleLocationKey(Bag, Slot, ItemId);
			ModuleData = (LocationKey and Zs_GuidLowStoreData.AllModuleLocationData) and Zs_GuidLowStoreData.AllModuleLocationData[LocationKey] or nil;
		end
		if (NeedTooltipData and not ModuleData) then
			Dream_ItemTooltipDebug("show_wait", ItemId, GuidLow, "reason=waiting_server_data");
			return;
		end
		local GuidData = Zs_GuidLowStoreData.AtGuidData[GuidLow];
		local BigStat = Zs_EntryIdStoreData.BigItemStatData[ItemId];
		Dream_ItemTooltipDebug("show_render", ItemId, GuidLow, "hasGuid=" .. Dream_ItemTooltipBool(GuidData) .. " hasBig=" .. Dream_ItemTooltipBool(BigStat));
		

		local DesiredWidth = 360;
		Dream_SetStableTooltipWidth(Self, DesiredWidth);

		local SuperGuidExtraText = (GuidData and Dream_BuildGuidExtraTooltipText(GuidData)) or "";
		local ModuleExtraText = Dream_BuildAllModuleTooltipText(ModuleData);
		local OfficialBasePropertyLine = nil;
		local ModuleBaseAnchorLine = nil;
		local ModuleBaseApplied = {};
		local ModuleBaseReplaceState = {};
		ModuleBaseReplaceState.ItemId = ItemId;
		ModuleBaseReplaceState.GuidLow = GuidLow;
		local IsWeaponItem = Dream_IsWeaponItem(ItemId) == true;
		if (not IsWeaponItem) then
			IsWeaponItem = Dream_TooltipHasWeaponDamageLine(Self, ItemId);
		end
		local WeaponDamageLineApplied = false;
		local WeaponDpsLineApplied = false;
		Dream_ItemTooltipDebug("show_module_data", ItemId, GuidLow, "base=" .. Dream_ItemTooltipBool(Dream_IsModuleText(ModuleData and ModuleData.BaseAttributes)) .. " add=" .. Dream_ItemTooltipBool(Dream_IsModuleText(ModuleData and ModuleData.AdditionalAttributes)) .. " lines=" .. tostring(Self:NumLines()) .. " baseText=" .. Dream_ItemTooltipShort(ModuleData and ModuleData.BaseAttributes or "nil", 80));
		for i = 1, Self:NumLines() do
			local GLine = _G[Self:GetName() .. "TextLeft" .. i];
			local St = GLine and GLine:GetText();
			if (St) then
				local IsWeaponDamageLine = Dream_IsWeaponDamageRangeLine(St);
				local IsWeaponDpsLine = Dream_IsWeaponDpsLine(St);
				local BigItemLineApplied = false;
				if ((IsWeaponDamageLine and WeaponDamageLineApplied) or (IsWeaponDpsLine and WeaponDpsLineApplied)) then
					GLine:SetText("");
					St = "";
					BigItemLineApplied = true;
				else
					local BigItemText = nil;
					if (not ((IsWeaponDamageLine or IsWeaponDpsLine) and Dream_HasFullGuidWeaponData(GuidData))) then
						BigItemText = Dream_ReplaceBigItemOfficialLine(St, BigStat, GuidData, IsWeaponItem);
					end
					if (not BigItemText and (IsWeaponDamageLine or IsWeaponDpsLine) and Dream_HasFullGuidWeaponData(GuidData)) then
						BigItemText = Dream_ReplaceGuidItemWeaponLine(St, GuidData, IsWeaponItem);
					end
					if (BigItemText) then
						GLine:SetText(BigItemText);
						St = BigItemText;
						BigItemLineApplied = true;
					end
				end

				if (i == 1) then
					if (GuidData) then
						local Prefix = (GuidData.Prefix == "nullptr") and "" or GuidData.Prefix;
						local Suffix = (GuidData.Suffix == "nullptr") and "" or GuidData.Suffix;
						local LevelStr = (GuidData.LevelStr == "nullptr") and "" or GuidData.LevelStr;
						GLine:SetText(Prefix .. St .. Suffix .. " " .. LevelStr);
						St = GLine:GetText();
					elseif (ModuleData and ModuleData.Display) then
						local Prefix = ModuleData.Display.Prefix or "";
						local Suffix = ModuleData.Display.Suffix or "";
						local QualityColor = ModuleData.Display.QualityColor or "";
						local ColorCode = Dream_ParseQualityColor(QualityColor);
						local ColoredItemName = ColorCode and ("|c" .. ColorCode .. St .. "|r") or St;
						local NewName = Prefix .. ColoredItemName .. Suffix;
						GLine:SetText(NewName);
						St = GLine:GetText();
					end

					local NextLine = _G[Self:GetName() .. "TextLeft" .. (i + 1)];
					local NextText = NextLine and NextLine:GetText() or nil;
					local AddText = "";
					if (ModuleData and ModuleData.Display) then
						local QualityColor = ModuleData.Display.QualityColor or "";
						local ColorCode, CustomName = Dream_ParseQualityColor(QualityColor);
						if (ColorCode) then
							local QualityName = (CustomName and CustomName ~= "") and CustomName or "鉴定品质";
							AddText = AddText .. "|c" .. ColorCode .. "◆ " .. QualityName .. " ◆|r|n";
						end
						local IdentificationLevel = tonumber(ModuleData.Display.Level) or 0;
						if (IdentificationLevel > 0) then
							AddText = AddText .. "|cFFFFD100鉴定等级: |r|cFF00FF00" .. tostring(IdentificationLevel) .. "|r|n";
						end
					end
					if (NextText and Zs_GuidLowStoreData.DevelopData[GuidLow]) then
						AddText = AddText .. "|cFFFF66FF装备特殊成长:|r |cFF00FF00当前等级: " .. Zs_GuidLowStoreData.DevelopData[GuidLow][1].. " 经验: 当前<"..Zs_GuidLowStoreData.DevelopData[GuidLow][2]..">下一级<"..(Zs_GuidLowStoreData.DevelopData[GuidLow][3] == 0 and "满级" or Zs_GuidLowStoreData.DevelopData[GuidLow][3]).. ">|r|n";
					end

					if (not NextText) then
						NextText = "";
					end
					
					if (NextLine) then
						NextLine:SetText(AddText .. NextText);
					end
				end

				if (GuidData and St ~= "") then
					local GuidWeaponText = Dream_ReplaceGuidItemWeaponLine(St, GuidData, IsWeaponItem);
					if (GuidWeaponText) then
						GLine:SetText(GuidWeaponText);
						St = GuidWeaponText;
						BigItemLineApplied = true;
					end
				end

				local ModuleBaseText = Dream_ReplaceModuleBaseAttributeLine(St, ModuleData, ModuleBaseApplied, ModuleBaseReplaceState);
				if (ModuleData and Dream_IsModuleText(ModuleData.BaseAttributes) and i <= 12) then
					Dream_ItemTooltipDebug("base_scan_show", ItemId, GuidLow, "line=" .. tostring(i) .. " match=" .. Dream_ItemTooltipBool(Dream_IsOfficialModuleBaseReplaceLine(St)) .. " result=" .. Dream_ItemTooltipBool(ModuleBaseText ~= nil) .. " text=" .. Dream_ItemTooltipShort(St, 70));
				end
				if (ModuleBaseText) then
					GLine:SetText(ModuleBaseText);
					GLine:SetWidth(Self:GetWidth());
					St = ModuleBaseText;
					if (ModuleBaseText ~= "") then
						ModuleBaseAnchorLine = GLine;
					end
				end

				if (BigItemLineApplied) then
					if (IsWeaponDamageLine) then
						WeaponDamageLineApplied = true;
					elseif (IsWeaponDpsLine) then
						WeaponDpsLineApplied = true;
					end
				end

				if (Dream_IsGuidSuperRandomItem(GuidData) and not BigItemLineApplied) then
					local Val = 0;
					local Num = GetStrValue(St);
					--local ayshuxin = "1#1#1#1#1#1#1";--有多少个属性这里就写多少个
					local ayshuxin = GuidData._Attris or "1#1#1#1#1#1#1";--有多少个属性这里就写多少个
					if (Num ~= 0) then
						Val = math.ceil(Num * GuidData.PutMod);
						--ayshuxin = Zs_GuidLowStoreData.AtGuidData[GuidLow].shuxin;
					end
				
				
				
				--//------------   随机属性倍率   ------------
				local _shuxin = Dream_Split(ayshuxin, "#");
				local function Dream_GetLegacyAttrMultiplierText(Index)
					local Multiplier = tostring(_shuxin[Index] or "1"):gsub(",", ""):match("^%+?(%d+)$") or "1";
					Multiplier = Multiplier:gsub("^0+", "");
					if (Multiplier == "" or Multiplier == "0") then
						return "1";
					end
					return Multiplier;
				end
				local function Dream_GetLegacyMultipliedText(Index)
					local BaseText = tostring(math.floor(tonumber(Num) or 0));
					local Multiplier = Dream_GetLegacyAttrMultiplierText(Index);
					if (Multiplier ~= "1" and Dream_MultiplyIntegerTextByIntegerText) then
						BaseText = Dream_MultiplyIntegerTextByIntegerText(BaseText, Multiplier);
					end
					return Dream_FormatBigItemNumber(BaseText);
				end
				local function Dream_SetLegacyStatLine(Index, Name)
					local Text = Dream_GetLegacyMultipliedText(Index);
					if (Val == 0) then
						GLine:SetText("+" .. Text .. " " .. Name);
					else
						GLine:SetText("+" .. Text .. " " .. Name .. " |cFFFD3FB8[+" .. Dream_FormatBigItemNumber(Val) .. "]|r");
					end
				end
				if (string.find(St, "^%+%d.") and string.find(St, "敏捷")) then Dream_SetLegacyStatLine(1, "敏捷"); end
				if (string.find(St, "^%+%d.") and string.find(St, "力量")) then Dream_SetLegacyStatLine(2, "力量"); end
				if (string.find(St, "^%+%d.") and string.find(St, "智力")) then Dream_SetLegacyStatLine(3, "智力"); end
				if (string.find(St, "^%+%d.") and string.find(St, "精神")) then Dream_SetLegacyStatLine(4, "精神"); end
				if (string.find(St, "^%+%d.") and string.find(St, "耐力")) then Dream_SetLegacyStatLine(5, "耐力"); end
				if (string.find(St, "^装备： 攻击强度提高%d")) then GLine:SetText("装备： 攻击强度提高" .. Dream_GetLegacyMultipliedText(6) .. "。"); end
				if (string.find(St, "^装备： 法术强度提高%d")) then GLine:SetText("装备： 法术强度提高" .. Dream_GetLegacyMultipliedText(7) .. "。"); end
				--随机属性倍率（额外添加就在下面写上，可以参考下方的名字）
				
			
				
				
				--[[if ((string.find(St, "^%+%d.") and string.find(St, "力量"))
						or (string.find(St, "^%+%d.") and string.find(St, "敏捷"))
						or (string.find(St, "^%+%d.") and string.find(St, "耐力"))
						or (string.find(St, "^%+%d.") and string.find(St, "智力"))
						or (string.find(St, "^%+%d.") and string.find(St, "精神"))
						or (string.find(St, "^%+%d.") and string.find(St, "生命值"))
						or (string.find(St, "^%+%d.") and string.find(St, "法力值"))
					) then

					if (Val ~= 0) then
						GLine:SetText(St .. " |cFFFD3FB8[+" .. Val .. "]|r");
					end
				end]]

				if (string.find(St, "^装备： 防御等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 防御等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 使你的躲闪等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 使你的躲闪等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 使你的招架等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 使你的招架等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 使你的盾牌格挡等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 使你的盾牌格挡等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 近战命中等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 近战命中等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 远程命中等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 远程命中等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 法术命中等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 法术命中等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 近战爆击等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 近战爆击等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 远程爆击等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 远程爆击等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 法术爆击等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 法术爆击等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 近战命中躲闪等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 近战命中躲闪等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 远程命中躲闪等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 远程命中躲闪等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 法术命中躲闪等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 法术命中躲闪等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 近战爆击躲闪等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 近战爆击躲闪等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 远程爆击躲闪等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 远程爆击躲闪等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 法术爆击躲闪等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 法术爆击躲闪等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 近战急速等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 近战急速等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 远程急速等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 远程急速等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 法术急速等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 法术急速等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 命中等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 命中等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 爆击等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 爆击等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 命中躲闪等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 命中躲闪等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 爆击躲闪等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 爆击躲闪等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 韧性等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 韧性等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 急速等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 急速等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 使你的精准等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 使你的精准等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 攻击强度提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 攻击强度提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 远程攻击强度提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 远程攻击强度提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 猎豹、熊、巨熊、枭兽形态攻击强度%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 猎豹、熊、巨熊、枭兽形态攻击强度%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 法术和魔法效果的伤害量提高最多%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 法术和魔法效果的伤害量提高最多%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 每5秒回复%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 每5秒回复%s|cFFFD3FB8[+ %s]|r点法力值。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 使你的护甲穿透等级提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 使你的护甲穿透等级提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 法术强度提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 法术强度提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 每5秒恢复%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 每5秒恢复%s|cFFFD3FB8[+ %s]|r点生命值。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 法术穿透提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 法术穿透提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				elseif (string.find(St, "^装备： 使你的盾牌格挡值提高%d")) then
					if (Val ~= 0) then
						GLine:SetText(string.format("装备： 使你的盾牌格挡值提高%s|cFFFD3FB8[+ %s]|r。",
							Num, Val));
					end
				end

				end

				if (Dream_IsOfficialBasePropertyLine(St) and not Dream_IsRandomEnchantLine(GuidLow, St)) then
					OfficialBasePropertyLine = GLine;
				end

			end
		end

		local ModuleBaseRemainderText = Dream_BuildModuleBaseRemainderLines(ModuleData, ModuleBaseApplied);
		Dream_ClearOfficialRandomEnchantLines(Self, GuidLow);
		local LegacyExtraText = SuperGuidExtraText;
		if (ModuleData and Dream_IsModuleText(ModuleData.SkillsData)) then
			-- FrozenCore can hydrate both the modern module skill payload and the
			-- legacy AsSpell payload. The latter describes the same skill section;
			-- keep the modern section and remove the duplicate legacy one.
			LegacyExtraText = Dream_RemoveModuleSection(LegacyExtraText, "追加技能");
		end
		local OtherExtraText = ModuleExtraText .. LegacyExtraText;
		OtherExtraText = Dream_InsertRandomEnchantAfterAdditional(OtherExtraText, GuidLow);
		Dream_ItemTooltipDebug("show_module_result", ItemId, GuidLow, "applied=" .. Dream_ItemTooltipBool(ModuleBaseReplaceState.BlockApplied) .. " remainder=" .. Dream_ItemTooltipBool(ModuleBaseRemainderText ~= "") .. " extra=" .. Dream_ItemTooltipBool(OtherExtraText ~= ""));
		local EquipmentText = ModuleBaseRemainderText;
		if (OtherExtraText ~= "") then
			EquipmentText = EquipmentText .. OtherExtraText;
		end
		if (EquipmentText ~= "") then
			Dream_AddEquipmentTooltipBlock(Self, ModuleBaseAnchorLine or OfficialBasePropertyLine, EquipmentText);
		end

		local ModuleTooltipKey = Dream_GetAllModuleTooltipKey(ModuleData, ItemId);
		if (ModuleTooltipKey) then
			Self.Dream_LastAllModuleTooltipKey = ModuleTooltipKey;
		end

		if (Zs_EntryIdStoreData.ItemLimitData1[ItemId]) then
			Self:AddLine("角色每日获取限制: "..Zs_EntryIdStoreData.ItemLimitData1[ItemId][1].."/"..Zs_EntryIdStoreData.ItemLimitData1[ItemId][2], 255 / 255, 102 / 255, 102 / 255, true);
		end

		if (Zs_EntryIdStoreData.ItemLimitData2[ItemId]) then
			Self:AddLine("角色永久获取限制: "..Zs_EntryIdStoreData.ItemLimitData2[ItemId][1].."/"..Zs_EntryIdStoreData.ItemLimitData2[ItemId][2], 255 / 255, 102 / 255, 102 / 255, true);
		end

		if (Zs_EntryIdStoreData.ItemLimitData3[ItemId]) then
			Self:AddLine("账号每日获取限制: "..Zs_EntryIdStoreData.ItemLimitData3[ItemId][1].."/"..Zs_EntryIdStoreData.ItemLimitData3[ItemId][2], 255 / 255, 102 / 255, 102 / 255, true);
		end

		if (Zs_EntryIdStoreData.ItemLimitData4[ItemId]) then
			Self:AddLine("账号永久获取限制: "..Zs_EntryIdStoreData.ItemLimitData4[ItemId][1].."/"..Zs_EntryIdStoreData.ItemLimitData4[ItemId][2], 255 / 255, 102 / 255, 102 / 255, true);
		end

		if (Zs_EntryIdStoreData.ItemUseLimitData1[ItemId]) then
			Self:AddLine("角色每日使用上限: "..Zs_EntryIdStoreData.ItemUseLimitData1[ItemId][1].."/"..Zs_EntryIdStoreData.ItemUseLimitData1[ItemId][2], 255 / 255, 102 / 255, 102 / 255, true);
		end

		if (Zs_EntryIdStoreData.ItemUseLimitData2[ItemId]) then
			Self:AddLine("角色永久使用上限: "..Zs_EntryIdStoreData.ItemUseLimitData2[ItemId][1].."/"..Zs_EntryIdStoreData.ItemUseLimitData2[ItemId][2], 255 / 255, 102 / 255, 102 / 255, true);
		end

		if (Zs_GuidLowStoreData.ItemEnchAtCountData[GuidLow]) then
			local AwCountValue = tonumber(Zs_GuidLowStoreData.ItemEnchAtCountData[GuidLow][2]) or 0;
			local AwCount = AwCountValue > 0 and tostring(Zs_GuidLowStoreData.ItemEnchAtCountData[GuidLow][2]) or "无限制";
			local AtGts = tostring(Zs_GuidLowStoreData.ItemEnchAtCountData[GuidLow][1]).."/"..AwCount;
			Self:AddDoubleLine("洗练次数信息", AtGts, 255 / 255, 102 / 255, 102 / 255, 255 / 255, 102 / 255, 102 / 255);
		end

		if (Zs_GuidLowStoreData.AtGuidData[GuidLow]) then
			if (Dream_ItemSellGuidGtsData) then
				for N = 1, #Dream_ItemSellGuidGtsData do
					if (Dream_ItemSellGuidGtsData[N][1] and Dream_ItemSellGuidGtsData[N][2] and Dream_ItemSellGuidGtsData[N][3] and Dream_ItemSellGuidGtsData[N][1] == ItemId and Dream_ItemSellGuidGtsData[N][2] == Zs_GuidLowStoreData.AtGuidData[GuidLow].ULevel) then
						if (Dream_ItemSellGuidGtsData[N][3]) then
							for i = 1, 8 do
								if (Dream_ItemSellGuidGtsData[N][3][i * 2 - 1] ~= "0" and Dream_ItemSellGuidGtsData[N][3][i * 2] ~= "0") then
									Self:AddDoubleLine("出售获得 " ..DreamGetItemLink(Dream_ItemSellGuidGtsData[N][3][i * 2 - 1]), Dream_ItemSellGuidGtsData[N][3][i * 2] .. " 个", 0, 255 / 255, 0, 0, 255 / 255, 0);
								end
							end
							if (Dream_ItemSellGuidGtsData[N][3][17] ~= "0") then
								Self:AddDoubleLine("出售奖励会员等级", Dream_ItemSellGuidGtsData[N][3][17], 0, 255 / 255,
									0, 0,
									255 / 255, 0);
							end
							if (Dream_ItemSellGuidGtsData[N][3][18] ~= "0") then
								Self:AddDoubleLine("出售奖励积分", Dream_ItemSellGuidGtsData[N][3][18], 0, 255 / 255, 0, 0,
									255 / 255, 0);
							end
							if (Dream_ItemSellGuidGtsData[N][3][19] ~= "0") then
								Self:AddDoubleLine("出售奖励经验值", Dream_ItemSellGuidGtsData[N][3][19], 0, 255 / 255, 0,
									0,
									255 / 255, 0);
							end
							if (Dream_ItemSellGuidGtsData[N][3][20] ~= "0") then
								Self:AddDoubleLine("出售奖励荣誉点", Dream_ItemSellGuidGtsData[N][3][20], 0, 255 / 255, 0,
									0,
									255 / 255, 0);
							end
							if (Dream_ItemSellGuidGtsData[N][3][21] ~= "0") then
								Self:AddDoubleLine("出售奖励竞技点", Dream_ItemSellGuidGtsData[N][3][21], 0, 255 / 255, 0,
									0,
									255 / 255, 0);
							end
							if (Dream_ItemSellGuidGtsData[N][3][22] ~= "0") then
								Self:AddDoubleLine("出售奖励金币", Dream_ItemSellGuidGtsData[N][3][22], 0, 255 / 255, 0, 0,
									255 / 255, 0);
							end
						end
					end
				end
			end
		end

		if (Dream_ItemSellEntryGtsData) then
			for N = 1, #Dream_ItemSellEntryGtsData do
				if (Dream_ItemSellEntryGtsData[N][1] and Dream_ItemSellEntryGtsData[N][2] and Dream_ItemSellEntryGtsData[N][3] and Dream_ItemSellEntryGtsData[N][1] == ItemId) then
					local Vd = Dream_ItemSellEntryGtsData[N][2] == 0 and "" or "商人["..Dream_ItemSellEntryGtsData[N][2].."] ";
					if (Dream_ItemSellEntryGtsData[N][3]) then
						for i = 1, 8 do
							if (Dream_ItemSellEntryGtsData[N][3][i * 2 - 1] ~= "0" and Dream_ItemSellEntryGtsData[N][3][i * 2] ~= "0") then
								Self:AddDoubleLine(Vd.."出售获得 " ..DreamGetItemLink(Dream_ItemSellEntryGtsData[N][3][i * 2 - 1]), Dream_ItemSellEntryGtsData[N][3][i * 2] .. " 个", 0, 255 / 255, 0, 0, 255 / 255, 0);
							end
						end
						if (Dream_ItemSellEntryGtsData[N][3][17] ~= "0") then
							Self:AddDoubleLine(Vd.."出售奖励会员等级", Dream_ItemSellEntryGtsData[N][3][17], 0, 255 / 255,
								0, 0,
								255 / 255, 0);
						end
						if (Dream_ItemSellEntryGtsData[N][3][18] ~= "0") then
							Self:AddDoubleLine(Vd.."出售奖励积分", Dream_ItemSellEntryGtsData[N][3][18], 0, 255 / 255, 0, 0,
								255 / 255, 0);
						end
						if (Dream_ItemSellEntryGtsData[N][3][19] ~= "0") then
							Self:AddDoubleLine(Vd.."出售奖励经验值", Dream_ItemSellEntryGtsData[N][3][19], 0, 255 / 255, 0,
								0,
								255 / 255, 0);
						end
						if (Dream_ItemSellEntryGtsData[N][3][20] ~= "0") then
							Self:AddDoubleLine(Vd.."出售奖励荣誉点", Dream_ItemSellEntryGtsData[N][3][20], 0, 255 / 255, 0,
								0,
								255 / 255, 0);
						end
						if (Dream_ItemSellEntryGtsData[N][3][21] ~= "0") then
							Self:AddDoubleLine(Vd.."出售奖励竞技点", Dream_ItemSellEntryGtsData[N][3][21], 0, 255 / 255, 0,
								0,
								255 / 255, 0);
						end
						if (Dream_ItemSellEntryGtsData[N][3][22] ~= "0") then
							Self:AddDoubleLine(Vd.."出售奖励金币", Dream_ItemSellEntryGtsData[N][3][22], 0, 255 / 255, 0, 0,
								255 / 255, 0);
						end
					end
				end
			end
		end

		if (Dream_ItemBuyGtsData) then
			for N = 1, #Dream_ItemBuyGtsData do
				if (Dream_ItemBuyGtsData[N][1] and Dream_ItemBuyGtsData[N][2] and Dream_ItemBuyGtsData[N][3] and Dream_ItemBuyGtsData[N][1] == ItemId) then
					local Vd = Dream_ItemBuyGtsData[N][2] == 0 and "" or "商人["..Dream_ItemBuyGtsData[N][2].."] ";
					if (Dream_ItemBuyGtsData[N][3]) then
						for i = 1, 8 do
							if (Dream_ItemBuyGtsData[N][3][i * 2 - 1] ~= "0" and Dream_ItemBuyGtsData[N][3][i * 2] ~= "0") then
								Self:AddDoubleLine(Vd.."购买需要 " ..DreamGetItemLink(Dream_ItemBuyGtsData[N][3][i * 2 - 1]), Dream_ItemBuyGtsData[N][3][i * 2] .. " 个", 255 / 255, 102 / 255, 0, 255 / 255, 102 / 255, 0);
							end
						end
						if (Dream_ItemBuyGtsData[N][3][17] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要会员等级", Dream_ItemBuyGtsData[N][3][17], 255 / 255, 102 / 255,
								0, 255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][18] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要消耗积分", Dream_ItemBuyGtsData[N][3][18], 255 / 255, 102 / 255,
								0, 255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][19] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要达到累计积分", Dream_ItemBuyGtsData[N][3][19], 255 / 255,
								102 / 255, 0, 255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][20] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要人物等级", Dream_ItemBuyGtsData[N][3][20], 255 / 255, 102 / 255,
								0, 255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][21] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要消耗荣誉点", Dream_ItemBuyGtsData[N][3][21], 255 / 255,
								102 / 255, 0, 255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][22] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要消耗竞技点", Dream_ItemBuyGtsData[N][3][22], 255 / 255,
								102 / 255, 0, 255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][23] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要消耗金币", Dream_ItemBuyGtsData[N][3][23], 255 / 255, 102 / 255,
								0, 255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][24] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要职业", Dream_ItemBuyGtsData[N][3][24], 255 / 255, 102 / 255, 0,
								255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][25] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要种族", Dream_ItemBuyGtsData[N][3][25], 255 / 255, 102 / 255, 0,
								255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][26] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要阵营", Dream_ItemBuyGtsData[N][3][26], 255 / 255, 102 / 255, 0,
								255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][27] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要声望", Dream_ItemBuyGtsData[N][3][27], 255 / 255, 102 / 255, 0,
								255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][28] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要位于地图", Dream_ItemBuyGtsData[N][3][28], 255 / 255, 102 / 255,
								0, 255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][29] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要位于区域", Dream_ItemBuyGtsData[N][3][29], 255 / 255, 102 / 255,
								0, 255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][30] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要成就点", Dream_ItemBuyGtsData[N][3][30], 255 / 255, 102 / 255, 0,
								255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][31] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要军衔", Dream_ItemBuyGtsData[N][3][31], 255 / 255, 102 / 255, 0,
								255 / 255, 102 / 255, 0);
						end
						if (Dream_ItemBuyGtsData[N][3][32] ~= "0") then
							Self:AddDoubleLine(Vd.."购买需要斗气等级", Dream_ItemBuyGtsData[N][3][32], 255 / 255, 102 / 255,
								0, 255 / 255, 102 / 255, 0);
						end
					end
				end
				
			end
		end

		Dream_AddItemIdLine(Self, ItemIdStr);
		Dream_AddFinalItemDescription(Self, ItemId, ModuleData);
		Dream_ShowRuneTooltipTextures(Self, GuidLow);
		
		--[[

		--自定义
	    Self:AddLine("\n");
		Self:AddDoubleLine("物品编号", ItemIdStr);
		local GLow = GuidLowNum - MaxGuidIndex;
		if (GLow > 0) then
		    Self:AddDoubleLine("物品标识", GLow);
		end
		local ILevel = GetItemLevelById(ItemId);
		if (ILevel ~= 0) then
		    Self:AddDoubleLine("物品等级", ILevel);
		end
	    Self:AddLine("\n");

		]]--
	end

		Dream_FormatTooltipLargeNumbers(Self);
end

ItemRefTooltip:HookScript("OnShow", OnItemGlobalTooltipShow)
GameTooltip:HookScript("OnShow", OnItemGlobalTooltipShow)
ShoppingTooltip1:HookScript("OnShow", OnItemGlobalTooltipShow)
ShoppingTooltip2:HookScript("OnShow", OnItemGlobalTooltipShow)
ShoppingTooltip3:HookScript("OnShow", OnItemGlobalTooltipShow)

ItemRefTooltip:HookScript("OnHide", Dream_ResetRuneTooltip)
GameTooltip:HookScript("OnHide", Dream_ResetRuneTooltip)
ShoppingTooltip1:HookScript("OnHide", Dream_ResetRuneTooltip)
ShoppingTooltip2:HookScript("OnHide", Dream_ResetRuneTooltip)
ShoppingTooltip3:HookScript("OnHide", Dream_ResetRuneTooltip)

local function Dream_OnTooltipSetItem(Self)
	local ItemId, ItemLink = Dream_GetTooltipItemId(Self);
	-- OnTooltipSetItem can fire more than once while FrozenCore supplies its
	-- cached native lines. Preserve custom-render keys for the same item so
	-- those callbacks do not clear and rebuild the tooltip repeatedly.
	local PreserveCustomState = (ItemId and Self.Dream_LastTooltipItemId == ItemId) and true or false;
	Dream_ResetRuneTooltip(Self, PreserveCustomState);
	Self.Dream_LastTooltipItemId = ItemId;
	local _, GuidLow = Dream_ParseItemLinkStoreKey(ItemLink);
	GuidLow = Dream_GetTooltipGuidLow(Self, GuidLow);
	local HasFrozenSnapshot = Dream_IsFrozenGuidCached(GuidLow, ItemId);
	if (Dream_TooltipIsLoadingItem(Self)) then
		return;
	end
	if (not Dream_IsTooltipReadyOrFrozen(ItemId, GuidLow, Self)) then
		return;
	end
	Dream_ShowItemIdOnTitle(Self, ItemId);
	local _, _, ItemIdStr = Dream_ParseItemLinkStoreKey(ItemLink);
	Dream_AddItemIdLine(Self, ItemIdStr);
	local _, RequestedGuidLow, NeedTooltipData = Dream_RequestTooltipItemStoreData(Self);
	GuidLow = RequestedGuidLow or GuidLow;
	Dream_ShowRuneTooltipTextures(Self, GuidLow);
	if (NeedTooltipData) then
		return;
	end

	Dream_ApplyBigItemStatLines(Self);
	Dream_FormatTooltipLargeNumbers(Self);
	Dream_ShowRuneTooltipTextures(Self, GuidLow);
end

ItemRefTooltip:HookScript("OnTooltipSetItem", Dream_OnTooltipSetItem)
GameTooltip:HookScript("OnTooltipSetItem", Dream_OnTooltipSetItem)
ShoppingTooltip1:HookScript("OnTooltipSetItem", Dream_OnTooltipSetItem)
ShoppingTooltip2:HookScript("OnTooltipSetItem", Dream_OnTooltipSetItem)
ShoppingTooltip3:HookScript("OnTooltipSetItem", Dream_OnTooltipSetItem)

-- Custom data is rendered into the already-open tooltip. Re-running
-- SetHyperlink here re-enters the native item-cache callback path and can
-- exhaust DBCACHECALLBACK on the 3.3.5 client.
local function Dream_RefreshOpenItemTooltips(ItemId)
	local Tips = { ItemRefTooltip, GameTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3 };
	for i = 1, #Tips do
		local Tip = Tips[i];
		if (Tip and Tip:IsShown()) then
			local NowItemId, ItemLink = Dream_GetTooltipItemId(Tip);
			if (NowItemId and NowItemId == ItemId and ItemLink) then
				Dream_ItemTooltipDebug("refresh_inline_entry", ItemId, 0, "tip=" .. tostring(Tip:GetName() or "nil"));
				Dream_ApplyBigItemStatLines(Tip);
				Dream_FormatTooltipLargeNumbers(Tip);
			end
		end
	end
end

local Dream_PendingGuidTooltipRefresh = {};
local Dream_GuidTooltipRefreshElapsed = 0;
local Dream_AppendAllModuleDataToTooltip;

local function Dream_GetLegacyTooltipDataKey(GuidData, EnchantData, RuneData, DevelopData, CountData)
	if (not GuidData and not EnchantData and not RuneData and not DevelopData and not CountData) then
		return nil;
	end
	return table.concat({
		tostring(GuidData and GuidData.ULevel or ""),
		tostring(GuidData and GuidData.Prefix or ""),
		tostring(GuidData and GuidData.Suffix or ""),
		tostring(GuidData and GuidData.LevelStr or ""),
		tostring(GuidData and GuidData.TStore or ""),
		tostring(GuidData and GuidData.VStore or ""),
		tostring(GuidData and GuidData.PutMod or ""),
		tostring(EnchantData and table.concat(EnchantData, "#") or ""),
		tostring(RuneData and table.concat({ RuneData.NowCount or "", RuneData.MaxCount or "", RuneData.ItemStore or "", RuneData.GName or "", RuneData.GListStore or "" }, "#") or ""),
		tostring(DevelopData and table.concat(DevelopData, "#") or ""),
		tostring(CountData and table.concat(CountData, "#") or ""),
	}, "|");
end

local function Dream_AppendLegacyDataToTooltip(Tip, ItemId, GuidLow)
	if (not Tip or not Tip:IsShown() or not ItemId or not GuidLow or GuidLow <= 0) then
		return false;
	end

	local GuidData = Zs_GuidLowStoreData.AtGuidData[GuidLow];
	local EnchantData = Zs_GuidLowStoreData.EnchantData[GuidLow];
	local RuneData = Zs_GuidLowStoreData.AtRunesData[GuidLow];
	local DevelopData = Zs_GuidLowStoreData.DevelopData[GuidLow];
	local CountData = Zs_GuidLowStoreData.ItemEnchAtCountData[GuidLow];
	local DataKey = Dream_GetLegacyTooltipDataKey(GuidData, EnchantData, RuneData, DevelopData, CountData);
	if (not DataKey or Tip.Dream_LastLegacyDataKey == DataKey) then
		if (RuneData) then
			Dream_ShowRuneTooltipTextures(Tip, GuidLow);
		end
		return false;
	end

	-- The initial OnShow renderer can already contain the same skill/stat
	-- section from ModuleData. Legacy GUID data arrives afterward; appending
	-- its equivalent block would create the second flickering section visible
	-- with FrozenCore enabled.
	if (Dream_TooltipHasCustomModuleSection(Tip)) then
		Tip.Dream_LastLegacyDataKey = DataKey;
		Dream_ShowRuneTooltipTextures(Tip, GuidLow);
		return false;
	end

	local AnchorLine = nil;
	for LineIndex = 1, Tip:NumLines() do
		local Line = _G[Tip:GetName() .. "TextLeft" .. LineIndex];
		local Text = Line and Line:GetText();
		if (Text and Dream_IsOfficialBasePropertyLine(Text) and not Dream_IsRandomEnchantLine(GuidLow, Text)) then
			AnchorLine = Line;
		end
	end

	local Added = false;
	if (GuidData) then
		local GuidText = Dream_BuildGuidExtraTooltipText(GuidData);
		if (GuidText ~= "") then
			Dream_AddEquipmentTooltipBlock(Tip, AnchorLine, GuidText);
			Added = true;
		end
	end

	local EnchantText = Dream_BuildRandomEnchantSection(GuidLow);
	if (EnchantText ~= "") then
		Dream_AddEquipmentTooltipBlock(Tip, AnchorLine, EnchantText);
		Added = true;
	end

	Tip.Dream_LastLegacyDataKey = DataKey;
	Dream_ShowRuneTooltipTextures(Tip, GuidLow);
	Dream_FormatTooltipLargeNumbers(Tip);
	return Added;
end

local function Dream_DoRefreshOpenGuidTooltips(GuidLow)
	local Tips = { ItemRefTooltip, GameTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3 };
	for i = 1, #Tips do
		local Tip = Tips[i];
		if (Tip and Tip:IsShown()) then
			local _, ItemLink = Dream_GetTooltipItemId(Tip);
			if (ItemLink) then
				local ItemId, NowGuidLow = Dream_ParseItemLinkStoreKey(ItemLink);
				NowGuidLow = Dream_GetTooltipGuidLow(Tip, NowGuidLow);
				if (ItemId and Dream_IsTooltipReadyOrFrozen(ItemId, NowGuidLow, Tip) and NowGuidLow == GuidLow) then
					Dream_ItemTooltipDebug("refresh_inline_guid", ItemId, GuidLow, "tip=" .. tostring(Tip:GetName() or "nil"));
					Dream_AppendLegacyDataToTooltip(Tip, ItemId, GuidLow);
					local ModuleData = Zs_GuidLowStoreData.AllModuleData[GuidLow];
					if (ModuleData) then
						Dream_AppendAllModuleDataToTooltip(Tip, ModuleData);
					end
				end
			end
		end
	end
end

local function Dream_RefreshOpenGuidTooltips(GuidLow)
	-- With FrozenCore enabled, the cache layer can deliver several packets for
	-- one GUID (version, legacy fields, snapshot completion). Rewriting an open
	-- Tooltip from each packet is the source of the remaining rune-skill blink.
	-- FrozenCore data is hydrated before the next native tooltip pass; defer
	-- rendering until the user re-enters the item instead of mutating it here.
	if (FrozenCore_DisableLegacyTooltipRequests) then
		return;
	end
	GuidLow = tonumber(GuidLow) or 0;
	if (GuidLow <= 0) then
		return;
	end
	Dream_PendingGuidTooltipRefresh[GuidLow] = true;
end

local function Dream_ProcessPendingGuidTooltipRefresh(Elapsed)
	Dream_GuidTooltipRefreshElapsed = Dream_GuidTooltipRefreshElapsed + (Elapsed or 0);
	if (Dream_GuidTooltipRefreshElapsed < 0.08) then
		return;
	end
	Dream_GuidTooltipRefreshElapsed = 0;

	local GuidLow = next(Dream_PendingGuidTooltipRefresh);
	if (not GuidLow) then
		return;
	end
	Dream_PendingGuidTooltipRefresh[GuidLow] = nil;
	Dream_DoRefreshOpenGuidTooltips(GuidLow);
end

function FrozenCore_OnSnapshotReady(GuidLow)
	GuidLow = tonumber(GuidLow) or 0;
	if (GuidLow > 0) then
		Dream_RefreshOpenGuidTooltips(GuidLow);
	end
end

Dream_AppendAllModuleDataToTooltip = function(Tip, ModuleData)
	if (not Tip or not Tip:IsShown() or not ModuleData) then
		return false;
	end

	if ((not ModuleData.GuidLow or ModuleData.GuidLow <= 0) and (ModuleData.Bag == nil or ModuleData.Slot == nil)) then
		return false;
	end

	local _, ItemLink = Dream_GetTooltipItemId(Tip);
	if (not ItemLink) then
		return false;
	end

	local ItemId, GuidLow = Dream_ParseItemLinkStoreKey(ItemLink);
	GuidLow = Dream_GetTooltipGuidLow(Tip, GuidLow);
	if (not ItemId or not Dream_IsTooltipReadyOrFrozen(ItemId, GuidLow, Tip)) then
		return false;
	end

	local MatchByGuid = (GuidLow and GuidLow > 0 and GuidLow == ModuleData.GuidLow);
	local MatchByLocation = false;
	if (not MatchByGuid and ModuleData.Bag ~= nil and ModuleData.Slot ~= nil) then
		local Bag, Slot = Dream_GetTooltipClientLocation(Tip);
		MatchByLocation = (Bag == ModuleData.Bag and Slot == ModuleData.Slot and ItemId == ModuleData.ItemId);
	end

	if (not MatchByGuid and not MatchByLocation) then
		return false;
	end

	local Key = Dream_GetAllModuleTooltipKey(ModuleData, ItemId);
	if (not Key) then
		return false;
	end

	-- The same module packet can be observed from several paths (the addon
	-- response, FrozenCore snapshot completion, and the GUID refresh queue).
	-- Once this exact payload was rendered, do not touch the existing lines;
	-- rewriting the anchor line changes tooltip height and causes visible
	-- flicker/jumping.
	if (Tip.Dream_LastAllModuleTooltipKey == Key) then
		return false;
	end

	-- A tooltip may receive the same logical module data through a second
	-- packet with a different auxiliary field. Existing section markers are
	-- authoritative here: appending again would duplicate the section and
	-- make the frame resize on every packet.
	for LineIndex = 1, Tip:NumLines() do
		local ExistingLine = _G[Tip:GetName() .. "TextLeft" .. LineIndex];
		local ExistingText = ExistingLine and ExistingLine:GetText();
		if (ExistingText and (string.find(ExistingText, "追加属性", 1, true) or
			string.find(ExistingText, "追加技能", 1, true) or
			string.find(ExistingText, "追加套装", 1, true) or
			string.find(ExistingText, "追加符文", 1, true) or
			string.find(ExistingText, "追加强化", 1, true) or
			string.find(ExistingText, "追加成长", 1, true))) then
			Tip.Dream_LastAllModuleTooltipKey = Key;
			return false;
		end
	end

	local OfficialBasePropertyLine = nil;
	local ModuleBaseAnchorLine = nil;
	local ModuleBaseApplied = {};
	local ModuleBaseReplaceState = {};
	ModuleBaseReplaceState.ItemId = ItemId;
	ModuleBaseReplaceState.GuidLow = ModuleData.GuidLow or GuidLow or 0;
	local HasModuleExtraText = false;
	local DidApplyBaseText = false;
	local InExistingModuleExtraSection = false;
	Dream_ItemTooltipDebug("append_module_start", ItemId, GuidLow, "tip=" .. tostring(Tip:GetName() or "nil") .. " lines=" .. tostring(Tip:NumLines()) .. " base=" .. Dream_ItemTooltipBool(Dream_IsModuleText(ModuleData.BaseAttributes)) .. " add=" .. Dream_ItemTooltipBool(Dream_IsModuleText(ModuleData.AdditionalAttributes)) .. " baseText=" .. Dream_ItemTooltipShort(ModuleData.BaseAttributes or "nil", 80));
	for LineIndex = 1, Tip:NumLines() do
		local GLine = _G[Tip:GetName() .. "TextLeft" .. LineIndex];
		local Text = GLine and GLine:GetText();
		if (Text and (string.find(Text, "追加属性", 1, true) or string.find(Text, "追加技能", 1, true) or string.find(Text, "追加套装", 1, true) or string.find(Text, "追加符文", 1, true) or string.find(Text, "追加强化", 1, true) or string.find(Text, "追加成长", 1, true) or string.find(Text, "随机附魔", 1, true))) then
			HasModuleExtraText = true;
			InExistingModuleExtraSection = true;
		end

		local ModuleBaseText = (not InExistingModuleExtraSection) and Dream_ReplaceModuleBaseAttributeLine(Text, ModuleData, ModuleBaseApplied, ModuleBaseReplaceState) or nil;
		if (Dream_IsModuleText(ModuleData.BaseAttributes) and LineIndex <= 12) then
			Dream_ItemTooltipDebug("base_scan_append", ItemId, GuidLow, "line=" .. tostring(LineIndex) .. " inExtra=" .. Dream_ItemTooltipBool(InExistingModuleExtraSection) .. " match=" .. Dream_ItemTooltipBool(Dream_IsOfficialModuleBaseReplaceLine(Text)) .. " result=" .. Dream_ItemTooltipBool(ModuleBaseText ~= nil) .. " text=" .. Dream_ItemTooltipShort(Text or "nil", 70));
		end
		if (ModuleBaseText and GLine) then
			GLine:SetText(ModuleBaseText);
			GLine:SetWidth(Tip:GetWidth());
			Text = ModuleBaseText;
			DidApplyBaseText = true;
			if (ModuleBaseText ~= "") then
				ModuleBaseAnchorLine = GLine;
			end
		end

		if (Dream_IsOfficialBasePropertyLine(Text) and not Dream_IsRandomEnchantLine(GuidLow, Text)) then
			OfficialBasePropertyLine = GLine;
		end
	end

	local ModuleExtraText = "";
	if (not HasModuleExtraText) then
		ModuleExtraText = Dream_BuildAllModuleTooltipText(ModuleData);
		ModuleExtraText = Dream_InsertRandomEnchantAfterAdditional(ModuleExtraText, ModuleData.GuidLow or GuidLow);
	end
	local ModuleBaseRemainderText = Dream_BuildModuleBaseRemainderLines(ModuleData, ModuleBaseApplied);
	Dream_ItemTooltipDebug("append_module_result", ItemId, GuidLow, "applied=" .. Dream_ItemTooltipBool(ModuleBaseReplaceState.BlockApplied) .. " remainder=" .. Dream_ItemTooltipBool(ModuleBaseRemainderText ~= "") .. " hasExtra=" .. Dream_ItemTooltipBool(HasModuleExtraText) .. " addExtra=" .. Dream_ItemTooltipBool(ModuleExtraText ~= ""));
	local EquipmentText = ModuleBaseRemainderText;
	if (ModuleExtraText ~= "") then
		EquipmentText = EquipmentText .. ModuleExtraText;
	end
	if (EquipmentText ~= "") then
		Dream_AddEquipmentTooltipBlock(Tip, ModuleBaseAnchorLine or OfficialBasePropertyLine, EquipmentText);
		DidApplyBaseText = true;
	elseif (not DidApplyBaseText) then
		return false;
	end

	Tip.Dream_LastAllModuleTooltipKey = Key;
	Dream_AddFinalItemDescription(Tip, ItemId, ModuleData);
	Dream_FormatTooltipLargeNumbers(Tip);
	return true;
end

local function Dream_AppendAllModuleDataToOpenTooltips(ModuleData)
	local Tips = { ItemRefTooltip, GameTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3 };
	for i = 1, #Tips do
		Dream_AppendAllModuleDataToTooltip(Tips[i], ModuleData);
	end
end

local ChatLink = nil;
local ChatText = nil;
local ChatBtn = nil;
local ChatSelf = nil;

function ResetChatLinkParam()
	ChatLink = nil;
	ChatText = nil;
	ChatBtn = nil;
	ChatSelf = nil;
end

function ChatLinkNull()
    return (ChatLink == nil and ChatText == nil);
end

for i=1,7 do
	local CFrame = _G["ChatFrame"..i];
	if (CFrame) then
		CFrame:HookScript("OnHyperlinkClick", function(self, link, text, button)
			local Has = false;
			if (link) then
				local ItemId, GuidLow, ItemIdStr = Dream_ParseItemLinkStoreKey(link);
				if (not ItemId) then
					return;
				end
	
				if (GuidLow > 0) then
					if (not IsShowGuidLowData(GuidLow, ItemId)) then
						NativeUITooltipQuery(ItemId, GuidLow);
					else
						Has = true;
					end
				end
	
				if (ItemIdStr) then
					if (not IsShowGEntryIdData(ItemId) or not IsShowBigItemStatData(ItemId)) then
						NativeUITooltipQuery(ItemId, 0);
					end
				end
			end
	
			if (Has) then
				ResetChatLinkParam();
			else
				ChatLink = link;
				ChatText = text;
				ChatBtn = button;
				ChatSelf = self;
			end
		end)
	end
end

--消息处理
local function Dream_OnItemCtAddonEvent(Self, event, Packet, Msg, Type, Sender)
	Dream_EnsureTooltipStoreData();
	if (event == "CHAT_MSG_ADDON") then
	
	
		if (Packet == "FrozenCoreCacheRemove") then
			local GuidLow = tonumber(Msg or "0");
			if (FrozenCore_RemoveGuidCache and GuidLow and GuidLow > 0) then
				FrozenCore_RemoveGuidCache(GuidLow);
			end
			if (GuidLow and GuidLow > 0) then
				Dream_ClearGuidStoreData(GuidLow);
				if (FrozenCore_CancelGuidSnapshot) then
					FrozenCore_CancelGuidSnapshot(GuidLow);
				end
			end
		elseif (Packet == "FrozenCoreCacheVersion" or Packet == "FrozenCoreCacheHit") then
			local Args = Dream_Split(Msg, "$");
			local GuidLow = tonumber(Args[1] or "0");
			local ServerCacheId = tonumber(Args[2] or "0");
			if (GuidLow and GuidLow > 0 and ServerCacheId and ServerCacheId > 0) then
				if (FrozenData) then
					FrozenData.ServerCacheId = FrozenData.ServerCacheId or {};
					FrozenData.ServerCacheId[GuidLow] = ServerCacheId;
				end
				if (Packet == "FrozenCoreCacheVersion" and FrozenCore_BeginGuidUpdate) then
					FrozenCore_BeginGuidUpdate(GuidLow, ServerCacheId);
				end
				Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.GuidLow, GuidLow);
				if (Dream_TooltipRequestCooldown and Dream_TooltipRequestCooldown.GuidLow) then
					Dream_TooltipRequestCooldown.GuidLow[GuidLow] = nil;
				end
				if (Packet == "FrozenCoreCacheHit") then
					Dream_ItemTooltipNoGuidClear(GuidLow);
					-- The local snapshot is already rendered. Rebuilding here would
					-- issue another cache check and can loop CacheHit -> SetHyperlink.
				end
			end
		elseif (Packet == "UITQ") then
			if (Msg and string.find(Msg, "^ALL_MODULE_DATA:")) then
				if (NativeUITQData) then
					local ChatModuleData = Dream_ParseAllModuleData(Msg);
					local ChatKey = ChatModuleData and (tostring(ChatModuleData.ItemId) .. ":" .. tostring(ChatModuleData.GuidLow or 0));
					local NativePayload = ChatKey and _G.Dream_NativeUITQPayloadByKey and _G.Dream_NativeUITQPayloadByKey[ChatKey];
					if (NativePayload and (NativePayload == Msg or (#NativePayload > #Msg and string.sub(NativePayload, 1, #Msg) == Msg))) then
						return;
					end
					if (ChatKey) then
						_G.Dream_ChatUITQPayloadByKey = _G.Dream_ChatUITQPayloadByKey or {};
						_G.Dream_ChatUITQPayloadByKey[ChatKey] = Msg;
					end
				end
				local ModuleData = Dream_ParseAllModuleData(Msg);
				if (ModuleData and ModuleData.ItemId and ModuleData.ItemId > 0 and ((ModuleData.GuidLow and ModuleData.GuidLow > 0) or (ModuleData.Bag ~= nil and ModuleData.Slot ~= nil) or Dream_IsModuleText(ModuleData.TemplateStatsData))) then
					if (not Dream_HasRenderableAllModuleData(ModuleData)) then
						if (ModuleData.GuidLow and ModuleData.GuidLow > 0) then
							Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.AllModuleGuid, ModuleData.GuidLow);
						end
						local EmptyLocationKey = Dream_GetAllModuleLocationKey(ModuleData.Bag, ModuleData.Slot, ModuleData.ItemId);
						if (EmptyLocationKey) then
							Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.AllModuleLocation, EmptyLocationKey);
						end
						Dream_ItemTooltipDebug("recv_all_module_empty", ModuleData.ItemId, ModuleData.GuidLow, "ignored=1");
						return;
					end

					if (ModuleData.GuidLow and ModuleData.GuidLow > 0) then
						Zs_GuidLowStoreData.AllModuleData[ModuleData.GuidLow] = ModuleData;
						if (FrozenCore_MarkGuidDataUpdated) then
							FrozenCore_MarkGuidDataUpdated(ModuleData.GuidLow, ModuleData.ItemId);
						end
						Dream_ItemTooltipNoGuidClear(ModuleData.GuidLow);
						Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.AllModuleGuid, ModuleData.GuidLow);
					end
					local LocationKey = Dream_GetAllModuleLocationKey(ModuleData.Bag, ModuleData.Slot, ModuleData.ItemId);
					if (LocationKey) then
						Zs_GuidLowStoreData.AllModuleLocationData[LocationKey] = ModuleData;
						Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.AllModuleLocation, LocationKey);
					end
					if (Dream_ApplyNativeTemplateStats(ModuleData)) then
						Dream_RefreshOpenItemTooltips(ModuleData.ItemId);
					end
					Dream_ItemTooltipDebug("recv_all_module", ModuleData.ItemId, ModuleData.GuidLow, "bag=" .. tostring(ModuleData.Bag) .. " slot=" .. tostring(ModuleData.Slot) .. " base=" .. Dream_ItemTooltipBool(Dream_IsModuleText(ModuleData.BaseAttributes)) .. " add=" .. Dream_ItemTooltipBool(Dream_IsModuleText(ModuleData.AdditionalAttributes)) .. " skill=" .. Dream_ItemTooltipBool(Dream_IsModuleText(ModuleData.SkillsData)) .. " set=" .. Dream_ItemTooltipBool(Dream_IsModuleText(ModuleData.SetData)) .. " rune=" .. Dream_ItemTooltipBool(Dream_IsModuleText(ModuleData.RuneData)) .. " baseText=" .. Dream_ItemTooltipShort(ModuleData.BaseAttributes or "nil", 80));
					if (not FrozenCore_DisableLegacyTooltipRequests) then
						Dream_AppendAllModuleDataToOpenTooltips(ModuleData);
					end
				end
			end
		elseif (Packet == "ClientAtGuidData") then
			local Args = Dream_Split(Msg, "$");
			local GuidLow = tonumber(Args[1]);
			Zs_GuidLowStoreData.AtGuidData[GuidLow] = {
				ULevel = tonumber(Args[2]),
				Prefix = Args[3],
				Suffix = Args[4],
				LevelStr = Args[5],
				MinDmg = Args[6],
				MaxDmg = Args[7],
				DPS = Args[8],
				TStore = Args[9],
				VStore = Args[10],
				AsSpell = Args[11],
				PutMod = tonumber(Args[12]),
				shuxin = Args[13],
				_Attris = Args[14],
				IsSuperRandom = (tonumber(Args[15] or "0") == 1),
				ItemId = tonumber(Args[16] or "0"),
			};
			if (FrozenCore_MarkGuidDataUpdated) then
				FrozenCore_MarkGuidDataUpdated(GuidLow, tonumber(Args[16] or "0"));
			end
			Dream_MarkGuidCacheId(GuidLow, tonumber(Args[16] or "0") or Dream_TooltipRequestedItemIdByGuid[GuidLow]);
			Dream_TooltipRequestedItemIdByGuid[GuidLow] = nil;
			Dream_ItemTooltipNoGuidClear(GuidLow);
			Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.GuidLow, GuidLow);
			if (Dream_TooltipRequestCooldown and Dream_TooltipRequestCooldown.GuidLow) then
				Dream_TooltipRequestCooldown.GuidLow[GuidLow] = nil;
			end
			Dream_ItemTooltipDebug("recv_guid", 0, GuidLow, "level=" .. tostring(Args[2]) .. " min=" .. Dream_ItemTooltipShort(Args[6], 18) .. " max=" .. Dream_ItemTooltipShort(Args[7], 18) .. " tLen=" .. string.len(tostring(Args[9] or "")) .. " vLen=" .. string.len(tostring(Args[10] or "")));
			Dream_RefreshOpenGuidTooltips(GuidLow);
			
		    if (not ChatLinkNull()) then
				ItemRefTooltip:Hide();
				SetItemRef(ChatLink, ChatText, ChatBtn, ChatSelf);
				ResetChatLinkParam();
			end
		elseif (Packet == "AutoEnchant") then
			local Args = Dream_Split(Msg, "$");
			local GuidLow = tonumber(Args[1]);
			local Arg = Dream_Split(Args[2], "#");
			local Descriptions = Dream_SplitKeepEmpty(Args[3] or "", "#");
			Dream_EnchantmentDes = Dream_EnchantmentDes or {};
			for i = 1, 5 do
				local EnchantId = Arg[i];
				local Description = Descriptions[i];
				if (EnchantId and EnchantId ~= "0" and Dream_IsModuleText(Description)) then
					Dream_EnchantmentDes[EnchantId] = Description;
				end
			end
			Zs_GuidLowStoreData.EnchantData[GuidLow] = { Arg[1], Arg[2], Arg[3], Arg[4], Arg[5] };
			if (FrozenCore_MarkGuidDataUpdated) then
				FrozenCore_MarkGuidDataUpdated(GuidLow);
			end
			Dream_MarkGuidCacheId(GuidLow, Dream_TooltipRequestedItemIdByGuid[GuidLow] or (Zs_GuidLowStoreData.AtGuidData[GuidLow] and Zs_GuidLowStoreData.AtGuidData[GuidLow].ItemId));
			Dream_TooltipRequestedItemIdByGuid[GuidLow] = nil;
			Dream_ItemTooltipNoGuidClear(GuidLow);
			Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.GuidLow, GuidLow);
			Dream_RefreshOpenGuidTooltips(GuidLow);
		elseif (Packet == "ClientAtRunesData") then
			local Args = Dream_Split(Msg, "$");
			local GuidLow = tonumber(Args[1]);
			local RuneMeta = {};
			if (Args[9] and Args[9] ~= "") then
				for RuneIndex, Record in ipairs(Dream_SplitKeepEmpty(Args[9], "#")) do
					local Fields = Dream_SplitKeepEmpty(Record, "~");
					RuneMeta[RuneIndex] = {
						ItemId = tonumber(Fields[1] or "0") or 0,
						DisplayId = tonumber(Fields[2] or "0") or 0,
						Name = Dream_UrlDecodeAddonField(Fields[3] or ""),
						Icon = Dream_UrlDecodeAddonField(Fields[4] or ""),
					};
				end
			end
			Zs_GuidLowStoreData.AtRunesData[GuidLow] = {
				NowCount = tonumber(Args[2]),
				MaxCount = tonumber(Args[3]),
				ItemStore = Args[4],
				OSpellStore = Args[5],
				GName = Dream_UrlDecodeAddonField(Args[6] or ""),
				GListStore = Dream_UrlDecodeAddonField(Args[7] or ""),
				ItemId = tonumber(Args[8] or "0"),
				RuneMeta = RuneMeta,
			};
			if (FrozenCore_MarkGuidDataUpdated) then
				FrozenCore_MarkGuidDataUpdated(GuidLow, tonumber(Args[8] or "0"));
			end
			Dream_MarkGuidCacheId(GuidLow, tonumber(Args[8] or "0") or Dream_TooltipRequestedItemIdByGuid[GuidLow]);
			Dream_TooltipRequestedItemIdByGuid[GuidLow] = nil;
			Dream_ItemTooltipNoGuidClear(GuidLow);
			Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.GuidLow, GuidLow);
			Dream_RefreshOpenGuidTooltips(GuidLow);
		elseif (Packet == "ClientGuidNoData") then
			local GuidLow = tonumber(Msg);
			if (FrozenCore_CancelGuidSnapshot) then
				FrozenCore_CancelGuidSnapshot(GuidLow);
			end
			Dream_MarkGuidCacheId(GuidLow, Dream_TooltipRequestedItemIdByGuid[GuidLow]);
			Dream_TooltipRequestedItemIdByGuid[GuidLow] = nil;
			if (GuidLow and Zs_GuidLowStoreData.AtGuidData) then
				Zs_GuidLowStoreData.AtGuidData[GuidLow] = nil;
			end
			if (GuidLow) then
				Zs_GuidLowStoreData.AtRunesData[GuidLow] = nil;
				Zs_GuidLowStoreData.EnchantData[GuidLow] = nil;
				Zs_GuidLowStoreData.DevelopData[GuidLow] = nil;
				Zs_GuidLowStoreData.ItemEnchAtCountData[GuidLow] = nil;
			end
			Dream_ItemTooltipNoGuidSet(GuidLow);
			Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.GuidLow, GuidLow);
			if (Dream_TooltipRequestCooldown and Dream_TooltipRequestCooldown.GuidLow) then
				Dream_TooltipRequestCooldown.GuidLow[GuidLow] = nil;
			end
			Dream_ItemTooltipDebug("recv_guid_nodata", 0, GuidLow, "reason=server_no_guid_data");
		elseif (Packet == "ClientRunesAddSlot") then
			local Args = Dream_Split(Msg, "$");
			local GuidLow = tonumber(Args[1]);
			if (Zs_GuidLowStoreData.AtRunesData[GuidLow]) then
				Zs_GuidLowStoreData.AtRunesData[GuidLow].MaxCount = tonumber(Args[2]);
				Dream_RefreshOpenGuidTooltips(GuidLow);
			end
		elseif (Packet == "ResetItemLimit") then
			if (Zs_EntryIdStoreData.ItemLimitData1) then
				for Id, _ in pairs(Zs_EntryIdStoreData.ItemLimitData1) do
					if (Zs_EntryIdStoreData.ItemLimitData1[Id][1]) then
						Zs_EntryIdStoreData.ItemLimitData1[Id][1] = "0";
					end
				end
			end

			if (Zs_EntryIdStoreData.ItemLimitData3) then
				for Id, _ in pairs(Zs_EntryIdStoreData.ItemLimitData3) do
					if (Zs_EntryIdStoreData.ItemLimitData3[Id][1]) then
						Zs_EntryIdStoreData.ItemLimitData3[Id][1] = "0";
					end
				end
			end

			if (Zs_EntryIdStoreData.ItemUseLimitData1) then
				for Id, _ in pairs(Zs_EntryIdStoreData.ItemUseLimitData1) do
					if (Zs_EntryIdStoreData.ItemUseLimitData1[Id][1]) then
						Zs_EntryIdStoreData.ItemUseLimitData1[Id][1] = "0";
					end
				end
			end
		elseif (Packet == "AutoItemEnchAtCount") then
			local Args = Dream_Split(Msg, "#");
			local GuidLow = tonumber(Args[1]);
			local RtsCount = Args[2];
			local AwRtsCount = tonumber(Args[3]);
			Zs_GuidLowStoreData.ItemEnchAtCountData[GuidLow] = { RtsCount, AwRtsCount };
			if (FrozenCore_MarkGuidDataUpdated) then
				FrozenCore_MarkGuidDataUpdated(GuidLow);
			end
			Dream_MarkGuidCacheId(GuidLow, Dream_TooltipRequestedItemIdByGuid[GuidLow] or (Zs_GuidLowStoreData.AtGuidData[GuidLow] and Zs_GuidLowStoreData.AtGuidData[GuidLow].ItemId) or (Zs_GuidLowStoreData.AtRunesData[GuidLow] and Zs_GuidLowStoreData.AtRunesData[GuidLow].ItemId));
			Dream_TooltipRequestedItemIdByGuid[GuidLow] = nil;
			Dream_ItemTooltipNoGuidClear(GuidLow);
			Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.GuidLow, GuidLow);
			Dream_RefreshOpenGuidTooltips(GuidLow);
		elseif (Packet == "AutoItemLimitData1") then
			local Args = Dream_Split(Msg, "#");
			local ItemId = tonumber(Args[1]);
			Zs_EntryIdStoreData.ItemLimitData1[ItemId] = { Args[2], Args[3] };
		elseif (Packet == "AutoItemLimitData2") then
			local Args = Dream_Split(Msg, "#");
			local ItemId = tonumber(Args[1]);
			Zs_EntryIdStoreData.ItemLimitData2[ItemId] = { Args[2], Args[3] };
		elseif (Packet == "AutoItemLimitData3") then
			local Args = Dream_Split(Msg, "#");
			local ItemId = tonumber(Args[1]);
			Zs_EntryIdStoreData.ItemLimitData3[ItemId] = { Args[2], Args[3] };
		elseif (Packet == "AutoItemLimitData4") then
			local Args = Dream_Split(Msg, "#");
			local ItemId = tonumber(Args[1]);
			Zs_EntryIdStoreData.ItemLimitData4[ItemId] = { Args[2], Args[3] };
		elseif (Packet == "AutoItemUseLimitData1") then
			local Args = Dream_Split(Msg, "#");
			local ItemId = tonumber(Args[1]);
			Zs_EntryIdStoreData.ItemUseLimitData1[ItemId] = { Args[2], Args[3] };
		elseif (Packet == "AutoItemUseLimitData2") then
			local Args = Dream_Split(Msg, "#");
			local ItemId = tonumber(Args[1]);
			Zs_EntryIdStoreData.ItemUseLimitData2[ItemId] = { Args[2], Args[3] };
		elseif (Packet == "ReloadItemTemplateData") then
			local ItemId = tonumber(Msg);
			if (ItemId) then
				Dream_WeaponItemCache[ItemId] = nil;
				Zs_EntryIdStoreData.BigItemStatData[ItemId] = nil;
				Zs_EntryIdStoreData.CacheIdData[ItemId] = nil;
				Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.EntryId, ItemId);
				Dream_RefreshOpenItemTooltips(ItemId);
			end
		elseif (Packet == "ReloadAllItemTemplateData") then
			local OpenItemIds = {};
			local Tips = { ItemRefTooltip, GameTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3 };
			for i = 1, #Tips do
				local Tip = Tips[i];
				if (Tip and Tip:IsShown()) then
					local ItemId = Dream_GetTooltipItemId(Tip);
					if (ItemId) then
						OpenItemIds[ItemId] = true;
					end
				end
			end

			Dream_WeaponItemCache = {};
			Zs_EntryIdStoreData.BigItemStatData = {};
			Zs_EntryIdStoreData.CacheIdData = {};
			Dream_TooltipRequestPending.EntryId = {};
			for ItemId in pairs(OpenItemIds) do
				Dream_RefreshOpenItemTooltips(ItemId);
			end
		elseif (Packet == "AutoBigItemStatData") then
			local Args = Dream_Split(Msg, "$");
			local ItemId = tonumber(Args[1]);
			local OldBigStat = Zs_EntryIdStoreData.BigItemStatData[ItemId] or {};
			Zs_EntryIdStoreData.BigItemStatData[ItemId] = {
				TStore = (Args[2] == "nullptr") and "" or Args[2],
				VStore = (Args[3] == "nullptr") and "" or Args[3],
				DmgMin = OldBigStat.DmgMin,
				DmgMax = OldBigStat.DmgMax,
				DPS = OldBigStat.DPS,
				WeaponChecked = OldBigStat.WeaponChecked,
			};
			Dream_MarkEntryCacheId(ItemId);
			Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.EntryId, ItemId);
			Dream_ItemTooltipDebug("recv_stat", ItemId, 0, "oldWeaponChecked=" .. Dream_ItemTooltipBool(OldBigStat.WeaponChecked) .. " keepDmg=" .. Dream_ItemTooltipShort(OldBigStat.DmgMin, 18) .. "/" .. Dream_ItemTooltipShort(OldBigStat.DmgMax, 18) .. " tLen=" .. string.len(tostring(Args[2] or "")) .. " vLen=" .. string.len(tostring(Args[3] or "")) .. " t=" .. Dream_ItemTooltipShort(Args[2], 80) .. " v=" .. Dream_ItemTooltipShort(Args[3], 120));
			Dream_RefreshOpenItemTooltips(ItemId);
		elseif (Packet == "AutoBigItemWeaponData") then
			local Args = Dream_Split(Msg, "$");
			local ItemId = tonumber(Args[1]);
			if (ItemId) then
				local BigStat = Zs_EntryIdStoreData.BigItemStatData[ItemId] or { TStore = "", VStore = "" };
				BigStat.DmgMin = Args[2];
				BigStat.DmgMax = Args[3];
				BigStat.DPS = (Args[4] == "nullptr") and "" or Args[4];
				BigStat.WeaponChecked = true;
				Zs_EntryIdStoreData.BigItemStatData[ItemId] = BigStat;
				Dream_MarkEntryCacheId(ItemId);
			end
			Dream_ItemTooltipDebug("recv_weapon", ItemId, 0, "min=" .. Dream_ItemTooltipShort(Args[2], 18) .. " max=" .. Dream_ItemTooltipShort(Args[3], 18) .. " dps=" .. Dream_ItemTooltipShort(Args[4], 18));
			Dream_RefreshOpenItemTooltips(ItemId);
		elseif (Packet == "ClientDevelopData") then
			local Args = Dream_Split(Msg, "#");
			local GuidLow = tonumber(Args[1]);
			local Rank = tonumber(Args[2]);
			local NowXp = tonumber(Args[3]);
			local NextRankXp = tonumber(Args[4]);
			Zs_GuidLowStoreData.DevelopData [GuidLow] = { Rank, NowXp, NextRankXp };
			if (FrozenCore_MarkGuidDataUpdated) then
				FrozenCore_MarkGuidDataUpdated(GuidLow);
			end
			Dream_MarkGuidCacheId(GuidLow, Dream_TooltipRequestedItemIdByGuid[GuidLow] or (Zs_GuidLowStoreData.AtGuidData[GuidLow] and Zs_GuidLowStoreData.AtGuidData[GuidLow].ItemId) or (Zs_GuidLowStoreData.AtRunesData[GuidLow] and Zs_GuidLowStoreData.AtRunesData[GuidLow].ItemId));
			Dream_TooltipRequestedItemIdByGuid[GuidLow] = nil;
			Dream_ItemTooltipNoGuidClear(GuidLow);
			Dream_ItemTooltipPendingClear(Dream_TooltipRequestPending.GuidLow, GuidLow);
			Dream_RefreshOpenGuidTooltips(GuidLow);
		elseif (Packet == "ResetLuaCache") then
			Zs_GuidLowStoreData = { AtGuidData = {}, EnchantData = {},AtRunesData = {},ItemEnchAtCountData = {},DevelopData = {},AllModuleData = {},AllModuleLocationData = {},CacheIdData = {},};
			Zs_EntryIdStoreData = { ItemLimitData1 = {}, ItemLimitData2 = {},ItemLimitData3 = {},ItemLimitData4 = {},ItemUseLimitData1 = {},ItemUseLimitData2 = {},BigItemStatData = {},CacheIdData = {},};
			Dream_WeaponItemCache = {};
			Dream_TooltipRequestPending = { GuidLow = {}, EntryId = {}, AllModuleGuid = {}, AllModuleLocation = {}, };
			Dream_TooltipRequestCooldown = { GuidLow = {}, };
			Dream_TooltipNoGuidData = {};
			Dream_TooltipRequestedItemIdByGuid = {};
			if (FrozenCore_RehydrateSavedVariables) then
				FrozenCore_RehydrateSavedVariables();
			end
		end
	elseif (event == "VARIABLES_LOADED") then
		Dream_EnsureTooltipStoreData();
		Dream_InstallItemStoreWarmHooks();
		for _, BigStat in pairs(Zs_EntryIdStoreData.BigItemStatData) do
			if (BigStat and BigStat.WeaponChecked and (not BigStat.DmgMin or not BigStat.DmgMax)) then
				BigStat.WeaponChecked = nil;
			end
		end
	end
end

--交互消息事件
local Dream_NativeUITQRevision = nil;
local Dream_NativeUITQElapsed = 0;
local function Dream_ProcessNativeUITQ(Elapsed)
	if (not NativeUITQData) then
		return;
	end

	Dream_NativeUITQElapsed = Dream_NativeUITQElapsed + (Elapsed or 0);
	if (Dream_NativeUITQElapsed < 0.2) then
		return;
	end
	Dream_NativeUITQElapsed = 0;

	local Payload, Revision = NativeUITQData();
	if (not Payload or Payload == "" or Revision == Dream_NativeUITQRevision) then
		return;
	end
	Dream_NativeUITQRevision = Revision;

	local ModuleData = Dream_ParseAllModuleData(Payload);
	if (not ModuleData or not ModuleData.ItemId) then
		return;
	end

	local Key = tostring(ModuleData.ItemId) .. ":" .. tostring(ModuleData.GuidLow or 0);
	_G.Dream_NativeUITQPayloadByKey = _G.Dream_NativeUITQPayloadByKey or {};
	local ChatPayload = _G.Dream_ChatUITQPayloadByKey and _G.Dream_ChatUITQPayloadByKey[Key];
	if (ChatPayload and ChatPayload == Payload) then
		return;
	end
	_G.Dream_NativeUITQPayloadByKey[Key] = Payload;
	Dream_OnItemCtAddonEvent(UIParent, "CHAT_MSG_ADDON", "UITQ", Payload, "WHISPER", "");
end

local ItemCtAddonFrame = CreateFrame("Frame", "ItemCtAddonFrame");
ItemCtAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
ItemCtAddonFrame:RegisterEvent("VARIABLES_LOADED");
ItemCtAddonFrame:SetScript("OnEvent", Dream_OnItemCtAddonEvent);
ItemCtAddonFrame:SetScript("OnUpdate", function(_, Elapsed)
	Dream_ProcessItemStoreWarmQueue(Elapsed);
	Dream_ProcessPendingGuidTooltipRefresh(Elapsed);
	Dream_ProcessNativeUITQ(Elapsed);
end);
