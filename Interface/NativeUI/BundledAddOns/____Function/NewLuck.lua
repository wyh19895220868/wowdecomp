---@diagnostic disable: missing-parameter

local NewLuckItems = { }

local NewLuckButtons = {};
local NewLuckIconStr = {};
local NewLuckCountStr = {};

local RandomIndex = 1;--随机的位置
local TimeEnd = 0;--时间判断

local NewLuckFrame = CreateFrame("Frame", "NewLuckFrame", UIParent);
NewLuckFrame:SetSize(1024, 600);
NewLuckFrame:RegisterForDrag("LeftButton");
NewLuckFrame:SetPoint("CENTER");
NewLuckFrame:SetToplevel(true);
NewLuckFrame:SetClampedToScreen(true);
NewLuckFrame:SetBackdrop({ bgFile = NewLuckBIcon })

tinsert(UISpecialFrames, "NewLuckFrame");

NewLuckFrame:Hide();

-- 关闭按钮
local NewLuckbuttonClose = CreateFrame("Button", "NewLuckbuttonClose", NewLuckFrame, "UIPanelCloseButton");
NewLuckbuttonClose:SetPoint("TOPRIGHT", -15, -48)
NewLuckbuttonClose:EnableMouse(true);
NewLuckbuttonClose:SetSize(40, 40);

local NewLeftLuckFrame = CreateFrame("Frame", "NewLeftLuckFrame", NewLuckFrame);
NewLeftLuckFrame:SetSize(480, 480);
NewLeftLuckFrame:SetPoint("LEFT", 85, -40);

--抽奖按钮-单次
local NewStartButtonLuckOne = CreateFrame("Button", "NewStartButtonLuckOne", NewLeftLuckFrame);
NewStartButtonLuckOne:SetPoint("BOTTOM", -180, 30);
NewStartButtonLuckOne:EnableMouse(true);
NewStartButtonLuckOne:SetSize(150, 30);
NewStartButtonLuckOne:SetBackdrop({ bgFile = NormalBtnIcon })
NewStartButtonLuckOne:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")

local NewStringLuckOne = NewStartButtonLuckOne:CreateFontString("NewStringLuckOne");
NewStringLuckOne:SetFont(Dream_GameFont, 15);
NewStartButtonLuckOne:SetFontString(NewStringLuckOne);
NewStartButtonLuckOne:SetText("|cffFFC125抽一次|r");

NewStartButtonLuckOne:SetScript("OnClick",
function(self)
    Dream_SendData("NewLuckCheckNeed", "1");    --通知服务端 检查有没有材料 返回后得到随机结果再开始动画
end)

--抽奖按钮-十连
local NewStartButtonLuckTen = CreateFrame("Button", "NewStartButtonLuckTen", NewLeftLuckFrame);
NewStartButtonLuckTen:SetSize(150, 30);
NewStartButtonLuckTen:SetPoint("BOTTOM", 180, 30);
NewStartButtonLuckTen:EnableMouse(true);
NewStartButtonLuckTen:SetBackdrop({ bgFile = NormalBtnIcon })
NewStartButtonLuckTen:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")

local NewStringLuckTen = NewStartButtonLuckTen:CreateFontString("NewStringLuckTen");
NewStringLuckTen:SetFont(Dream_GameFont, 15);
NewStartButtonLuckTen:SetFontString(NewStringLuckTen);
NewStartButtonLuckTen:SetText("|cffFFC125十连抽|r");

NewStartButtonLuckTen:SetScript("OnClick",
function(self)
    Dream_SendData("NewLuckCheckNeed", "10");    --通知服务端 检查有没有材料 返回后得到随机结果再开始动画
end)

--材料提示
local NewLuckStrCmText = NewLuckFrame:CreateFontString("NewLuckStrCmText");
NewLuckStrCmText:SetFont(Dream_GameFont, 16);
NewLuckStrCmText:SetPoint("TOPLEFT", 80, -80);
NewLuckStrCmText:SetText("");

--抽奖中提示
local NewLuckStrIngText = NewLuckFrame:CreateFontString("NewLuckStrIngText");
NewLuckStrIngText:SetFont(Dream_GameFont, 20);
NewLuckStrIngText:SetPoint("TOPLEFT", 640, -75);
NewLuckStrIngText:SetText("");

--滚动框外框
local NewLuckScrollOut = CreateFrame("Frame", "NewLuckScrollOut", NewLuckFrame);
NewLuckScrollOut:SetSize(275, 355);
NewLuckScrollOut:SetPoint("RIGHT", -141, -68);
NewLuckScrollOut:EnableMouseWheel(true);

--滚动条
local NewLuckScrollBar = CreateFrame("Slider", "NewLuckScrollBar", NewLuckScrollOut, "OptionsSliderTemplate");
NewLuckScrollBar:SetSize(20, 370);
NewLuckScrollBar:SetPoint("RIGHT", NewLuckScrollOut, 60, -10);
NewLuckScrollBar:EnableMouseWheel(true);
NewLuckScrollBar:SetOrientation("VERTICAL");
_G[NewLuckScrollBar:GetName().."High"]:Hide();
_G[NewLuckScrollBar:GetName().."Low"]:Hide();
NewLuckScrollBar:SetMinMaxValues(1, 100);
NewLuckScrollBar:SetValue(1);
NewLuckScrollBar:SetValueStep(9);

NewLuckScrollBar:SetScript("OnMouseWheel",
function(self, delta)
    local Value = self:GetValue();
    if (delta < 0) then
		self:SetValue(Value + 10);
	else
		self:SetValue(Value - 10);
	end
end)

--滚动消息内
local NewLuckScrollMsg = CreateFrame("ScrollingMessageFrame", "NewLuckScrollMsg", NewLuckScrollOut);
NewLuckScrollMsg:SetSize(270, 340);
NewLuckScrollMsg:SetPoint("CENTER");
NewLuckScrollMsg:SetFont(Dream_GameFont, 15);
NewLuckScrollMsg:SetSpacing(5);
NewLuckScrollMsg:SetFrameStrata("HIGH");
NewLuckScrollMsg:SetFading(false);
NewLuckScrollMsg:SetInsertMode("BOTTOM");
NewLuckScrollMsg:ScrollToTop();
NewLuckScrollMsg:SetMaxLines(100);
NewLuckScrollMsg:Show();

NewLuckScrollBar:SetScript("OnValueChanged",
function(self, value)
    if (value < 100) then
	    NewLuckScrollMsg:ScrollUp();
	else
	    NewLuckScrollMsg:ScrollDown();
	end
end)

--鼠标轮滑向下=-1 向上=1
NewLuckScrollOut:SetScript("OnMouseWheel",
function(self, delta)
    local Value = NewLuckScrollBar:GetValue();
    if (delta < 0) then
	    NewLuckScrollMsg:ScrollDown();
		NewLuckScrollBar:SetValue(Value + 10);
	else
	    NewLuckScrollMsg:ScrollUp();
		NewLuckScrollBar:SetValue(Value - 10);
	end
end)

--鼠标轮滑向下=-1 向上=1
NewLuckFrame:SetScript("OnMouseWheel",
function(self, delta)
    local Value = NewLuckScrollBar:GetValue();
    if (delta < 0) then
	    NewLuckScrollMsg:ScrollDown();
		NewLuckScrollBar:SetValue(Value + 10);
	else
	    NewLuckScrollMsg:ScrollUp();
		NewLuckScrollBar:SetValue(Value - 10);
	end
end)

local AntiPngButton = CreateFrame("Button", "AntiPngButton", NewLeftLuckFrame);
AntiPngButton:SetPoint("CENTER");
-- Keep the pointer above every prize slot.  The slots use frame level 100,
-- so the old default child level left this texture behind the green panel.
AntiPngButton:SetFrameLevel(NewLuckFrame:GetFrameLevel() + 101);
AntiPngButton:EnableMouse(false);
AntiPngButton.PointerTexture = AntiPngButton:CreateTexture(nil, "OVERLAY");
AntiPngButton.PointerTexture:SetAllPoints(AntiPngButton);
AntiPngButton.PointerTexture:SetTexture(VoidIcon);

local AnimationGroup = AntiPngButton:CreateAnimationGroup()
local Animation = AnimationGroup:CreateAnimation("Rotation")
Animation:SetSmoothing("OUT")
Animation:SetDuration(DmDuration)
Animation:SetDegrees(-360 * 5)--顺时针转5圈 这个动画只是搞效果 会很快

local AnimationGroupEnd = AntiPngButton:CreateAnimationGroup()
local AnimationEnd = AnimationGroupEnd:CreateAnimation("Rotation")
AnimationEnd:SetSmoothing("OUT")

Animation:SetScript("OnPlay",
function(self)
    for i = 1, #NewLuckItems do
        NewLuckButtons[i]:UnlockHighlight();
        NewLuckButtons[i]:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square");
    end
end)

Animation:SetScript("OnFinished",
function(self)
    local OneIndex = 360 / #NewLuckItems; --计算出位置
    AnimationEnd:SetDuration(DmDuration);
    AnimationEnd:SetDegrees(-(OneIndex * RandomIndex))--直接转到指定位置
    AnimationEnd:Play();
end)

AnimationEnd:SetScript("OnUpdate",
function(self, elapsed)
    if (self:IsPlaying()) then
        TimeEnd = TimeEnd + elapsed;
        if (TimeEnd >= self:GetDuration()) then--判断时间刚好等于动画的持续时间则表示已到达指定位置
            TimeEnd = 0;
            self:Stop();
            NewLuckStrIngText:SetText("");
            NewLuckButtons[RandomIndex + 1]:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight");
            NewLuckButtons[RandomIndex + 1]:LockHighlight();
            Dream_SendData("CheckLuckIndex", tostring(RandomIndex));
        end
    end
end)

NewLuckFrame:SetScript("OnShow",
function(self)
    for i = 1, #NewLuckItems do
        local Angle = 2.0 * math.pi * (i - 1) / #NewLuckItems
        local BtnX = #NewLuckItems * 6 * math.sin(Angle)
        local BtnY = #NewLuckItems * 6 * math.cos(Angle)
        NewLuckButtons[i]:SetPoint("CENTER", NewLeftLuckFrame, "CENTER", BtnX, BtnY)
    end
end)

local function Dream_OnNewLuckAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		--新抽奖
        if (Packet == "DoNewLuckData") then
            local Store = Dream_Split(Msg, "$");
            local ItemId = GetItemIdByLink(Store[1]);
            local Count = tonumber(Store[2]);
            local TenItemId = GetItemIdByLink(Store[3]);
            local TenCount = tonumber(Store[4]);
            local TenStr = (TenItemId > 0 and TenCount > 0) and "|cffFFC125十连抽额外获得|r |T"..DreamGetItemIcon(TenItemId)..":16|t "..Store[3].." X |CFFFF0000"..TenCount.."|r |cffFFC125个|r" or "";
            NewLuckStrCmText:SetText("|cffFFC125每次抽奖需要|r |T"..DreamGetItemIcon(ItemId)..":16|t "..Store[1].." X |CFFFF0000"..Count.."|r |cffFFC125个|r "..TenStr);
            local Args = Dream_Split(Store[5], "|");
            for i=1,#Args do
                local TheArgs = Dream_Split(Args[i], "#");
                NewLuckItems[i] = { tonumber(TheArgs[1]), tonumber(TheArgs[2]) };
            end

            local pointerSize = #NewLuckItems * 10;
            AntiPngButton:SetSize(pointerSize, pointerSize);
            AntiPngButton.PointerTexture:SetAllPoints(AntiPngButton);

            --开始布局 因为取数据比 OnShow 优先 所以先把布局弄好 才能显示
            NewLuckButtons = {};
            NewLuckIconStr = {};
            NewLuckCountStr = {};
            for i = 1, #NewLuckItems do
                NewLuckButtons[i] = CreateFrame("Button", "NewLuckButtons"..i, NewLuckFrame);
                NewLuckIconStr[i] = NewLuckButtons[i]:CreateFontString("NewLuckIconStr"..i);
                NewLuckCountStr[i] = NewLuckButtons[i]:CreateFontString("NewLuckCountStr"..i);
                
                NewLuckButtons[i]:SetSize(52, 52);
                NewLuckButtons[i]:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square");
                NewLuckIconStr[i]:SetFont(Dream_GameFont, 12);
                NewLuckIconStr[i]:SetAllPoints(NewLuckButtons[i]);
                NewLuckButtons[i]:SetFontString(NewLuckIconStr[i]);
                NewLuckButtons[i]:SetText("|T"..DreamGetItemIcon(NewLuckItems[i][1])..":48|t");
            
                NewLuckCountStr[i]:SetFont(Dream_GameFont, 12, "OUTLINE");
                NewLuckCountStr[i]:SetPoint("CENTER", NewLuckButtons[i], 0, -10);
                NewLuckCountStr[i]:SetText("|cFFFF6600"..NewLuckItems[i][2].."|r");

                NewLuckButtons[i]:SetFrameLevel(100);
            
                NewLuckButtons[i]:SetScript("OnEnter",
                function(self)
                    GameTooltip:SetOwner(NewLuckButtons[i], "ANCHOR_LEFT");
                    Dream_SetTooltipItemId(GameTooltip, NewLuckItems[i][1]);
                    GameTooltip:Show();
                end)
            
                NewLuckButtons[i]:SetScript("OnLeave",
                function(self)
                    GameTooltip:Hide();
                end)
            end
        elseif(Packet == "NewLuckCheckNeedNow") then
            Dream_SendData("NewLuckPlayBegin");
		elseif(Packet == "NewStartLuckNow") then
            local Args = Dream_Split(Msg, "#");
            NewLuckStrIngText:SetText("|cFF00FF00正在抽奖中...剩余次数 [ "..Args[2].." ]|r");
            RandomIndex = tonumber(Args[1])
            Animation:Play()
        elseif(Packet == "NewLuckUpdateScrollMsg") then
            if (NewLuckScrollMsg:GetNumMessages() >= NewLuckScrollMsg:GetMaxLines()) then
                NewLuckScrollMsg:Clear();
                NewLuckScrollMsg:AddMessage(Msg);
            else
                NewLuckScrollMsg:AddMessage(Msg);
            end
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("GetNewLuckData");
	end
end

--交互消息事件
local NewLuckAddonFrame = CreateFrame("Frame", "NewLuckAddonFrame");
NewLuckAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
NewLuckAddonFrame:RegisterEvent("PLAYER_LOGIN");
NewLuckAddonFrame:SetScript("OnEvent", Dream_OnNewLuckAddonEvent);
