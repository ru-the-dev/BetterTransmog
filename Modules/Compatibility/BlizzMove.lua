local addon, ns = ...;

---@class BetterTransmog
local Core = ns.Core;

--- @class BetterTransmog.Modules.Compatibility.BlizzMove : LibRu.Module
local Module = Core.Libs.LibRu.Module.New("Compatibility.BlizzMove", Core, { Core });

if Core.Debug then
    Module.LogContext:DisableLevels("INFO");
end

local function IsBlizzMoveLoaded()
    return C_AddOns.IsAddOnLoaded("BlizzMove")
end

local function TryDisableBlizzMoveTransmogFrame()
    if  not IsBlizzMoveLoaded() then
        Module:LogInfo("BlizzMove not loaded.")
        return
    else 
        Module:LogInfo("BlizzMove loaded.")
    end

    local aceAddon = _G.LibStub:GetLibrary("AceAddon-3.0", true)
    local addon = aceAddon and aceAddon:GetAddon("BlizzMove", true)
    addon = addon or _G.BlizzMove

    if addon then
        Module:LogInfo("BlizzMove addon found via AceAddon or global.")
    else
        Module:LogInfo("BlizzMove addon NOT found.")
        return false;
    end

    local oldProcessFrame = addon.ProcessFrame

    ---@diagnostic disable-next-line: inject-field
    addon.ProcessFrame = function(self, addOnName, frameName, frameData, frameParent, retriedAfterNotFound)
        if addOnName == "Blizzard_Transmog" and frameName == "TransmogFrame" then
            Module:LogInfo("BlizzMove: blocked ProcessFrame for " .. tostring(frameName))
            return false
        end

        if type(oldProcessFrame) == "function" then
            local ok, result = pcall(oldProcessFrame, self, addOnName, frameName, frameData, frameParent, retriedAfterNotFound)
            if not ok then
                Module:LogInfo("BlizzMove: ProcessFrame pcall failed for " .. tostring(addOnName) .. "." .. tostring(frameName) .. ": " .. tostring(result))
                return false
            end
            return result
        end
    end


    if addon.DB then
        local function SafeUnregisterFrame(addOnName, frameName)
            local ok, result

            if type(addon.UnregisterFrame) == "function" then
                ok, result = pcall(addon.UnregisterFrame, addon, addOnName, frameName, true)
                Module:LogInfo("BlizzMove: UnregisterFrame via addon " ..
                tostring(addOnName) .. "." .. tostring(frameName) .. " -> " .. tostring(ok) .. ", " .. tostring(result))
                return ok and result
            end

            Module:LogInfo("BlizzMove: UnregisterFrame not available for " ..
            tostring(addOnName) .. "." .. tostring(frameName))
            return false
        end

        --- call unregister frame just in case it was already registered
        SafeUnregisterFrame("Blizzard_Transmog", "TransmogFrame")
    end
    
    return true;
end

function Module:OnInitialize()
    if TryDisableBlizzMoveTransmogFrame() then return end;

    Core.EventFrame:AddEvent("ADDON_LOADED", function (self, handle, event, addonName)
        if addonName == "BlizzMove" then
            TryDisableBlizzMoveTransmogFrame()
            self:RemoveEvent(handle)
        end
    end)
end
