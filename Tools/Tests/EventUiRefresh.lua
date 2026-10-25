dofile("Tools/Tests/WowUiMock.lua")
dofile(arg[1] or "Interface/NativeUI/BundledAddOns/____Function/OnGameEventShow.lua")
EventShowFrame:Show()
metrics.textures = 0
local receive = AddonEventShowFrame:GetScript("OnEvent")
receive(AddonEventShowFrame, "CHAT_MSG_ADDON", "AutoEventSizeNow", "100")
for i = 1, 100 do
    receive(AddonEventShowFrame, "CHAT_MSG_ADDON", "AutoEventDataNow",
        i .. "^1^2^Event^Description^test.blp^Teleport^^^1^60^Type^1")
end
Tick(0.1)
print("100 activity rows: texture assignments=" .. metrics.textures)
assert(metrics.textures <= 9, "one response batch repeatedly redraws every visible card")
EventShowFrame:Hide(); EventShowFrame:Show()
assert(metrics.requests == 1, "rapid reopen sends duplicate activity requests")
print("Activity UI refresh regression passed")
