-- Initialization and setup logic

_G.BetterTransmog = {};

--- @class LibRu
local LibRu = _G["LibRu"]

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end



-- Debug logging system
_G.BetterTransmog.Debug = true; -- Toggle this to enable/disable debug messages


function _G.BetterTransmog.DebugLog(message)
    print("|cff9f7fffBetterTransmog [DEBUG]:|r " .. tostring(message))
end

-- If not in debug mode, replace with empty function
if not _G.BetterTransmog.Debug then
    _G.BetterTransmog.DebugLog = function() end
end



-- Create a Global event frame
_G.BetterTransmog.EventFrame = LibRu.Frames.EventFrame.New(CreateFrame("Frame"));