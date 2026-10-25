---@diagnostic disable: missing-parameter

local NtMaxPm = 10;
local NtRankLineStr = {};

local PutNtRankFrame = CreateFrame("Frame", "PutNtRankFrame", UIParent);
PutNtRankFrame:SetSize(600, 450);
PutNtRankFrame:RegisterForDrag("LeftButton");
PutNtRankFrame:SetPoint("CENTER");
PutNtRankFrame:SetClampedToScreen(true);
PutNtRankFrame:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
});

tinsert(UISpecialFrames, "PutNtRankFrame");
PutNtRankFrame:Hide();

for i=1,NtMaxPm do
	NtRankLineStr[i] = PutNtRankFrame:CreateFontString("NtRankLineStr"..i);
	NtRankLineStr[i]:SetFont(Dream_GameFont, 18);
	NtRankLineStr[i]:SetPoint("TOP", 0, -((i - 1) * 30 + 120));
end

-- 关闭按钮
local NtRankFramebuttonClose = CreateFrame("Button", "NtRankFramebuttonClose", PutNtRankFrame, "UIPanelCloseButton");
NtRankFramebuttonClose:SetPoint("TOPRIGHT", 5, 5);
NtRankFramebuttonClose:EnableMouse(true);
NtRankFramebuttonClose:SetSize(36, 36);

local NtRankText = PutNtRankFrame:CreateFontString("NtRankText");
NtRankText:SetFont(Dream_GameFont, 18);
NtRankText:SetPoint("TOP", 0, -50);
NtRankText:SetText("");

PutNtRankFrame:SetScript("OnShow",
function(self)
	Dream_SendData("GetPutNtRankFrame");
end)

PutNtRankFrame:SetScript("OnHide",
function(self)
	NtRankText:SetText("");
	for i=1,NtMaxPm do
		NtRankLineStr[i]:SetText("");
	end
end)

--消息处理
local function Dream_OnNtRankEvent(Self, event, Packet, Msg, Type, Sender)
    if (event == "CHAT_MSG_ADDON") then
		if (Packet == "AutoPutNtRankFrame") then
			NtRankText:SetText("|cFF00FF00每天会以邮件发送奖励 未上榜的依然有对应奖励|r");
			local Args = Dream_Split(Msg, "$");
			for N = 1, #Args do
				if (N <= NtMaxPm) then
					local Arg = Dream_Split(Args[N], "#");
					local RankIndex = "|cFFFF3300 <"..Dream_GetNumCustom(N)..">|r";
					local PlayerInfo = "|cFF00FF00"..Arg[1].."|r";
					local NtRank = "|cFF00FFFF天梯层数|r |cFFFFFF00"..Arg[2].."|r";
					NtRankLineStr[N]:SetText(RankIndex.."  "..PlayerInfo.."  "..NtRank.."  |cFF00FFFF奖励:|r "..Arg[3]);
				end
			end
		end
	elseif (event == "PLAYER_LOGIN") then
		
	end
end

--交互消息事件
local NtRankFrame = CreateFrame("Frame", "NtRankFrame");
NtRankFrame:RegisterEvent("CHAT_MSG_ADDON");
NtRankFrame:RegisterEvent("PLAYER_LOGIN");
NtRankFrame:SetScript("OnEvent", Dream_OnNtRankEvent);




--------------------------------------------------------------------


