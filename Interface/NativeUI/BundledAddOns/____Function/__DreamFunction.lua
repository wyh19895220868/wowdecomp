
--常用方法 /dump 可测试

--数字1...转01
function Dream_GetNumCustom(Str)
    local Len = string.len(Str);
    if (Len == 1) then
	    return ("0"..Str);
	end
	return (Str);
end

--消息
function Dream_SendData(Packet, Msg)
    if (Msg == nil or Msg == "") then
	    Msg = " ";
	end
	SendAddonMessage(Packet, Msg, "GUILD", UnitName("player"));
end

if (RegisterAddonMessagePrefix) then
	RegisterAddonMessagePrefix("TooltipDebug");
elseif (C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix) then
	C_ChatInfo.RegisterAddonMessagePrefix("TooltipDebug");
end

local Dream_ChineseNumberUnits = {
    { exponent = 64, text = "不可思议" },
    { exponent = 60, text = "那由他" },
    { exponent = 56, text = "阿僧祇" },
    { exponent = 52, text = "恒河沙" },
    { exponent = 48, text = "极" },
    { exponent = 44, text = "载" },
    { exponent = 40, text = "正" },
    { exponent = 36, text = "涧" },
    { exponent = 32, text = "沟" },
    { exponent = 28, text = "穰" },
    { exponent = 24, text = "秭" },
    { exponent = 20, text = "垓" },
    { exponent = 16, text = "京" },
    { exponent = 12, text = "兆" },
    { exponent = 8, text = "亿" },
    { exponent = 4, text = "万" },
}

local function Dream_TrimNumberText(text)
    text = tostring(text or "")
    text = text:gsub("(%..-)0+$", "%1")
    text = text:gsub("%.$", "")
    return text
end

local function Dream_FormatUnsignedIntegerWithUnit(digits, exponent)
    local integerLen = #digits - exponent
    local integerPart = digits:sub(1, integerLen)
    local fractionPart = digits:sub(integerLen + 1)

    local decimals = fractionPart:sub(1, 2)

    while #decimals < 2 do
        decimals = decimals .. "0"
    end

    return Dream_TrimNumberText(integerPart .. "." .. decimals)
end

function Dream_FormatChineseNumber(value)
    local text = tostring(value or "")
    text = text:gsub(",", "")
    local sign, digits = text:match("^([%-]?)(%d+)$")
    if not digits then
        return text
    end

    digits = digits:gsub("^0+", "")
    if digits == "" then
        return "0"
    end

    for _, unit in ipairs(Dream_ChineseNumberUnits) do
        if #digits > unit.exponent then
            return sign .. Dream_FormatUnsignedIntegerWithUnit(digits, unit.exponent) .. unit.text
        end
    end

    return sign .. digits
end

function Dream_FormatTooltipNumberText(text)
    if (text == nil) then
        return text
    end

    text = tostring(text):gsub("(%d+%.%d+)", function(value)
        local integerPart = value:match("^(%d+)%.%d+$")
        if (integerPart and #integerPart >= 9) then
            return Dream_FormatChineseNumber(integerPart)
        end
        return value
    end)

    text = text:gsub("(%d+)", function(digits)
        if (#digits >= 9) then
            return Dream_FormatChineseNumber(digits)
        end
        return digits
    end)

    text = text:gsub("万万", "万")
    text = text:gsub("亿亿", "亿")
    text = text:gsub("兆兆", "兆")
    text = text:gsub("京京", "京")
    return text
end

function Dream_IsPositiveIntegerText(value)
    local digits = tostring(value or ""):gsub(",", ""):match("^%+?(%d+)$")
    if not digits then
        return false
    end

    digits = digits:gsub("^0+", "")
    return digits ~= ""
end

local function Dream_MultiplyIntegerTextBySmallInt(value, multiplier)
    local digits = tostring(value or "0"):match("^(%d+)$")
    multiplier = tonumber(multiplier) or 0
    if (not digits or multiplier <= 0) then
        return "0"
    end

    local carry = 0
    local out = {}
    for i = #digits, 1, -1 do
        local n = tonumber(digits:sub(i, i)) * multiplier + carry
        table.insert(out, 1, tostring(n % 10))
        carry = math.floor(n / 10)
    end

    while carry > 0 do
        table.insert(out, 1, tostring(carry % 10))
        carry = math.floor(carry / 10)
    end

    local text = table.concat(out):gsub("^0+", "")
    return (text == "") and "0" or text
end

function Dream_MultiplyIntegerTextByIntegerText(value, multiplier)
    local valueSign, valueDigits = tostring(value or "0"):gsub(",", ""):match("^([%-]?)(%d+)$")
    local multiplierSign, multiplierDigits = tostring(multiplier or "0"):gsub(",", ""):match("^([%-]?)(%d+)$")
    if (not valueDigits or not multiplierDigits) then
        return "0"
    end

    valueDigits = valueDigits:gsub("^0+", "")
    multiplierDigits = multiplierDigits:gsub("^0+", "")
    if (valueDigits == "" or multiplierDigits == "") then
        return "0"
    end

    local result = {}
    for i = 1, (#valueDigits + #multiplierDigits) do
        result[i] = 0
    end

    for i = #valueDigits, 1, -1 do
        local a = tonumber(valueDigits:sub(i, i)) or 0
        for j = #multiplierDigits, 1, -1 do
            local b = tonumber(multiplierDigits:sub(j, j)) or 0
            local pos = i + j
            result[pos] = result[pos] + (a * b)
        end
    end

    for i = #result, 2, -1 do
        local carry = math.floor(result[i] / 10)
        result[i] = result[i] % 10
        result[i - 1] = result[i - 1] + carry
    end

    local out = {}
    for i = 1, #result do
        table.insert(out, tostring(result[i]))
    end

    local text = table.concat(out):gsub("^0+", "")
    if (text == "") then
        return "0"
    end

    if ((valueSign == "-" and multiplierSign ~= "-") or (valueSign ~= "-" and multiplierSign == "-")) then
        return "-" .. text
    end

    return text
end

local function Dream_FormatScaledIntegerText(value, scaleDigits, decimals)
    value = tostring(value or "0"):gsub("^0+", "")
    if (value == "") then
        value = "0"
    end

    while #value <= scaleDigits do
        value = "0" .. value
    end

    local integerPart = value:sub(1, #value - scaleDigits):gsub("^0+", "")
    local fractionPart = value:sub(#value - scaleDigits + 1)
    if (integerPart == "") then
        integerPart = "0"
    end

    decimals = tonumber(decimals)
    if (not decimals or decimals <= 0) then
        return integerPart
    end

    fractionPart = fractionPart:sub(1, decimals)
    while #fractionPart < decimals do
        fractionPart = fractionPart .. "0"
    end

    return Dream_TrimNumberText(integerPart .. "." .. fractionPart)
end

function Dream_ScaleNumberTextByFloat(value, factor, decimals)
    local text = tostring(value or "0"):gsub(",", "")
    local sign, integerPart, fractionPart = text:match("^([%-]?)(%d+)%.?(%d*)$")
    if (not integerPart) then
        return tostring(value or "0")
    end

    local scaledFactor = math.floor((tonumber(factor) or 0) * 10000 + 0.5)
    if (scaledFactor <= 0) then
        return "0"
    end

    local digits = (integerPart .. fractionPart):gsub("^0+", "")
    if (digits == "") then
        return "0"
    end

    local product = Dream_MultiplyIntegerTextBySmallInt(digits, scaledFactor)
    local result = Dream_FormatScaledIntegerText(product, #fractionPart + 4, decimals)
    if (sign == "-" and result ~= "0") then
        result = "-" .. result
    end
    return result
end

--取可攻击怪物标识
function Dream_GetCreGuidLow()
	if (not UnitExists("target")) then
	    return 0;
	end
	if (not UnitCanAttack("player", "target")) then
	    return 0;
	end
	local HeightGuid = UnitGUID("target");
	local UType = tonumber(HeightGuid:sub( 5, 5),  16) % 8;
	if (UType ~= 3) then
	    return 0;
	end
	local CreGuidLow  = tonumber(HeightGuid:sub(13, 18), 16);
	return CreGuidLow;
end
	
--字体 GameFontNormal:GetFont() "Interface\\Fonts\\FRIZQT_.TTF"
Dream_GameFont = GameFontNormal:GetFont();

--分割返回数组 --原字符--分割的字符
function Dream_Split(S, R)
    local List = {};
    string.gsub(S, '[^'..R..']+', function(F) table.insert(List, F) end);
    return List;
end

--分割返回多变量 --分割的字符--原字符
function Dream_DoSplit(R, S)
    return strsplit(R, S);
end

--计算页
function DreamGetPage(Count, MaxOnePages)
    local PageCount = math.floor(Count / MaxOnePages);
    local X = (Count % MaxOnePages);
    if (X ~= 0) then
        if (Count > PageCount * MaxOnePages) then
            PageCount = PageCount + 1;
        end
    end
    return PageCount;
end

--加 Tooltip 提示
function DoPrepareScript(Fm, Text)
	if (Fm and Text) then
	    Fm:SetScript("OnEnter", function() GameTooltip:SetOwner(Fm, "ANCHOR_TOP"); GameTooltip:SetText(Text); GameTooltip:Show() end)
        Fm:SetScript("OnLeave", function() GameTooltip:SetOwner(Fm, "ANCHOR_TOP"); GameTooltip:Hide() end)
    end
end

--超链接
function Dream_NormalizeHyperlink(Link)
	if (not Link) then
		return nil;
	end

	Link = tostring(Link);

	local ItemString = string.match(Link, "item[%-?%d:]+");
	if (ItemString) then
		return ItemString;
	end

	local HItemString = string.match(Link, "Hitem[%-?%d:]+");
	if (HItemString) then
		return string.gsub(HItemString, "^Hitem", "item");
	end

	local SpellString = string.match(Link, "spell[%-?%d:]+");
	if (SpellString) then
		return SpellString;
	end

	local HSpellString = string.match(Link, "Hspell[%-?%d:]+");
	if (HSpellString) then
		return string.gsub(HSpellString, "^Hspell", "spell");
	end

	return Link;
end

function Dream_SetTooltipHyperlink(Tooltip, Link)
	if (not Tooltip or not Link) then
		return false;
	end

	local SafeLink = Dream_NormalizeHyperlink(Link);
	if (not SafeLink or SafeLink == "") then
		return false;
	end

	-- An entry-only item hyperlink makes the 3.3.5 client allocate a new
	-- DBCACHECALLBACK. FrozenCore already supplies custom item data, so do not
	-- force that legacy lookup from auxiliary UI code.
	if (FrozenCore_DisableLegacyTooltipRequests and string.match(SafeLink, "^item:%d+$")) then
		return false;
	end

	local Now = (GetTime and GetTime()) or 0;
	if (Tooltip.Dream_LastHyperlink == SafeLink and Tooltip.Dream_LastHyperlinkAt and
		(Now - Tooltip.Dream_LastHyperlinkAt) < 0.25) then
		return false;
	end
	Tooltip.Dream_LastHyperlink = SafeLink;
	Tooltip.Dream_LastHyperlinkAt = Now;

	Tooltip:SetHyperlink(SafeLink);
	return true;
end

-- The 3.3.5 client allocates a DBCACHECALLBACK for uncached item lookups.
-- Repeating GetItemInfo/GetItemIcon while a tooltip is rebuilding can exhaust
-- that small callback pool even though Lua memory is still available.
Dream_ItemInfoCache = Dream_ItemInfoCache or {};
Dream_ItemInfoRequestAt = Dream_ItemInfoRequestAt or {};
Dream_ItemIconCache = Dream_ItemIconCache or {};

function Dream_GetItemInfoOnce(Entry)
	return Dream_GetItemInfoOnceWithRequest(Entry, false);
end

function Dream_GetItemInfoOnceWithRequest(Entry, AllowClientRequest)
	local ItemId = (type(Entry) == "string") and tonumber(string.match(Entry, "item:(%d+)")) or tonumber(Entry);
	if (not ItemId or ItemId <= 0) then
		return nil;
	end

	local Cached = Dream_ItemInfoCache[ItemId];
	if (Cached) then
		return unpack(Cached);
	end

	-- The equipment tooltip never opts into this branch. Rune socket entries
	-- are separate item IDs, so they need one controlled native cache request
	-- to resolve their name and icon.
	if (not AllowClientRequest or not GetItemInfo) then
		return nil;
	end

	local Now = (GetTime and GetTime()) or 0;
	local LastRequestAt = Dream_ItemInfoRequestAt[ItemId];
	if (LastRequestAt and (Now - LastRequestAt) < 1.0) then
		return nil;
	end
	Dream_ItemInfoRequestAt[ItemId] = Now;
	local Info = { GetItemInfo(ItemId) };
	if (Info[1]) then
		Dream_ItemInfoCache[ItemId] = Info;
		return unpack(Info);
	end
	return nil;
end

function Dream_MarkItemInfoReceived(Entry)
	Entry = tonumber(Entry);
	if (Entry and Entry > 0) then
		Dream_ItemInfoCache[Entry] = nil;
		Dream_ItemInfoRequestAt[Entry] = nil;
	end
end

-- GET_ITEM_INFO_RECEIVED is emitted by the client after its native item-cache
-- request completes. Only read the API from this event; no addon code asks the
-- client to fetch an uncached item ID.
if (CreateFrame) then
	local DreamItemInfoEventFrame = CreateFrame("Frame", "DreamItemInfoEventFrame");
	DreamItemInfoEventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	DreamItemInfoEventFrame:SetScript("OnEvent", function(_, _, Entry)
		Entry = tonumber(Entry);
		if (not Entry or Entry <= 0 or not GetItemInfo) then
			return;
		end
		local Info = { GetItemInfo(Entry) };
		if (Info[1]) then
			Dream_ItemInfoCache[Entry] = Info;
			Dream_ItemInfoRequestAt[Entry] = nil;
			if (Dream_OnRuneItemInfoReceived) then
				Dream_OnRuneItemInfoReceived(Entry);
			end
		end
	end);
end

function DreamGetItemLink(Entry)
	if (type(Entry) == "string") then
		Entry = tonumber(Entry)
	end

	local _, ItemLink = Dream_GetItemInfoOnce(Entry);
	if (ItemLink) then
		return ItemLink;
	end

	-- Do not recursively force the client item cache while FrozenCore is
	-- processing equipment data. The old 3.3.5 client can exhaust its
	-- DBCACHECALLBACK allocations after repeated SetHyperlink calls.
	if (FrozenCore_DisableLegacyTooltipRequests) then
		return "|cFF808080物品ID:" .. tostring(Entry) .. "|r";
	end

	-- Do not issue an entry-only SetHyperlink fallback. The native tooltip will
	-- load the hovered item, while FrozenCore handles the custom payload.
	return "";
end

--图标
function DreamGetItemIcon(Entry)
	if (type(Entry) == "string") then
		Entry = tonumber(Entry)
	end

	local Icon = Dream_ItemIconCache[Entry];
	if (Icon) then
		Dream_ItemIconCache[Entry] = Icon;
		return Icon;
	end

	local _, _, _, _, _, _, _, _, _, IconStr = Dream_GetItemInfoOnce(Entry);
	if (IconStr) then
		Dream_ItemIconCache[Entry] = IconStr;
		return IconStr;
	end

	-- Icons live in Item.dbc, so this works before the item stats have been
	-- fetched from the server (mall/codex/lottery pages rely on it).
	if (GetItemIcon) then
		local NativeIcon = GetItemIcon(Entry);
		if (NativeIcon and NativeIcon ~= "") then
			Dream_ItemIconCache[Entry] = NativeIcon;
			return NativeIcon;
		end
	end
	return "";
end

function Dream_GetRuneItemLink(Entry)
	local ItemName, ItemLink = Dream_GetItemInfoOnceWithRequest(Entry, true);
	return ItemLink or ItemName or "";
end

function Dream_GetRuneItemIcon(Entry)
	local _, _, _, _, _, _, _, _, _, IconStr = Dream_GetItemInfoOnceWithRequest(Entry, true);
	return IconStr or "";
end

-- Mall/codex/lottery/reward entries are not bag items, so FrozenCore never
-- caches them and GetItemInfo() stays nil. Allow one native entry lookup per
-- entry so those explicit UI hovers can populate the client item cache.
-- Set to false to restore the old placeholder-only behavior.
Dream_AllowEntryRequestFallback = true;
Dream_EntryRequestAt = Dream_EntryRequestAt or {};

function Dream_SetTooltipItemId(Tooltip, Entry)
	Entry = tonumber(Entry);
	if (not Tooltip or not Entry or Entry <= 0) then
		return false;
	end

	local _, Link = Dream_GetItemInfoOnceWithRequest(Entry, true);
	if (Link and Link ~= "") then
		return Dream_SetTooltipHyperlink(Tooltip, Link);
	end

	if (Dream_AllowEntryRequestFallback and Tooltip.SetHyperlink) then
		local Now = (GetTime and GetTime()) or 0;
		local Last = Dream_EntryRequestAt[Entry];
		if (not Last or (Now - Last) >= 2.0) then
			Dream_EntryRequestAt[Entry] = Now;
			Tooltip:SetHyperlink("item:" .. Entry .. ":0:0:0:0:0:0:0");
			return true;
		end
	end

	if (Tooltip.ClearLines) then
		Tooltip:ClearLines();
	end
	if (Tooltip.AddLine) then
		Tooltip:AddLine("物品信息尚未由客户端缓存");
	end
	return false;
end

function DreamGetSpellIcon(SpellId)
	if (type(SpellId) == "string") then
		SpellId = tonumber(SpellId)
	end
    local _, _, Icon = GetSpellInfo(SpellId)
    if (Icon) then
        return Icon;
    end
    return "";
end

----------------------------------------------------------------------------------------
--取技能说明
function GetSpellDescription(SpellId)
	if (type(SpellId) == "string") then
		SpellId = tonumber(Entry)
	end

	if (not SpellDescriptionTooltip) then
		CreateFrame("GameTooltip","SpellDescriptionTooltip",UIParent,"GameTooltipTemplate");
		SpellDescriptionTooltip:SetOwner(UIParent,"ANCHOR_NONE");
	end
	SpellDescriptionTooltip:ClearLines();
	SpellDescriptionTooltip:SetHyperlink("spell:"..SpellId);

	if (_G["SpellDescriptionTooltipTextLeft"..SpellDescriptionTooltip:NumLines()]) then
		local Des = _G["SpellDescriptionTooltipTextLeft"..SpellDescriptionTooltip:NumLines()]:GetText();
		if (Des) then
			return Des;
		end
	end

	return "";
end

--菜单显示链接

local function GossipExtend(Self)
	if Self:GetText() then
		local ItemString = string.match(Self:GetText(), "Hitem[%-?%d:]+")
		local SpellString = string.match(Self:GetText(), "Hspell[%-?%d:]+")
		if ItemString then
			local _, ItemId = Dream_DoSplit(":", ItemString)
			GameTooltip:SetOwner(_G["GossipFrame"], "ANCHOR_CURSOR")
			GameTooltip:ClearLines()
			Dream_SetTooltipHyperlink(GameTooltip, "item:"..ItemId)
			GameTooltip:Show()
		end

		if SpellString then
			local _, SpellId = Dream_DoSplit(":", SpellString)
			GameTooltip:SetOwner(_G["GossipFrame"], "ANCHOR_CURSOR")
			GameTooltip:ClearLines()
			Dream_SetTooltipHyperlink(GameTooltip, "spell:"..SpellId)
			GameTooltip:Show()
		end
	end
end

for i=1,32 do if _G["GossipTitleButton"..i] then _G["GossipTitleButton"..i]:SetScript("OnEnter", GossipExtend) _G["GossipTitleButton"..i]:SetScript("OnLeave", function() GameTooltip:Hide()end) end end

--取数值
function GetStrValue(Str)
	local num = Str:match("%d+");
	return tonumber(num) or 0;
end

--从Link中取ID
function GetItemIdByLink(ItemLink)
	if (not ItemLink) then
		return 0;
	end
	local ItemId = ItemLink:match("|Hitem:(%d+):");
	if (not ItemId) then
		ItemId = ItemLink:match("item:(%d+):?");
	end
	if (ItemId) then
		local NumItemId = tonumber(ItemId);
		if (NumItemId) then
			return NumItemId;
		end
	end
    return 0;
end

--取物品等级
function GetItemLevelById(ItemId)
	local _, _, _, ItemLevel = Dream_GetItemInfoOnce(ItemId);
	return (ItemLevel) and tonumber(ItemLevel) or 0;
end

--取数组
function GetTabCount(Tab)
	local Count = 0;
	for _, _ in pairs(Tab) do
		Count = Count + 1;
	end
	return Count;
end

--直接显示Link
function NowShowTips(Fm, Link, Point)
	if (Fm and Link) then
		if (Point == nil) then
			Point = "ANCHOR_RIGHT";
		end
		GameTooltip:SetOwner(Fm, Point);
		Dream_SetTooltipHyperlink(GameTooltip, Link);
		GameTooltip:Show();
	end
end

function FuncFrameUpdateAlpha(Fm, Show)
	if (Fm) then
		local Value = (not Show) and 0.6 or 1.0;
		Fm:SetAlpha(Value);
	end
end

function AutoTabMax(Tab)
	local Max = nil;
	if (not Tab) then
		return Max;
	end
	for _, V in pairs(Tab) do
		if (Max == nil) then
			Max = V;
		end
		if (Max < V) then
			Max = V;
		end
	end
	return Max;
end

function IsSTypeIn(St)
	local In = false;
	local Args = Dream_Split(St, "#");
	for i=1,#Args do
		local SType = tonumber(Args[i]);
		if (SType ~= -1) then
			In = true;
		end
	end
	return In;
end

function IsSpellIn(St)
	local In = false;
	local Args = Dream_Split(St, "#");
	for i=1,#Args do
		local SpellId = tonumber(Args[i]);
		if (SpellId ~= 0) then
			In = true;
		end
	end
	return In;
end

function IsRunesIn(St)
	local In = false;
	local Args = Dream_Split(St, "#");
	for i=1,#Args do
		local RunesItemId = tonumber(Args[i]);
		if (RunesItemId ~= 0) then
			In = true;
		end
	end
	return In;
end

function AutoPullStr(SType, SValue, PutMod)
	local RawSValue = tostring(SValue or "0");
	local PutSValue = Dream_ScaleNumberTextByFloat(RawSValue, PutMod or 0, 0);
	SValue = Dream_FormatChineseNumber(RawSValue);
	local APutStr = "";
	local BPutStr = "";
	if (PutSValue ~= "0") then
		local ShowPutSValue = Dream_FormatChineseNumber(PutSValue);
		APutStr = " |cFFFD3FB8[+"..ShowPutSValue.."]|r";
		BPutStr = "|cFFFD3FB8[+"..ShowPutSValue.."]|r";
	end
	
	if (SType == 0) then
		return"|cFFFFFF00+ "..SValue.." |cFF0066FF[法力值]|r"..APutStr;
	elseif (SType == 1) then
		return"|cFFFFFF00+ "..SValue.." |cFFFF0000[生命值]|r"..APutStr;
	elseif (SType == 2) then
		return"|cFFFFFF00+ "..SValue.." |cFFAAAAAA[护甲]|r"..APutStr;
	elseif (SType == 4) then
		return"|cFFFFFF00+ "..SValue.." |cFFFF8000[力量]|r"..APutStr;
	elseif (SType == 3) then
		return"|cFFFFFF00+ "..SValue.." |cFF40C040[敏捷]|r"..APutStr;
	elseif (SType == 7) then
		return"|cFFFFFF00+ "..SValue.." |cFF808080[耐力]|r"..APutStr;
	elseif (SType == 5) then
		return"|cFFFFFF00+ "..SValue.." |cFF8040FF[智力]|r"..APutStr;
	elseif (SType == 6) then
		return"|cFFFFFF00+ "..SValue.." |cFFFFFF00[精神]|r"..APutStr;
	elseif (SType == 12) then
		return string.format("|cFF05E105装备： 防御等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 13) then
		return string.format("|cFF05E105装备： 使你的躲闪等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 14) then
		return string.format("|cFF05E105装备： 使你的招架等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 15) then
		return string.format("|cFF05E105装备： 使你的盾牌格挡等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 16) then
		return string.format("|cFF05E105装备： 近战命中等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 17) then
		return string.format("|cFF05E105装备： 远程命中等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 18) then
		return string.format("|cFF05E105装备： 法术命中等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 19) then
		return string.format("|cFF05E105装备： 近战爆击等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 20) then
		return string.format("|cFF05E105装备： 远程爆击等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 21) then
		return string.format("|cFF05E105装备： 法术爆击等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 22) then
		return string.format("|cFF05E105装备： 近战命中躲闪等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 23) then
		return string.format("|cFF05E105装备： 远程命中躲闪等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 24) then
		return string.format("|cFF05E105装备： 法术命中躲闪等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 25) then
		return string.format("|cFF05E105装备： 近战爆击躲闪等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 26) then
		return string.format("|cFF05E105装备： 远程爆击躲闪等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 27) then
		return string.format("|cFF05E105装备： 法术爆击躲闪等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 28) then
		return string.format("|cFF05E105装备： 近战急速等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 29) then
		return string.format("|cFF05E105装备： 远程急速等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 30) then
		return string.format("|cFF05E105装备： 法术急速等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 31) then
		return string.format("|cFF05E105装备： 命中等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 32) then
		return string.format("|cFF05E105装备： 爆击等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 33) then
		return string.format("|cFF05E105装备： 命中躲闪等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 34) then
		return string.format("|cFF05E105装备： 爆击躲闪等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 35) then
		return string.format("|cFF05E105装备： 韧性等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 36) then
		return string.format("|cFF05E105装备： 急速等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 37) then
		return string.format("|cFF05E105装备： 使你的精准等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 38) then
		return string.format("|cFF05E105装备： 攻击强度提高%s。|r", SValue)..BPutStr;
	elseif (SType == 39) then
		return string.format("|cFF05E105装备： 远程攻击强度提高%s。|r", SValue)..BPutStr;
	elseif (SType == 40) then
		return string.format("|cFF05E105装备： 猎豹、熊、巨熊、枭兽形态攻击强度%s。|r", SValue)..BPutStr;
	elseif (SType == 41) then
		return string.format("|cFF05E105装备： 法术和魔法效果的治疗量提高最多%s。|r", SValue)..BPutStr;
	elseif (SType == 42) then
		return string.format("|cFF05E105装备： 法术和魔法效果的伤害量提高最多%s。|r", SValue)..BPutStr;
	elseif (SType == 43) then
		return string.format("|cFF05E105装备： 每5秒回复%s点法力值。|r", SValue)..BPutStr;
	elseif (SType == 44) then
		return string.format("|cFF05E105装备： 使你的护甲穿透等级提高%s。|r", SValue)..BPutStr;
	elseif (SType == 45) then
		return string.format("|cFF05E105装备： 法术强度提高%s。|r", SValue)..BPutStr;
	elseif (SType == 46) then
		return string.format("|cFF05E105装备： 每5秒恢复%s点生命值。|r", SValue)..BPutStr;
	elseif (SType == 47) then
		return string.format("|cFF05E105装备： 法术穿透提高%s。|r", SValue)..BPutStr;
	elseif (SType == 48) then
		return string.format("|cFF05E105装备： 使你的盾牌格挡值提高%s。|r", SValue)..BPutStr;
	end
	return "";
end

function ReverseTable(Tab)
	local Tmp = {};
	for i = 1, #Tab do
		Tmp[i] = table.remove(Tab)
	end
	return Tmp;
end

function GetRunesIcon(Num)
	local File = "";
	if (Num == 1) then
		File = InRunesIconFile1;
	elseif (Num == 2) then
		File = InRunesIconFile2;
	elseif (Num == 3) then
		File = InRunesIconFile3;
	elseif (Num == 4) then
		File = InRunesIconFile4;
	elseif (Num == 5) then
		File = InRunesIconFile5;
	elseif (Num == 6) then
		File = InRunesIconFile6;
	elseif (Num == 7) then
		File = InRunesIconFile7;
	elseif (Num == 8) then
		File = InRunesIconFile8;
	end
	return File;
end

function GetPutModStr(NumMod, Value)
	if (NumMod <= 0 or Value <= 0) then
		return "";
	end
	return string.format("%.1f", math.floor(Value * NumMod));
end

function ItemInBagPlayer(KItemId)
    for Bag = 0, 4 do
        local NumSlots = GetContainerNumSlots(Bag)
        for Slot = 1, NumSlots do
            local ItemID  = GetContainerItemID(Bag, Slot)
            if (ItemID and ItemID == KItemId) then
                return true;
            end
        end
    end
	return false;
end

function GetStatStr(SType)
	if (SType == 0) then
		return "法力值";
	elseif (SType == 1) then
		return "生命值";
	elseif (SType == 2) then
		return "护甲";
	elseif (SType == 4) then
		return "力量";
	elseif (SType == 3) then
		return "敏捷";
	elseif (SType == 7) then
		return "耐力";
	elseif (SType == 5) then
		return "智力";
	elseif (SType == 6) then
		return "精神";
	elseif (SType == 12) then
		return "防御等级";
	elseif (SType == 13) then
		return "躲闪等级";
	elseif (SType == 14) then
		return "招架等级";
	elseif (SType == 15) then
		return "格挡等级";
	elseif (SType == 16) then
		return "近战命中等级";
	elseif (SType == 17) then
		return "远程命中等级";
	elseif (SType == 18) then
		return "法术命中等级";
	elseif (SType == 19) then
		return "近战爆击等级";
	elseif (SType == 20) then
		return "远程爆击等级";
	elseif (SType == 21) then
		return "法术爆击等级";
	elseif (SType == 22) then
		return "近战躲闪等级";
	elseif (SType == 23) then
		return "远程躲闪等级";
	elseif (SType == 24) then
		return "法术躲闪等级";
	elseif (SType == 25) then
		return "近战躲闪等级";
	elseif (SType == 26) then
		return "远程躲闪等级";
	elseif (SType == 27) then
		return "法术躲闪等级";
	elseif (SType == 28) then
		return "近战急速等级";
	elseif (SType == 29) then
		return "远程急速等级";
	elseif (SType == 30) then
		return "法术急速等级";
	elseif (SType == 31) then
		return "命中等级";
	elseif (SType == 32) then
		return "爆击等级";
	elseif (SType == 33) then
		return "躲闪等级";
	elseif (SType == 34) then
		return "躲闪等级";
	elseif (SType == 35) then
		return "韧性等级";
	elseif (SType == 36) then
		return "急速等级";
	elseif (SType == 37) then
		return "精准等级";
	elseif (SType == 38) then
		return "攻击强度";
	elseif (SType == 39) then
		return "远程攻击强度";
	elseif (SType == 40) then
		return "形态攻击强度";
	elseif (SType == 41) then
		return "治疗量提高";
	elseif (SType == 42) then
		return "伤害量提高";
	elseif (SType == 43) then
		return "5秒回蓝";
	elseif (SType == 44) then
		return "护甲穿透等级";
	elseif (SType == 45) then
		return "法术强度";
	elseif (SType == 46) then
		return "5秒回血";
	elseif (SType == 47) then
		return "法术穿透等级";
	elseif (SType == 48) then
		return "盾牌格挡值";
	end
	return "";
end

function GetDiffStr(Diff)
	if (Diff == 0) then
		return "不限难度";
	elseif (Diff == 1) then
		return "英雄";
	elseif (Diff == 2) then
		return "25人普通";
	elseif (Diff == 3) then
		return "25人英雄";
	end
	return "不限难度";
end
