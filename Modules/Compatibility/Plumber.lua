local addon, ns = ...;

---@class BetterTransmog
local Core = ns.Core;

--- @class BetterTransmog.Modules.Compatibility.Plumber : LibRu.Module
local Module = Core.Libs.LibRu.Module.New("Compatibility.Plumber", Core, { Core }, true);
if Core.Debug then
    Module.LogContext:DisableLevels("INFO");
end

local function IsPlumberLoaded()
    return C_AddOns.IsAddOnLoaded("Plumber")
end

local function TryDisablePlumberOutfitSelect()
    if not IsPlumberLoaded() then
        Module:LogInfo("Plumber not loaded.")
        return false
    end

    local disabled = false

    if type(_G.PlumberDB) == "table" then
        if _G.PlumberDB.TransmogOutfitSelect == true then
            _G.PlumberDB.TransmogOutfitSelect = false

            -- Warn user that we disabled it, and that plumbers module will not work with BetterTransmog enabled.
            Core:PrintAddonMessage("|cFFFFFF00Disabled Plumber's TransmogOutfitSelect module to avoid conflicts. Please do not re-enable it while BetterTransmog is enabled.|r")

        end
        disabled = true
    end

    if disabled then
        Module:LogInfo("Plumber detected: TransmogOutfitSelect disabled.")
    else
        Module:LogWarning("Plumber detected, but TransmogOutfitSelect could not be disabled (no API/db found).")
    end

    return disabled
end

function Module:OnInitialize()
    if TryDisablePlumberOutfitSelect() then return end;
    
    Core.EventFrame:AddEvent("ADDON_LOADED", function (self, handle, event, addonName)
        if addonName == "Plumber" then
            self:RemoveEvent(handle)
            TryDisablePlumberOutfitSelect()
        end
    end)
end