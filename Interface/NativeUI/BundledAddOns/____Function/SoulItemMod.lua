
local SoulItemButtons = { }
local SoulItemTypeStr = {};
local SoulItemButtonTextures = { }
local SoulItemIconRetryEntries = {}
local SoulItemIconCache = {}
local SoulItemIconRetryElapsed = 0
local SoulItemLoginSyncElapsed = nil
local SoulItemLoginSyncIndex = 0
local SoulItemTooltipSyncCache = {}

local SOUL_ITEM_ICON_RETRY_INTERVAL = 2.0
local SOUL_ITEM_ICON_RETRY_ATTEMPTS = 3
local SOUL_ITEM_LOGIN_SYNC_DELAYS = { 1.0, 3.0 }

local function BuildSoulItemTooltipLink(ItemLink, ItemGuid)
    if (not ItemLink or not ItemGuid or ItemGuid <= 0) then
        return ItemLink
    end

    local ItemPart = string.match(ItemLink, "item[%-?%d:]+")
    if (not ItemPart or not Dream_Split) then
        return ItemLink
    end

    local Parts = Dream_Split(ItemPart, ":")
    if (#Parts < 10) then
        return ItemLink
    end

    local GuidBase = tonumber(MaxGuidIndex) or 100000000
    local ExpectedGuid = GuidBase + ItemGuid
    if (tonumber(Parts[9]) == ExpectedGuid) then
        return ItemLink
    end

    Parts[9] = tostring(ExpectedGuid)
    local NewItemPart = table.concat(Parts, ":")
    return string.gsub(ItemLink, "item[%-?%d:]+", NewItemPart, 1)
end

local SoulButtonIcons =
{
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Head",--头部
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Neck",--颈部
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Shoulder",--肩部
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest",--背部
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest",--胸部
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Shirt",--衬衣
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Tabard",--战袍
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Wrists",--护腕
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands",--手部
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Waist",--腰部
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs",--腿部
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Feet",--脚部
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger",--戒指1
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger",--戒指2
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket",--饰品1
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket",--饰品2
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-MainHand",--主手武器
}

local SoulItemTypes =
{
	"头部",
	"颈部",
	"肩部",
	"背部",
	"胸部",
	"衬衣",
	"战袍",
	"腕部",
	"手部",
	"腰部",
	"腿部",
	"脚部",
	"上戒",
	"下戒",
	"上饰",
	"下饰",
	"主手",
	"副手",
	"远程",
}

local Dream_SoulStatPointData = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

local SoulNeedXp = 0;
local SoulMeRank = 0;
local SoulMeXp = 0;
local SoulNowPoint = 0;
local SoulNextCount = 1;

local SoulStatTypeStr = {};
local SoulStatNowPointStr = {};
local SoulStatClickRightButton = {};

local SoulStatType = {
        [1] = {"|cFF00FF00力量|r", "4"},
		[2] = {"|cFF00FF00敏捷|r", "3"},
		[3] = {"|cFF00FF00耐力|r", "7"},
		[4] = {"|cFF00FF00智力|r", "5"},
		[5] = {"|cFF00FF00精神|r", "6"},
		[6] = {"|cFF00FF00攻强|r", "38"},
		[7] = {"|cFF00FF00法强|r", "45"},
		[8] = {"|cFF00FF00急速等级|r", "36"},
		[9] = {"|cFF00FF00命中等级|r", "31"},
		[10] = {"|cFF00FF00暴击等级|r", "32"},
		[11] = {"|cFF00FF00护甲穿透等级|r", "44"},
		[12] = {"|cFF00FF00法术穿透等级|r", "47"},
};

--静态弹出框
StaticPopupDialogs["ResetStatPt"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
        Dream_SendData("AcceptResetStatPt");
	end,

	OnCancel = function(Self)

	end,

	OnShow = function(Self)

	end,

	exclusive = true,
	whileDead = true,
	hideOnEscape = true,
	timeout = 0,
};

StaticPopupDialogs["PopStatIncrease"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
		local Num = Self.editBox:GetNumber();
        Dream_SendData("AcceptStatIncrease", Self.Try.."#"..tostring(Num));
	end,

	OnCancel = function(Self)

	end,

	OnShow = function (Self)
	    Self.editBox:ClearFocus();
        Self.editBox:SetText(SoulNowPoint);
    end,

	exclusive = true,
	whileDead = true,
	hideOnEscape = true,
	timeout = 0,
	hasEditBox = true,
};

StaticPopupDialogs["ItemSoulStartNow"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
		local GuidLowStr = Self.GuidLowStr;
		local NumStr = Self.NumStr;
        Dream_SendData("AcceptItemSoulStartNow", GuidLowStr.."#"..NumStr);
	end,

	OnCancel = function(Self)

	end,

	OnShow = function (Self)

    end,

	exclusive = true,
	whileDead = true,
	hideOnEscape = true,
	timeout = 0,
};

StaticPopupDialogs["TaskItemSoulNow"] = {

	text = "\n\n你确定要卸除此部位的装备吗?",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
		Dream_SendData("TaskItemSoul", Self.NumStr);
	end,

	OnCancel = function(Self)

	end,

	OnShow = function (Self)

    end,

	exclusive = true,
	whileDead = true,
	hideOnEscape = true,
	timeout = 0,
};

local SoulItemFuncFrame = CreateFrame("Frame", "SoulItemFuncFrame", UIParent);
SoulItemFuncFrame:SetSize(640, 720);
SoulItemFuncFrame:RegisterForDrag("LeftButton");
SoulItemFuncFrame:SetPoint("CENTER", 0, 100);
SoulItemFuncFrame:SetToplevel(true);
SoulItemFuncFrame:SetClampedToScreen(true);
SoulItemFuncFrame:SetBackdrop({ bgFile = SoulIconFile0 });
tinsert(UISpecialFrames, "SoulItemFuncFrame");
SoulItemFuncFrame:Hide();

-- 关闭按钮
local SoulClose = CreateFrame("Button", "SoulClose", SoulItemFuncFrame, "UIPanelCloseButton");
SoulClose:SetPoint("TOPRIGHT", -5, -5)
SoulClose:EnableMouse(true);
SoulClose:SetSize(32, 32);

local OnTopSoulLeftText = SoulItemFuncFrame:CreateFontString("OnTopSoulLeftText");
OnTopSoulLeftText:SetFont(Dream_GameFont, 13);
OnTopSoulLeftText:SetPoint("TOPLEFT", 60, -165);
OnTopSoulLeftText:SetVertexColor(255/255, 255/255, 0/255)
OnTopSoulLeftText:SetText("[巅峰属性斗气 点击+号可查看加点详情]");

local OnTopSoulRightText = SoulItemFuncFrame:CreateFontString("OnTopSoulRightText");
OnTopSoulRightText:SetFont(Dream_GameFont, 13);
OnTopSoulRightText:SetPoint("TOPRIGHT", -60, -165);
OnTopSoulRightText:SetVertexColor(255/255, 255/255, 0/255)
OnTopSoulRightText:SetText("[双甲 左键拖入装备装载 右键卸下]");

local SoulItemLeftFrame = CreateFrame("Frame", "SoulItemLeftFrame", SoulItemFuncFrame);
SoulItemLeftFrame:SetSize(260, 480);
SoulItemLeftFrame:SetPoint("LEFT", 50, -88);
SoulItemLeftFrame:SetBackdrop({ bgFile = SoulIconFile3 });

local TopSoulText = SoulItemLeftFrame:CreateFontString("TopSoulText");
TopSoulText:SetFont(Dream_GameFont, 15);
TopSoulText:SetPoint("TOPLEFT", 0, -10);
TopSoulText:SetVertexColor(160/255, 200/255, 160/255)
TopSoulText:SetText(string.format("巅峰等级 [ %u ] 可用点数 [ %u ]", SoulMeRank, SoulNowPoint));

--进度条
local SoulButtonBar = CreateFrame("Button", "SoulButtonBar", SoulItemLeftFrame)
SoulButtonBar:SetSize(240, 20)
SoulButtonBar:SetPoint("TOP", -5, -35)
SoulButtonBar:SetBackdrop(
{
     bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
     edgeSize = 12,
     insets = { left = 3, right = 3, top = 3, bottom = 3 }
});
local AtSoulStatusBarOne = CreateFrame("StatusBar", "AtSoulStatusBarOne", SoulButtonBar)
AtSoulStatusBarOne:SetOrientation("HORIZONTAL")
AtSoulStatusBarOne:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
AtSoulStatusBarOne:SetStatusBarColor(255/255, 102/255, 0/255)
AtSoulStatusBarOne:SetPoint("CENTER")
AtSoulStatusBarOne:SetSize(SoulButtonBar:GetWidth() - 8, SoulButtonBar:GetHeight() - 8)
AtSoulStatusBarOne:SetMinMaxValues(1, 100)

local SoulButtonBarTexts = AtSoulStatusBarOne:CreateFontString("SoulButtonBarTexts")
SoulButtonBarTexts:SetFont(Dream_GameFont, 8)
SoulButtonBarTexts:SetAllPoints(AtSoulStatusBarOne)

local Schedule = (SoulNeedXp > 0) and (SoulMeXp * 100 / SoulNeedXp) or 0;
SoulButtonBarTexts:SetText("|cFF00FF00经验 "..SoulMeXp.."/"..SoulNeedXp.." 进度 "..string.format("%.f", Schedule).."% 下一级点数 "..SoulNextCount.."|r")
AtSoulStatusBarOne:SetValue(math.floor(Schedule))

local TitleSoulItemFrame = CreateFrame("Frame", "TitleSoulItemFrame", SoulItemLeftFrame);
TitleSoulItemFrame:SetSize(240, 40);
TitleSoulItemFrame:SetPoint("TOP", 0, -60);
TitleSoulItemFrame:SetBackdrop({ bgFile = SoulIconFile5 });

local TitleSoulText = TitleSoulItemFrame:CreateFontString("TitleSoulText");
TitleSoulText:SetFont(Dream_GameFont, 18);
TitleSoulText:SetPoint("CENTER");
TitleSoulText:SetVertexColor(160/255, 200/255, 160/255)
TitleSoulText:SetText("巅峰属性");

local SoulItemRightFrame = CreateFrame("Frame", "SoulItemRightFrame", SoulItemFuncFrame);
SoulItemRightFrame:SetSize(280, 480);
SoulItemRightFrame:SetPoint("RIGHT", -50, -88);

local InSoulItemFrame = CreateFrame("Frame", "InSoulItemFrame", SoulItemRightFrame);
InSoulItemFrame:SetSize(200, 400);
InSoulItemFrame:SetPoint("CENTER", 0, 30);
InSoulItemFrame:SetBackdrop({ bgFile = SoulPlayerIconFile });

for i=1,12 do
    SoulStatTypeStr[i] = SoulItemLeftFrame:CreateFontString("SoulStatTypeStr"..i);
	SoulStatTypeStr[i]:SetFont(Dream_GameFont, 12);
	SoulStatTypeStr[i]:SetSize(120, 30);
	SoulStatTypeStr[i]:SetPoint("TOPLEFT", -10, -70 + (-28 * i));
	SoulStatTypeStr[i]:SetText(SoulStatType[i][1]);

	SoulStatNowPointStr[i] = SoulItemLeftFrame:CreateFontString("SoulStatNowPointStr"..i);
	SoulStatNowPointStr[i]:SetFont(Dream_GameFont, 12);
	SoulStatNowPointStr[i]:SetSize(200, 30);
	SoulStatNowPointStr[i]:SetPoint("TOPLEFT", 50, -70 + (-28 * i));
	SoulStatNowPointStr[i]:SetVertexColor(255/255, 255/255, 0/255)
	SoulStatNowPointStr[i]:SetText(tostring(Dream_SoulStatPointData[i]));

	SoulStatClickRightButton[i] = CreateFrame("Button", "SoulStatClickRightButton"..i, SoulItemLeftFrame);
	SoulStatClickRightButton[i]:SetPoint("TOPLEFT", 220, -75 + (-28 * i));
    SoulStatClickRightButton[i]:SetSize(24, 24);
	SoulStatClickRightButton[i]:SetNormalTexture("Interface\\BUTTONS\\UI-PlusButton-Up")
    SoulStatClickRightButton[i]:SetHighlightTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Highlight")
    SoulStatClickRightButton[i]:SetPushedTexture("Interface\\BUTTONS\\UI-PlusButton-Disabled")
	SoulStatClickRightButton[i]:SetID(1);
	SoulStatClickRightButton[i]:SetScript("OnClick",
	function(self)
		local Dialog = StaticPopup_Show("PopStatIncrease", "\n|cFF00FFFF每点斗气可加|r |cFF00FF00"..self:GetID().."|r "..SoulStatType[i][1].."\n\n|cFFFF66FF正数表示加 负数表示减|r\n\n|cFF00FF00你确定要这么做吗?|r\n");
		Dialog.Try = SoulStatType[i][2];
	end)
end

--重置按钮
local SoulStatResetButton = CreateFrame("Button", "SoulStatResetButton", SoulItemLeftFrame);
SoulStatResetButton:SetSize(150, 24);
SoulStatResetButton:SetPoint("BOTTOM", 0, 15);
SoulStatResetButton:EnableMouse(true);
SoulStatResetButton:SetBackdrop({ bgFile = NormalBtnIcon })
SoulStatResetButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
SoulStatResetButton:SetScript("OnClick",
function(Self)
    Dream_SendData("StatPointDoReset");
end)

SoulItemLeftFrame:SetScript("OnHide",
function(self)
    StaticPopup_Hide("ResetStatPt");
end)

local SoulFontStringReset = SoulStatResetButton:CreateFontString("SoulFontStringReset");
SoulFontStringReset:SetFont(Dream_GameFont, 15);
SoulStatResetButton:SetFontString(SoulFontStringReset);
SoulStatResetButton:SetText("|cffFFC125重置点数|r");

for i=1,#SoulButtonIcons do
	SoulItemButtons[i] = CreateFrame("Button", "SoulItemButtons"..i, SoulItemRightFrame)
	SoulItemButtons[i]:SetSize(36, 36)
	SoulItemButtons[i]:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square");
	SoulItemButtons[i]:SetBackdrop({ bgFile = SoulButtonIcons[i] })

	SoulItemButtonTextures[i] = SoulItemButtons[i]:CreateTexture("SoulItemButtonTextures"..i);
	SoulItemButtonTextures[i]:SetSize(32, 32);
    SoulItemButtonTextures[i]:SetPoint("CENTER");
	SoulItemButtonTextures[i]:SetTexture("");

	SoulItemTypeStr[i] = SoulItemButtons[i]:CreateFontString("SoulItemTypeStr"..i);
	SoulItemTypeStr[i]:SetFont(Dream_GameFont, 15, "OUTLINE");
	SoulItemTypeStr[i]:SetText("|cFF00FF00"..SoulItemTypes[i].."|r");

	if (i < 9) then
		SoulItemButtons[i]:SetPoint("LEFT", 10, 200 - (i - 1) * 48);
		SoulItemTypeStr[i]:SetPoint("CENTER", SoulItemButtons[i], 30, 0);
	elseif (i < 17) then
		SoulItemButtons[i]:SetPoint("RIGHT", -10, 200 - (i - 9) * 48)
		SoulItemTypeStr[i]:SetPoint("CENTER", SoulItemButtons[i], -30, 0);
	else
		SoulItemButtons[i]:SetPoint("BOTTOMLEFT", (i - 17) * 60 + 120, 36)
		SoulItemTypeStr[i]:SetPoint("CENTER", SoulItemButtons[i], 0, -30);
	end

	SoulItemButtons[i].ItemGuid = 0;
	SoulItemButtons[i].ItemLink = "item:0";

	SoulItemButtons[i]:RegisterForClicks("AnyDown");
	--拖入处理
	SoulItemButtons[i]:SetScript("OnClick",
	function(self, BtnType)
		if (BtnType == "LeftButton") then
			local IType, _, ItemLink = GetCursorInfo();
			if (IType ~= "item") then
				return;
			end
			local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
			local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
			Dream_SendData("InItemSoulQuery", tostring(GuidLow).."#"..i);
			ClearCursor();
		elseif (BtnType == "RightButton") then
			if (self.ItemGuid ~= 0) then
				local Dialog = StaticPopup_Show("TaskItemSoulNow");
				Dialog.NumStr = i;
			end
		end
	end)

	SoulItemButtons[i]:SetScript("OnEnter",
	function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		Dream_SetTooltipHyperlink(GameTooltip, self.ItemLink);
		GameTooltip:Show();
	end)
	SoulItemButtons[i]:SetScript("OnLeave",
	function(self)
		GameTooltip:Hide();
	end)
end

local function ClearSoulItemButton(num)
    local button = SoulItemButtons[num]
    local texture = SoulItemButtonTextures[num]
    if not button or not texture then
        return
    end

    if button.ItemGuid and button.ItemGuid > 0 then
        SoulItemTooltipSyncCache[button.ItemGuid] = nil
    end
    button.ItemGuid = 0
    button.ItemLink = "item:0"
    texture:SetTexture("")
end

local function ApplySoulItemIcon(itemId, icon)
    for num = 1, #SoulItemButtons do
        local button = SoulItemButtons[num]
        local texture = SoulItemButtonTextures[num]
        if button and texture and GetItemIdByLink(button.ItemLink) == itemId then
            texture:SetTexture(icon)
        end
    end
end

local function RequestSoulItemIcon(itemId)
    local retry = SoulItemIconRetryEntries[itemId]
    if not retry then
        return
    end

    local icon = nil
	-- SoulItem buttons are custom frames, so the native bag/equipment UI
	-- does not request their item template for us. Allow one throttled client
	-- cache request for this icon only; keep the shared read-only helper intact.
	if Dream_GetItemInfoOnceWithRequest then
		local _, _, _, _, _, _, _, _, _, Icon = Dream_GetItemInfoOnceWithRequest(itemId, true)
		icon = Icon
	elseif DreamGetItemIcon then
		icon = DreamGetItemIcon(itemId)
	end

    if icon and icon ~= "" then
        SoulItemIconCache[itemId] = icon
        SoulItemIconRetryEntries[itemId] = nil
        ApplySoulItemIcon(itemId, icon)
        return
    end

    retry = retry - 1
    if retry <= 0 then
        SoulItemIconRetryEntries[itemId] = nil
    else
        SoulItemIconRetryEntries[itemId] = retry
    end
end

if CreateFrame then
    local SoulItemInfoEventFrame = CreateFrame("Frame", "SoulItemInfoEventFrame")
    SoulItemInfoEventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    SoulItemInfoEventFrame:SetScript("OnEvent", function(_, _, itemId)
        itemId = tonumber(itemId) or 0
        if itemId > 0 and SoulItemIconRetryEntries[itemId] then
            RequestSoulItemIcon(itemId)
        end
    end)
end

local function HasSoulItemTooltipPayload(itemGuid, itemId)
    if not itemGuid or itemGuid <= 0 or not itemId or itemId <= 0 then
        return false
    end

    local cacheId = Zs_GuidLowStoreData and Zs_GuidLowStoreData.CacheIdData and tonumber(Zs_GuidLowStoreData.CacheIdData[itemGuid])
    return cacheId == itemId and IsShowGuidLowData and IsShowGuidLowData(itemGuid, itemId) and true or false
end

local function RequestSoulItemTooltipData(num, force)
    local button = SoulItemButtons[num]
    if not button or not button.ItemGuid or button.ItemGuid <= 0 then
        return
    end

    local itemId = GetItemIdByLink(button.ItemLink)
    if not itemId or itemId <= 0 then
        return
    end

    local hasGuidPayload = HasSoulItemTooltipPayload(button.ItemGuid, itemId)
    local now = (GetTime and GetTime()) or 0
    local lastSync = SoulItemTooltipSyncCache[button.ItemGuid]
    local forceGuidRequest = not hasGuidPayload and (force or not lastSync or (now - lastSync) >= SOUL_ITEM_ICON_RETRY_INTERVAL)
    if forceGuidRequest then
        SoulItemTooltipSyncCache[button.ItemGuid] = now
    end

    if Dream_RequestItemTooltipStoreDataNow then
        Dream_RequestItemTooltipStoreDataNow(button.ItemLink, 254, num, button.ItemGuid, forceGuidRequest)
    elseif Dream_QueueItemTooltipStoreRequest then
        Dream_QueueItemTooltipStoreRequest(button.ItemLink, 254, num, button.ItemGuid, forceGuidRequest)
    end
end

local function SetSoulItemButtonData(num, itemGuid, itemLink)
    local button = SoulItemButtons[num]
    if not button then
        return
    end

    button.ItemGuid = itemGuid or 0
    button.ItemLink = BuildSoulItemTooltipLink(itemLink or "item:0", button.ItemGuid)
    RequestSoulItemTooltipData(num, false)
    local itemId = GetItemIdByLink(button.ItemLink)
    if not itemId or itemId <= 0 then
        SoulItemButtonTextures[num]:SetTexture("")
        return
    end

    local icon = SoulItemIconCache[itemId]
    if icon then
        SoulItemButtonTextures[num]:SetTexture(icon)
    else
        SoulItemButtonTextures[num]:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        if not SoulItemIconRetryEntries[itemId] then
            SoulItemIconRetryEntries[itemId] = SOUL_ITEM_ICON_RETRY_ATTEMPTS
            RequestSoulItemIcon(itemId)
        end
    end
end

local function RefreshSoulItemClientData()
    Dream_SendData("GetMeSoulItemData")
    for num = 1, #SoulItemButtons do
        RequestSoulItemTooltipData(num, false)
    end
end

if SoulItemFuncFrame and SoulItemFuncFrame.HookScript then
    SoulItemFuncFrame:HookScript("OnShow", RefreshSoulItemClientData)
end

local function ProcessSoulItemClientRetries(elapsed)
    if SoulItemLoginSyncElapsed then
        SoulItemLoginSyncElapsed = SoulItemLoginSyncElapsed + elapsed
        local syncDelay = SOUL_ITEM_LOGIN_SYNC_DELAYS[SoulItemLoginSyncIndex]
        if syncDelay and SoulItemLoginSyncElapsed >= syncDelay then
            Dream_SendData("GetMeSoulItemData")
            SoulItemLoginSyncIndex = SoulItemLoginSyncIndex + 1
        elseif not syncDelay then
            SoulItemLoginSyncElapsed = nil
        end
    end

    SoulItemIconRetryElapsed = SoulItemIconRetryElapsed + elapsed
    if SoulItemIconRetryElapsed < SOUL_ITEM_ICON_RETRY_INTERVAL then
        return
    end
    SoulItemIconRetryElapsed = 0

    for itemId in pairs(SoulItemIconRetryEntries) do
        RequestSoulItemIcon(itemId)
    end
end

--消息处理
local function Dream_OnSoulItemAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "MeStatPointData") then
			local Args = Dream_Split(Msg, "#");
			SoulNextCount = tonumber(Args[1]);
			SoulNeedXp = tonumber(Args[2]);
			SoulMeRank = tonumber(Args[3]);
			SoulMeXp = tonumber(Args[4]);
			SoulNowPoint = tonumber(Args[5]);

			for i=6,#Args do
				Dream_SoulStatPointData[i - 5] = tonumber(Args[i])
				SoulStatNowPointStr[i - 5]:SetText(Args[i]);
			end

			TopSoulText:SetText(string.format("巅峰等级 [ %u ] 可用点数 [ %u ]", SoulMeRank, SoulNowPoint));
			local Sce = (SoulNeedXp > 0) and (SoulMeXp * 100 / SoulNeedXp) or 0;
			SoulButtonBarTexts:SetText("|cFF00FF00当前经验"..SoulMeXp.."/"..SoulNeedXp.." 进度 "..string.format("%.f", Sce).."% 下一级获得点数 "..SoulNextCount.."|r")
            AtSoulStatusBarOne:SetValue(math.floor(Sce))
		elseif (Packet == "ResetStatPtInfo") then
			StaticPopup_Show("ResetStatPt", "\n|cFF00FF00重置斗气|r\n\n"..Msg.."\n|r\n|cFF00FF00你确定要这么做吗?|r");
		elseif (Packet == "StatPointConfigData") then
			local Args = Dream_Split(Msg, "#");
			for i=1,#Args do
				SoulStatClickRightButton[i]:SetID(tonumber(Args[i]));
			end
		elseif (Packet == "NoItemSoul") then
			local Num = tonumber(Msg);
			ClearSoulItemButton(Num)
		elseif (Packet == "LoginAutoSoulItemData") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local ItemGuid = tonumber(Args[2]);
			local ItemLink = Args[3];
			SetSoulItemButtonData(Num, ItemGuid, ItemLink)
		elseif (Packet == "AutoSoulItemData") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local ItemGuid = tonumber(Args[2]);
			local ItemLink = Args[3];
			SetSoulItemButtonData(Num, ItemGuid, ItemLink)
			NowShowTips(SoulItemButtons[Num], SoulItemButtons[Num].ItemLink);
		elseif (Packet == "NeedInfoItemSoul") then
			local Args = Dream_Split(Msg, "#");
			local ItemGuid = Args[1];
			local Num = Args[2];
			local Gts = Args[3];
			local Dialog = StaticPopup_Show("ItemSoulStartNow", Gts);
            Dialog.GuidLowStr = ItemGuid;
			Dialog.NumStr = Num;
		elseif (Packet == "TaskSoulItemNull") then
			local Num = tonumber(Msg);
			ClearSoulItemButton(Num)
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("GetMeStatPointData");
		Dream_SendData("GetStatPointConfigData");
		Dream_SendData("GetMeSoulItemData");
		SoulItemLoginSyncElapsed = 0
		SoulItemLoginSyncIndex = 1
	elseif (event == "PLAYER_ENTERING_WORLD") then
		RefreshSoulItemClientData()
	end
end

--交互消息事件
local SoulItemAddonFrame = CreateFrame("Frame", "SoulItemAddonFrame");
SoulItemAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
SoulItemAddonFrame:RegisterEvent("PLAYER_LOGIN");
SoulItemAddonFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
SoulItemAddonFrame:SetScript("OnEvent", Dream_OnSoulItemAddonEvent);
SoulItemAddonFrame:SetScript("OnUpdate", function(self, elapsed)
	ProcessSoulItemClientRetries(elapsed)
end)

--------------------------------------------------------------------



