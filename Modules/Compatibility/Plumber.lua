---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.Compatibility.Plumber : LibRu.Module
local Module = Core.Libs.LibRu.Module.New("Compatibility.Plumber", Core, { Core });

local function IsPlumberLoaded()
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded("Plumber")
    end
    
    return false
end

local function TryDisablePlumberOutfitSelect()
    if not IsPlumberLoaded() then
        return false
    end

    local disabled = false

    if type(_G.PlumberDB) == "table" then
        _G.PlumberDB.TransmogOutfitSelect = false
        disabled = true
    end

    local plumber = _G.Plumber
    local cc = plumber and plumber.ControlCenter
    if cc then
        if cc.SetModuleEnabled then
            cc:SetModuleEnabled("TransmogOutfitSelect", false)
            disabled = true
        end
        if cc.DisableModule then
            cc:DisableModule("TransmogOutfitSelect")
            disabled = true
        end
        if cc.ToggleModule then
            cc:ToggleModule("TransmogOutfitSelect", false)
            disabled = true
        end
    end

    if disabled then
        Module:DebugLog("Plumber detected: TransmogOutfitSelect disabled.")
    else
        Module:DebugLog("Plumber detected, but TransmogOutfitSelect could not be disabled (no API/db found).")
    end

    return disabled
end

function Module:OnInitialize()
    if TryDisablePlumberOutfitSelect() then
        return
    end

    Core.EventFrame:AddEvent("ADDON_LOADED", function (self, handle, event, addonName)
        if addonName == "Plumber" then
            self:UnregisterEvent("ADDON_LOADED")
            TryDisablePlumberOutfitSelect()
        end
    end)
end