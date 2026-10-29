-- Data-only helper kept for the damage-rank percentage.
--
-- The multi-bar target frame is now drawn by the client's bundled FrameXML
-- (Interface\NativeUI\NativeUI.lua) from the native snapshot, so this file no
-- longer creates frames, textures or labels and never touches the target
-- portrait frame. The addon query below only caches the exact multi-bar totals
-- for Dream_GetDmgRankMaxHealth; it is not used by any unit frame.

local Open = true;
local CustomTargetData = { };

_G.DreamCustomTargetHealthData = _G.DreamCustomTargetHealthData or {};
local DreamCustomTargetHealthData = _G.DreamCustomTargetHealthData;

local SelectedTargetGuid;
local SelectedTargetData;

function Dream_GetCustomTargetHealth()
    local Guid = UnitGUID("target");
    if (not Open or not Guid or Dream_GetCreGuidLow() == 0) then
        return nil, false;
    end
    if (Guid ~= SelectedTargetGuid) then
        return nil, true;
    end
    return SelectedTargetData, SelectedTargetData == nil;
end;

-- Legacy entry points: some module may still call them. Nothing to hide or
-- update because the addon-owned frame no longer exists.
function HideUICustomTargetFrame()
end

function UpdateUICustomTargetFrame()
end

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

function CustomTargetFrameOnEvent(self, event, Packet, Msg, Type, Sender)
    if (event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD") then
        SelectedTargetGuid = UnitGUID("target");
        SelectedTargetData = nil;
        if (not Open) then
            return;
        end
        local CreGuidLow = Dream_GetCreGuidLow();
        if (CreGuidLow ~= 0) then
            -- A creature GUID can be reused; drop the old snapshot while the
            -- current target query is in flight.
            DreamCustomTargetHealthData[CreGuidLow] = nil;
            CustomTargetData[CreGuidLow] = { CurrentMultipleHp = 1, MaxMultipleHp = 1 };
            Dream_SendData("QueryCustomTargetHp", tostring(CreGuidLow));
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
                CustomTargetData[CreGuidLow] = DataInfo;
                DreamCustomTargetHealthData[CreGuidLow] = DataInfo;

                if (Dream_GetCreGuidLow() == CreGuidLow and UnitGUID("target") == SelectedTargetGuid) then
                    SelectedTargetData = DataInfo;
                end
            end
        elseif (Packet == "AutoOpenCustomTargetHp") then
            Open = (tonumber(Msg) == 1);
            CustomTargetFrameOnEvent(self, "PLAYER_TARGET_CHANGED");
        elseif (Packet == "ResetCustomTargetHp") then
            local CreGuidLow = tonumber(Msg);
            if (CustomTargetData[CreGuidLow]) then
                CustomTargetData[CreGuidLow].CurrentMultipleHp = CustomTargetData[CreGuidLow].MaxMultipleHp;
                CustomTargetData[CreGuidLow].BarHealth = CustomTargetData[CreGuidLow].BarMax;
                CustomTargetData[CreGuidLow].TotalHealthText = BuildBigHealthText(CustomTargetData[CreGuidLow]);
                CustomTargetData[CreGuidLow].MaxHealthText = BigMulSmall(CustomTargetData[CreGuidLow].BarMax, CustomTargetData[CreGuidLow].MaxMultipleHp);
                DreamCustomTargetHealthData[CreGuidLow] = CustomTargetData[CreGuidLow];
            end
        end
    elseif (event == "PLAYER_LOGIN") then
        Dream_SendData("GetOpenCustomTargetHp");
    end
end

local CustomTargetFrameEvent = CreateFrame("Frame", "CustomTargetFrameEvent");
CustomTargetFrameEvent:RegisterEvent("PLAYER_TARGET_CHANGED");
CustomTargetFrameEvent:RegisterEvent("PLAYER_ENTERING_WORLD");
CustomTargetFrameEvent:RegisterEvent("CHAT_MSG_ADDON");
CustomTargetFrameEvent:RegisterEvent("PLAYER_LOGIN");
CustomTargetFrameEvent:SetScript("OnEvent", CustomTargetFrameOnEvent);
