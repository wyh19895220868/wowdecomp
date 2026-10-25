
--静态弹出框
StaticPopupDialogs["NewYesDoItemEnchTask"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
        Dream_SendData("NewYesDoItemEnchTask", tostring(Self.EnchNum));
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

local NewItemEnchFrame = CreateFrame("Frame", "NewItemEnchFrame", UIParent);
NewItemEnchFrame:SetSize(720, 480);
NewItemEnchFrame:SetPoint("CENTER");
NewItemEnchFrame:SetToplevel(true);
NewItemEnchFrame:SetClampedToScreen(true);
NewItemEnchFrame:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
});

tinsert(UISpecialFrames, "NewItemEnchFrame");
NewItemEnchFrame:Hide();

NewItemEnchFrame.Buttons = {};

-- 关闭按钮
local NewItemEnchFrameButtonClose = CreateFrame("Button", "NewItemEnchFrameButtonClose", NewItemEnchFrame, "UIPanelCloseButton");
NewItemEnchFrameButtonClose:SetPoint("TOPRIGHT", 5, 5);
NewItemEnchFrameButtonClose:EnableMouse(true);
NewItemEnchFrameButtonClose:SetSize(30, 30);

--标题模块
local NewItemEnchFrameTitleBar = CreateFrame("Frame", "NewItemEnchFrameTitleBar", NewItemEnchFrame);
NewItemEnchFrameTitleBar:SetSize(200, 30);
NewItemEnchFrameTitleBar:SetPoint("TOP", 0, 24);
NewItemEnchFrameTitleBar:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

--标题模块文字描述
local NewItemEnchFrameTitleBarText = NewItemEnchFrameTitleBar:CreateFontString("NewItemEnchFrameTitleBarText");
NewItemEnchFrameTitleBarText:SetFont(Dream_GameFont, 15);
NewItemEnchFrameTitleBarText:SetPoint("CENTER");
NewItemEnchFrameTitleBarText:SetText("|cffFFC125附魔提取|转移|r");

local NewItemEnchFrameTopGtsText = NewItemEnchFrame:CreateFontString("NewItemEnchFrameTopGtsText");
NewItemEnchFrameTopGtsText:SetFont(Dream_GameFont, 15);
NewItemEnchFrameTopGtsText:SetPoint("TOP", 0, -10);
NewItemEnchFrameTopGtsText:SetText("|cFF00FF00将被提取的装备拖入左边 提取到的目标装备拖入右边\n根据附魔信息点击中间按钮转移到右边即可 注意目标装备如果有同位置的附魔将会被覆盖|r");

NewItemEnchFrameButton1 = CreateFrame("Button", "NewItemEnchFrameButton1", NewItemEnchFrame);
NewItemEnchFrameButton1:SetSize(80, 80);
NewItemEnchFrameButton1:EnableMouse(true);
NewItemEnchFrameButton1:RegisterForDrag("LeftButton");
NewItemEnchFrameButton1:SetPoint("TOPLEFT", 125, -60);
NewItemEnchFrameButton1:SetBackdrop({bgFile = "Interface\\Buttons\\UI-EmptySlot-White"});
NewItemEnchFrameButton1.GuidLow = 0;
NewItemEnchFrameButton1.ItemLink = "item:0";
NewItemEnchFrameButton1.ItemId = 0;
NewItemEnchFrameButton1.FontString = NewItemEnchFrameButton1:CreateFontString("$parentFontString");
NewItemEnchFrameButton1.FontString:SetSize(NewItemEnchFrameButton1:GetWidth(), NewItemEnchFrameButton1:GetHeight());
NewItemEnchFrameButton1.FontString:SetFont(Dream_GameFont, 12);
NewItemEnchFrameButton1.FontString:SetAllPoints(NewItemEnchFrameButton1);
NewItemEnchFrameButton1:SetFontString(NewItemEnchFrameButton1.FontString);
NewItemEnchFrameButton1:SetText("");
NewItemEnchFrameButton1:SetScript("OnEnter",
function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	Dream_SetTooltipHyperlink(GameTooltip, self.ItemLink);
	GameTooltip:Show();
end)

NewItemEnchFrameButton1:SetScript("OnLeave",
function(self)
	GameTooltip:Hide();
end)
NewItemEnchFrameButton1:SetScript("OnClick",
function(self)
    local IType, ItemId, ItemLink = GetCursorInfo()
    if (IType ~= "item") then
		return
    end

	for i=1,5 do
		NewItemEnchInfoFrame1.FontString[i]:SetText("");
		NewItemEnchInfoFrame1.SubFrame[i].EnchId = 0;
	end
	local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
	local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
	self.ItemLink = ItemLink;
	Dream_SendData("NewItemEnchTaskCheck1", tostring(GuidLow));
	ClearCursor();
end)

NewItemEnchFrameButton2 = CreateFrame("Button", "NewItemEnchFrameButton2", NewItemEnchFrame);
NewItemEnchFrameButton2:SetSize(80, 80);
NewItemEnchFrameButton2:EnableMouse(true);
NewItemEnchFrameButton2:RegisterForDrag("LeftButton");
NewItemEnchFrameButton2:SetPoint("TOPRIGHT", -125, -60);
NewItemEnchFrameButton2:SetBackdrop({bgFile = "Interface\\Buttons\\UI-EmptySlot-White"});
NewItemEnchFrameButton2.GuidLow = 0;
NewItemEnchFrameButton2.ItemLink = "item:0";
NewItemEnchFrameButton2.ItemId = 0;
NewItemEnchFrameButton2.FontString = NewItemEnchFrameButton2:CreateFontString("$parentFontString");
NewItemEnchFrameButton2.FontString:SetSize(NewItemEnchFrameButton2:GetWidth(), NewItemEnchFrameButton2:GetHeight());
NewItemEnchFrameButton2.FontString:SetFont(Dream_GameFont, 12);
NewItemEnchFrameButton2.FontString:SetAllPoints(NewItemEnchFrameButton2);
NewItemEnchFrameButton2:SetFontString(NewItemEnchFrameButton2.FontString);
NewItemEnchFrameButton2:SetText("");
NewItemEnchFrameButton2:SetScript("OnEnter",
function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	Dream_SetTooltipHyperlink(GameTooltip, self.ItemLink);
	GameTooltip:Show();
end)

NewItemEnchFrameButton2:SetScript("OnLeave",
function(self)
	GameTooltip:Hide();
end)
NewItemEnchFrameButton2:SetScript("OnClick",
function(self)
    local IType, ItemId, ItemLink = GetCursorInfo()
    if (IType ~= "item") then
		return
    end

	for i=1,5 do
		NewItemEnchInfoFrame2.FontString[i]:SetText("");
		NewItemEnchInfoFrame2.SubFrame[i].EnchId = 0;
	end
	local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
	local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
	self.ItemLink = ItemLink;
	Dream_SendData("NewItemEnchTaskCheck2", tostring(GuidLow));
	ClearCursor();
end)

local NewItemEnchInfoFrame1 = CreateFrame("Frame", "NewItemEnchInfoFrame1", NewItemEnchFrame);
NewItemEnchInfoFrame1:SetSize(300, 320);
NewItemEnchInfoFrame1:SetPoint("LEFT", 20, -60);
NewItemEnchInfoFrame1:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
});
NewItemEnchInfoFrame1.SubFrame = {};
NewItemEnchInfoFrame1.FontString = {};

local NewItemEnchInfoFrame2 = CreateFrame("Frame", "NewItemEnchInfoFrame2", NewItemEnchFrame);
NewItemEnchInfoFrame2:SetSize(300, 320);
NewItemEnchInfoFrame2:SetPoint("RIGHT", -20, -60);
NewItemEnchInfoFrame2:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
});
NewItemEnchInfoFrame2.SubFrame = {};
NewItemEnchInfoFrame2.FontString = {};

for i=1,5 do
	NewItemEnchInfoFrame1.SubFrame[i] = CreateFrame("Frame", "$parentSubFrame"..i, NewItemEnchInfoFrame1);
	NewItemEnchInfoFrame1.SubFrame[i]:SetSize(300, 50);
	NewItemEnchInfoFrame1.SubFrame[i]:SetPoint("TOP", 0, -((i - 1) * 60 + 16));

	NewItemEnchInfoFrame1.FontString[i] = NewItemEnchInfoFrame1.SubFrame[i]:CreateFontString("$parentFontString"..i);
    NewItemEnchInfoFrame1.FontString[i]:SetFont(Dream_GameFont, 15);
    NewItemEnchInfoFrame1.FontString[i]:SetPoint("CENTER");
	NewItemEnchInfoFrame1.FontString[i]:SetSize(NewItemEnchInfoFrame1.SubFrame[i]:GetWidth(), NewItemEnchInfoFrame1.SubFrame[i]:GetHeight());
    NewItemEnchInfoFrame1.FontString[i]:SetText("");

	NewItemEnchInfoFrame2.SubFrame[i] = CreateFrame("Frame", "$parentSubFrame"..i, NewItemEnchInfoFrame2);
	NewItemEnchInfoFrame2.SubFrame[i]:SetSize(300, 50);
	NewItemEnchInfoFrame2.SubFrame[i]:SetPoint("TOP", 0, -((i - 1) * 60 + 16));

	NewItemEnchInfoFrame2.FontString[i] = NewItemEnchInfoFrame2.SubFrame[i]:CreateFontString("$parentFontString"..i);
    NewItemEnchInfoFrame2.FontString[i]:SetFont(Dream_GameFont, 15);
    NewItemEnchInfoFrame2.FontString[i]:SetPoint("CENTER");
	NewItemEnchInfoFrame2.FontString[i]:SetSize(NewItemEnchInfoFrame2.SubFrame[i]:GetWidth(), NewItemEnchInfoFrame2.SubFrame[i]:GetHeight());
    NewItemEnchInfoFrame2.FontString[i]:SetText("");

	NewItemEnchFrame.Buttons[i] = CreateFrame("Button", "$parentButtons"..i, NewItemEnchFrame, "UIPanelButtonTemplate");
	NewItemEnchFrame.Buttons[i]:SetSize(80, 24);
	NewItemEnchFrame.Buttons[i]:EnableMouse(true);
	NewItemEnchFrame.Buttons[i]:RegisterForDrag("LeftButton");
	NewItemEnchFrame.Buttons[i]:SetPoint("CENTER", 0, -((i - 1) * 60 - 56));
	NewItemEnchFrame.Buttons[i]:SetID(i);
	NewItemEnchFrame.Buttons[i].FontString = NewItemEnchFrame.Buttons[i]:CreateFontString("$parentFontString");
    NewItemEnchFrame.Buttons[i].FontString:SetSize(NewItemEnchFrame.Buttons[i]:GetWidth(), NewItemEnchFrame.Buttons[i]:GetHeight());
    NewItemEnchFrame.Buttons[i].FontString:SetFont(Dream_GameFont, 12);
    NewItemEnchFrame.Buttons[i].FontString:SetAllPoints(NewItemEnchFrame.Buttons[i]);
    NewItemEnchFrame.Buttons[i]:SetFontString(NewItemEnchFrame.Buttons[i].FontString);
    NewItemEnchFrame.Buttons[i]:SetText("提取|转移->");

	NewItemEnchFrame.Buttons[i]:SetScript("OnClick",
    function(self)
		if (NewItemEnchInfoFrame1.SubFrame[i].EnchId == 0) then
			return;
		end
		Dream_SendData("NewDoItemEnchTaskInfo", tostring(self:GetID()));
    end)

	NewItemEnchInfoFrame1.SubFrame[i].EnchId = 0;
	NewItemEnchInfoFrame2.SubFrame[i].EnchId = 0;
end

function NewResetItemEnchUIData()
	NewItemEnchFrameButton1.GuidLow = 0;
	NewItemEnchFrameButton1.ItemLink = "item:0";
	NewItemEnchFrameButton1.ItemId = 0;
	NewItemEnchFrameButton1:SetText("");

	NewItemEnchFrameButton2.GuidLow = 0;
	NewItemEnchFrameButton2.ItemLink = "item:0";
	NewItemEnchFrameButton2.ItemId = 0;
	NewItemEnchFrameButton2:SetText("");

	for i=1,5 do
		NewItemEnchInfoFrame1.FontString[i]:SetText("");
		NewItemEnchInfoFrame2.FontString[i]:SetText("");
		NewItemEnchInfoFrame1.SubFrame[i].EnchId = 0;
		NewItemEnchInfoFrame2.SubFrame[i].EnchId = 0;
	end

	Dream_SendData("NewItemEnchInitNow");
end

local NewItemEnchFrameResetButton = CreateFrame("Button", "NewItemEnchFrameResetButton", NewItemEnchFrame, "UIPanelButtonTemplate");
NewItemEnchFrameResetButton:SetSize(100, 30);
NewItemEnchFrameResetButton:EnableMouse(true);
NewItemEnchFrameResetButton:RegisterForDrag("LeftButton");
NewItemEnchFrameResetButton:SetPoint("TOP", 0, -80);

NewItemEnchFrameResetButton.FontString = NewItemEnchFrameResetButton:CreateFontString("$parentFontString");
NewItemEnchFrameResetButton.FontString:SetSize(NewItemEnchFrameResetButton:GetWidth(), NewItemEnchFrameResetButton:GetHeight());
NewItemEnchFrameResetButton.FontString:SetFont(Dream_GameFont, 12);
NewItemEnchFrameResetButton.FontString:SetAllPoints(NewItemEnchFrameResetButton);
NewItemEnchFrameResetButton:SetFontString(NewItemEnchFrameResetButton.FontString);
NewItemEnchFrameResetButton:SetText("重置界面");

NewItemEnchFrameResetButton:SetScript("OnClick",
function(self)
	NewResetItemEnchUIData();
end)

NewItemEnchFrame:SetScript("OnShow",
function(self)
	NewResetItemEnchUIData();
end)

--消息处理
local function Dream_OnNewItemEnchAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "NewNoFuncItemEnch1") then
			NewItemEnchFrameButton1.GuidLow = 0;
			NewItemEnchFrameButton1.ItemLink = "item:0";
			NewItemEnchFrameButton1.ItemId = 0;
			NewItemEnchFrameButton1:SetText("");
			for i=1,5 do
				NewItemEnchInfoFrame1.FontString[i]:SetText("");
				NewItemEnchInfoFrame1.SubFrame[i].EnchId = 0;
			end
		elseif (Packet == "NewYesEnchTaskCheck1") then
			local Args = Dream_Split(Msg, "#");
			local GuidLow = tonumber(Args[1]);
			local ItemId = tonumber(Args[2]);
			NewItemEnchFrameButton1.GuidLow = GuidLow;
			NewItemEnchFrameButton1.ItemId = ItemId;
			NewItemEnchFrameButton1:SetText("|T"..DreamGetItemIcon(tonumber(ItemId))..":64|t");
			NowShowTips(NewItemEnchFrameButton1, NewItemEnchFrameButton1.ItemLink);
		elseif (Packet == "NewShowEnchInfo1") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local EnchId = tonumber(Args[2]);
			local EnchStr = Args[3];
			NewItemEnchInfoFrame1.SubFrame[Num].EnchId = EnchId;
			NewItemEnchInfoFrame1.FontString[Num]:SetText(EnchStr);
		elseif (Packet == "NewNoFuncItemEnch2") then
			NewItemEnchFrameButton2.GuidLow = 0;
			NewItemEnchFrameButton2.ItemLink = "item:0";
			NewItemEnchFrameButton2.ItemId = 0;
			NewItemEnchFrameButton2:SetText("");
			for i=1,5 do
				NewItemEnchInfoFrame2.FontString[i]:SetText("");
				NewItemEnchInfoFrame2.SubFrame[i].EnchId = 0;
			end
		elseif (Packet == "NewYesEnchTaskCheck2") then
			local Args = Dream_Split(Msg, "#");
			local GuidLow = tonumber(Args[1]);
			local ItemId = tonumber(Args[2]);
			NewItemEnchFrameButton2.GuidLow = GuidLow;
			NewItemEnchFrameButton2.ItemId = ItemId;
			NewItemEnchFrameButton2:SetText("|T"..DreamGetItemIcon(tonumber(ItemId))..":64|t");
			NowShowTips(NewItemEnchFrameButton2, NewItemEnchFrameButton2.ItemLink);
		elseif (Packet == "NewShowEnchInfo2") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local EnchId = tonumber(Args[2]);
			local EnchStr = Args[3];
			NewItemEnchInfoFrame2.SubFrame[Num].EnchId = EnchId;
			NewItemEnchInfoFrame2.FontString[Num]:SetText(EnchStr);
		elseif (Packet == "NewDoItemEnchTaskNeedGts") then
			local Args = Dream_Split(Msg, "#");
			local Num = tonumber(Args[1]);
			local Gts = Args[2];
			local Dialog = StaticPopup_Show("NewYesDoItemEnchTask", "\n"..Gts.."\n提取转移后左边的会被摧毁\n你确定要这么做吗?");
			if (Dialog) then
				Dialog.EnchNum = Num;
			end
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("NewItemEnchInitNow");
	end
end

--交互消息事件
local NewItemEnchAddonFrame = CreateFrame("Frame", "NewItemEnchAddonFrame");
NewItemEnchAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
NewItemEnchAddonFrame:RegisterEvent("PLAYER_LOGIN");
NewItemEnchAddonFrame:SetScript("OnEvent", Dream_OnNewItemEnchAddonEvent);

--------------------------------------------------------------------



