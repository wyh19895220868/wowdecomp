---@diagnostic disable: missing-parameter

local ChoiceItemSelectBtn = {};
local ChoiceItemSelectBtnStr = {};
local ChoiceItemNeedStr = {};

local SelectId = 0;

local ChoiceItemUpFrame = CreateFrame("Frame", "ChoiceItemUpFrame", UIParent);
ChoiceItemUpFrame:SetSize(900, 600);
ChoiceItemUpFrame:RegisterForDrag("LeftButton");
ChoiceItemUpFrame:SetPoint("CENTER");
ChoiceItemUpFrame:SetToplevel(true);
ChoiceItemUpFrame:SetClampedToScreen(true);
ChoiceItemUpFrame:SetBackdrop({ bgFile = ChoiceUpBIcon })

ChoiceItemUpFrame:EnableMouseWheel(true);

tinsert(UISpecialFrames, "ChoiceItemUpFrame");

ChoiceItemUpFrame:Hide();

-- 关闭按钮
local ChoiceItemUpClose = CreateFrame("Button", "ChoiceItemUpClose", ChoiceItemUpFrame, "UIPanelCloseButton");
ChoiceItemUpClose:SetPoint("TOPRIGHT", -64, -50);
ChoiceItemUpClose:EnableMouse(true);
ChoiceItemUpClose:SetSize(40, 40);
ChoiceItemUpClose:SetScript("OnClick",
function(self)
    ChoiceItemUpFrame:Hide();
end)

local ChoiceItemUpStr1 = ChoiceItemUpFrame:CreateFontString("ChoiceItemUpStr1");
ChoiceItemUpStr1:SetFont(Dream_GameFont, 18);
ChoiceItemUpStr1:SetPoint("TOP", 0, -80);
ChoiceItemUpStr1:SetText("|cFF00FF00[升级]|r")

local ChoiceItemUpStr2 = ChoiceItemUpFrame:CreateFontString("ChoiceItemUpStr2");
ChoiceItemUpStr2:SetFont(Dream_GameFont, 15);
ChoiceItemUpStr2:SetPoint("TOP", 0, -115);
ChoiceItemUpStr2:SetText("|cFF00FF00鼠标拖入装备到方框中 然后选择下面中的一项升级 注意左下角提示|r")

local ChoiceItemUpStr3 = ChoiceItemUpFrame:CreateFontString("ChoiceItemUpStr3");
ChoiceItemUpStr3:SetFont(Dream_GameFont, 15);
ChoiceItemUpStr3:SetPoint("CENTER", 0, 30);
ChoiceItemUpStr3:SetText("|cFFFF6600当前选择升级为 <尚未选择>|r ")

local ChoiceOneFramebutton = CreateFrame("Button", "ChoiceOneFramebutton", ChoiceItemUpFrame);
local ChoiceUpOneString = ChoiceOneFramebutton:CreateFontString("ChoiceUpOneString");

ChoiceUpOneString:SetFont(Dream_GameFont, 12);
ChoiceUpOneString:SetAllPoints(ChoiceOneFramebutton);
ChoiceOneFramebutton:SetFontString(ChoiceUpOneString);

ChoiceOneFramebutton:SetSize(108, 108);
ChoiceOneFramebutton:SetPoint("TOP", 2, -133);
ChoiceOneFramebutton:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square");

ChoiceOneFramebutton:SetText("")
ChoiceOneFramebutton.GuidLow = 0;
ChoiceOneFramebutton.TopLink = "item:0";

ChoiceOneFramebutton:SetScript("OnEnter",
function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	Dream_SetTooltipHyperlink(GameTooltip, self.TopLink);
	GameTooltip:Show();
end)

ChoiceOneFramebutton:SetScript("OnLeave",
function(self)
	GameTooltip:Hide();
end)

for i=1,3 do
    ChoiceItemSelectBtn[i] = CreateFrame("Button", "ChoiceItemSelectBtn"..i, ChoiceItemUpFrame);
    ChoiceItemSelectBtnStr[i]  = ChoiceItemSelectBtn[i]:CreateFontString("ChoiceItemSelectBtnStr"..i);

    ChoiceItemSelectBtnStr[i]:SetFont(Dream_GameFont, 12);
    ChoiceItemSelectBtnStr[i]:SetAllPoints(ChoiceItemSelectBtn[i]);
    ChoiceItemSelectBtn[i]:SetFontString(ChoiceItemSelectBtnStr[i]);

    ChoiceItemSelectBtn[i]:SetSize(80, 80);
	ChoiceItemSelectBtn[i]:SetPoint("LEFT", (i - 1) * 155 + 256, -43.5);

	ChoiceItemSelectBtn[i]:SetText("")

	ChoiceItemSelectBtn[i]:SetScript("OnEnter",
    function(self)
	    GameTooltip:SetOwner(ChoiceItemSelectBtn[i], "ANCHOR_RIGHT");
        Dream_SetTooltipItemId(GameTooltip, ChoiceItemSelectBtn[i]:GetID());
        GameTooltip:Show();
    end)

    ChoiceItemSelectBtn[i]:SetScript("OnLeave",
    function(self)
	    GameTooltip:Hide();
    end)
	
	ChoiceItemSelectBtn[i]:SetScript("OnClick",
    function(self)
	    UpdateSelectClick(i);
    end)
end

for i=1,5 do
    ChoiceItemNeedStr[i] = ChoiceItemUpFrame:CreateFontString("ChoiceItemNeedStr"..i);
    ChoiceItemNeedStr[i]:SetFont(Dream_GameFont, 15);
    ChoiceItemNeedStr[i]:SetPoint("CENTER", 0, -((i - 1) * 22 + 120));
    ChoiceItemNeedStr[i]:SetText("")
end

function UpdateSelectClick(Num)
    if (ChoiceItemSelectBtn[Num]:GetText() == "") then
	    return;
	end
	for i=1,3 do
	    if (i == Num) then
		    ChoiceItemSelectBtn[i]:LockHighlight();
			if (ChoiceItemSelectBtn[i].Link) then
			    ChoiceItemUpStr3:SetText("|cFFFF6600当前选择升级为|r "..ChoiceItemSelectBtn[i].Link)
				SelectId = i;
			end
		else
		    ChoiceItemSelectBtn[i]:UnlockHighlight();
	    end
	end
end

ChoiceItemUpFrame:SetScript("OnShow",
function(self)
	ChoiceItemUpStr3:SetText("|cFFFF6600当前选择升级为 <尚未选择>|r ")
    ChoiceOneFramebutton:SetText("");
	ChoiceOneFramebutton:SetID(0);
	SelectId = 0;
	for i=1,3 do
		ChoiceItemSelectBtn[i]:SetHighlightTexture("");
	    ChoiceItemSelectBtn[i]:UnlockHighlight();
		ChoiceItemSelectBtn[i]:SetID(0);
		ChoiceItemSelectBtn[i]:SetText("")
	end
	for i=1,5 do
        ChoiceItemNeedStr[i]:SetText("")
    end
end)

ChoiceOneFramebutton:SetScript("OnClick",
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
	Dream_SendData("ChoiceItemSrcIn", tostring(GuidLow));
	ClearCursor();
end)

-- 升级按钮
local ChoiceItemUpStart = CreateFrame("Button", "ChoiceItemUpStart", ChoiceItemUpFrame);
ChoiceItemUpStart:SetPoint("BOTTOM", 0, 30);
ChoiceItemUpStart:EnableMouse(true);
ChoiceItemUpStart:SetSize(150, 30);
ChoiceItemUpStart:SetBackdrop({ bgFile = NormalBtnIcon })
ChoiceItemUpStart:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")

local ChoiceItemUpStartStr = ChoiceItemUpStart:CreateFontString("ChoiceItemUpStartStr")
ChoiceItemUpStartStr:SetFont(Dream_GameFont, 15)
ChoiceItemUpStart:SetFontString(ChoiceItemUpStartStr)
ChoiceItemUpStart:SetText("|cffFFC125确定升级|r")

ChoiceItemUpStart:SetScript("OnClick",
function(self)
    if (SelectId == 0) then
	    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600[自选升级]: 尚未选择想升级的项目|r");
		return
    end
    if (ChoiceOneFramebutton.GuidLow > 0) then
	    Dream_SendData("ChoiceItemStartUp", tostring(ChoiceOneFramebutton.GuidLow).."#"..tostring(SelectId));
		ChoiceItemUpStr3:SetText("|cFFFF6600当前选择升级为 <尚未选择>|r ")
        ChoiceOneFramebutton:SetText("");
	    ChoiceOneFramebutton:SetID(0);
		ChoiceOneFramebutton.GuidLow = 0;
		ChoiceOneFramebutton.TopLink = "item:0";
	    SelectId = 0;
	    for i=1,3 do
	        ChoiceItemSelectBtn[i]:SetHighlightTexture("");
	        ChoiceItemSelectBtn[i]:UnlockHighlight();
		    ChoiceItemSelectBtn[i]:SetID(0);
		    ChoiceItemSelectBtn[i]:SetText("")
	    end
	    for i=1,5 do
            ChoiceItemNeedStr[i]:SetText("")
        end
	end
end)

--消息处理
local function Dream_ChoiceItemUpAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "NotUpChoice") then
		    ChoiceOneFramebutton:SetText("");
			ChoiceOneFramebutton:SetID(0);
			ChoiceItemUpStr3:SetText("")
			ChoiceOneFramebutton.GuidLow = 0;
			ChoiceOneFramebutton.TopLink = "item:0";
			NowShowTips(ChoiceOneFramebutton, "item:0");
			for i=1,3 do
				ChoiceItemSelectBtn[i]:UnlockHighlight();
			    ChoiceItemSelectBtn[i]:SetID(0);
			    ChoiceItemSelectBtn[i]:SetText("")
			end
			for i=1,5 do
                ChoiceItemNeedStr[i]:SetText("")
            end
			
		    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600[自选升级]: 这件装备无法升级......请重新放入|r");
		elseif (Packet == "ChoiceItemInfo") then
		    local Args = Dream_Split(Msg, "#");
			ChoiceOneFramebutton:SetID(tonumber(Args[1]));
		    ChoiceOneFramebutton:SetText("|T"..DreamGetItemIcon(tonumber(Args[1]))..":100|t")
			local TextStr = "\n";
			if (Args[2] == "1") then
			    TextStr = TextStr.."|cFFFF6600升级成功后|r |cFFFF0000可以保存|r |cFFFF6600随机附魔宝石|r\n";
			else
			    TextStr = TextStr.."|cFFFF6600升级成功后|r |cFFFF0000不能保存|r |cFFFF6600随机附魔宝石|r\n";
			end
			
			if (Args[3] == "1") then
			    TextStr = TextStr.."|cFFFF6600升级失败 原物品必定碎裂|r\n";
			else
			    TextStr = TextStr.."|cFFFF6600升级失败 原物品不会碎裂|r\n";
			end
			
			local TarList = 0;
			if (Args[4] ~= "Not") then
				TarList = TarList + 1;
			    local ItemId = GetItemIdByLink(Args[4]);
			    ChoiceItemSelectBtn[1]:SetID(ItemId);
			    ChoiceItemSelectBtn[1]:SetText("|T"..DreamGetItemIcon(ItemId)..":72|t")
				ChoiceItemSelectBtn[1].Link = Args[4]
			    TextStr = TextStr.."|cFFFF6600选择升级为|r "..Args[4].." |cFFFF6600概率是|r |cFFFF0000"..Args[5].."|r\n";
				ChoiceItemSelectBtn[1]:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight");
			end
			
			if (Args[6] ~= "Not") then
				TarList = TarList + 1;
				local ItemId = GetItemIdByLink(Args[6]);
			    ChoiceItemSelectBtn[2]:SetID(ItemId);
			    ChoiceItemSelectBtn[2]:SetText("|T"..DreamGetItemIcon(ItemId)..":72|t")
				ChoiceItemSelectBtn[2].Link = Args[6]
			    TextStr = TextStr.."|cFFFF6600选择升级为|r "..Args[6].." |cFFFF6600概率是|r |cFFFF0000"..Args[7].."|r\n";
				ChoiceItemSelectBtn[2]:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight");
			end
			
			if (Args[8] ~= "Not") then
				TarList = TarList + 1;
				local ItemId = GetItemIdByLink(Args[8]);
			    ChoiceItemSelectBtn[3]:SetID(ItemId);
			    ChoiceItemSelectBtn[3]:SetText("|T"..DreamGetItemIcon(ItemId)..":72|t")
				ChoiceItemSelectBtn[3].Link = Args[8]
			    TextStr = TextStr.."|cFFFF6600选择升级为|r "..Args[8].." |cFFFF6600概率是|r |cFFFF0000"..Args[9].."|r\n";
				ChoiceItemSelectBtn[3]:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight");
			end
			
			TextStr = TextStr.."|cFFFF6600附加幸运几率|r |cFFFF0000"..Args[10].."|r\n";
			DEFAULT_CHAT_FRAME:AddMessage(TextStr);
			
			if  (TarList == 1) then
				local Num = 1;
				if (Args[4] ~= "Not") then
					Num = 1;
				elseif (Args[6] ~= "Not") then
					Num = 2;
				elseif (Args[8] ~= "Not") then
					Num = 3;
				end
				UpdateSelectClick(Num)
				TextStr = TextStr.."";
			else
				TextStr = TextStr.."|cFFFF6600请选择中间三项中的一个再 [确定升级]|r\n";
			end

			if (Args[11]) then
			    local Arg = Dream_Split(Args[11], "$");
				if (Arg[1] and Arg[1] ~= "" and tonumber(Arg[2]) > 0) then
				    ChoiceItemNeedStr[1]:SetText("|cFFFF6600需要材料|r "..Arg[1].." X |cFFFF0000"..Arg[2].."|r")
				end
				if (Arg[3] and Arg[3] ~= "" and tonumber(Arg[4]) > 0) then
				    ChoiceItemNeedStr[2]:SetText("|cFFFF6600需要材料|r "..Arg[3].." X |cFFFF0000"..Arg[4].."|r")
				end
				if (Arg[5] and Arg[5] ~= "" and tonumber(Arg[6]) > 0) then
				    ChoiceItemNeedStr[3]:SetText("|cFFFF6600需要材料|r "..Arg[5].." X |cFFFF0000"..Arg[6].."|r")
				end
				if (Arg[7] and Arg[7] ~= "" and tonumber(Arg[8]) > 0) then
				    ChoiceItemNeedStr[4]:SetText("|cFFFF6600需要材料|r "..Arg[7].." X |cFFFF0000"..Arg[8].."|r")
				end
				if (Arg[9] and Arg[9] ~= "" and tonumber(Arg[10]) > 0) then
				    ChoiceItemNeedStr[5]:SetText("|cFFFF6600需要材料|r "..Arg[9].." X |cFFFF0000"..Arg[10].."|r")
				end
			end
		elseif (Packet == "AsItemChoiceUp") then
			ChoiceItemUpFrame:Show();
			local Args = Dream_Split(Msg, "#");
			ChoiceOneFramebutton.GuidLow = tonumber(Args[1]);
			ChoiceOneFramebutton:SetID(tonumber(Args[2]));
			Dream_SendData("ChoiceItemSrcIn", tostring(tonumber(Args[1])));
			ClearCursor();
		end
	elseif (event == "PLAYER_LOGIN") then

	end
end

--交互消息事件
local ChoiceItemUpAddonFrame = CreateFrame("Frame", "ChoiceItemUpAddonFrame");
ChoiceItemUpAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
ChoiceItemUpAddonFrame:RegisterEvent("PLAYER_LOGIN");
ChoiceItemUpAddonFrame:SetScript("OnEvent", Dream_ChoiceItemUpAddonEvent);

