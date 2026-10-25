
--静态弹出框
StaticPopupDialogs["DoItemEnchTaskInfo"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
        Dream_SendData("DoItemEnchTaskInfo", tostring(Self.EnchNum));
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

local ItemEnchFrame = CreateFrame("Frame", "ItemEnchFrame", UIParent);
ItemEnchFrame:SetSize(720, 480);
ItemEnchFrame:SetPoint("CENTER");
ItemEnchFrame:SetToplevel(true);
ItemEnchFrame:SetClampedToScreen(true);
ItemEnchFrame:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
});

tinsert(UISpecialFrames, "ItemEnchFrame");
ItemEnchFrame:Hide();

ItemEnchFrame.Buttons = {};
ItemEnchFrame.NeedGts = "";

-- 关闭按钮
local ItemEnchFrameButtonClose = CreateFrame("Button", "ItemEnchFrameButtonClose", ItemEnchFrame, "UIPanelCloseButton");
ItemEnchFrameButtonClose:SetPoint("TOPRIGHT", 5, 5);
ItemEnchFrameButtonClose:EnableMouse(true);
ItemEnchFrameButtonClose:SetSize(30, 30);

--标题模块
local ItemEnchFrameTitleBar = CreateFrame("Frame", "ItemEnchFrameTitleBar", ItemEnchFrame);
ItemEnchFrameTitleBar:SetSize(200, 30);
ItemEnchFrameTitleBar:SetPoint("TOP", 0, 24);
ItemEnchFrameTitleBar:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

--标题模块文字描述
local ItemEnchFrameTitleBarText = ItemEnchFrameTitleBar:CreateFontString("ItemEnchFrameTitleBarText");
ItemEnchFrameTitleBarText:SetFont(Dream_GameFont, 15);
ItemEnchFrameTitleBarText:SetPoint("CENTER");
ItemEnchFrameTitleBarText:SetText("|cffFFC125附魔提取|转移|r");

local ItemEnchFrameTopGtsText = ItemEnchFrame:CreateFontString("ItemEnchFrameTopGtsText");
ItemEnchFrameTopGtsText:SetFont(Dream_GameFont, 15);
ItemEnchFrameTopGtsText:SetPoint("TOP", 0, -10);
ItemEnchFrameTopGtsText:SetText("|cFF00FF00将被提取的装备拖入左边 提取到的目标装备拖入右边\n根据附魔信息点击中间按钮转移到右边即可 注意目标装备如果有同位置的附魔将会被覆盖|r");

ItemEnchFrameButton1 = CreateFrame("Button", "ItemEnchFrameButton1", ItemEnchFrame);
ItemEnchFrameButton1:SetSize(80, 80);
ItemEnchFrameButton1:EnableMouse(true);
ItemEnchFrameButton1:RegisterForDrag("LeftButton");
ItemEnchFrameButton1:SetPoint("TOPLEFT", 125, -60);
ItemEnchFrameButton1:SetBackdrop({bgFile = "Interface\\Buttons\\UI-EmptySlot-White"});
ItemEnchFrameButton1.GuidLow = 0;
ItemEnchFrameButton1.ItemLink = "item:0";
ItemEnchFrameButton1.ItemId = 0;
ItemEnchFrameButton1.FontString = ItemEnchFrameButton1:CreateFontString("$parentFontString");
ItemEnchFrameButton1.FontString:SetSize(ItemEnchFrameButton1:GetWidth(), ItemEnchFrameButton1:GetHeight());
ItemEnchFrameButton1.FontString:SetFont(Dream_GameFont, 12);
ItemEnchFrameButton1.FontString:SetAllPoints(ItemEnchFrameButton1);
ItemEnchFrameButton1:SetFontString(ItemEnchFrameButton1.FontString);
ItemEnchFrameButton1:SetText("");
ItemEnchFrameButton1:SetScript("OnEnter",
function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	Dream_SetTooltipHyperlink(GameTooltip, self.ItemLink);
	GameTooltip:Show();
end)

ItemEnchFrameButton1:SetScript("OnLeave",
function(self)
	GameTooltip:Hide();
end)
ItemEnchFrameButton1:SetScript("OnClick",
function(self)
    local IType, ItemId, ItemLink = GetCursorInfo()
    if (IType ~= "item") then
		return
    end

	for i=1,5 do
		ItemEnchInfoFrame1.FontString[i]:SetText("");
		ItemEnchInfoFrame1.SubFrame[i].EnchId = 0;
	end
	local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
	local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
	self.ItemLink = ItemLink;
	Dream_SendData("ItemEnchTaskCheck1", tostring(GuidLow));
	ClearCursor();
end)

ItemEnchFrameButton2 = CreateFrame("Button", "ItemEnchFrameButton2", ItemEnchFrame);
ItemEnchFrameButton2:SetSize(80, 80);
ItemEnchFrameButton2:EnableMouse(true);
ItemEnchFrameButton2:RegisterForDrag("LeftButton");
ItemEnchFrameButton2:SetPoint("TOPRIGHT", -125, -60);
ItemEnchFrameButton2:SetBackdrop({bgFile = "Interface\\Buttons\\UI-EmptySlot-White"});
ItemEnchFrameButton2.GuidLow = 0;
ItemEnchFrameButton2.ItemLink = "item:0";
ItemEnchFrameButton2.ItemId = 0;
ItemEnchFrameButton2.FontString = ItemEnchFrameButton2:CreateFontString("$parentFontString");
ItemEnchFrameButton2.FontString:SetSize(ItemEnchFrameButton2:GetWidth(), ItemEnchFrameButton2:GetHeight());
ItemEnchFrameButton2.FontString:SetFont(Dream_GameFont, 12);
ItemEnchFrameButton2.FontString:SetAllPoints(ItemEnchFrameButton2);
ItemEnchFrameButton2:SetFontString(ItemEnchFrameButton2.FontString);
ItemEnchFrameButton2:SetText("");
ItemEnchFrameButton2:SetScript("OnEnter",
function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	Dream_SetTooltipHyperlink(GameTooltip, self.ItemLink);
	GameTooltip:Show();
end)

ItemEnchFrameButton2:SetScript("OnLeave",
function(self)
	GameTooltip:Hide();
end)
ItemEnchFrameButton2:SetScript("OnClick",
function(self)
    local IType, ItemId, ItemLink = GetCursorInfo()
    if (IType ~= "item") then
		return
    end

	for i=1,5 do
		ItemEnchInfoFrame2.FontString[i]:SetText("");
		ItemEnchInfoFrame2.SubFrame[i].EnchId = 0;
	end
	local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
	local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
	self.ItemLink = ItemLink;
	Dream_SendData("ItemEnchTaskCheck2", tostring(GuidLow));
	ClearCursor();
end)

local ItemEnchInfoFrame1 = CreateFrame("Frame", "ItemEnchInfoFrame1", ItemEnchFrame);
ItemEnchInfoFrame1:SetSize(300, 320);
ItemEnchInfoFrame1:SetPoint("LEFT", 20, -60);
ItemEnchInfoFrame1:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
});
ItemEnchInfoFrame1.SubFrame = {};
ItemEnchInfoFrame1.FontString = {};

local ItemEnchInfoFrame2 = CreateFrame("Frame", "ItemEnchInfoFrame2", ItemEnchFrame);
ItemEnchInfoFrame2:SetSize(300, 320);
ItemEnchInfoFrame2:SetPoint("RIGHT", -20, -60);
ItemEnchInfoFrame2:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
});
ItemEnchInfoFrame2.SubFrame = {};
ItemEnchInfoFrame2.FontString = {};

for i=1,5 do
	ItemEnchInfoFrame1.SubFrame[i] = CreateFrame("Frame", "$parentSubFrame"..i, ItemEnchInfoFrame1);
	ItemEnchInfoFrame1.SubFrame[i]:SetSize(300, 50);
	ItemEnchInfoFrame1.SubFrame[i]:SetPoint("TOP", 0, -((i - 1) * 60 + 16));

	ItemEnchInfoFrame1.FontString[i] = ItemEnchInfoFrame1.SubFrame[i]:CreateFontString("$parentFontString"..i);
    ItemEnchInfoFrame1.FontString[i]:SetFont(Dream_GameFont, 15);
    ItemEnchInfoFrame1.FontString[i]:SetPoint("CENTER");
	ItemEnchInfoFrame1.FontString[i]:SetSize(ItemEnchInfoFrame1.SubFrame[i]:GetWidth(), ItemEnchInfoFrame1.SubFrame[i]:GetHeight());
    ItemEnchInfoFrame1.FontString[i]:SetText("");

	ItemEnchInfoFrame2.SubFrame[i] = CreateFrame("Frame", "$parentSubFrame"..i, ItemEnchInfoFrame2);
	ItemEnchInfoFrame2.SubFrame[i]:SetSize(300, 50);
	ItemEnchInfoFrame2.SubFrame[i]:SetPoint("TOP", 0, -((i - 1) * 60 + 16));

	ItemEnchInfoFrame2.FontString[i] = ItemEnchInfoFrame2.SubFrame[i]:CreateFontString("$parentFontString"..i);
    ItemEnchInfoFrame2.FontString[i]:SetFont(Dream_GameFont, 15);
    ItemEnchInfoFrame2.FontString[i]:SetPoint("CENTER");
	ItemEnchInfoFrame2.FontString[i]:SetSize(ItemEnchInfoFrame2.SubFrame[i]:GetWidth(), ItemEnchInfoFrame2.SubFrame[i]:GetHeight());
    ItemEnchInfoFrame2.FontString[i]:SetText("");

	ItemEnchFrame.Buttons[i] = CreateFrame("Button", "$parentButtons"..i, ItemEnchFrame, "UIPanelButtonTemplate");
	ItemEnchFrame.Buttons[i]:SetSize(80, 24);
	ItemEnchFrame.Buttons[i]:EnableMouse(true);
	ItemEnchFrame.Buttons[i]:RegisterForDrag("LeftButton");
	ItemEnchFrame.Buttons[i]:SetPoint("CENTER", 0, -((i - 1) * 60 - 56));
	ItemEnchFrame.Buttons[i]:SetID(i + 6);
	ItemEnchFrame.Buttons[i].FontString = ItemEnchFrame.Buttons[i]:CreateFontString("$parentFontString");
    ItemEnchFrame.Buttons[i].FontString:SetSize(ItemEnchFrame.Buttons[i]:GetWidth(), ItemEnchFrame.Buttons[i]:GetHeight());
    ItemEnchFrame.Buttons[i].FontString:SetFont(Dream_GameFont, 12);
    ItemEnchFrame.Buttons[i].FontString:SetAllPoints(ItemEnchFrame.Buttons[i]);
    ItemEnchFrame.Buttons[i]:SetFontString(ItemEnchFrame.Buttons[i].FontString);
    ItemEnchFrame.Buttons[i]:SetText("提取|转移->");

	ItemEnchFrame.Buttons[i]:SetScript("OnClick",
    function(self)
		if (ItemEnchInfoFrame1.SubFrame[i].EnchId == 0) then
			return;
		end
		local Dialog = StaticPopup_Show("DoItemEnchTaskInfo", "\n"..ItemEnchFrame.NeedGts.."\n你确定要这么做吗?");
		if (Dialog) then
			Dialog.EnchNum = self:GetID();
		end
    end)

	ItemEnchInfoFrame1.SubFrame[i].EnchId = 0;
	ItemEnchInfoFrame2.SubFrame[i].EnchId = 0;
end

function ResetItemEnchUIData()
	ItemEnchFrameButton1.GuidLow = 0;
	ItemEnchFrameButton1.ItemLink = "item:0";
	ItemEnchFrameButton1.ItemId = 0;
	ItemEnchFrameButton1:SetText("");

	ItemEnchFrameButton2.GuidLow = 0;
	ItemEnchFrameButton2.ItemLink = "item:0";
	ItemEnchFrameButton2.ItemId = 0;
	ItemEnchFrameButton2:SetText("");

	for i=1,5 do
		ItemEnchInfoFrame1.FontString[i]:SetText("");
		ItemEnchInfoFrame2.FontString[i]:SetText("");
		ItemEnchInfoFrame1.SubFrame[i].EnchId = 0;
		ItemEnchInfoFrame2.SubFrame[i].EnchId = 0;
	end

	ItemEnchFrame.NeedGts = "";
	Dream_SendData("ItemEnchInitNow");
end

local ItemEnchFrameResetButton = CreateFrame("Button", "ItemEnchFrameResetButton", ItemEnchFrame, "UIPanelButtonTemplate");
ItemEnchFrameResetButton:SetSize(100, 30);
ItemEnchFrameResetButton:EnableMouse(true);
ItemEnchFrameResetButton:RegisterForDrag("LeftButton");
ItemEnchFrameResetButton:SetPoint("TOP", 0, -80);

ItemEnchFrameResetButton.FontString = ItemEnchFrameResetButton:CreateFontString("$parentFontString");
ItemEnchFrameResetButton.FontString:SetSize(ItemEnchFrameResetButton:GetWidth(), ItemEnchFrameResetButton:GetHeight());
ItemEnchFrameResetButton.FontString:SetFont(Dream_GameFont, 12);
ItemEnchFrameResetButton.FontString:SetAllPoints(ItemEnchFrameResetButton);
ItemEnchFrameResetButton:SetFontString(ItemEnchFrameResetButton.FontString);
ItemEnchFrameResetButton:SetText("重置界面");

ItemEnchFrameResetButton:SetScript("OnClick",
function(self)
	ResetItemEnchUIData();
end)

ItemEnchFrame:SetScript("OnShow",
function(self)
	ResetItemEnchUIData();
end)

--消息处理
local function Dream_OnItemEnchAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "NoFuncItemEnch1") then
			ItemEnchFrameButton1.GuidLow = 0;
			ItemEnchFrameButton1.ItemLink = "item:0";
			ItemEnchFrameButton1.ItemId = 0;
			ItemEnchFrameButton1:SetText("");
			ItemEnchFrame.NeedGts = "";
		elseif (Packet == "YesEnchTaskCheck1") then
			local Args = Dream_Split(Msg, "#");
			local GuidLow = tonumber(Args[1]);
			local ItemId = tonumber(Args[2]);
			local Gts = Args[3];
			ItemEnchFrameButton1.GuidLow = GuidLow;
			ItemEnchFrameButton1.ItemId = ItemId;
			ItemEnchFrameButton1:SetText("|T"..DreamGetItemIcon(tonumber(ItemId))..":64|t");
			NowShowTips(ItemEnchFrameButton1, ItemEnchFrameButton1.ItemLink);
			ItemEnchFrame.NeedGts = Gts;
		elseif (Packet == "ShowEnchInfo1") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local EnchId = tonumber(Args[2]);
			local EnchStr = Args[3];
			ItemEnchInfoFrame1.SubFrame[Num].EnchId = EnchId;
			ItemEnchInfoFrame1.FontString[Num]:SetText(EnchStr);
		elseif (Packet == "NoFuncItemEnch2") then
			ItemEnchFrameButton2.GuidLow = 0;
			ItemEnchFrameButton2.ItemLink = "item:0";
			ItemEnchFrameButton2.ItemId = 0;
			ItemEnchFrameButton2:SetText("");
			ItemEnchFrame.NeedGts = "";
		elseif (Packet == "YesEnchTaskCheck2") then
			local Args = Dream_Split(Msg, "#");
			local GuidLow = tonumber(Args[1]);
			local ItemId = tonumber(Args[2]);
			ItemEnchFrameButton2.GuidLow = GuidLow;
			ItemEnchFrameButton2.ItemId = ItemId;
			ItemEnchFrameButton2:SetText("|T"..DreamGetItemIcon(tonumber(ItemId))..":64|t");
			NowShowTips(ItemEnchFrameButton2, ItemEnchFrameButton2.ItemLink);
		elseif (Packet == "ShowEnchInfo2") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local EnchId = tonumber(Args[2]);
			local EnchStr = Args[3];
			ItemEnchInfoFrame2.SubFrame[Num].EnchId = EnchId;
			ItemEnchInfoFrame2.FontString[Num]:SetText(EnchStr);
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("ItemEnchInitNow");
	end
end

--交互消息事件
local ItemEnchAddonFrame = CreateFrame("Frame", "ItemEnchAddonFrame");
ItemEnchAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
ItemEnchAddonFrame:RegisterEvent("PLAYER_LOGIN");
ItemEnchAddonFrame:SetScript("OnEvent", Dream_OnItemEnchAddonEvent);

--------------------------------------------------------------------



