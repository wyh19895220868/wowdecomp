---@diagnostic disable: missing-parameter

local TnLen = 36;      --间隔
local FontSize = 15;   --字体大小
local OnIconSize = 55;   --图标大小

--更改以上项目即可

local Showed = true;
local CtLen = 78;
local BtnSize = 44;

local GtButton = {};
local GtButtonStr = {};
local TipListReceived = false;
local TipRetryElapsed = 0;
local TipRetryIndex = 1;
local TipRetryDelays = { 0.5, 2, 5 };

local function RequestFunctionList()
    TipListReceived = false;
    TipRetryElapsed = 0;
    TipRetryIndex = 1;
    Dream_SendData("TipFunction");
end

local AsFunc = {
    "NewLuckFrame",
	"SignInRewBackDropFrame",
	"ItemShopFrame",
	"ChoiceItemUpFrame",
	"RandomItemUpFrame",
	"StatPointFrame",
	"DmgRankFrame",
	"EqUpFrame",
	"PutNtRankFrame",
	"ItemCardsFrame",
	"EventShowFrame",
	"ActivityShowFrame",
	"SecretPlaceKeyFrame",
	"ItemMagicFrame",
	"ItemEnchFrame",
	"SoulItemFuncFrame",
	"NewItemEnchFrame",
	"ItemZodiacFrame",
	"CombatPetFrame",
	"TaskEnchSpellFrame",
	"PicGuideFrame",
	"ItemForgeUIFrame",
	"BeastCardFrame",
};

--显示功能类型
local FrameFuncType = {
    FuncType1,
	FuncType2,
	FuncType3,
	FuncType4,
	FuncType5,
	FuncType6,
	FuncType7,
	FuncType8,
	FuncType9,
	FuncType10,
	FuncType11,
	FuncType12,
	FuncType13,
	FuncType14,
	FuncType15,
	FuncType16,
	FuncType17,
	FuncType18,
	FuncType19,
	FuncType20,
	FuncType21,
	FuncType22,
	FuncType23,
};

local function GetFunctionIcon(index)
	local icon = _G["FuncIcon"..tostring(index)];
	return icon or FuncIcon1;
end

local SourceButton = CreateFrame("Button", "SourceButton", UIParent);
SourceButton:SetSize(30, 30);
SourceButton:SetPoint("BOTTOMRIGHT", -20, 160);
SourceButton:SetToplevel(true);
SourceButton:SetMovable(true);
SourceButton:EnableMouse(true);
SourceButton:RegisterForDrag("LeftButton");
SourceButton:SetPushedTexture("Interface\\BUTTONS\\UI-Quickslot-Depress");
SourceButton:SetBackdrop({bgFile = TipBtnRightFilePath});
SourceButton:SetScript("OnDragStart", SourceButton.StartMoving);
SourceButton:SetScript("OnHide", SourceButton.StopMovingOrSizing);
SourceButton:SetScript("OnDragStop", SourceButton.StopMovingOrSizing);
SourceButton:SetScript("OnClick",
function(self)
	if (Showed) then
        SourceButton:SetBackdrop({bgFile = TipBtnLeftFilePath});
		_G["FunctionFrame"]:Hide();
	else
		SourceButton:SetBackdrop({bgFile = TipBtnRightFilePath});
		_G["FunctionFrame"]:Show();
	end
	Showed = (not Showed);
    if not TipListReceived then RequestFunctionList(); end
end)
SourceButton:Show();

SourceButton:SetScript("OnEnter",
function(self)
    GameTooltip:SetOwner(SourceButton, "ANCHOR_TOP", 0, 20);
    GameTooltip:SetText(TipBtnText);
    GameTooltip:Show();
end)

SourceButton:SetScript("OnLeave",
function(self)
    GameTooltip:Hide();
end)

-- 初始
local FunctionFrame = CreateFrame("Frame", "FunctionFrame", SourceButton);
FunctionFrame:SetSize(#FrameFuncType * CtLen + BtnSize, 96);
FunctionFrame:RegisterForDrag("LeftButton");
FunctionFrame:SetPoint("RIGHT", SourceButton, -10, 0);
FunctionFrame:SetClampedToScreen(true);
FunctionFrame:Show();

for i=1,#FrameFuncType do
    GtButton[i] = CreateFrame("Button", "GtButton"..i, FunctionFrame, (IsRingTipBtn == 1) and "DreamRingSmButtonTemplate" or "");
	GtButton[i]:SetSize(OnIconSize, OnIconSize);
    GtButton[i]:EnableMouse(true);
    GtButton[i]:RegisterForDrag("LeftButton");
    GtButton[i]:SetPushedTexture("Interface\\BUTTONS\\UI-Quickslot-Depress");
	GtButton[i]:SetPoint("RIGHT", -(i * TnLen + (i - 1) * 20), 12);

	local BtnIcon = GetFunctionIcon(i);
	if (i == 1) then
		BtnIcon = FuncIcon1;
	elseif (i == 2) then
		BtnIcon = FuncIcon2;
	elseif (i == 3) then
		BtnIcon = FuncIcon3;
	elseif (i == 4) then
		BtnIcon = FuncIcon4;
	elseif (i == 5) then
		BtnIcon = FuncIcon5;
	elseif (i == 6) then
		BtnIcon = FuncIcon6;
	elseif (i == 7) then
		BtnIcon = FuncIcon7;
	elseif (i == 8) then
		BtnIcon = FuncIcon8;
	elseif (i == 9) then
		BtnIcon = FuncIcon9;
	elseif (i == 10) then
		BtnIcon = FuncIcon10;
	elseif (i == 11) then
		BtnIcon = FuncIcon11;
	elseif (i == 12) then
		BtnIcon = FuncIcon12;
	elseif (i == 13) then
		BtnIcon = FuncIcon13;
	elseif (i == 14) then
		BtnIcon = FuncIcon14;
	elseif (i == 15) then
		BtnIcon = FuncIcon15;
	elseif (i == 16) then
		BtnIcon = FuncIcon16;
	elseif (i == 17) then
		BtnIcon = FuncIcon17;
	elseif (i == 18) then
		BtnIcon = FuncIcon18;
	elseif (i == 19) then
		BtnIcon = FuncIcon19;
	elseif (i == 20) then
		BtnIcon = FuncIcon20;
	elseif (i == 21) then
		BtnIcon = FuncIcon21;
	elseif (i == 22) then
		BtnIcon = FuncIcon22;
	elseif (i == 23) then
		BtnIcon = FuncIcon23;
	end

	GtButton[i]:SetBackdrop({bgFile = BtnIcon})

	GtButton[i]:SetID(i);

	GtButtonStr[i] = GtButton[i]:CreateFontString("GtButtonStr"..i);
	GtButtonStr[i]:SetFont(Dream_GameFont, FontSize);
	GtButtonStr[i]:SetPoint("CENTER", 0, -36);
	GtButtonStr[i]:SetText(FrameFuncType[i]);

	GtButton[i]:Hide();

	GtButton[i]:SetScript("OnClick",
    function(self)
		MouseImplement(self:GetID());
    end)

	GtButton[i]:SetScript("OnEnter",
    function(self)
        local index = self:GetID();
        GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:SetText(FrameFuncType[index].."["..index.."]".."|r"..OnFuncText);
        GameTooltip:Show();
    end)
	GtButton[i]:SetScript("OnLeave",
    function(self)
        GameTooltip:Hide();
    end)
end

function MouseImplement(Num)
	for i=1,#AsFunc do
	    if (_G[AsFunc[i]]) then
			if (i ~= Num) then
		        _G[AsFunc[i]]:Hide();
		    else
		        if (_G[AsFunc[i]]:IsShown()) then
			        _G[AsFunc[i]]:Hide();
			    else
			        _G[AsFunc[i]]:Show();
			    end
		    end
		end
	end

	if (Num == 22 and ItemForgeUI and ItemForgeUI.RefreshContent) then
		ItemForgeUI:RefreshContent();
	end
end

--消息处理
local function Dream_OnTipFunctionEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "BackTipFunction") then
            TipListReceived = true;
			SourceButton:Show();
			for i=1,#FrameFuncType do
				GtButton[i]:Hide();
				GtButton[i]:ClearAllPoints();
				GtButtonStr[i]:Hide();
				GtButtonStr[i]:ClearAllPoints();
				GtButtonStr[i]:SetText("");
			end
			if (Msg == "") then
				SourceButton:Hide();
				return;
			end
			local Args = Dream_Split(Msg, "#");
			FunctionFrame:SetSize(#Args * CtLen + BtnSize, 96);
			for i=1,#Args do
				local Num = tonumber(Args[i]);
				GtButton[Num]:Show();
				GtButton[Num]:SetPoint("RIGHT", -(i * TnLen + (i - 1) * 20), 12);

				local BtnIcon = GetFunctionIcon(Num);
				if (Num == 1) then
					BtnIcon = FuncIcon1;
				elseif (Num == 2) then
					BtnIcon = FuncIcon2;
				elseif (Num == 3) then
					BtnIcon = FuncIcon3;
				elseif (Num == 4) then
					BtnIcon = FuncIcon4;
				elseif (Num == 5) then
					BtnIcon = FuncIcon5;
				elseif (Num == 6) then
					BtnIcon = FuncIcon6;
				elseif (Num == 7) then
					BtnIcon = FuncIcon7;
				elseif (Num == 8) then
					BtnIcon = FuncIcon8;
				elseif (Num == 9) then
					BtnIcon = FuncIcon9;
				elseif (Num == 10) then
					BtnIcon = FuncIcon10;
				elseif (Num == 11) then
					BtnIcon = FuncIcon11;
				elseif (Num == 12) then
					BtnIcon = FuncIcon12;
				elseif (Num == 13) then
					BtnIcon = FuncIcon13;
				elseif (Num == 14) then
					BtnIcon = FuncIcon14;
				elseif (Num == 15) then
					BtnIcon = FuncIcon15;
				elseif (Num == 16) then
					BtnIcon = FuncIcon16;
				elseif (Num == 17) then
					BtnIcon = FuncIcon17;
				elseif (Num == 18) then
					BtnIcon = FuncIcon18;
				elseif (Num == 19) then
					BtnIcon = FuncIcon19;
				elseif (Num == 20) then
					BtnIcon = FuncIcon20;
				elseif (Num == 21) then
					BtnIcon = FuncIcon21;
				elseif (Num == 22) then
					BtnIcon = FuncIcon22;
				elseif (Num == 23) then
					BtnIcon = FuncIcon23;
				end

				GtButton[Num]:SetBackdrop({bgFile = BtnIcon});

				GtButtonStr[Num]:Show();
				GtButtonStr[Num]:SetPoint("CENTER", 0, -36);
				GtButtonStr[Num]:SetText(FrameFuncType[Num]);
			end
		elseif (Packet == "ResetUI") then
            RequestFunctionList();
		elseif (Packet == "OpenRandomUpUI") then
			if (_G[AsFunc[5]]) then
				if (_G[AsFunc[5]]:IsShown()) then
			        _G[AsFunc[5]]:Hide();
			    else
			        _G[AsFunc[5]]:Show();
			    end
			end
		end
    elseif (event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD") then
        RequestFunctionList();
	end
end

--交互消息事件
local TipFunctionFrame = CreateFrame("Frame", "TipFunctionFrame");
TipFunctionFrame:RegisterEvent("CHAT_MSG_ADDON");
TipFunctionFrame:RegisterEvent("PLAYER_LOGIN");
TipFunctionFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
TipFunctionFrame:SetScript("OnEvent", Dream_OnTipFunctionEvent);
-- The native client can load this file after PLAYER_LOGIN during a UI reload.
TipFunctionFrame:SetScript("OnUpdate", function(self, elapsed)
    if TipListReceived or not TipRetryDelays[TipRetryIndex] then return; end
    TipRetryElapsed = TipRetryElapsed + elapsed;
    local PlayerName = UnitName("player");
    if TipRetryElapsed >= TipRetryDelays[TipRetryIndex] and PlayerName and PlayerName ~= "" then
        TipRetryIndex = TipRetryIndex + 1;
        Dream_SendData("TipFunction");
    end
end);
