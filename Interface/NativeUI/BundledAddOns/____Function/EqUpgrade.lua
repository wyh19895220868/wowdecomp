---@diagnostic disable: missing-parameter

local ButtonIcons =
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
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-SecondaryHand",--副手
	"Interface\\PaperDoll\\UI-PaperDoll-Slot-Ranged",--远程
}

local ItemTypes =
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

--静态弹出框
StaticPopupDialogs["EqNeedInfo"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",
	
	OnAccept = function(Self)
        Dream_SendData("AcceptEqNeedInfo", Self.SlotStr);
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

local AtItemEqIcons = { }
local AtItemEqButtons = { }
local AtItemEqButtonStrs = { }
local AtItemEqButtonBars = { }

local EqUpFrame = CreateFrame("Frame", "EqUpFrame", UIParent);
EqUpFrame:SetSize(1040, 480);
EqUpFrame:RegisterForDrag("LeftButton");
EqUpFrame:SetPoint("CENTER");
EqUpFrame:SetToplevel(true);
EqUpFrame:SetClampedToScreen(true);
EqUpFrame:SetBackdrop({ bgFile = EqUpBIcon })
tinsert(UISpecialFrames, "EqUpFrame");
EqUpFrame:Hide();

-- 关闭按钮
local EqUpClose = CreateFrame("Button", "EqUpClose", EqUpFrame, "UIPanelCloseButton");
EqUpClose:SetPoint("TOPRIGHT", -140, -8)
EqUpClose:EnableMouse(true);
EqUpClose:SetSize(32, 32);

for i=1,19 do
	AtItemEqIcons[i] = CreateFrame("Frame", "AtItemEqIcons"..i, EqUpFrame)
	AtItemEqIcons[i]:SetFrameStrata("TOOLTIP")
	AtItemEqIcons[i]:SetSize(36, 36)
	AtItemEqIcons[i]:SetBackdrop({ bgFile = ButtonIcons[i] })

	AtItemEqButtons[i] = CreateFrame("Button", "AtItemEqButtons"..i, EqUpFrame)
	AtItemEqButtons[i]:SetSize(300, 36)

	AtItemEqButtonStrs[i] = AtItemEqButtons[i]:CreateFontString("AtItemEqButtonStrs"..i);
	AtItemEqButtonStrs[i]:SetFont(Dream_GameFont, 16);
	AtItemEqButtonStrs[i]:SetAllPoints(AtItemEqButtons[i]);
	AtItemEqButtons[i]:SetFontString(AtItemEqButtonStrs[i]);
	AtItemEqButtons[i]:SetText("|cFF00FFFF"..ItemTypes[i].."装备栏0级|r");
	AtItemEqButtons[i]:SetID(i);
	AtItemEqButtons[i].ModStr = "0";

	AtItemEqButtonBars[i] = CreateFrame("StatusBar", "AtItemEqButtonBars"..i, AtItemEqButtons[i])
	AtItemEqButtonBars[i]:SetSize(170, 32)
	AtItemEqButtonBars[i]:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	AtItemEqButtonBars[i]:SetStatusBarColor(0/255, 255/255, 0/255, 0.4)
	AtItemEqButtonBars[i]:SetMinMaxValues(1, 10000)
	AtItemEqButtonBars[i]:SetValue(0)

	if (i < 9) then
		AtItemEqButtons[i]:SetBackdrop({bgFile = EqUpLeftIcon })
		AtItemEqIcons[i]:SetPoint("LEFT", 240, 136 - (i - 1) * 36)
		AtItemEqButtons[i]:SetPoint("LEFT", 195, 136 - (i - 1) * 36)
		AtItemEqButtonBars[i]:SetPoint("LEFT", 84, 0)
	elseif (i < 17) then
		AtItemEqButtons[i]:SetBackdrop({bgFile = EqUpRightIcon })
		AtItemEqIcons[i]:SetPoint("RIGHT", -260, 136- (i - 9) * 36)
		AtItemEqButtons[i]:SetPoint("RIGHT", -215, 136 - (i - 9) * 36)
		AtItemEqButtonBars[i]:SetPoint("LEFT", 48, 0)
	else
		AtItemEqButtons[i]:SetBackdrop({bgFile = EqUpDIcon })
		AtItemEqIcons[i]:SetPoint("BOTTOMLEFT", (i - 17) * 240 + 160, 36)
		AtItemEqButtons[i]:SetPoint("BOTTOMLEFT", (i - 17) * 240 + 114, 36)
		AtItemEqButtonBars[i]:SetPoint("LEFT", 84, 0)
	end

	--鼠标显示图标
	AtItemEqButtons[i]:SetScript("OnEnter",
	function(self)
		if (i < 9) then
		    GameTooltip:SetOwner(AtItemEqButtons[i], "ANCHOR_TOP", 50, 0);
	    elseif (i < 17) then
			GameTooltip:SetOwner(AtItemEqButtons[i], "ANCHOR_TOP", -50, 0);
		else
			GameTooltip:SetOwner(AtItemEqButtons[i], "ANCHOR_TOP", 50, 0);
		end
		GameTooltip:SetText("穿戴的"..ItemTypes[i].."装备属性提高"..self.ModStr.."%");
		GameTooltip:Show();
	end)
	
	AtItemEqButtons[i]:SetScript("OnLeave",
	function(self)
		GameTooltip:Hide();
	end)

	AtItemEqButtons[i]:SetScript("OnClick",
    function(self)
        UpdateClickButton(i);
    end)
end

EqUpFrame:SetScript("OnHide",
function(self)
    StaticPopup_Hide("EqNeedInfo");
end)

EqUpFrame:SetScript("OnShow",
function(self)
    EqUpFrame:SetAlpha(1.0);
end)

function UpdateClickButton(Num)
	Dream_SendData("EqPlayerInfoSlot", tostring(Num));
end

--消息处理
local function Dream_OnEqUpEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "ApplyMeEqSlotData") then
			local Args = Dream_Split(Msg, "$");
			for i=1,#Args do
				local Arg = Dream_Split(Args[i], "#");
				local Num = tonumber(Arg[1]);
				AtItemEqButtonBars[Num]:SetMinMaxValues(1, tonumber(Arg[3]))
				AtItemEqButtonBars[Num]:SetValue(tonumber(Arg[2]))
				AtItemEqButtons[Num]:SetText("|cFF00FFFF"..ItemTypes[Num].."装备栏"..Arg[2].."级|r");
				AtItemEqButtons[Num].ModStr = string.format("%.f", tonumber(Arg[4]));
			end
		elseif (Packet == "NowEqNeedInfo") then
			local Args = Dream_Split(Msg, "#");
			local Dialog = StaticPopup_Show("EqNeedInfo", "\n|cFF00FF00提升此装备栏|r\n\n"..Args[2].."\n\n|cFF00FF00你确定要这么做吗?|r");
	        if (Dialog) then
				Dialog.SlotStr = Args[1];
				EqUpFrame:SetAlpha(0.6);
		        Dialog:SetScript("OnHide",
                function(self)
				    EqUpFrame:SetAlpha(1.0);
                end)
	        end
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("GetMeEqSlotData");
	end
end

--交互消息事件
local EqUpFrame = CreateFrame("Frame", "EqUpFrame");
EqUpFrame:RegisterEvent("CHAT_MSG_ADDON");
EqUpFrame:RegisterEvent("PLAYER_LOGIN");
EqUpFrame:SetScript("OnEvent", Dream_OnEqUpEvent);