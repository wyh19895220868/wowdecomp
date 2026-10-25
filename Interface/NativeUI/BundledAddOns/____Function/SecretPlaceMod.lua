
local MaxAuras = 24;
local MaxOnePages = 6;
local MaxSubs = 3;
local CreAuraFrames = {};
local CreAuraInfoFrames = {};

local SecretPlaceKeyFrame = CreateFrame("Frame", "SecretPlaceKeyFrame", UIParent);
SecretPlaceKeyFrame:SetSize(600, 680);
SecretPlaceKeyFrame:RegisterForDrag("LeftButton");
SecretPlaceKeyFrame:SetPoint("CENTER");
SecretPlaceKeyFrame:SetToplevel(true);
SecretPlaceKeyFrame:SetClampedToScreen(true);
SecretPlaceKeyFrame:SetBackdrop({bgFile = "Interface\\Icons\\SecretPlaceKeyBg"});

tinsert(UISpecialFrames, "SecretPlaceKeyFrame");
SecretPlaceKeyFrame:Hide();

local ASubKeyDrop = CreateFrame("Frame", "ASubKeyDrop", SecretPlaceKeyFrame);
ASubKeyDrop:SetSize(256, 256);
ASubKeyDrop:SetPoint("CENTER", 0, 180);
ASubKeyDrop:SetBackdrop({bgFile = "Interface\\Icons\\ASubKeyDrop"});

local BSubKeyDrop = CreateFrame("Frame", "BSubKeyDrop", ASubKeyDrop);
BSubKeyDrop:SetSize(320, 320);
BSubKeyDrop:SetPoint("CENTER", 0, 0);
BSubKeyDrop:SetBackdrop({bgFile = "Interface\\Icons\\BSubKeyDrop"});

local CSubKeyDrop = CreateFrame("Frame", "CSubKeyDrop", ASubKeyDrop);
CSubKeyDrop:SetSize(210, 210);
CSubKeyDrop:SetPoint("CENTER", 0, 0);
CSubKeyDrop:SetBackdrop({bgFile = "Interface\\Icons\\CSubKeyDrop"});

local DSubKeyDrop = CreateFrame("Frame", "DSubKeyDrop", ASubKeyDrop);
DSubKeyDrop:SetSize(130, 130);
DSubKeyDrop:SetPoint("CENTER", 0, 0);
DSubKeyDrop:SetBackdrop({bgFile = "Interface\\Icons\\DSubKeyDrop"});

local ESubKeyDrop = CreateFrame("Frame", "ESubKeyDrop", ASubKeyDrop);
ESubKeyDrop:SetSize(215, 215);
ESubKeyDrop:SetPoint("CENTER", 0, 5);
ESubKeyDrop:SetBackdrop({bgFile = "Interface\\Icons\\ESubKeyDrop"});

local FSubKeyDrop = CreateFrame("Frame", "FSubKeyDrop", ASubKeyDrop);
FSubKeyDrop:SetSize(360, 30);
FSubKeyDrop:SetPoint("BOTTOM", 0, -50);
FSubKeyDrop:SetBackdrop({bgFile = "Interface\\Icons\\FSubKeyDrop"});

local AnimationDrop1 = CreateFrame("Frame", "AnimationDrop1", ASubKeyDrop);
AnimationDrop1:SetSize(210, 210);
AnimationDrop1:SetPoint("CENTER", 0, 0);
local AnimationTexture1 = AnimationDrop1:CreateTexture();
AnimationTexture1:SetTexture("Interface\\Icons\\AnimationDrop1");
AnimationTexture1:SetAllPoints();
AnimationTexture1:SetBlendMode("ADD");
local AnimationDropGroup1 = AnimationTexture1:CreateAnimationGroup();
local AnGroup1 = AnimationDropGroup1:CreateAnimation("Rotation");
AnGroup1:SetDegrees(360);
AnGroup1:SetDuration(10);
AnGroup1:SetSmoothing("OUT");
AnimationDropGroup1:SetLooping("BOUNCE");
AnimationDropGroup1:Play();

local AnimationDrop2 = CreateFrame("Frame", "AnimationDrop2", ASubKeyDrop);
AnimationDrop2:SetSize(130, 130);
AnimationDrop2:SetPoint("CENTER", 0, 0);
local AnimationTexture2 = AnimationDrop2:CreateTexture();
AnimationTexture2:SetTexture("Interface\\Icons\\AnimationDrop2");
AnimationTexture2:SetAllPoints();
AnimationTexture2:SetBlendMode("ADD");
local AnimationDropGroup2 = AnimationTexture2:CreateAnimationGroup();
local AnGroup2 = AnimationDropGroup2:CreateAnimation("Rotation");
AnGroup2:SetDegrees(360);
AnGroup2:SetDuration(10);
AnGroup2:SetSmoothing("OUT");
AnimationDropGroup2:SetLooping("BOUNCE");
AnimationDropGroup2:Play();

local HightQpOnEnterFrame1 = CreateFrame("Frame", "HightQpOnEnterFrame1", BSubKeyDrop);
HightQpOnEnterFrame1:SetSize(45, 45);
HightQpOnEnterFrame1:SetPoint("TOP", 0, -15);
HightQpOnEnterFrame1:SetBackdrop({bgFile = "Interface\\Icons\\HightQpOnEnter"});
local HightQpOnEnterFrame11 = CreateFrame("Frame", "HightQpOnEnterFrame11", HightQpOnEnterFrame1);
HightQpOnEnterFrame11:SetSize(30, 30);
HightQpOnEnterFrame11:SetPoint("CENTER", 0, 0);
HightQpOnEnterFrame11:SetBackdrop({bgFile = "Interface\\Icons\\HightQpOnEnter11"});

local HightQpOnEnterFrame2 = CreateFrame("Frame", "HightQpOnEnterFrame1", BSubKeyDrop);
HightQpOnEnterFrame2:SetSize(45, 45);
HightQpOnEnterFrame2:SetPoint("TOPRIGHT", -25, -98);
HightQpOnEnterFrame2:SetBackdrop({bgFile = "Interface\\Icons\\HightQpOnEnter"});
local HightQpOnEnterFrame12 = CreateFrame("Frame", "HightQpOnEnterFrame12", HightQpOnEnterFrame2);
HightQpOnEnterFrame12:SetSize(30, 30);
HightQpOnEnterFrame12:SetPoint("CENTER", 0, 0);
HightQpOnEnterFrame12:SetBackdrop({bgFile = "Interface\\Icons\\HightQpOnEnter12"});

local HightQpOnEnterFrame3 = CreateFrame("Frame", "HightQpOnEnterFrame3", BSubKeyDrop);
HightQpOnEnterFrame3:SetSize(45, 45);
HightQpOnEnterFrame3:SetPoint("BOTTOMRIGHT", -65, 41);
HightQpOnEnterFrame3:SetBackdrop({bgFile = "Interface\\Icons\\HightQpOnEnter"});
local HightQpOnEnterFrame13 = CreateFrame("Frame", "HightQpOnEnterFrame13", HightQpOnEnterFrame3);
HightQpOnEnterFrame13:SetSize(30, 30);
HightQpOnEnterFrame13:SetPoint("CENTER", 0, 0);
HightQpOnEnterFrame13:SetBackdrop({bgFile = "Interface\\Icons\\HightQpOnEnter13"});

local HightQpOnEnterFrame4 = CreateFrame("Frame", "HightQpOnEnterFrame4", BSubKeyDrop);
HightQpOnEnterFrame4:SetSize(45, 45);
HightQpOnEnterFrame4:SetPoint("BOTTOMLEFT", 66 ,42);
HightQpOnEnterFrame4:SetBackdrop({bgFile = "Interface\\Icons\\HightQpOnEnter"});
local HightQpOnEnterFrame14 = CreateFrame("Frame", "HightQpOnEnterFrame14", HightQpOnEnterFrame4);
HightQpOnEnterFrame14:SetSize(30, 30);
HightQpOnEnterFrame14:SetPoint("CENTER", 0, 0);
HightQpOnEnterFrame14:SetBackdrop({bgFile = "Interface\\Icons\\HightQpOnEnter14"});

local HightQpOnEnterFrame5 = CreateFrame("Frame", "HightQpOnEnterFrame5", BSubKeyDrop);
HightQpOnEnterFrame5:SetSize(45, 45);
HightQpOnEnterFrame5:SetPoint("LEFT", 22, 42);
HightQpOnEnterFrame5:SetBackdrop({bgFile = "Interface\\Icons\\HightQpOnEnter"});
local HightQpOnEnterFrame15 = CreateFrame("Frame", "HightQpOnEnterFrame15", HightQpOnEnterFrame5);
HightQpOnEnterFrame15:SetSize(30, 30);
HightQpOnEnterFrame15:SetPoint("CENTER", 0, 0);
HightQpOnEnterFrame15:SetBackdrop({bgFile = "Interface\\Icons\\HightQpOnEnter15"});

--文字部分
local SecretPlaceKeyText1 = SecretPlaceKeyFrame:CreateFontString("SecretPlaceKeyText1");
SecretPlaceKeyText1:SetFont(Dream_GameFont, 18);
SecretPlaceKeyText1:SetPoint("CENTER", 0, 40);
SecretPlaceKeyText1:SetText("|cFFFF66FF钥匙信息预览 实际以进入秘境右侧界面为准|r");

--信息部分
local SecretPlaceKeyText2 = SecretPlaceKeyFrame:CreateFontString("SecretPlaceKeyText2");
SecretPlaceKeyText2:SetFont(Dream_GameFont, 16);
SecretPlaceKeyText2:SetPoint("CENTER", 0, -40);
SecretPlaceKeyText2:SetText("");

for i=1, MaxSubs do
    CreAuraFrames[i] = CreateFrame("Frame", "CreAuraFrame"..i, SecretPlaceKeyFrame);
    CreAuraFrames[i]:SetSize(400, 60);
    CreAuraFrames[i]:SetPoint("CENTER", 0, -130-(i - 1) * 60);
    CreAuraFrames[i]:SetBackdrop(
    {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    CreAuraFrames[i].Count = 0;
    CreAuraFrames[i].SelectPage = 1;

    CreAuraFrames[i].FontString = CreAuraFrames[i]:CreateFontString("$parent".."FontString"..i);
    CreAuraFrames[i].FontString:SetFont(Dream_GameFont, 16);
    CreAuraFrames[i].FontString:SetPoint("LEFT", CreAuraFrames[i], 13, 10);
    if (i == MaxSubs) then
        CreAuraFrames[i].FontString:SetText("|cFF00FF00玩家|r");
    else
        CreAuraFrames[i].FontString:SetText("|cFF00FF00怪物|r");
    end

    CreAuraFrames[i].PageStr = CreAuraFrames[i]:CreateFontString("$parent".."PageStr"..i);
    CreAuraFrames[i].PageStr:SetFont(Dream_GameFont, 13);
    CreAuraFrames[i].PageStr:SetPoint("LEFT", CreAuraFrames[i], 13, -10);
    CreAuraFrames[i].PageStr:SetText("|cFF00FF00第"..CreAuraFrames[i].SelectPage.."页|r");

    CreAuraFrames[i].CreAuraTexture1 = CreAuraFrames[i]:CreateTexture();
    CreAuraFrames[i].CreAuraTexture1:SetTexture("Interface\\Icons\\AuraTexture");
    CreAuraFrames[i].CreAuraTexture1:SetSize(60, 60);
    CreAuraFrames[i].CreAuraTexture1:SetPoint("LEFT", CreAuraFrames[i], 0, 0);
    CreAuraFrames[i].KeySpells = {};
    for j=1, MaxAuras do
        CreAuraFrames[i].KeySpells[j] = CreateFrame("Button", "$parent".."KeySpells"..j, CreAuraFrames[i]);
        CreAuraFrames[i].KeySpells[j]:SetSize(48, 48);
        CreAuraFrames[i].KeySpells[j]:SetBackdrop({bgFile = "Interface\\Icons\\AuraBtn"});

        CreAuraFrames[i].KeySpells[j].Texture = CreAuraFrames[i].KeySpells[j]:CreateTexture();
        CreAuraFrames[i].KeySpells[j].Texture:SetSize(32, 32);
        CreAuraFrames[i].KeySpells[j].Texture:SetPoint("CENTER", CreAuraFrames[i].KeySpells[j], 0, 0);
        CreAuraFrames[i].KeySpells[j].Texture:SetTexture("");

        CreAuraFrames[i].KeySpells[j].SpellId = 0;
        CreAuraFrames[i].KeySpells[j]:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetHyperlink("spell:"..self.SpellId);
            GameTooltip:Show();
        end)

        CreAuraFrames[i].KeySpells[j]:SetScript("OnLeave",
        function(self)
	        GameTooltip:Hide();
        end)

        CreAuraFrames[i].KeySpells[j]:Hide();
    end
    CreAuraFrames[i].NextButton = CreateFrame("Button", "$parent".."NextButton"..i, CreAuraFrames[i]);
    CreAuraFrames[i].NextButton:SetSize(24, 48);
    CreAuraFrames[i].NextButton:SetPoint("RIGHT", CreAuraFrames[i], -10, 0);
    CreAuraFrames[i].NextButton:SetNormalTexture("Interface\\Icons\\Next2");
    CreAuraFrames[i].NextButton:SetPushedTexture("Interface\\Icons\\Next1");
    CreAuraFrames[i].NextButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
    CreAuraFrames[i]:Show();
    CreAuraFrames[i].NextButton:SetScript("OnClick",
    function(self)
        DoClickNext(CreAuraFrames[i]);
    end)
end
--钥匙孔
local KeyStoreFrame = CreateFrame("Frame", "KeyStoreFrame", ASubKeyDrop);
KeyStoreFrame:SetSize(100, 100);
KeyStoreFrame:SetPoint("CENTER", 0, 0);
KeyStoreFrame:SetBackdrop({bgFile = "Interface\\Icons\\KeyStoreKong"});
local KeyStoreText = KeyStoreFrame:CreateTexture("$parent".."KeyStoreText", "ARTWORK");
KeyStoreText:SetSize(60, 60);
KeyStoreText:SetPoint("CENTER",0,0);

--钥匙孔按钮
local KeyStoreButton = CreateFrame("Button", "KeyStoreButton", KeyStoreFrame);
KeyStoreButton:SetSize(100, 100);
KeyStoreButton:SetPoint("CENTER", 0, 0);
KeyStoreButton:EnableMouse(true);
KeyStoreButton:RegisterForDrag("LeftButton");
local KeyStoreButtonTexture = KeyStoreButton:CreateTexture();
KeyStoreButtonTexture:SetSize(60, 60);
KeyStoreButtonTexture:SetPoint("CENTER", KeyStoreButton, 0, 0);
KeyStoreButtonTexture:SetTexture("");

local KeyStoreButtonString = RandomOneFramebutton:CreateFontString("KeyStoreButtonString");
KeyStoreButtonString:SetFont(Dream_GameFont, 12);
KeyStoreButtonString:SetAllPoints(KeyStoreButton);
KeyStoreButton:SetFontString(KeyStoreButtonString);
KeyStoreButton.GuidLow = 0;
KeyStoreButton.ItemId = 0;

--发光钥匙环
local HightKeyStore = CreateFrame("Frame", "HightKeyStore", KeyStoreButton);
HightKeyStore:SetSize(100, 100);
HightKeyStore:SetPoint("CENTER", 0, 0);
HightKeyStore:SetBackdrop({bgFile = "Interface\\Icons\\HightKeyStore"});

--关闭按钮
local SecretPlaceKeyCloseButten = CreateFrame("Button","SecretPlaceKeyCloseButten", SecretPlaceKeyFrame, "UIPanelCloseButton");
SecretPlaceKeyCloseButten:SetSize(45, 45);
SecretPlaceKeyCloseButten:SetPoint("TOPRIGHT", -83, -2);
SecretPlaceKeyCloseButten:EnableMouse(true);
       
--创建开启秘境的按钮       
local OpenSecretPlaceButton = CreateFrame('Button', "OpenSecretPlaceButton", SecretPlaceKeyFrame, "UIPanelButtonTemplate");
OpenSecretPlaceButton:SetPoint("BOTTOM", 0, 20);
OpenSecretPlaceButton:SetSize(140, 30);
OpenSecretPlaceButton:SetText("进入大秘境");

KeyStoreButton:SetScript("OnEnter",
function(self)
    if (SecretPlaceKeyText2:GetText()) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText(SecretPlaceKeyText2:GetText());
        GameTooltip:Show();
    end
end)

KeyStoreButton:SetScript("OnLeave",
function(self)
	GameTooltip:Hide();
end)

SecretPlaceKeyFrame:SetScript("OnShow",
function(self)

end)

--拖入处理
KeyStoreButton:SetScript("OnClick",
function(self)
    local IType, ItemId, ItemLink = GetCursorInfo();
    if (IType ~= "item") then
		return;
    end

	local _, _, _, _, _, _, _, _, ItemGuidLow, _ = Dream_DoSplit(":", string.match(ItemLink, "item[%-?%d:]+"));
	local GuidLow = tonumber(ItemGuidLow) - MaxGuidIndex
	self.GuidLow = GuidLow;
    self.ItemId = tonumber(ItemId);
	Dream_SendData("GetKeySecretPlace", tostring(GuidLow));
	ClearCursor();
end)

--进入按钮
OpenSecretPlaceButton:SetScript("OnClick",
function(self)
    if (KeyStoreButton.GuidLow ~= 0) then
        Dream_SendData("GoNowSecretPlace", tostring(KeyStoreButton.GuidLow));
    end
end)

function ResetDataKey()
    KeyStoreButton.GuidLow = 0;
    KeyStoreButton.ItemId = 0;
    KeyStoreButtonTexture:SetTexture("");
    SecretPlaceKeyText2:SetText("");
    GameTooltip:Hide();
end

--重置UI
function ResetKeyUI()
    for i=1, MaxSubs do
        for j=1, MaxAuras do
            CreAuraFrames[i].KeySpells[j]:Hide();
        end
    end
end

--重置UI
function ResetDataUI()
    for i=1, MaxSubs do
        for j=1, MaxAuras do
            CreAuraInfoFrames[i].KeySpells[j]:Hide();
        end
    end
end

function ShowDataKeyUI(Msg)
    local Args = Dream_Split(Msg, "^");
    KeyStoreButton.GuidLow = tonumber(Args[1]);
    KeyStoreButton.ItemId = tonumber(Args[2]);
    local Info = string.format("|cFFFFFF00秘境名称:|r |cFF00FFFF[%s]|r\n|cFFFFFF00秘境副本:|r |cFF00FFFF[%s]|r\n|cFFFFFF00挑战时间:|r |cFF00FFFF%s|r\n|cFFFFFF00允许死亡次数:|r |cFF00FFFF%s次|r\n|cFFFFFF00掉落等级:|r |cFF00FFFF%s级|r\n|cFFFFFF00进入是否消耗钥匙:|r |cFF00FFFF%s|r", Args[3], Args[4], Args[5], Args[6], Args[7], Args[8]);
    SecretPlaceKeyText2:SetText(Info);
    KeyStoreButtonTexture:SetTexture(DreamGetItemIcon(tonumber(KeyStoreButton.ItemId)));
end

--初始化数据
function DoInitDataSpell(Self, Num, SpellId)
    Self.Count = Num;
    Self.KeySpells[Num]:Show();
    Self.KeySpells[Num]:SetPoint("LEFT", Self, (Num - 1) * 50 + 64, 0);
    Self.KeySpells[Num].Texture:SetTexture(DreamGetSpellIcon(SpellId));
    Self.KeySpells[Num].SpellId = SpellId;
    if (Num > MaxOnePages) then
        Self.KeySpells[Num]:Hide();
    end
end

--翻页处理
function DoClickNext(Self)
    for Num=(Self.SelectPage - 1) * MaxOnePages + 1, Self.SelectPage * MaxOnePages do
        Self.KeySpells[Num]:Hide();
    end

    local Page = DreamGetPage(Self.Count, MaxOnePages);
    Self.SelectPage = Self.SelectPage + 1;
    if (Self.SelectPage > Page or Self.SelectPage > 4) then
        Self.SelectPage = 1;
    end

    for Num=(Self.SelectPage - 1) * MaxOnePages + 1, Self.SelectPage * MaxOnePages do
        local N = Num - (Self.SelectPage - 1) * MaxOnePages;
        Self.KeySpells[Num]:Show();
        Self.KeySpells[Num]:SetPoint("LEFT", Self, (N - 1) * 50 + 64, 0);
        if (Num > Self.Count) then
            Self.KeySpells[Num]:Hide();
        end
    end
    Self.PageStr:SetText("|cFF00FF00第"..Self.SelectPage.."页|r");
end

local SecretInfoFrame = CreateFrame("Frame", "SecretInfoFrame", UIParent);
SecretInfoFrame:SetSize(400, 320);
SecretInfoFrame:RegisterForDrag("LeftButton");
SecretInfoFrame:SetPoint("RIGHT");
SecretInfoFrame:SetToplevel(true);
SecretInfoFrame:SetClampedToScreen(true);
SecretInfoFrame:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
});
SecretInfoFrame:Hide();

local TopInfoFrame = CreateFrame("Frame", "TopInfoFrame", SecretInfoFrame);
TopInfoFrame:SetSize(200, 20);
TopInfoFrame:SetPoint("TOP");
TopInfoFrame:SetBackdrop({ bgFile = "Interface\\Icons\\InfoTop" });
local TopMapFrame = CreateFrame("Frame", "TopMapFrame", SecretInfoFrame);
TopMapFrame:SetSize(300, 40);
TopMapFrame:SetPoint("TOP", 0, -20);
TopMapFrame:SetBackdrop({ bgFile = "Interface\\Icons\\InfoMap" });
local TopMapFrameFontString = TopMapFrame:CreateFontString("TopMapFrameFontString");
TopMapFrameFontString:SetFont(Dream_GameFont, 18);
TopMapFrameFontString:SetAllPoints(TopMapFrame);
TopMapFrameFontString:SetText("");

local SecretInfoFrameStr1 = SecretInfoFrame:CreateFontString("SecretInfoFrameStr1");
SecretInfoFrameStr1:SetFont(Dream_GameFont, 15);
SecretInfoFrameStr1:SetPoint("TOP", 0, -70);
SecretInfoFrameStr1:SetText("");

local SecretInfoFrameStr2 = SecretInfoFrame:CreateFontString("SecretInfoFrameStr2");
SecretInfoFrameStr2:SetFont(Dream_GameFont, 15);
SecretInfoFrameStr2:SetPoint("TOP", 0, -90);
SecretInfoFrameStr2:SetText("");

local SecretInfoFrameStr3 = SecretInfoFrame:CreateFontString("SecretInfoFrameStr3");
SecretInfoFrameStr3:SetFont(Dream_GameFont, 15);
SecretInfoFrameStr3:SetPoint("TOP", 0, -110);
SecretInfoFrameStr3:SetText("");

for i=1, MaxSubs do
    CreAuraInfoFrames[i] = CreateFrame("Frame", "CreAuraInfoFrames"..i, SecretInfoFrame);
    CreAuraInfoFrames[i]:SetSize(400, 60);
    CreAuraInfoFrames[i]:SetPoint("CENTER", 0, 0-(i - 1) * 60);
    CreAuraInfoFrames[i]:SetBackdrop(
    {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    });
    CreAuraInfoFrames[i].Count = 0;
    CreAuraInfoFrames[i].SelectPage = 1;

    CreAuraInfoFrames[i].FontString = CreAuraInfoFrames[i]:CreateFontString("$parent".."FontString"..i);
    CreAuraInfoFrames[i].FontString:SetFont(Dream_GameFont, 16);
    CreAuraInfoFrames[i].FontString:SetPoint("LEFT", CreAuraInfoFrames[i], 13, 10);
    if (i == MaxSubs) then
        CreAuraInfoFrames[i].FontString:SetText("|cFF00FF00玩家|r");
    else
        CreAuraInfoFrames[i].FontString:SetText("|cFF00FF00怪物|r");
    end

    CreAuraInfoFrames[i].PageStr = CreAuraInfoFrames[i]:CreateFontString("$parent".."PageStr"..i);
    CreAuraInfoFrames[i].PageStr:SetFont(Dream_GameFont, 13);
    CreAuraInfoFrames[i].PageStr:SetPoint("LEFT", CreAuraInfoFrames[i], 13, -10);
    CreAuraInfoFrames[i].PageStr:SetText("|cFF00FF00第"..CreAuraInfoFrames[i].SelectPage.."页|r");

    CreAuraInfoFrames[i].CreAuraTexture1 = CreAuraInfoFrames[i]:CreateTexture();
    CreAuraInfoFrames[i].CreAuraTexture1:SetTexture("Interface\\Icons\\AuraTexture");
    CreAuraInfoFrames[i].CreAuraTexture1:SetSize(60, 60);
    CreAuraInfoFrames[i].CreAuraTexture1:SetPoint("LEFT", CreAuraInfoFrames[i], 0, 0);
    CreAuraInfoFrames[i].KeySpells = {};
    for j=1, MaxAuras do
        CreAuraInfoFrames[i].KeySpells[j] = CreateFrame("Button", "$parent".."KeySpells"..j, CreAuraInfoFrames[i]);
        CreAuraInfoFrames[i].KeySpells[j]:SetSize(48, 48);
        CreAuraInfoFrames[i].KeySpells[j]:SetBackdrop({bgFile = "Interface\\Icons\\AuraBtn"});

        CreAuraInfoFrames[i].KeySpells[j].Texture = CreAuraInfoFrames[i].KeySpells[j]:CreateTexture();
        CreAuraInfoFrames[i].KeySpells[j].Texture:SetSize(32, 32);
        CreAuraInfoFrames[i].KeySpells[j].Texture:SetPoint("CENTER", CreAuraInfoFrames[i].KeySpells[j], 0, 0);
        CreAuraInfoFrames[i].KeySpells[j].Texture:SetTexture("");

        CreAuraInfoFrames[i].KeySpells[j].SpellId = 0;
        CreAuraInfoFrames[i].KeySpells[j]:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetHyperlink("spell:"..self.SpellId);
            GameTooltip:Show();
        end)

        CreAuraInfoFrames[i].KeySpells[j]:SetScript("OnLeave",
        function(self)
	        GameTooltip:Hide();
        end)

        CreAuraInfoFrames[i].KeySpells[j]:Hide();
    end
    CreAuraInfoFrames[i].NextButton = CreateFrame("Button", "$parent".."NextButton"..i, CreAuraInfoFrames[i]);
    CreAuraInfoFrames[i].NextButton:SetSize(24, 48);
    CreAuraInfoFrames[i].NextButton:SetPoint("RIGHT", CreAuraInfoFrames[i], -10, 0);
    CreAuraInfoFrames[i].NextButton:SetNormalTexture("Interface\\Icons\\Next2");
    CreAuraInfoFrames[i].NextButton:SetPushedTexture("Interface\\Icons\\Next1");
    CreAuraInfoFrames[i].NextButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
    CreAuraInfoFrames[i]:Show();
    CreAuraInfoFrames[i].NextButton:SetScript("OnClick",
    function(self)
        DoClickNext(CreAuraInfoFrames[i]);
    end)
end

SecretInfoFrame:SetScript("OnShow",
function(self)

end)

--消息处理
local function Dream_OnSecretAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "ShowNowSecretPlaceInfo") then
            SecretInfoFrame:Show();
            ResetDataUI();
            local Args = Dream_Split(Msg, "^");
            local Arg1 = Dream_Split(Args[1], "#");
            for K=1, #Arg1 do
                DoInitDataSpell(CreAuraInfoFrames[1], K, tonumber(Arg1[K]));
            end
            local Arg2 = Dream_Split(Args[2], "#");
            for N=1, #Arg2 do
                DoInitDataSpell(CreAuraInfoFrames[2], N, tonumber(Arg2[N]));
            end
            local Arg3 = Dream_Split(Args[3], "#");
            for X=1, #Arg3 do
                DoInitDataSpell(CreAuraInfoFrames[3], X, tonumber(Arg3[X]));
            end
        elseif (Packet == "UpdateSecretInfo") then
            local Args = Dream_Split(Msg, "^");
            TopMapFrameFontString:SetText(string.format("|cFF00FFFF副本: [%s]|r", Args[1]));
            SecretInfoFrameStr1:SetText(string.format("|cFFFFFF00秘境战斗剩余时间: %s|r", Args[2]));
            SecretInfoFrameStr2:SetText(string.format("|cFFFFFF00当前已死亡次数: %s次|r", Args[3]));
            SecretInfoFrameStr3:SetText(string.format("|cFFFFFF00允许死亡次数: %s次 掉落等级 %s级|r", Args[4], Args[5]));
        elseif (Packet == "CloseSecretInfo") then
            SecretInfoFrame:Hide();
        elseif (Packet == "NoFuncSecretPlace") then
            ResetDataKey();
            ResetKeyUI();
            ResetDataUI();
            DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[提示]: 这不是秘境钥匙 无法插入|r");
        elseif (Packet == "AutoKeySecretPlace") then
            ResetKeyUI();
            ResetDataUI();
            ShowDataKeyUI(Msg);
        elseif (Packet == "AutoKeySpells") then
            local Args = Dream_Split(Msg, "#");
            local Num = tonumber(Args[1]);
            local SpellId = tonumber(Args[2]);
            DoInitDataSpell(CreAuraFrames[1], Num, SpellId);
        elseif (Packet == "AutoRmKeySpells") then
            local Args = Dream_Split(Msg, "#");
            local Num = tonumber(Args[1]);
            local SpellId = tonumber(Args[2]);
            DoInitDataSpell(CreAuraFrames[2], Num, SpellId);
        elseif (Packet == "AutoKeyPlayerSpells") then
            local Args = Dream_Split(Msg, "#");
            local Num = tonumber(Args[1]);
            local SpellId = tonumber(Args[2]);
            DoInitDataSpell(CreAuraFrames[3], Num, SpellId);
        elseif (Packet == "NotKeyInBag") then
            DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[提示]: 你没有秘境钥匙 无法进入|r");
        elseif (Packet == "CompleteOrStopSecret") then
            ResetDataKey();
            ResetKeyUI();
            ResetDataUI();
		end
    elseif (event == "PLAYER_LOGIN") then
        Dream_SendData("CheckSecretPlaceGuid");
	end
end

--交互消息事件
local SecretAddonFrame = CreateFrame("Frame", "SecretAddonFrame");
SecretAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
SecretAddonFrame:RegisterEvent("PLAYER_LOGIN");
SecretAddonFrame:RegisterEvent("VARIABLES_LOADED");
SecretAddonFrame:SetScript("OnEvent", Dream_OnSecretAddonEvent);
