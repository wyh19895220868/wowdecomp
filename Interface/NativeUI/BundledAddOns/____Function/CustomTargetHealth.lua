
local Open = true;
local CustomTargetData = { };
local CustomTargetHealthOffsetX = 200;
local CustomTargetHealthTexturePath = "Interface\\Icons\\newUi\\";
local CustomTargetHealthScale = 1.1;
local CustomTargetHealthBarWidth = 400 * CustomTargetHealthScale;
local CustomTargetHealthBarHeight = 50 * CustomTargetHealthScale;
local CustomTargetHealthFillWidth = 270 * CustomTargetHealthScale;
local CustomTargetHealthFillHeight = 35 * CustomTargetHealthScale;
local CustomTargetHealthFillOffsetX = 58;
local CustomTargetHealthCountSize = 40;

-- Expose the new multi-bar snapshot to the PlayerAttributePanel overlay.  The
-- stock target frame only receives the projected per-bar health value, while
-- this snapshot contains the real current/maximum totals for display.
_G.DreamCustomTargetHealthData = _G.DreamCustomTargetHealthData or {};

-- The selected full GUID owns the display. Nearby snapshots stay cached, but
-- never establish readiness for a new selection, even with the same entry.
local SelectedTargetGuid;
local SelectedTargetData;

function Dream_GetCustomTargetHealth()
    local Guid = UnitGUID("target");
    if (not Open or not Guid or Dream_GetCreGuidLow() == 0) then
        return nil, false;
    end
    if (Guid ~= SelectedTargetGuid) then
        -- NativeUI can receive PLAYER_TARGET_CHANGED before this addon does.
        return nil, true;
    end
    return SelectedTargetData, SelectedTargetData == nil;
end

local function RefreshTargetHealthText()
    if (_G.NativeUI_RefreshTargetHealth) then
        _G.NativeUI_RefreshTargetHealth();
    end
    if (_G.PlayerAttributePanel_RefreshTargetHealth) then
        _G.PlayerAttributePanel_RefreshTargetHealth();
    end
end

local function GetCustomTargetHealthBarIndex(DataInfo)
	local Current = tonumber(DataInfo and DataInfo.CurrentMultipleHp) or 1;
	local MaxBars = tonumber(DataInfo and DataInfo.MaxMultipleHp) or 1;
	local Index = MaxBars - Current + 1;
	if (Index < 1) then
		Index = 1;
	elseif (Index > 10) then
		Index = ((Index - 1) - math.floor((Index - 1) / 10) * 10) + 1;
	end

	return Index;
end

local function GetCustomTargetHealthBarTexture(DataInfo)
	local Index = GetCustomTargetHealthBarIndex(DataInfo);
	return CustomTargetHealthTexturePath.."xbar"..tostring(Index);
end

local function GetCustomTargetHealthBackTexture(DataInfo)
	local Index = GetCustomTargetHealthBarIndex(DataInfo) + 1;
	if (Index > 10) then
		Index = 1;
	end

	return CustomTargetHealthTexturePath.."xbar"..tostring(Index);
end

local CustomTargetFrame = CreateFrame("Frame", "CustomTargetFrame", TargetFrame);
CustomTargetFrame:SetSize(CustomTargetHealthBarWidth, CustomTargetHealthBarHeight);
CustomTargetFrame:SetPoint("RIGHT", 360 + CustomTargetHealthOffsetX, 5);
CustomTargetFrame:SetFrameLevel(10);
CustomTargetFrame.BackTexture = CustomTargetFrame:CreateTexture(nil, "BACKGROUND");
CustomTargetFrame.BackTexture:SetTexture(CustomTargetHealthTexturePath.."xtback");
CustomTargetFrame.BackTexture:SetAllPoints(CustomTargetFrame);

local CustomTargetFrameLeftNum = CreateFrame("Frame", "CustomTargetFrameLeftNum", CustomTargetFrame);
CustomTargetFrameLeftNum:SetSize(CustomTargetHealthCountSize, CustomTargetHealthCountSize);
CustomTargetFrameLeftNum:SetPoint("RIGHT", CustomTargetFrame, "LEFT", 46, 0);
CustomTargetFrameLeftNum:SetFrameLevel(CustomTargetFrame:GetFrameLevel() + 1);
CustomTargetFrameLeftNum.BackTexture = CustomTargetFrameLeftNum:CreateTexture(nil, "BACKGROUND");
CustomTargetFrameLeftNum.BackTexture:SetTexture(CustomTargetHealthTexturePath.."ER_item");
CustomTargetFrameLeftNum.BackTexture:SetAllPoints(CustomTargetFrameLeftNum);

local CustomTargetStr = CustomTargetFrameLeftNum:CreateFontString("CustomTargetStr", "OVERLAY")
CustomTargetStr:SetFont(Dream_GameFont, 14, "OUTLINE");
CustomTargetStr:SetAllPoints(CustomTargetFrameLeftNum);
CustomTargetStr:SetJustifyH("CENTER");
CustomTargetStr:SetJustifyV("MIDDLE");
CustomTargetStr:SetTextColor(0, 1, 1);

local CustomTargetBackBar = CreateFrame("StatusBar", "CustomTargetBackBar", CustomTargetFrame);
CustomTargetBackBar:SetOrientation("HORIZONTAL");
CustomTargetBackBar:SetStatusBarTexture(CustomTargetHealthTexturePath.."xbar2");
CustomTargetBackBar:SetStatusBarColor(1, 1, 1);
CustomTargetBackBar:SetPoint("LEFT", CustomTargetHealthFillOffsetX, 0);
CustomTargetBackBar:SetSize(CustomTargetHealthFillWidth, CustomTargetHealthFillHeight);
CustomTargetBackBar:SetFrameLevel(CustomTargetFrame:GetFrameLevel() - 3);
CustomTargetBackBar:SetMinMaxValues(0, 100);
CustomTargetBackBar:SetValue(100);

local CustomTargetDiffBar = CreateFrame("StatusBar", "CustomTargetDiffBar", CustomTargetFrame);
CustomTargetDiffBar:SetOrientation("HORIZONTAL");
CustomTargetDiffBar:SetStatusBarTexture(CustomTargetHealthTexturePath.."xbar10");
CustomTargetDiffBar:SetStatusBarColor(1, 1, 1);
CustomTargetDiffBar:SetPoint("LEFT", CustomTargetHealthFillOffsetX, 0);
CustomTargetDiffBar:SetSize(CustomTargetHealthFillWidth, CustomTargetHealthFillHeight);
CustomTargetDiffBar:SetFrameLevel(CustomTargetFrame:GetFrameLevel() - 2);
CustomTargetDiffBar:SetMinMaxValues(0, 100);
CustomTargetDiffBar:SetValue(0);

local CustomTargetStatusBar = CreateFrame("StatusBar", "CustomTargetStatusBar", CustomTargetFrame);
CustomTargetStatusBar:SetOrientation("HORIZONTAL");
CustomTargetStatusBar:SetStatusBarTexture(CustomTargetHealthTexturePath.."xbar1");
CustomTargetStatusBar:SetStatusBarColor(1, 1, 1);
CustomTargetStatusBar:SetPoint("LEFT", CustomTargetHealthFillOffsetX, 0);
CustomTargetStatusBar:SetSize(CustomTargetHealthFillWidth, CustomTargetHealthFillHeight);
CustomTargetStatusBar:SetFrameLevel(CustomTargetFrame:GetFrameLevel() - 1);
CustomTargetStatusBar:SetMinMaxValues(0, 100);

local CustomStatusBarText = CustomTargetFrame:CreateFontString("CustomStatusBarText", "OVERLAY")
CustomStatusBarText:SetFont(Dream_GameFont, 15, "OUTLINE");
CustomStatusBarText:SetSize(CustomTargetHealthFillWidth - 20, CustomTargetHealthFillHeight);
CustomStatusBarText:SetPoint("CENTER", CustomTargetStatusBar, "CENTER", -10, -2);
CustomStatusBarText:SetJustifyH("RIGHT");
CustomStatusBarText:SetTextColor(0, 1, 0.6);

function HideUICustomTargetFrame()
	CustomTargetFrameLeftNum:Hide();
	CustomTargetFrame:Hide();
	CustomTargetStr:SetText("");
	CustomStatusBarText:SetText("");
end

HideUICustomTargetFrame();

local function NormalizeBigDigits(Value)
	if (Value == nil) then
		return nil;
	end

	local Digits = tostring(Value);
	Digits = string.gsub(Digits, "[,%s]", "");
	if (string.find(Digits, "[^%d]")) then
		return nil;
	end

	Digits = string.gsub(Digits, "^0+", "");
	if (Digits == "") then
		return "0";
	end

	return Digits;
end

local function BigAdd(A, B)
	A = NormalizeBigDigits(A) or "0";
	B = NormalizeBigDigits(B) or "0";

	local Carry = 0;
	local Out = {};
	local IA = string.len(A);
	local IB = string.len(B);
	while (IA > 0 or IB > 0 or Carry > 0) do
		local DA = (IA > 0) and tonumber(string.sub(A, IA, IA)) or 0;
		local DB = (IB > 0) and tonumber(string.sub(B, IB, IB)) or 0;
		local Sum = DA + DB + Carry;
		table.insert(Out, 1, tostring(Sum - math.floor(Sum / 10) * 10));
		Carry = math.floor(Sum / 10);
		IA = IA - 1;
		IB = IB - 1;
	end

	return table.concat(Out);
end

local function BigMulSmall(A, Mul)
	A = NormalizeBigDigits(A) or "0";
	Mul = tonumber(Mul) or 0;
	if (A == "0" or Mul <= 0) then
		return "0";
	end

	local Carry = 0;
	local Out = {};
	for I = string.len(A), 1, -1 do
		local Product = tonumber(string.sub(A, I, I)) * Mul + Carry;
		table.insert(Out, 1, tostring(Product - math.floor(Product / 10) * 10));
		Carry = math.floor(Product / 10);
	end

	while (Carry > 0) do
		table.insert(Out, 1, tostring(Carry - math.floor(Carry / 10) * 10));
		Carry = math.floor(Carry / 10);
	end

	return table.concat(Out);
end

local function BigCompare(A, B)
	A = NormalizeBigDigits(A) or "0";
	B = NormalizeBigDigits(B) or "0";
	if (string.len(A) ~= string.len(B)) then
		return string.len(A) < string.len(B) and -1 or 1;
	end
	if (A == B) then
		return 0;
	end
	return A < B and -1 or 1;
end

local function BigPercent(A, B)
	A = NormalizeBigDigits(A) or "0";
	B = NormalizeBigDigits(B) or "0";
	if (B == "0" or A == "0") then
		return 0;
	end
	if (BigCompare(A, B) >= 0) then
		return 100;
	end
	local Scaled = BigMulSmall(A, 100);
	local Low, High = 0, 99;
	while (Low < High) do
		local Mid = math.floor((Low + High + 1) / 2);
		if (BigCompare(BigMulSmall(B, Mid), Scaled) <= 0) then
			Low = Mid;
		else
			High = Mid - 1;
		end
	end
	return Low;
end

local function BuildBigHealthText(DataInfo)
	local BarHealth = NormalizeBigDigits(DataInfo.BarHealth);
	local BarMax = NormalizeBigDigits(DataInfo.BarMax);
	if (not BarHealth or not BarMax or BarMax == "0") then
		return nil;
	end

	local CurrentBars = tonumber(DataInfo.CurrentMultipleHp) or 1;
	local MaxBars = tonumber(DataInfo.MaxMultipleHp) or 1;
	local CurrentTotal = "0";
	if (CurrentBars > 0) then
		CurrentTotal = BigAdd(BigMulSmall(BarMax, CurrentBars - 1), BarHealth);
	end

	local MaxTotal = BigMulSmall(BarMax, MaxBars);
	return CurrentTotal .. "/" .. MaxTotal;
end

local function FormatHealthDisplayValue(Value)
	-- Keep full health as digits: stock UnitHealth is int32 and Lua numbers
	-- cannot represent every integer above 2^53. Truncate units, never round.
	local Digits = NormalizeBigDigits(Value) or "0";
	local Units = {
		{ exp = 24, suffix = "秭" },
		{ exp = 20, suffix = "垓" },
		{ exp = 16, suffix = "京" },
		{ exp = 12, suffix = "兆" },
		{ exp = 8, suffix = "亿" },
		{ exp = 4, suffix = "万" },
	};
	for _, Unit in ipairs(Units) do
		if (string.len(Digits) > Unit.exp) then
			local Split = string.len(Digits) - Unit.exp;
			local Whole = string.sub(Digits, 1, Split);
			local Fraction = string.sub(Digits, Split + 1, Split + 1);
			return Whole .. (Fraction ~= "0" and "." .. Fraction or "") .. Unit.suffix;
		end
	end
	return Digits;
end

local function BuildDisplayHealthText(DataInfo)
	local Text = BuildBigHealthText(DataInfo) or "0/0";
	local Current, Maximum = string.match(Text, "^(%d+)/(%d+)$");
	if (not Current or not Maximum) then
		return Text;
	end

	Current = NormalizeBigDigits(Current);
	Maximum = NormalizeBigDigits(Maximum);
	if (not Current or not Maximum) then
		return Text;
	end

	return FormatHealthDisplayValue(Current) .. "/" .. FormatHealthDisplayValue(Maximum);
end

function UpdateUICustomTargetFrame(DataInfo)
	local MaxBars = tonumber(DataInfo and DataInfo.MaxMultipleHp) or 1;
	if (MaxBars <= 1) then
		HideUICustomTargetFrame();
	else
		-- The legacy HBUI frame reads the native per-bar projection. Once the
		-- external multi-bar frame has data, it must not compete for this target.
		if (_G.BossHealthBar and _G.BossHealthBar.HideFrame) then
			_G.BossHealthBar:HideFrame();
		end
		-- A zero current segment can be a delayed bar-switch packet. The server
		-- marks a dead target with no remaining bars, so only use that field here.
		local TargetIsDead = (tonumber(DataInfo.CurrentMultipleHp) or 0) <= 0;
		if (TargetIsDead) then
			DataInfo.CurrentMultipleHp = 0;
		end

		CustomTargetFrameLeftNum:Show();
		CustomTargetFrame:Show();
		local ShowBars = tonumber(DataInfo.CurrentMultipleHp) or 0;

		if (TargetIsDead) then
			CustomTargetStr:Hide();
			CustomStatusBarText:SetText("");
			CustomStatusBarText:Hide();
		else
			CustomTargetStr:Show();
			local BarCountText = tostring(ShowBars);
			if (string.len(BarCountText) > 10) then
				BarCountText = "9999999999+";
			end
			CustomTargetStr:SetText(string.format("|cFF00FFFF%sX|r", BarCountText));
			CustomStatusBarText:Show();
			CustomStatusBarText:SetText(BuildDisplayHealthText(DataInfo));
		end

		local BarPct = BigPercent(DataInfo.BarHealth, DataInfo.BarMax);
		CustomTargetStatusBar:SetStatusBarTexture(GetCustomTargetHealthBarTexture(DataInfo));
		CustomTargetBackBar:SetStatusBarTexture(GetCustomTargetHealthBackTexture(DataInfo));
		CustomTargetDiffBar:SetStatusBarTexture(CustomTargetHealthTexturePath.."xbar10");
		CustomTargetDiffBar:SetValue(0);
		CustomTargetStatusBar:SetStatusBarColor(1, 1, 1);
		CustomTargetStatusBar:SetValue(BarPct);
	end
end

function CustomTargetFrameOnEvent(self, event, Packet, Msg, Type, Sender)
	if (event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD") then
		SelectedTargetGuid = UnitGUID("target");
		SelectedTargetData = nil;
		if (not Open) then
			HideUICustomTargetFrame();
			RefreshTargetHealthText();
			return;
		end
		HideUICustomTargetFrame();
		local CreGuidLow  = Dream_GetCreGuidLow();
		if (CreGuidLow ~= 0) then
			-- A creature GUID can be reused. Clear its old snapshot while the
			-- current target query is in flight so a single-bar creature never
			-- inherits stale external multi-bar totals.
			_G.DreamCustomTargetHealthData[CreGuidLow] = nil;
			CustomTargetData[CreGuidLow] = { CurrentMultipleHp = 1, MaxMultipleHp = 1 };
			if (_G.BossHealthBar and _G.BossHealthBar.HideFrame) then
				_G.BossHealthBar:HideFrame();
			end
			-- Nearby creatures use the same broadcast. Always ask for the current
			-- target so a cached packet from another creature can never be displayed.
			Dream_SendData("QueryCustomTargetHp", tostring(CreGuidLow));
		end
		RefreshTargetHealthText();
	elseif (event == "UNIT_HEALTH") then
		if (Packet ~= "target") then
			return;
		end
		if (not Open) then
			HideUICustomTargetFrame();
			return;
		end
		local DataInfo = Dream_GetCustomTargetHealth();
		if (DataInfo and DataInfo.MaxMultipleHp > 1) then
			UpdateUICustomTargetFrame(DataInfo);
		end
	elseif (event == "CHAT_MSG_ADDON") then
		if (Packet == "CustomTargetHpCount") then
			local Args = Dream_Split(Msg, "#");
			local CreGuidLow = tonumber(Args[1]);
			local CurrentMultipleHp = tonumber(Args[2]);
			local MaxMultipleHp = tonumber(Args[3]);
			if (CreGuidLow and CurrentMultipleHp and MaxMultipleHp) then
				local DataInfo = {
					CurrentMultipleHp = CurrentMultipleHp,
					MaxMultipleHp = MaxMultipleHp,
					BarHealth = NormalizeBigDigits(Args[4]),
					BarMax = NormalizeBigDigits(Args[5]),
				};
				DataInfo.TotalHealthText = BuildBigHealthText(DataInfo);
				DataInfo.MaxHealthText = BigMulSmall(DataInfo.BarMax, MaxMultipleHp);
				if (not DataInfo.TotalHealthText) then
					return;
				end
				-- Ordered server snapshots own this display. Increasing health can
				-- be a heal or respawn; native UNIT_HEALTH never replaces these totals.
				CustomTargetData[CreGuidLow] = DataInfo;
				_G.DreamCustomTargetHealthData[CreGuidLow] = DataInfo;

				-- The server also sends health packets for nearby creatures. Keep
				-- those cached, but never let them overwrite the selected target UI.
				if (Dream_GetCreGuidLow() == CreGuidLow and UnitGUID("target") == SelectedTargetGuid) then
					SelectedTargetData = DataInfo;
					if (Open) then
						UpdateUICustomTargetFrame(DataInfo);
					end
					RefreshTargetHealthText();
				end
			end
		elseif (Packet == "AutoOpenCustomTargetHp") then
			Open = (tonumber(Msg) == 1);
			CustomTargetFrameOnEvent(self, "PLAYER_TARGET_CHANGED");
		elseif (Packet == "ResetCustomTargetHp") then
			local CreGuidLow = tonumber(Msg);
			_G.DreamCustomTargetHealthResetGuid = CreGuidLow;
			if (CustomTargetData[CreGuidLow]) then
				CustomTargetData[CreGuidLow].CurrentMultipleHp = CustomTargetData[CreGuidLow].MaxMultipleHp;
				CustomTargetData[CreGuidLow].BarHealth = CustomTargetData[CreGuidLow].BarMax;
				CustomTargetData[CreGuidLow].TotalHealthText = BuildBigHealthText(CustomTargetData[CreGuidLow]);
				CustomTargetData[CreGuidLow].MaxHealthText = BigMulSmall(CustomTargetData[CreGuidLow].BarMax, CustomTargetData[CreGuidLow].MaxMultipleHp);
				_G.DreamCustomTargetHealthData[CreGuidLow] = CustomTargetData[CreGuidLow];
				if (Open and Dream_GetCreGuidLow() == CreGuidLow and UnitGUID("target") == SelectedTargetGuid
					and SelectedTargetData == CustomTargetData[CreGuidLow]) then
					UpdateUICustomTargetFrame(CustomTargetData[CreGuidLow]);
					RefreshTargetHealthText();
				end
			end
		elseif (Packet == "ThroughLimitHp") then
			-- Player health scaling is handled by its owning UI, not this creature target frame.
			return;
		elseif (Packet == "ThroughDamage") then
			-- Damage float values are owned by DamageDisplayUI.
			return;
		end
	elseif (event == "PLAYER_LOGIN") then
		Dream_SendData("GetOpenCustomTargetHp");
	end
end

local CustomTargetFrameEvent = CreateFrame("Frame", "CustomTargetFrameEvent");
CustomTargetFrameEvent:RegisterEvent("PLAYER_TARGET_CHANGED");
CustomTargetFrameEvent:RegisterEvent("PLAYER_ENTERING_WORLD");
CustomTargetFrameEvent:RegisterEvent("UNIT_HEALTH")
CustomTargetFrameEvent:RegisterEvent("CHAT_MSG_ADDON");
CustomTargetFrameEvent:RegisterEvent("PLAYER_LOGIN");
CustomTargetFrameEvent:SetScript("OnEvent", CustomTargetFrameOnEvent);

--------------------------------------------------------------------
