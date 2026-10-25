-- Minimal WoW API fixture. Runs the actual bundled scripts without game data.
metrics = { textures = 0, reads = 0, values = 0, requests = 0 }
frames, hooks = {}, {}
local methods = {}
local function noop() end
local function object(kind, name)
    local obj = { kind = kind, name = name, scripts = {}, shown = true, width = 120, height = 20 }
    setmetatable(obj, { __index = function(_, key)
        if methods[key] then return methods[key] end
        if string.match(key, "^[A-Z]") then return noop end
    end })
    if name then _G[name] = obj end
    frames[#frames + 1] = obj
    return obj
end
function CreateFrame(kind, name) return object(kind, name) end
function methods:GetName() return self.name end
function methods:GetObjectType() return self.kind end
function methods:SetScript(name, callback) self.scripts[name] = callback end
function methods:GetScript(name) return self.scripts[name] end
function methods:HookScript(name, callback)
    local previous = self.scripts[name]
    self.scripts[name] = function(...) if previous then previous(...) end; callback(...) end
end
function methods:CreateTexture(name) return object("Texture", name) end
function methods:CreateFontString(name) return object("FontString", name) end
function methods:SetTexture(value) metrics.textures = metrics.textures + 1; self.texture = value end
function methods:GetText() return rawget(self, "text") end
function methods:SetText(value) self.text = value end
function methods:GetFont() return "font.ttf", 10, "OUTLINE" end
function methods:GetFontString() return self end
function methods:GetHighlightTexture() return self end
function methods:SetSize(w, h) self.width, self.height = w, h end
function methods:GetWidth() return self.width end
function methods:GetHeight() return self.height end
function methods:GetFrameLevel() return 1 end
function methods:GetChildren() end
function methods:GetRegions() end
function methods:SetMinMaxValues(a, b) self.minimum, self.maximum = a, b end
function methods:GetMinMaxValues() return self.minimum or 0, self.maximum or 100 end
function methods:SetValue(v) self.value = v; metrics.values = metrics.values + 1 end
function methods:GetValue() return rawget(self, "value") or 0 end
function methods:IsShown() return self.shown end
function methods:Hide() self.shown = false end
function methods:Show()
    local wasShown = self.shown; self.shown = true
    if not wasShown and self.scripts.OnShow then self.scripts.OnShow(self) end
end
function hooksecurefunc(name, callback) hooks[name] = callback end
function TextStatusBar_UpdateTextString() end
function TargetFrame_Update() end
function UnitFrameHealthBar_Update() end
function FauxScrollFrame_Update() end
function FauxScrollFrame_GetOffset() return 0 end
function GetTime() return 100 end
function Dream_SendData() metrics.requests = metrics.requests + 1 end
function wipe(t) for k in pairs(t) do t[k] = nil end end
function UnitExists() return true end
function UnitGUID(unit) return unit == "target" and "target-guid" or "player-guid" end
function NativeUIHello() end
function NativeUIRevision() return 1 end
function NativeUnitValue(unit, key)
    metrics.reads = metrics.reads + 1
    if key == "INT256" then return "1" end
    if key == "CUR_HEALTH" or key == "CUR_POWER" then return "45000000000" end
    if key == "MAX_HEALTH" or key == "MAX_POWER" then return "90000000000" end
end
function Tick(dt)
    for _, frame in ipairs(frames) do
        if frame.scripts.OnUpdate and frame.shown then frame.scripts.OnUpdate(frame, dt) end
    end
end
tinsert = table.insert
UISpecialFrames = {}
Dream_GameFont = "font.ttf"
UIParent = CreateFrame("Frame", "UIParent")
GameTooltip = CreateFrame("Frame", "GameTooltip")
GameFontNormal = object("FontString", "GameFontNormal")
