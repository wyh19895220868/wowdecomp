-- Original third-party helper decoded for maintenance; author alias AY_QQ2283219390 retained.
--Thanks for MagicDragoon.

function OptionsFrame_DisableCheckBox(checkBox)
    --checkBox:SetChecked(0);
    checkBox:Disable();
    getglobal(checkBox:GetName().."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function OptionsFrame_EnableCheckBox(checkBox, setChecked, checked, isWhite)
    if ( setChecked ) then
        checkBox:SetChecked(checked);
    end
    checkBox:Enable();
    if ( isWhite ) then
        getglobal(checkBox:GetName().."Text"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
    else
        getglobal(checkBox:GetName().."Text"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    end

end

function OptionsFrame_DisableSlider(slider)
    local name = slider:GetName()
    if not getglobal(name) then return end
    getglobal(name):EnableMouse(false)
    getglobal(name.."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
    getglobal(name.."Low"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
    getglobal(name.."High"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
end


function OptionsFrame_EnableSlider(slider)
    local name = slider:GetName()
    if not getglobal(name) then return end
    getglobal(name):EnableMouse(true)
    getglobal(name.."Text"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    getglobal(name.."Low"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    getglobal(name.."High"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end

function PlayerMobHealth(UnitHealth, UnitHealthMax)

    local HealthText = FormatHPNumber(UnitHealth)
    local maximum = tonumber(UnitHealthMax) or 0
    local current = tonumber(UnitHealth) or 0
    local HealthRate = maximum > 0 and math.floor(math.min(1, math.max(0, current / maximum)) * 100) or 0
    local HealthShow = string.format("%-16s%d%%", HealthText, HealthRate)

    if _G["MobHealth_Text"] and current > 0 and maximum > 0 then
        _G["MobHealth_Text"]:SetText(HealthShow)
        _G["MobHealth_Text"]:Show()
    else
        if _G["MobHealth_Text"] then _G["MobHealth_Text"]:Hide() end
    end

    if _G["MobManaText"] then _G["MobManaText"]:Hide() end

end
