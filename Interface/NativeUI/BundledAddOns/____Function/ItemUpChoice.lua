---@diagnostic disable: missing-parameter

local RandomItemSelectBtn = {};
local RandomItemSelectBtnStr = {};
local RandomItemNeedStr = {};

local RandomItemUpFrame = CreateFrame("Frame", "RandomItemUpFrame", UIParent);
RandomItemUpFrame:SetSize(900, 600);
RandomItemUpFrame:RegisterForDrag("LeftButton");
RandomItemUpFrame:SetPoint("CENTER");
RandomItemUpFrame:SetToplevel(true);
RandomItemUpFrame:SetClampedToScreen(true);
RandomItemUpFrame:SetBackdrop({ bgFile = RandomUpBIcon })

RandomItemUpFrame:EnableMouseWheel(true);

tinsert(UISpecialFrames, "RandomItemUpFrame");

RandomItemUpFrame:Hide();

-- 关闭按钮
local RandomItemUpClose = CreateFrame("Button", "RandomItemUpClose", RandomItemUpFrame, "UIPanelCloseButton");
RandomItemUpClose:SetPoint("TOPRIGHT", -64, -50);
RandomItemUpClose:EnableMouse(true);
RandomItemUpClose:SetSize(40, 40);
RandomItemUpClose:SetScript("OnClick",
function(self)
    RandomItemUpFrame:Hide();
end)

local RandomOneFramebutton = CreateFrame("Button", "RandomOneFramebutton", RandomItemUpFrame);
local RandomUpOneString = RandomOneFramebutton:CreateFontString("RandomUpOneString");

RandomUpOneString:SetFont(Dream_GameFont, 12);
RandomUpOneString:SetAllPoints(RandomOneFramebutton);
RandomOneFramebutton:SetFontString(RandomUpOneString);

RandomOneFramebutton:SetSize(108, 108);
RandomOneFramebutton:SetPoint("TOP", 2, -133);
RandomOneFramebutton:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square");

RandomOneFramebutton:SetText("")
RandomOneFramebutton.GuidLow = 0;
RandomOneFramebutton.TopLink = "item:0";

RandomOneFramebutton:SetScript("OnEnter",
function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    Dream_SetTooltipHyperlink(GameTooltip, self.TopLink);
    GameTooltip:Show();
end)

RandomOneFramebutton:SetScript("OnLeave",
function(self)
	GameTooltip:Hide();
end)

for i=1,3 do
    RandomItemSelectBtn[i] = CreateFrame("Button", "RandomItemSelectBtn"..i, RandomItemUpFrame);
    RandomItemSelectBtnStr[i]  = RandomItemSelectBtn[i]:CreateFontString("RandomItemSelectBtnStr"..i);

    RandomItemSelectBtnStr[i]:SetFont(Dream_GameFont, 12);
    RandomItemSelectBtnStr[i]:SetAllPoints(RandomItemSelectBtn[i]);
    RandomItemSelectBtn[i]:SetFontString(RandomItemSelectBtnStr[i]);

    RandomItemSelectBtn[i]:SetSize(80, 80);
	RandomItemSelectBtn[i]:SetPoint("LEFT", (i - 1) * 155 + 256, -43.5);

	RandomItemSelectBtn[i]:SetText("")

	RandomItemSelectBtn[i]:SetScript("OnEnter",
    function(self)
	    GameTooltip:SetOwner(RandomItemSelectBtn[i], "ANCHOR_RIGHT");
        Dream_SetTooltipItemId(GameTooltip, RandomItemSelectBtn[i]:GetID());
        GameTooltip:Show();
    end)

    RandomItemSelectBtn[i]:SetScript("OnLeave",
    function(self)
	    GameTooltip:Hide();
    end)
end

for i=1,5 do
    RandomItemNeedStr[i] = RandomItemUpFrame:CreateFontString("RandomItemNeedStr"..i);
    RandomItemNeedStr[i]:SetFont(Dream_GameFont, 15);
    RandomItemNeedStr[i]:SetPoint("CENTER", 0, -((i - 1) * 22 + 120));
    RandomItemNeedStr[i]:SetText("")
end

RandomItemUpFrame:SetScript("OnShow",
function(self)
    RandomOneFramebutton:SetText("");
	RandomOneFramebutton:SetID(0);
	for i=1,3 do
		RandomItemSelectBtn[i]:SetID(0);
		RandomItemSelectBtn[i]:SetText("")
		RandomItemSelectBtn[1]:SetHighlightTexture("");
	end
	for i=1,5 do
        RandomItemNeedStr[i]:SetText("")
    end
end)

RandomOneFramebutton:SetScript("OnClick",
function(self)
    local IType, ItemId, ItemLink = GetCursorInfo()
    if (IType ~= "item") then
		return
    end
	
	local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
	local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
	self.GuidLow = GuidLow;
	self.TopLink = ItemLink;
	NowShowTips(self, ItemLink);
	self:SetID(ItemId);
	Dream_SendData("RandomItemSrcIn", tostring(GuidLow));
	ClearCursor();
end)

-- 升级按钮
local RandomItemUpStart = CreateFrame("Button", "RandomItemUpStart", RandomItemUpFrame);
RandomItemUpStart:SetPoint("BOTTOM", 0, 30);
RandomItemUpStart:EnableMouse(true);
RandomItemUpStart:SetSize(150, 30);
RandomItemUpStart:SetBackdrop({ bgFile = NormalBtnIcon })
RandomItemUpStart:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")

local RandomItemUpStartStr = RandomItemUpStart:CreateFontString("RandomItemUpStartStr")
RandomItemUpStartStr:SetFont(Dream_GameFont, 15)
RandomItemUpStart:SetFontString(RandomItemUpStartStr)
RandomItemUpStart:SetText("|cffFFC125确定升级|r")

RandomItemUpStart:SetScript("OnClick",
function(self)
    if (RandomOneFramebutton.GuidLow > 0) then
	    Dream_SendData("RandomItemStartUp", tostring(RandomOneFramebutton.GuidLow));
        RandomOneFramebutton:SetText("");
	    RandomOneFramebutton:SetID(0);
		RandomOneFramebutton.GuidLow = 0;
		RandomOneFramebutton.TopLink = "item:0";
	    for i=1,3 do
		    RandomItemSelectBtn[i]:SetID(0);
		    RandomItemSelectBtn[i]:SetText("")
			RandomItemSelectBtn[1]:SetHighlightTexture("");
	    end
	    for i=1,5 do
            RandomItemNeedStr[i]:SetText("")
        end
	end
end)

local RandomItemUpStr1 = RandomItemUpFrame:CreateFontString("RandomItemUpStr1");
RandomItemUpStr1:SetFont(Dream_GameFont, 18);
RandomItemUpStr1:SetPoint("TOP", 0, -80);
RandomItemUpStr1:SetText("|cFF00FF00[升级]|r")

local RandomItemUpStr2 = RandomItemUpFrame:CreateFontString("RandomItemUpStr2");
RandomItemUpStr2:SetFont(Dream_GameFont, 15);
RandomItemUpStr2:SetPoint("TOP", 0, -115);
RandomItemUpStr2:SetText("|cFF00FF00鼠标拖入装备到方框中 系统会随机升级下列中的|r")

local RandomItemUpStr3 = RandomItemUpFrame:CreateFontString("RandomItemUpStr3");
RandomItemUpStr3:SetFont(Dream_GameFont, 15);
RandomItemUpStr3:SetPoint("CENTER", 0, 30);
RandomItemUpStr3:SetText("|cFF00FF00点击 [确定升级] 系统会自动随机 注意左下角提示|r")

--消息处理
local function Dream_RandomItemUpAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "NotUpRandom") then
		    RandomOneFramebutton:SetText("");
			RandomOneFramebutton:SetID(0);
			RandomOneFramebutton.GuidLow = 0;
			RandomOneFramebutton.TopLink = "item:0";
			NowShowTips(RandomOneFramebutton, "item:0");
			for i=1,3 do
			    RandomItemSelectBtn[i]:SetID(0);
			    RandomItemSelectBtn[i]:SetText("")
			end
			for i=1,5 do
                RandomItemNeedStr[i]:SetText("")
            end
			
		    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600[升级]: 这件装备无法升级......请重新放入|r");
		elseif (Packet == "RandomItemInfo") then
		    local Args = Dream_Split(Msg, "#");
			RandomOneFramebutton:SetID(tonumber(Args[1]));
		    RandomOneFramebutton:SetText("|T"..DreamGetItemIcon(tonumber(Args[1]))..":100|t")
			local TextStr = "\n";
			if (Args[2] == "1") then
			    TextStr = TextStr.."|cFFFF6600升级成功后|r |cFFFF0000可以保存|r |cFFFF6600随机附魔宝石|r\n";
			else
			    TextStr = TextStr.."|cFFFF6600升级成功后|r |cFFFF0000不能保存|r |cFFFF6600随机附魔宝石|r\n";
			end
			
			if (Args[3] ~= "Not") then
			    local ItemId = GetItemIdByLink(Args[3]);
			    RandomItemSelectBtn[1]:SetID(ItemId);
			    RandomItemSelectBtn[1]:SetText("|T"..DreamGetItemIcon(ItemId)..":72|t")
			    TextStr = TextStr.."|cFFFF6600随机升级为|r "..Args[3].." |cFFFF6600概率是|r |cFFFF0000"..Args[4].."|r\n";
				RandomItemSelectBtn[1]:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square");
			end
			
			if (Args[5] ~= "Not") then
				local ItemId = GetItemIdByLink(Args[5]);
			    RandomItemSelectBtn[2]:SetID(ItemId);
			    RandomItemSelectBtn[2]:SetText("|T"..DreamGetItemIcon(ItemId)..":72|t")
			    TextStr = TextStr.."|cFFFF6600随机升级为|r "..Args[5].." |cFFFF6600概率是|r |cFFFF0000"..Args[6].."|r\n";
				RandomItemSelectBtn[2]:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square");
			end
			
			if (Args[7] ~= "Not") then
				local ItemId = GetItemIdByLink(Args[7]);
			    RandomItemSelectBtn[3]:SetID(ItemId);
			    RandomItemSelectBtn[3]:SetText("|T"..DreamGetItemIcon(ItemId)..":72|t")
			    TextStr = TextStr.."|cFFFF6600随机升级为|r "..Args[7].." |cFFFF6600概率是|r |cFFFF0000"..Args[8].."|r\n";
				RandomItemSelectBtn[3]:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square");
			end
			
			TextStr = TextStr.."|cFFFF6600附加幸运几率|r |cFFFF0000"..Args[9].."|r\n";
			DEFAULT_CHAT_FRAME:AddMessage(TextStr);
			
			if (Args[10]) then
			    local Arg = Dream_Split(Args[10], "$");
				if (Arg[1] and Arg[1] ~= "" and tonumber(Arg[2]) > 0) then
				    RandomItemNeedStr[1]:SetText("|cFFFF6600需要材料|r "..Arg[1].." X |cFFFF0000"..Arg[2].."|r")
				end
				if (Arg[3] and Arg[3] ~= "" and tonumber(Arg[4]) > 0) then
				    RandomItemNeedStr[2]:SetText("|cFFFF6600需要材料|r "..Arg[3].." X |cFFFF0000"..Arg[4].."|r")
				end
				if (Arg[5] and Arg[5] ~= "" and tonumber(Arg[6]) > 0) then
				    RandomItemNeedStr[3]:SetText("|cFFFF6600需要材料|r "..Arg[5].." X |cFFFF0000"..Arg[6].."|r")
				end
				if (Arg[7] and Arg[7] ~= "" and tonumber(Arg[8]) > 0) then
				    RandomItemNeedStr[4]:SetText("|cFFFF6600需要材料|r "..Arg[7].." X |cFFFF0000"..Arg[8].."|r")
				end
				if (Arg[9] and Arg[9] ~= "" and tonumber(Arg[10]) > 0) then
				    RandomItemNeedStr[5]:SetText("|cFFFF6600需要材料|r "..Arg[9].." X |cFFFF0000"..Arg[10].."|r")
				end
			end
		elseif (Packet == "AsItemRandomUp") then
			RandomItemUpFrame:Show();
			local Args = Dream_Split(Msg, "#");
			RandomOneFramebutton.GuidLow = tonumber(Args[1]);
			RandomOneFramebutton:SetID(tonumber(Args[2]));
			Dream_SendData("RandomItemSrcIn", tostring(tonumber(Args[1])));
			ClearCursor();
		end
	elseif (event == "PLAYER_LOGIN") then

	end
end

--交互消息事件
local RandomItemUpAddonFrame = CreateFrame("Frame", "RandomItemUpAddonFrame");
RandomItemUpAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
RandomItemUpAddonFrame:RegisterEvent("PLAYER_LOGIN");
RandomItemUpAddonFrame:SetScript("OnEvent", Dream_RandomItemUpAddonEvent);

