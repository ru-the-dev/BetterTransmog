-- Initialization and setup logic
--- @type LibRu
local LibRu = LibStub:GetLibrary("LibRu");

if not LibRu then
    error("BetterTransmog dependency missing: LibRu");
end

---@class BetterTransmog : LibRu.Module
---@field Modules {AccountDB: BetterTransmog.Modules.AccountDB, ChangeLog: BetterTransmog.Modules.ChangeLog, MinimapButton: BetterTransmog.Modules.MinimapButton, Settings: BetterTransmog.Modules.Settings, TransmogFrame: BetterTransmog.Modules.TransmogFrame}
local Core = LibRu.Module.New("BetterTransmog", nil, nil, true)

-- Register LibRu in Core for easy access
Core.Libs = {}
Core.Libs.LibRu = LibRu;


-- Create a Global event frame
Core.EventFrame = LibRu.Frames.EventFrame.New(CreateFrame("Frame"));


-- listen to addon messages for debugging if debug is enabled
if Core.Debug == true then
    Core.EventFrame:AddEvent("CHAT_MSG_ADDON", function(self, handle, event, prefix, message, channel, sender, target, zoneChannelID, localID, name, instanceID)
        Core:DebugLog(string.format(
            "Addon msg [%s] %s -> %s: %s",
            tostring(prefix),
            tostring(sender),
            tostring(channel),
            tostring(message)
        ))
    end)
end

Core.EventFrame:AddEvent("ADDON_LOADED", function (self, handle, event, addonName)
    if addonName ~= Core:GetFullName() then return end

    --- Initialize the addon (core module and submodules)
    Core:Initialize();

    self:RemoveEvent(handle);
end)

function Core:PrintAddonMessage(msg)
    print("[" .. self:GetFullName(true) .. "]:|r " .. tostring(msg));
end

_G.BetterTransmog = Core;

