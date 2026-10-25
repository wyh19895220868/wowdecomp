-- Keep the native client's WorldText combat text off while DamageDisplayUI
-- draws its own server-provided 64-bit damage text. Restored on logout so
-- removing this addon brings the native text back automatically.
local frame = CreateFrame("Frame");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("PLAYER_LOGOUT");
frame:SetScript("OnEvent", function(_, event)
    if not SetCVar then
        return;
    end

    if event == "PLAYER_LOGOUT" then
        SetCVar("nativeCombatText", "1");
        return;
    end

    local enabled = true;
    if DamageDisplayUIDB and DamageDisplayUIDB.enabled == false then
        enabled = false;
    end

    SetCVar("nativeCombatText", enabled and "0" or "1");
end);
