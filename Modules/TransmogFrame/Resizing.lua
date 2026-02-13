local addon, ns = ...;

-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = ns.Core;

--- @class BetterTransmog.Modules.TransmogFrame.Resizing : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "Resizing", 
    Core.Modules.TransmogFrame, 
    { 
        Core.Modules.TransmogFrame
    },
    false
);

--- =======================================================
--- Dependencies
--- ======================================================
---@type BetterTransmog.Modules.TransmogFrame
local transmogFrameModule = Core.Modules.TransmogFrame;


--- =======================================================
-- Module Settings
-- =======================================================

Module.Settings = {}



-- =======================================================
-- Module Implementation
-- =======================================================  
local function GetSavedSize(displayMode)
    displayMode = displayMode or transmogFrameModule.DisplayMode

    ---@type BetterTransmog.Modules.AccountDB|nil
    local accountDBModule = Core:GetModule("AccountDB")
 
    if not accountDBModule then
        return nil
    end

    if displayMode == transmogFrameModule.Enum.DISPLAY_MODE.OUTFIT_SWAP then
        return accountDBModule.DB:Get().TransmogFrame.FrameSizeOutfit
    end

    return accountDBModule.DB:Get().TransmogFrame.FrameSizeFull
end

local function GetDefaultOutfitWidth()
    local staticWidth = transmogFrameModule:GetStaticSizedChildrenWidth()
    if staticWidth and staticWidth > 0 then
        return staticWidth
    end

    local outfitModule = transmogFrameModule:GetModule("OutfitCollection")
    local previewModule = transmogFrameModule:GetModule("CharacterPreview")

    local outfitWidth = outfitModule and outfitModule.Settings and outfitModule.Settings.ExpandedWidth or 312
    local previewWidth = previewModule and previewModule.Settings and previewModule.Settings.MinFrameWidth or 450

    return outfitWidth + previewWidth
end

local function ClampSizeForMode(width, height, displayMode)
    local minWidth = transmogFrameModule.Settings.MinWidth
    local minHeight = transmogFrameModule.Settings.MinHeight

    if displayMode == transmogFrameModule.Enum.DISPLAY_MODE.OUTFIT_SWAP then
        local outfitWidth = GetDefaultOutfitWidth()
        width = outfitWidth
        height = math.max(height or minHeight, minHeight)
        return width, height
    end

    width = math.max(width or minWidth, minWidth)
    height = math.max(height or minHeight, minHeight)
    return width, height
end

local function RestoreSavedSize(displayMode)
    displayMode = displayMode or transmogFrameModule.DisplayMode

    Module:LogInfo("Restoring TransmogFrame size from AccountDB for display mode: " .. tostring(displayMode))

    -- restore size from account DB
    local savedSize = GetSavedSize(displayMode)
    if not savedSize then return end

    local width, height = ClampSizeForMode(savedSize.Width, savedSize.Height, displayMode)
    transmogFrameModule:GetFrame():SetSize(width, height)
end

local function SaveFrameSize(displayMode)
    displayMode = displayMode or transmogFrameModule.DisplayMode

    Module:LogInfo("Saving TransmogFrame size to AccountDB for display mode: " .. tostring(displayMode))

    if transmogFrameModule.IsApplyingMode then
        Module:LogInfo("Skipping size save while applying display mode.")
        return
    end

    local width, height = transmogFrameModule:GetFrame():GetSize()

    -- save size to account DB
    local savedSize = GetSavedSize(displayMode)
    if not savedSize then return end

    savedSize.Width = width
    savedSize.Height = height
end

function Module:SaveFrameSize(displayMode)
    SaveFrameSize(displayMode)
end

function Module:RestoreSavedSize(displayMode)
    RestoreSavedSize(displayMode)
end

---@param eventFrame Frame
---@param handle any
---@param displayMode string
local function ApplyDisplayMode(eventFrame, handle, displayMode)
    if not transmogFrameModule:IsValidDisplayMode(displayMode) then
        Module:LogWarning("UnimplmentedDisplayMode: " .. tostring(displayMode))
        return
    end

    if displayMode == transmogFrameModule.Enum.DISPLAY_MODE.FULL then
        transmogFrameModule:SetDefaultResizeBounds();
        RestoreSavedSize(displayMode)
    elseif displayMode == transmogFrameModule.Enum.DISPLAY_MODE.OUTFIT_SWAP then
        -- outfit-mode positioning is applied after preview collapse/expand in CharacterPreview
        RestoreSavedSize(displayMode)
    end
end

function Module:OnInitialize()
    Module:LogInfo("Applying changes.")

    -- restore size for the first time opening
    RestoreSavedSize();

    -- add resize button
    Module:AddResizeButton();

    Core.EventFrame:AddScript("OnTransmogFrameDisplayModeChanged", ApplyDisplayMode)

    -- hook on situations show to adjust width if needed
    transmogFrameModule:GetFrame().WardrobeCollection.TabContent.SituationsFrame:HookScript("OnShow", function(self)
        Module:LogInfo("Situations tab shown, adjusting width if needed.")

        ---@type BetterTransmog.Modules.TransmogFrame.WardrobeCollection|nil
        local wardrobeCollectionModule = transmogFrameModule:GetModule("WardrobeCollection")
        
        if wardrobeCollectionModule then
            wardrobeCollectionModule:UpdateSituationTabMinWidth()
        end
    end)
end

function Module:AddResizeButton()
    if transmogFrameModule:GetFrame().BT_ResizeButton then
        Module:LogInfo("Resize button already exists, skipping creation.")
        return
    end

    local resizeButton = Core.Libs.LibRu.Frames.ResizeButton.New(
        transmogFrameModule:GetFrame(),
        transmogFrameModule:GetFrame(),
        30
    )

    resizeButton:SetFrameStrata("FULLSCREEN_DIALOG")
    resizeButton:AddScript("OnMouseUp", function()
        SaveFrameSize()
    end)
    ---@class TransmogFrame : Frame
    local transmogFrame = transmogFrameModule:GetFrame()
    transmogFrame.BT_ResizeButton = resizeButton
end