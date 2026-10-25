---@diagnostic disable: missing-parameter

local DayButtons = {}
local DayStrings = {}

local NowYear = tonumber(date("%Y"));
local NowMonth = tonumber(date("%m"));
local NowDay = tonumber(date("%d"));

--local _, MaxMonth, _, MaxYear = CalendarGetMaxDate()
--local _, MinMonth, _, MinYear = CalendarGetMinDate()

local SignInRewSubFrames = {}
local DayStr = {}

local SignInRewShowButtons = {}
local SignInRewShowButtonStrs = {}
local SignInRewShowButtonCountStrs = {}

local SignInContinuousRewButtons = {}
local SignInContinuousRewButtonStrs = {}
local SignInContinuousRewButtonCountStrs = {}

local SignInTotalRewButtons = {}
local SignInTotalRewButtonStrs = {}
local SignInTotalRewButtonCountStrs = {}

local PlayerSeriesDays = 0;
local PlayerTotalDays = 0;
local PlayerSignInData = {}
local RewardSignInData = {}

local ContinuousDays = 0;
local TotalDays = 0;

local ExtraCRew = 111;     --定义的连续奖励序号 不可更改
local ExtraTRew = 222;     --定义的连续奖励序号 不可更改

--以上变量不可更改

function MeSetBackdrop(Button, BgFile)
    Button:SetBackdrop({ bgFile = BgFile })
end

----------------------------------------------------------------------------------------------------
-- 奖励窗口 主窗口
local SignInRewBackDropFrame = CreateFrame("Frame", "SignInRewBackDropFrame", EventSignFrame)
SignInRewBackDropFrame:SetSize(400, 400)
SignInRewBackDropFrame:RegisterForDrag("LeftButton")
SignInRewBackDropFrame:SetPoint("CENTER", -160, 50)
SignInRewBackDropFrame:SetToplevel(true);
SignInRewBackDropFrame:SetClampedToScreen(true);
SignInRewBackDropFrame:SetBackdrop({ bgFile = SignBIcon })

tinsert(UISpecialFrames, "SignInRewBackDropFrame")

SignInRewBackDropFrame:Hide()

-- 关闭按钮
local SignInRewBackDropFrameClose = CreateFrame("Button", "SignInRewBackDropFrameClose", SignInRewBackDropFrame, "UIPanelCloseButton")
SignInRewBackDropFrameClose:SetPoint("TOPRIGHT", -35, -5)
SignInRewBackDropFrameClose:EnableMouse(true)
SignInRewBackDropFrameClose:SetSize(30, 30)

-- 关闭按钮
local EventSignFrameClose = CreateFrame("Button", "EventSignFrameClose", SignInRewBackDropFrame, "UIPanelCloseButton")
EventSignFrameClose:SetPoint("TOPRIGHT", 315, -5)
EventSignFrameClose:EnableMouse(true)
EventSignFrameClose:SetSize(30, 30)

--滚动窗口
local SignInRewScrollFrame = CreateFrame("ScrollFrame","SignInRewScrollFrame",SignInRewBackDropFrame)
SignInRewScrollFrame:SetSize(680, 360)
SignInRewScrollFrame:SetPoint("CENTER", 180, -20)
SignInRewScrollFrame:Show()
SignInRewScrollFrame:EnableMouse(true)
SignInRewScrollFrame:EnableMouseWheel(true)

--滚动子窗口
local SignInRewScrollChildFrame = CreateFrame("Frame","SignInRewScrollChildFrame",SignInRewScrollFrame) 
SignInRewScrollChildFrame:SetSize(680, 360)
SignInRewScrollChildFrame:SetPoint("CENTER")
SignInRewScrollChildFrame:Show()
SignInRewScrollFrame:SetScrollChild(SignInRewScrollChildFrame)


local SignInRewSlider = CreateFrame("Slider","SignInRewSlider",SignInRewScrollFrame)
SignInRewSlider:SetOrientation("VERTICAL")
SignInRewSlider:SetMinMaxValues(0, 100)
SignInRewSlider:SetValue(0)
SignInRewSlider:SetValueStep(1.0)
SignInRewSlider:SetPoint("LEFT",SignInRewScrollFrame,"RIGHT", 0, 0)
SignInRewSlider:SetSize(32, 32)

SignInRewSlider:SetScript("OnValueChanged",
function(self,offset)
    SignInRewScrollFrame:SetVerticalScroll(math.ceil((SignInRewScrollChildFrame:GetHeight() - SignInRewScrollFrame:GetHeight()) / 100 * self:GetValue()))
end)

SignInRewScrollFrame:SetScript("OnMouseWheel",
function(self, Val)
	local MinVal,MaxVal = SignInRewSlider:GetMinMaxValues()
	local InVal = SignInRewSlider:GetValue()
	local De = InVal - (Val * 4)
	De = max(De, MinVal)
	De = min(De, MaxVal)
	if (De ~= InVal) then
		SignInRewSlider:SetValue(De);
	end
end)

local _, _, MonthDays, _ = CalendarGetMonth(0)
for i=1,MonthDays do
	SignInRewSubFrames[i] = CreateFrame("Frame", "SignInRewSubFrame"..i, SignInRewScrollChildFrame)
    SignInRewSubFrames[i]:SetSize(254, 56)
    SignInRewSubFrames[i]:SetPoint("TOP", SignInRewScrollChildFrame, -180, -((SignInRewSubFrames[i]:GetHeight()-5) * (i - 1) + 5))

    DayStr[i] = SignInRewSubFrames[i]:CreateFontString("DayStr"..i)
    DayStr[i]:SetFont(Dream_GameFont, 15)
    DayStr[i]:SetPoint("LEFT", SignInRewSubFrames[i], 10, 8)
    DayStr[i]:SetText("|cFF00FF00"..i.."日|r")

	SignInRewShowButtons[i] = {}
	SignInRewShowButtonStrs[i] = {}
	SignInRewShowButtonCountStrs[i] = {}

	for j=1,6 do
	    SignInRewShowButtons[i][j] = CreateFrame("Button", "SignInShowButton["..i.."]"..j, SignInRewSubFrames[i])
        SignInRewShowButtons[i][j]:SetSize(30, 30)
        SignInRewShowButtons[i][j]:SetPoint("LEFT", SignInRewSubFrames[i], 44 + ((SignInRewShowButtons[i][j]:GetWidth() + 4) * (j - 1)), 8)
        SignInRewShowButtons[i][j]:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight")
        SignInRewShowButtons[i][j]:SetBackdrop( { bgFile = SignItemIcon })
        SignInRewShowButtonStrs[i][j] = SignInRewShowButtons[i][j]:CreateFontString("$parent".."Str"..j)
        SignInRewShowButtonStrs[i][j]:SetFont(Dream_GameFont, 9)
        SignInRewShowButtonStrs[i][j]:SetAllPoints(SignInRewShowButtons[i][j])
        SignInRewShowButtons[i][j]:SetFontString(SignInRewShowButtonStrs[i][j])
        SignInRewShowButtonCountStrs[i][j] = SignInRewShowButtons[i][j]:CreateFontString("$parent".."CStr"..j)
        SignInRewShowButtonCountStrs[i][j]:SetFont(Dream_GameFont, 12, "OUTLINE")
        SignInRewShowButtonCountStrs[i][j]:SetPoint("CENTER", SignInRewShowButtons[i][j], 0, -16)
	end
end

SignInRewScrollChildFrame:SetHeight(56 * MonthDays)

--额外奖励窗口
local ExtraRewFrame = CreateFrame("Frame", "ExtraRewFrame", SignInRewBackDropFrame)
ExtraRewFrame:SetSize(350, 110)
ExtraRewFrame:SetPoint("BOTTOMRIGHT", 310, 4)
ExtraRewFrame:SetBackdrop({ bgFile = ERewardIcon })

local SignInContinuousRewFrame = CreateFrame("Frame", "SignInContinuousRewFrame", ExtraRewFrame)
SignInContinuousRewFrame:SetSize(340, 48)
SignInContinuousRewFrame:SetPoint("BOTTOM", ExtraRewFrame, 0, 34)
SignInContinuousRewFrame:SetFrameStrata("HIGH")
local SignInContinuousRewStr = SignInContinuousRewFrame:CreateFontString("SignInContinuousRewStr")
SignInContinuousRewStr:SetFont(Dream_GameFont, 13)
SignInContinuousRewStr:SetPoint("LEFT", SignInContinuousRewFrame, 10, 0)

local SignInTotalRewFrame = CreateFrame("Frame", "SignInTotalRewFrame", ExtraRewFrame)
SignInTotalRewFrame:SetSize(340, 48)
SignInTotalRewFrame:SetPoint("BOTTOM", ExtraRewFrame, 0, -3)
SignInTotalRewFrame:SetFrameStrata("HIGH")
local SignInTotalRewStr = SignInTotalRewFrame:CreateFontString("SignInTotalRewStr")
SignInTotalRewStr:SetFont(Dream_GameFont, 13)
SignInTotalRewStr:SetPoint("LEFT", SignInTotalRewFrame, 10, 0)

for i=1,6 do
    SignInContinuousRewButtons[i] = CreateFrame("Button", "SignInContinuousRewButtons"..i, SignInContinuousRewFrame)
    SignInContinuousRewButtons[i]:SetSize(30, 30)
    SignInContinuousRewButtons[i]:SetPoint("LEFT", SignInContinuousRewFrame, 105 + ((SignInContinuousRewButtons[i]:GetWidth() + 7) * (i - 1)), 2)
    SignInContinuousRewButtons[i]:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight")
	SignInContinuousRewButtons[i]:SetBackdrop( { bgFile = SignItemIcon })
    SignInContinuousRewButtonStrs[i] = SignInContinuousRewButtons[i]:CreateFontString("SignInContinuousRewButtonStrs"..i)
    SignInContinuousRewButtonStrs[i]:SetFont(Dream_GameFont, 9)
    SignInContinuousRewButtonStrs[i]:SetAllPoints(SignInContinuousRewButtons[i])
    SignInContinuousRewButtons[i]:SetFontString(SignInContinuousRewButtonStrs[i])
    SignInContinuousRewButtonCountStrs[i] = SignInContinuousRewButtons[i]:CreateFontString("SignInContinuousRewButtonCountStrs"..i)
    SignInContinuousRewButtonCountStrs[i]:SetFont(Dream_GameFont, 9, "OUTLINE")
    SignInContinuousRewButtonCountStrs[i]:SetPoint("CENTER", SignInContinuousRewButtons[i], 0, -16)

	SignInTotalRewButtons[i] = CreateFrame("Button", "SignInTotalRewButtons"..i, SignInTotalRewFrame)
    SignInTotalRewButtons[i]:SetSize(30, 30)
    SignInTotalRewButtons[i]:SetPoint("LEFT", SignInTotalRewFrame, 105 + ((SignInTotalRewButtons[i]:GetWidth() + 7) * (i - 1)), 2)
    SignInTotalRewButtons[i]:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight")
	SignInTotalRewButtons[i]:SetBackdrop( { bgFile = SignItemIcon })
    SignInTotalRewButtonStrs[i] = SignInTotalRewButtons[i]:CreateFontString("SignInTotalRewButtonStrs"..i)
    SignInTotalRewButtonStrs[i]:SetFont(Dream_GameFont, 9)
    SignInTotalRewButtonStrs[i]:SetAllPoints(SignInTotalRewButtons[i])
    SignInTotalRewButtons[i]:SetFontString(SignInTotalRewButtonStrs[i])
    SignInTotalRewButtonCountStrs[i] = SignInTotalRewButtons[i]:CreateFontString("SignInTotalRewButtonCountStrs"..i)
    SignInTotalRewButtonCountStrs[i]:SetFont(Dream_GameFont, 9, "OUTLINE")
    SignInTotalRewButtonCountStrs[i]:SetPoint("CENTER", SignInTotalRewButtons[i], 0, -16)
end

----------------------------------------------------------------------------------------------------
--签到窗口
local EventSignFrame = CreateFrame("Frame", "EventSignFrame", SignInRewBackDropFrame)
EventSignFrame:SetSize(360, 300)
EventSignFrame:SetPoint("TOPRIGHT", 315, 16)
EventSignFrame:SetBackdrop({ bgFile = DateIcon })

-- 下边文字
local SignTisText = EventSignFrame:CreateFontString("SignTisText")
SignTisText:SetFont(Dream_GameFont, 12)
SignTisText:SetPoint("BOTTOM", 0, 20)
SignTisText:SetText("|cFFFF66FF连签:|r |cFF00FF00"..PlayerSeriesDays.."天|r |cFF999999[未达成奖励]|r |cFFFF66FF累签:|r |cFF00FF00"..PlayerTotalDays.."天|r |cFF999999[未达成奖励]|r")

-- 补签文字
local RepairText = EventSignFrame:CreateFontString("RepairText")
RepairText:SetFont(Dream_GameFont, 12)
RepairText:SetPoint("CENTER", 0, -220)
RepairText:SetVertexColor(0, 255/255, 0)

-- 中间月份
local EventSignMonthButtonCenter = CreateFrame("Button", "EventSignMonthButtonCenter", EventSignFrame)
EventSignMonthButtonCenter:SetSize(120, 30)
EventSignMonthButtonCenter:SetPoint("TOP", 0, -32)
EventSignMonthButtonCenter:EnableMouse(true)

-- 月份说明
local ButtonCenterStr  = EventSignMonthButtonCenter:CreateFontString("ButtonCenterStr")
ButtonCenterStr:SetFont(Dream_GameFont, 15)
ButtonCenterStr:SetPoint("CENTER")

for i=1,42,1 do
    DayButtons[i] = CreateFrame("Button", "DayButton"..i, EventSignFrame)
	DayButtons[i]:SetSize(46, 30)
	if (i < 8) then
	    DayButtons[i]:SetPoint("LEFT", (i - 1) * 44 + 24, 51)
	elseif (i > 7 and i < 15) then
	    DayButtons[i]:SetPoint("LEFT", (i - 7 - 1) * 44 + 24, 23)
	elseif (i > 14 and i < 22) then
	    DayButtons[i]:SetPoint("LEFT", (i - 14 - 1) * 44 + 24, -5)
    elseif (i > 21 and i < 29) then
	    DayButtons[i]:SetPoint("LEFT", (i - 21 - 1) * 44 + 24, -33)
	elseif (i > 28 and i < 36) then
	    DayButtons[i]:SetPoint("LEFT", (i - 28 - 1) * 44 + 24, -61)
    else
	    DayButtons[i]:SetPoint("LEFT", (i - 35 - 1) * 44 + 24, -89)
	end

	DayButtons[i]:SetHighlightTexture("Interface\\Buttons\\UI-Quickslot-Depress")

	DayButtons[i]:SetScript("OnClick",
    function(self)
	    UpDateSignDay(i)
    end)

	DayStrings[i] = DayButtons[i]:CreateFontString("DayString"..i)
	DayStrings[i]:SetPoint("CENTER")
	DayStrings[i]:SetFont(Dream_GameFont, 15)
end

--------------------------------------------------------------------------------------------------------------------------------

EventSignFrame:SetScript("OnShow",
function(self)
	UpdateDayEvent()
end)

SignInRewBackDropFrame:SetScript("OnHide",
function(self)
    StaticPopup_Hide("SignRepair");
end)

SignInRewBackDropFrame:SetScript("OnShow",
function(self)
	FuncFrameUpdateAlpha(SignInRewBackDropFrame, true);
    SignInRewSlider:SetValue(0);
    SignInContinuousRewStr:SetText("|cFF00FF00连续签到"..ContinuousDays.."天|r")
	SignInTotalRewStr:SetText("|cFF00FF00累计签到"..TotalDays.."天|r")
    local Month, Year, NumDays, FirstWeekday = CalendarGetMonth(0)
	for i=1,NumDays do
	    for j=1,6 do
			if (RewardSignInData[i]) then
			    if (tonumber(RewardSignInData[i][j * 2 - 1]) ~= 0) then
	                SignInRewShowButtons[i][j]:SetText("|T"..DreamGetItemIcon(tonumber(RewardSignInData[i][j * 2 - 1]))..":30|t");

					SignInRewShowButtons[i][j]:SetScript("OnEnter",
					    function()
						    GameTooltip:SetOwner(SignInRewShowButtons[i][j], "ANCHOR_RIGHT");
						    Dream_SetTooltipItemId(GameTooltip, tonumber(RewardSignInData[i][j * 2 - 1]));
						    GameTooltip:SetFrameStrata("TOOLTIP");GameTooltip:Show()
						end)
                    SignInRewShowButtons[i][j]:SetScript("OnLeave",
					    function()
						    GameTooltip:SetOwner(SignInRewShowButtons[i][j], "ANCHOR_RIGHT");
						    GameTooltip:Hide()
						end)
				end
				if (tonumber(RewardSignInData[i][j * 2]) ~= 0) then
			        SignInRewShowButtonCountStrs[i][j]:SetText("|cFFFF6600"..RewardSignInData[i][j * 2].."|r");
				end
	        end
	    end
    end

	for i=1,6 do
		SignInContinuousRewButtons[i]:SetText("")
		SignInContinuousRewButtonCountStrs[i]:SetText("")
		SignInTotalRewButtons[i]:SetText("")
		SignInTotalRewButtonCountStrs[i]:SetText("")

		if (RewardSignInData[ExtraCRew]) then
		    if (tonumber(RewardSignInData[ExtraCRew][i * 2 - 1]) ~= 0) then
			    SignInContinuousRewButtons[i]:SetText("|T"..DreamGetItemIcon(tonumber(RewardSignInData[ExtraCRew][i * 2 - 1]))..":24|t")

				SignInContinuousRewButtons[i]:SetScript("OnEnter",
					function()
						GameTooltip:SetOwner(SignInContinuousRewButtons[i], "ANCHOR_RIGHT");
						Dream_SetTooltipItemId(GameTooltip, tonumber(RewardSignInData[ExtraCRew][i * 2 - 1]));
						GameTooltip:SetFrameStrata("TOOLTIP");GameTooltip:Show()
				    end)
                    SignInContinuousRewButtons[i]:SetScript("OnLeave",
					function()
						GameTooltip:SetOwner(SignInContinuousRewButtons[i], "ANCHOR_RIGHT");
						GameTooltip:Hide()
					end)
			end
			if (tonumber(RewardSignInData[ExtraCRew][i * 2]) ~= 0) then
			    SignInContinuousRewButtonCountStrs[i]:SetText("|cFFFF6600"..RewardSignInData[ExtraCRew][i * 2].."|r");
			end
		end
		if (RewardSignInData[ExtraTRew]) then
		    if (tonumber(RewardSignInData[ExtraTRew][i * 2 - 1]) ~= 0) then
			    SignInTotalRewButtons[i]:SetText("|T"..DreamGetItemIcon(tonumber(RewardSignInData[ExtraTRew][i * 2 - 1]))..":24|t")

				SignInTotalRewButtons[i]:SetScript("OnEnter",
					function()
						GameTooltip:SetOwner(SignInTotalRewButtons[i], "ANCHOR_RIGHT");
						Dream_SetTooltipItemId(GameTooltip, tonumber(RewardSignInData[ExtraTRew][i * 2 - 1]));
						GameTooltip:SetFrameStrata("TOOLTIP");GameTooltip:Show()
				    end)
                SignInTotalRewButtons[i]:SetScript("OnLeave",
					function()
						GameTooltip:SetOwner(SignInTotalRewButtons[i], "ANCHOR_RIGHT");
						GameTooltip:Hide()
					end)
			end
			if (tonumber(RewardSignInData[ExtraTRew][i * 2]) ~= 0) then
			    SignInTotalRewButtonCountStrs[i]:SetText("|cFFFF6600"..RewardSignInData[ExtraTRew][i * 2].."|r");
			end
		end
    end
end)

function UpdateDayEvent()
	local NowClick = 0;
    local PreMonth, PreYear, PreNumDays, PreFirstWeekday = CalendarGetMonth(NowClick - 1)
    local Month, Year, NumDays, FirstWeekday = CalendarGetMonth(NowClick)
	local NextMonth, NextYear, NextNumDays, NextFirstWeekday = CalendarGetMonth(NowClick + 1)

	local PreFirstDay = PreNumDays - (FirstWeekday - 1)
	local NextFirstDay = NumDays + FirstWeekday - 1
	local FirstDay = FirstWeekday - 1

	ButtonCenterStr:SetText("|cFFFFFF00"..Year.."年"..Month.."月|r")

	for i=1,42,1 do
		DayStrings[i]:SetVertexColor(204/255, 204/255, 204/255)
		DayStrings[i]:SetAlpha(0.5)
		if (i < FirstWeekday) then
		    DayStrings[i]:SetText(tostring(i + PreFirstDay))
			DayButtons[i].Year = PreYear
			DayButtons[i].Month = PreMonth
		elseif (i > NextFirstDay) then
		    DayStrings[i]:SetText(tostring(i - NextFirstDay))
			DayButtons[i].Year = NextYear
			DayButtons[i].Month = NextMonth
		else
			DayStrings[i]:SetVertexColor(255/255, 255/255, 0)
			DayStrings[i]:SetAlpha(1)
			DayStrings[i]:SetText(tostring(i - FirstDay))
			DayButtons[i].Year = Year
			DayButtons[i].Month = Month

			local UiDay = tonumber(DayStrings[i]:GetText())

			if (Year == NowYear and Month == NowMonth) then
				if (UiDay == NowDay) then
					if (PlayerSignInData[UiDay] ~= nil) then
						MeSetTexture(DayButtons[i], InSIcon)
					end
					if (PlayerSignInData[UiDay] == nil) then
						DoPrepareScript(DayButtons[i], "|cFFFF0033今天|r\n|cFFFFCC66点击签到|r")
					else
						DoPrepareScript(DayButtons[i], "|cFFFF0033今天|r\n|cFFFFCC66已经签到|r")
					end
				elseif (UiDay > NowDay) then
					DoPrepareScript(DayButtons[i], "|cFFFF0033还未到达|r\n|cFFFFCC66不可签到|r")
				elseif (UiDay < NowDay) then
					MeSetTexture(DayButtons[i], (PlayerSignInData[UiDay] == nil) and NoSIcon or InSIcon)
					if (PlayerSignInData[UiDay] == nil) then
						DoPrepareScript(DayButtons[i], "|cFFFF0033错过日期|r\n|cFFFFCC66点击补签|r")
					else
						DoPrepareScript(DayButtons[i], "|cFFFFCC66已经签到|r")
					end
				end

			else
				DoPrepareScript(DayButtons[i], "")
			end
		end
	end
end

--静态弹出框
StaticPopupDialogs["SignRepair"] = {

	text = "%s",
	button1 = "确定",
	button2 = "取消",

	OnAccept = function(Self)
		Dream_SendData("OnStartSign", Self.UiYear.."#"..Self.UiMonth.."#"..Self.UiDay.."#");
	end,

	OnCancel = function(Self)

	end,

	OnShow = function(Self)

	end,

	exclusive = true,
	whileDead = true,
	hideOnEscape = true,
	timeout = 0,
	hasEditBox = false,
};

function ApplyPlayerSignData(Msg)
	local Args = Dream_Split(Msg, "$");
	local Day = tonumber(Args[1]);
	PlayerSeriesDays = tonumber(Args[2]);
	PlayerTotalDays = tonumber(Args[3]);
	PlayerSignInData[Day] = 1;
	UpdateDayEvent();

	local GtsStr1 = (PlayerSeriesDays >= ContinuousDays) and "|cFF00FF00[已达成奖励]|r" or "|cFF999999[未达成奖励]|r";
	local GtsStr2 = (PlayerTotalDays >= TotalDays) and "|cFF00FF00[已达成奖励]|r" or "|cFF999999[未达成奖励]|r";
	SignTisText:SetText("|cFFFF66FF连签:|r |cFF00FF00"..PlayerSeriesDays.."天|r "..GtsStr1.." |cFFFF66FF累签:|r |cFF00FF00"..PlayerTotalDays.."天|r "..GtsStr2)
end

function ApplyRewardSignData(Msg)
	local Args = Dream_Split(Msg, "$");
	local Day = tonumber(Args[1]);
    local Datas = Dream_Split(Args[2], "#");
	RewardSignInData[Day] = { Datas[1], Datas[2], Datas[3], Datas[4], Datas[5], Datas[6], Datas[7], Datas[8], Datas[9], Datas[10], Datas[11], Datas[12] };
end

function MeSetTexture(Button, File)
    local ButtonTexture = Button:CreateTexture("ButtonTexture")
    ButtonTexture:SetAllPoints(Button)
    ButtonTexture:SetTexture(File)
	Button:SetNormalTexture(ButtonTexture)
end

function ApplyRepairInfo(Msg)
    local Args = Dream_Split(Msg, "$");
	local Dialog = StaticPopup_Show("SignRepair", "\n|cFF00FF00[补签]|r\n"..Args[2].."|cFF00FF00你确定要这么做吗?|r");
	if (Dialog) then
		local DArgs = Dream_Split(Args[1], "#");
	    Dialog.UiYear = DArgs[1];
		Dialog.UiMonth = DArgs[2];
		Dialog.UiDay = DArgs[3];
		FuncFrameUpdateAlpha(SignInRewBackDropFrame, false);
		Dialog:SetScript("OnHide",
        function(self)
			FuncFrameUpdateAlpha(SignInRewBackDropFrame, true);
        end)
	end
end

function UpDateSignDay(Num)
    local UiDay = tonumber(DayStrings[Num]:GetText())
	local UiYear = DayButtons[Num].Year
	local UiMonth = DayButtons[Num].Month
	local Check = (NowYear == UiYear and NowMonth == UiMonth and UiDay <= NowDay)
	if (not Check) then
	    DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[签到提示]: 你无法进行签到 日期检测出错|r");
	    return;
	end

	if (PlayerSignInData[UiDay] ~= nil) then
	    DEFAULT_CHAT_FRAME:AddMessage("|cffFFC125[签到提示]: 你这个日期已经签到过了......|r");
		return;
	end

	if (UiDay < NowDay) then
	    Dream_SendData("ReqRepair", tostring(UiYear).."#"..tostring(UiMonth).."#"..tostring(UiDay).."#");
	else
	    Dream_SendData("OnStartSign", tostring(UiYear).."#"..tostring(UiMonth).."#"..tostring(UiDay).."#");
	end
end

--消息处理
local function Dream_OnSignAddonEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		--签到
		if (Packet == "PlayerSignData") then
		    ApplyPlayerSignData(Msg);
		elseif (Packet == "SendRepair") then
		    ApplyRepairInfo(Msg);
		elseif (Packet == "ConfigSignData") then
		    local Args = Dream_Split(Msg, "$");
		    ContinuousDays = tonumber(Args[1]);
			TotalDays = tonumber(Args[2]);
			if (SignInRewBackDropFrame:IsShown()) then
			    SignInRewBackDropFrame:Hide();
			    SignInRewBackDropFrame:Show();
			end
		elseif (Packet == "RewardSignData") then
		    ApplyRewardSignData(Msg);
		elseif (Packet == "NULLSignData") then
		    PlayerSignInData = {};
			if (EventSignFrame:IsShown()) then
			    EventSignFrame:Hide();
			    EventSignFrame:Show();
			end
			if (SignInRewBackDropFrame:IsShown()) then
			    SignInRewBackDropFrame:Hide();
			    SignInRewBackDropFrame:Show();
			end
		end
	elseif (event == "PLAYER_LOGIN") then
		PlayerSignInData = {};
		Dream_SendData("GetSignData");
	end
end

--交互消息事件
local SignAddonFrame = CreateFrame("Frame", "SignAddonFrame");
SignAddonFrame:RegisterEvent("CHAT_MSG_ADDON");
SignAddonFrame:RegisterEvent("PLAYER_LOGIN");
SignAddonFrame:SetScript("OnEvent", Dream_OnSignAddonEvent);


