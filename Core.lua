-- Initialization and setup logic
local addon, ns = ...

--- @type LibRu
local LibRu = LibStub:GetLibrary("LibRu");

if not LibRu then
    error("BetterTransmog dependency missing: LibRu");
end

---@class BetterTransmog : LibRu.Module
---@field Modules {AccountDB: BetterTransmog.Modules.AccountDB, ChangeLog: BetterTransmog.Modules.ChangeLog, MinimapButton: BetterTransmog.Modules.MinimapButton, Settings: BetterTransmog.Modules.Settings, TransmogFrame: BetterTransmog.Modules.TransmogFrame}
local Core = LibRu.Module.New("BetterTransmog", nil, nil)

Core.Debug = true;

if Core.Debug then
    Core.LogContext:DisableLevels("INFO");
end

-- Register LibRu in Core for easy access
Core.Libs = {}
Core.Libs.LibRu = LibRu;



-- Create a Global event frame
Core.EventFrame = LibRu.Frames.EventFrame.New(CreateFrame("Frame"));

Core.EventFrame:AddEvent("ADDON_LOADED", function (self, handle, event, addonName)
    if addonName ~= Core:GetFullName() then return end

    if not Core.Debug then
        Core:SetLoggingEnabled(false, true);
    end

    --- Initialize the addon (core module and submodules)
    Core:Initialize();

    self:RemoveEvent(handle);
end)

function Core:PrintAddonMessage(msg)
    print("[" .. self:GetFullName(true) .. "]:|r " .. tostring(msg));
end

ns.Core = Core;

