dofile("Tools/Tests/WowUiMock.lua")
SlashCmdList = {}
DEFAULT_CHAT_FRAME = CreateFrame("Frame")
dofile("Interface/NativeUI/BundledAddOns/MaterialPreview/MaterialPreview.lua")

assert(SlashCmdList.MATERIALPREVIEW ~= nil, "slash command was not registered")
for _, frame in ipairs(frames) do
    local onEvent = frame:GetScript("OnEvent")
    if onEvent then onEvent(frame, "PLAYER_LOGIN") end
end
assert(MaterialPreviewFrame:IsShown() == false, "PLAYER_LOGIN should keep the preview hidden")
SlashCmdList.MATERIALPREVIEW()
assert(MaterialPreviewFrame ~= nil, "preview frame was not created")
assert(MaterialPreviewFrame:IsShown() == true, "toggle should show the preview frame")
SlashCmdList.MATERIALPREVIEW()
assert(MaterialPreviewFrame:IsShown() == false, "second toggle should hide the preview frame")
print("MaterialPreview Lua mock test passed; texture assignments=" .. metrics.textures)
