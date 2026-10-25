
--取说明
function GetTaskEnchantDes(EnchantId)
	if (not Dream_EnchantmentDes) then
		return "<没有词条>";
	end

	if (not Dream_EnchantmentDes[EnchantId]) then
		return "<没有词条>";
	end

	return Dream_EnchantmentDes[EnchantId];
end

local TaskEnchSpellFrame = CreateFrame("Frame", "TaskEnchSpellFrame", UIParent);
TaskEnchSpellFrame:SetSize(720, 720);
TaskEnchSpellFrame:SetPoint("CENTER", 0, 60);
TaskEnchSpellFrame:SetToplevel(true);
TaskEnchSpellFrame:SetClampedToScreen(true);
TaskEnchSpellFrame:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
});

tinsert(UISpecialFrames, "TaskEnchSpellFrame");
TaskEnchSpellFrame:Hide();

-- 关闭按钮
local TaskEnchSpellFrameButtonClose = CreateFrame("Button", "TaskEnchSpellFrameButtonClose", TaskEnchSpellFrame, "UIPanelCloseButton");
TaskEnchSpellFrameButtonClose:SetPoint("TOPRIGHT", 5, 5);
TaskEnchSpellFrameButtonClose:EnableMouse(true);
TaskEnchSpellFrameButtonClose:SetSize(30, 30);

--标题模块
local TaskEnchSpellFrameTitleBar = CreateFrame("Frame", "TaskEnchSpellFrameTitleBar", TaskEnchSpellFrame);
TaskEnchSpellFrameTitleBar:SetSize(200, 30);
TaskEnchSpellFrameTitleBar:SetPoint("TOP", 0, 24);
TaskEnchSpellFrameTitleBar:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

--标题模块文字描述
local TaskEnchSpellFrameTitleBarText = TaskEnchSpellFrameTitleBar:CreateFontString("TaskEnchSpellFrameTitleBarText");
TaskEnchSpellFrameTitleBarText:SetFont(Dream_GameFont, 15);
TaskEnchSpellFrameTitleBarText:SetPoint("CENTER");
TaskEnchSpellFrameTitleBarText:SetText("|cffFFC125词条洗练|锁定|r");

local TAsButtonText = TaskEnchSpellFrame:CreateFontString("TAsButtonText");
TAsButtonText:SetFont(Dream_GameFont, 18);
TAsButtonText:SetPoint("TOP", 0, -40);
TAsButtonText:SetText("|cFF00FF00将需要洗练的装备拖入下框中|r");

TaskEnchSpellFrameAsButton = CreateFrame("Button", "TaskEnchSpellFrameAsButton", TaskEnchSpellFrame);
TaskEnchSpellFrameAsButton:SetSize(80, 80);
TaskEnchSpellFrameAsButton:EnableMouse(true);
TaskEnchSpellFrameAsButton:RegisterForDrag("LeftButton");
TaskEnchSpellFrameAsButton:SetPoint("TOP", 0, -80);
TaskEnchSpellFrameAsButton:SetBackdrop({bgFile = "Interface\\Buttons\\UI-EmptySlot-White"});
TaskEnchSpellFrameAsButton.GuidLow = 0;
TaskEnchSpellFrameAsButton.ItemLink = "item:0";
TaskEnchSpellFrameAsButton.ItemId = 0;
TaskEnchSpellFrameAsButton.FontString = TaskEnchSpellFrameAsButton:CreateFontString("$parentFontString");
TaskEnchSpellFrameAsButton.FontString:SetSize(TaskEnchSpellFrameAsButton:GetWidth(), TaskEnchSpellFrameAsButton:GetHeight());
TaskEnchSpellFrameAsButton.FontString:SetFont(Dream_GameFont, 12);
TaskEnchSpellFrameAsButton.FontString:SetAllPoints(TaskEnchSpellFrameAsButton);
TaskEnchSpellFrameAsButton:SetFontString(TaskEnchSpellFrameAsButton.FontString);
TaskEnchSpellFrameAsButton:SetText("");
TaskEnchSpellFrameAsButton:RegisterForClicks("AnyDown");
TaskEnchSpellFrameAsButton:SetScript("OnEnter",
function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	Dream_SetTooltipHyperlink(GameTooltip, self.ItemLink);
	GameTooltip:Show();
end)

TaskEnchSpellFrameAsButton:SetScript("OnLeave",
function(self)
	GameTooltip:Hide();
end)
TaskEnchSpellFrameAsButton:SetScript("OnClick",
function(self, BtnType)
	if (BtnType == "LeftButton") then
        local IType, ItemId, ItemLink = GetCursorInfo()
        if (IType ~= "item") then
		    return
        end
	    local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
	    local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
	    self.GuidLow = GuidLow;
	    self.ItemId = ItemId;
	    self.ItemLink = ItemLink;
	    Dream_SendData("TaskEnchSpellCheck", tostring(GuidLow));
	elseif (BtnType == "RightButton") then
		self.GuidLow = 0;
		self.ItemLink = "item:0";
		self.ItemId = 0;
		self.FontString:SetText("");
		for i=1,5 do
			TaskEnchSpellFrame.FontString[i]:SetText("");
			TaskEnchSpellFrame.Button[i].EnchId = 0;
			TaskEnchSpellFrame.Button[i].Lock = 0;
			TaskEnchSpellFrame.Button[i]:SetText("");
			TaskEnchSpellFrame.Button[i]:Disable();
		end
	end
	ClearCursor();
end)

TaskEnchSpellFrame.SubFrame = {};
TaskEnchSpellFrame.FontString = {};
TaskEnchSpellFrame.Button = {};
for i=1,5 do
	TaskEnchSpellFrame.SubFrame[i] = CreateFrame("Frame", "$parentSubFrame"..i, TaskEnchSpellFrame);
	TaskEnchSpellFrame.SubFrame[i]:SetSize(520, 60);
	TaskEnchSpellFrame.SubFrame[i]:SetPoint("TOPLEFT", 20, -((i - 1) * 70 + 180));

	TaskEnchSpellFrame.SubFrame[i]:SetBackdrop(
    {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    edgeSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })

	TaskEnchSpellFrame.FontString[i] = TaskEnchSpellFrame.SubFrame[i]:CreateFontString("$parentFontString"..i);
    TaskEnchSpellFrame.FontString[i]:SetFont(Dream_GameFont, 15);
    TaskEnchSpellFrame.FontString[i]:SetPoint("CENTER");
	TaskEnchSpellFrame.FontString[i]:SetSize(TaskEnchSpellFrame.SubFrame[i]:GetWidth(), TaskEnchSpellFrame.SubFrame[i]:GetHeight());
    TaskEnchSpellFrame.FontString[i]:SetText("");

	TaskEnchSpellFrame.Button[i] = CreateFrame("Button", "$parentSubButton"..i, TaskEnchSpellFrame, "UIPanelButtonTemplate");
    TaskEnchSpellFrame.Button[i]:SetSize(120, 40);
    TaskEnchSpellFrame.Button[i]:EnableMouse(true);
    TaskEnchSpellFrame.Button[i]:RegisterForDrag("LeftButton");
    TaskEnchSpellFrame.Button[i]:SetPoint("TOPRIGHT", -30, -((i - 1) * 70 + 190));
	TaskEnchSpellFrame.Button[i]:SetText("");
	TaskEnchSpellFrame.Button[i].EnchId = 0;
	TaskEnchSpellFrame.Button[i].Lock = 0;
	TaskEnchSpellFrame.Button[i]:Disable();

	TaskEnchSpellFrame.Button[i]:SetScript("OnClick",
    function(self)
		if (TaskEnchSpellFrame.Button[i].Lock == 0) then
			TaskEnchSpellFrame.Button[i].Lock = 1;
			TaskEnchSpellFrame.Button[i]:SetText("|cFF00FF00已锁定|r");
		else
			TaskEnchSpellFrame.Button[i].Lock = 0;
			TaskEnchSpellFrame.Button[i]:SetText("锁定");
		end
		local AsLock = true;
		for N=1,5 do
			if (TaskEnchSpellFrame.Button[N].Lock == 0) then
				AsLock = false;
			end
		end
		if (AsLock) then
			TaskEnchSpellFrameOkButton:Disable();
		else
			TaskEnchSpellFrameOkButton:Enable();
		end
    end)
end

local GsAsButtonText1 = TaskEnchSpellFrame:CreateFontString("GsAsButtonText1");
GsAsButtonText1:SetFont(Dream_GameFont, 18);
GsAsButtonText1:SetPoint("BOTTOM", 0, 140);

local GsAsButtonText2 = TaskEnchSpellFrame:CreateFontString("GsAsButtonText2");
GsAsButtonText2:SetFont(Dream_GameFont, 18);
GsAsButtonText2:SetPoint("BOTTOM", 0, 120);
GsAsButtonText2:SetText("|cFF00FF00你当前拥有<0>个|r");

TaskEnchSpellFrameOkButton = CreateFrame("Button", "TaskEnchSpellFrameOkButton", TaskEnchSpellFrame, "UIPanelButtonTemplate");
TaskEnchSpellFrameOkButton:SetSize(150, 50);
TaskEnchSpellFrameOkButton:EnableMouse(true);
TaskEnchSpellFrameOkButton:RegisterForDrag("LeftButton");
TaskEnchSpellFrameOkButton:SetPoint("BOTTOM", 0, 50);
TaskEnchSpellFrameOkButton:SetText("确认洗练");
TaskEnchSpellFrameOkButton:SetScript("OnClick",
function(self)
	local Args = "";
	for i=1,5 do
		if (TaskEnchSpellFrame.Button[i].EnchId ~= 0) then
			local Lock = tostring(TaskEnchSpellFrame.Button[i].Lock);
			Args = Args..i.."#"..Lock.."$";
		end
	end
	Args = Args.."^"..TaskEnchSpellFrameAsButton.GuidLow;
	Dream_SendData("TaskEnchSpellUpdateNow", Args);
	TaskEnchSpellFrameOkButton:Disable();
end)

TaskEnchSpellFrame:SetScript("OnShow",
function(self)
	Dream_SendData("TaskEnchSpellNeedInfo");
end)

--消息处理
local function Dream_OnTaskEnchSpellAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "NoFuncItemTaskEnchSpell") then
			TaskEnchSpellFrameAsButton.GuidLow = 0;
			TaskEnchSpellFrameAsButton.ItemLink = "item:0";
			TaskEnchSpellFrameAsButton.ItemId = 0;
			TaskEnchSpellFrameAsButton.FontString:SetText("");
			for i=1,5 do
				TaskEnchSpellFrame.FontString[i]:SetText("");
				TaskEnchSpellFrame.Button[i].EnchId = 0;
				TaskEnchSpellFrame.Button[i].Lock = 0;
				TaskEnchSpellFrame.Button[i]:SetText("");
				TaskEnchSpellFrame.Button[i]:Disable();
			end
		elseif (Packet == "TaskEnchSpellCheckYes") then
			TaskEnchSpellFrameOkButton:Enable();
			TaskEnchSpellFrameAsButton.FontString:SetText("|T"..DreamGetItemIcon(tonumber(TaskEnchSpellFrameAsButton.ItemId))..":64|t");
			NowShowTips(TaskEnchSpellFrameAsButton, TaskEnchSpellFrameAsButton.ItemLink);
			local Args = Dream_Split(Msg, "#");
			for i=1,5 do
				local EnchId = tonumber(Args[i]);
				local Des = GetTaskEnchantDes(Args[i]);
				if (EnchId == 0) then
					TaskEnchSpellFrame.Button[i].Lock = 1;
					TaskEnchSpellFrame.Button[i]:SetText("");
					TaskEnchSpellFrame.Button[i]:Disable();
				else
					TaskEnchSpellFrame.Button[i]:SetText("锁定");
					TaskEnchSpellFrame.Button[i]:Enable();
				end
				TaskEnchSpellFrame.FontString[i]:SetText(Des);
				TaskEnchSpellFrame.Button[i].EnchId = EnchId;
			end
		elseif (Packet == "TaskEnchSpellCheckYesNow") then
			TaskEnchSpellFrameOkButton:Enable();
			local Args = Dream_Split(Msg, "#");
			for i=1,5 do
				local EnchId = tonumber(Args[i]);
				local Des = GetTaskEnchantDes(Args[i]);
				if (EnchId == 0) then
					TaskEnchSpellFrame.Button[i].Lock = 1;
					TaskEnchSpellFrame.Button[i]:SetText("");
					TaskEnchSpellFrame.Button[i]:Disable();
				else
					if (TaskEnchSpellFrame.Button[i].Lock == 1) then
						TaskEnchSpellFrame.Button[i]:SetText("|cFF00FF00已锁定|r");
					else
						TaskEnchSpellFrame.Button[i]:SetText("锁定");
					end
					TaskEnchSpellFrame.Button[i]:Enable();
				end
				TaskEnchSpellFrame.FontString[i]:SetText(Des);
				TaskEnchSpellFrame.Button[i].EnchId = EnchId;
			end
		elseif (Packet == "TaskEnchSpellCheckItemCount") then
			local HCount = tonumber(Msg);
			GsAsButtonText2:SetText("|cFF00FF00你当前拥有<"..HCount..">个|r");
		elseif(Packet == "TaskEnchSpellNeedInfo") then
			local Args = Dream_Split(Msg, "#");
			GsAsButtonText1:SetText("|cFF00FF00每次洗练需要消耗"..DreamGetItemLink(Args[1]).." X 1|r");
			GsAsButtonText2:SetText("|cFF00FF00你当前拥有<"..Args[2]..">个|r");
		end
	elseif (event == "PLAYER_LOGIN") then
	end
end

--交互消息事件
local TaskEnchSpellAddonFrame = CreateFrame("Frame", "TaskEnchSpellAddonFrame");
TaskEnchSpellAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
TaskEnchSpellAddonFrame:RegisterEvent("PLAYER_LOGIN");
TaskEnchSpellAddonFrame:SetScript("OnEvent", Dream_OnTaskEnchSpellAddonEvent);
