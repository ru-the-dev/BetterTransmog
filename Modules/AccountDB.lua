local addon, ns = ...;

-- SavedVariables: BetterTransmogAccountDB

---@class BetterTransmog
local Core = ns.Core;

---@class BetterTransmog.Modules.AccountDB : LibRu.Module
local Module = Core.Libs.LibRu.Module.New("AccountDB", Core, { Core }, false);


---@class BetterTransmog.Modules.AccountDB.Defaults
local DEFAULTS = {
    LastChangeLogVersion = "",
    MinimapButton = { -- for LibDbIcon
        Hidden = false
    },
    TransmogFrame = {
        CharacterPreviewFrameWidth = 450,
        CharacterPreviewCollapsedOutfit = false,
        FramePositionFull = {
            Point = "CENTER",
            RelativeTo = "UIParent",
            RelativePoint = "CENTER",
            OffsetX = 0,
            OffsetY = 0,
        },
        FramePositionOutfit = {
            Point = "CENTER",
            RelativeTo = "UIParent",
            RelativePoint = "CENTER",
            OffsetX = 0,
            OffsetY = 0,
        },
        FrameSizeFull = {
            Width = 1330,
            Height = 750,
        },
        FrameSizeOutfit = {
            Width = 762,
            Height = 750,
        }
    }
}

function Module:OnInitialize()
    _G.BetterTransmogAccountDB = _G.BetterTransmogAccountDB or {};
    
    local AccountDB = Core.Libs.LibRu.Database.Create(_G.BetterTransmogAccountDB, DEFAULTS);

    AccountDB:Init();

    Module.DB = AccountDB;

    self:DebugLog("AccountDB initialized.");
end

