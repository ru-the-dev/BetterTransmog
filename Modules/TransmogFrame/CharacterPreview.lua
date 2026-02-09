local addon, ns = ...;

-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = ns.Core;

--- @class BetterTransmog.Modules.TransmogFrame.CharacterPreview : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "CharacterPreview", 
    Core.Modules.TransmogFrame, 
    { 
        Core.Modules.TransmogFrame 
    },
    true
);

Module.IsResetCameraHooked = false;


--- ======================================================
--- Locals 
--- ====================================================
---@type BetterTransmog.Modules.TransmogFrame
local transmogFrameModule = Core.Modules.TransmogFrame;
local _characterPreviewFrame = nil;

--- =======================================================
--- Module Settings
--- =======================================================

Module.Settings = {
    MinFrameWidth = 450,
    MaxFrameWidth = 900,
    MinCameraZoom = 2.5,
    MaxCameraZoom = 7.5,
    DefaultCameraZoom = 5.0,
    HiddenFrameWidth = 0.1,
    LinkOutfitButton = {
        Width = 110,
        Height = 22,
        OffsetX = 10,
        OffsetY = 10,
        FrameStrata = "HIGH",
    },
    CollapseButton = {
        Size = 30,
        OffsetX = 5,
        OffsetY = -70,
        FrameStrata = "DIALOG",
    }
}

-- =======================================================
-- Module Implementation
-- =======================================================



local function CharacterPreviewFrame_FixCamera()
    local preview = Module:GetFrame()
    local modelScene = preview.ModelScene
    local camera = modelScene:GetActiveCamera();

    if (not camera) then
        Module:DebugLog("No active camera found in CharacterPreview ModelScene.");
        return
    end

    camera:SetMinZoomDistance(Module.Settings.MinCameraZoom); 
    camera:SetMaxZoomDistance(Module.Settings.MaxCameraZoom);

    -- Set the current zoom to a reasonable default
    camera:SetZoomDistance(Module.Settings.DefaultCameraZoom);
end

local function CharacterPreviewFrame_HookReset()
    if Module.IsResetCameraHooked then return end;

    -- Hook the Reset method to reapply camera settings after reset
    local preview = Module:GetFrame()
    local modelScene = preview.ModelScene

    hooksecurefunc(modelScene, "Reset", function()
        CharacterPreviewFrame_FixCamera()
    end)

    Module.IsResetCameraHooked = true;
end

local function CharacterPreviewFrame_UpdateWidth()

    local accountDBModule = Core:GetModule("AccountDB");

    local previewWidth = (accountDBModule and accountDBModule.DB:Get().TransmogFrame.CharacterPreviewFrameWidth) 
        or Module.Settings.MinFrameWidth

    local preview = Module:GetFrame()

    local clampedWidth = math.min(
        math.max(
            previewWidth,
            Module.Settings.MinFrameWidth
        ),
        Module.Settings.MaxFrameWidth
    )

    Module:DebugLog("Setting CharacterPreview frame width to " .. clampedWidth)

    preview:SetWidth(clampedWidth)
    return clampedWidth
end

local function SetSlotButtonsVisible(visible)
    local preview = Module:GetFrame()
    if preview.BottomSlots then
        if visible then
            preview.BottomSlots:Show()
        else
            preview.BottomSlots:Hide()
        end
    end
    if preview.LeftSlots then
        if visible then
            preview.LeftSlots:Show()
        else
            preview.LeftSlots:Hide()
        end
    end
    if preview.RightSlots then
        if visible then
            preview.RightSlots:Show()
        else
            preview.RightSlots:Hide()
        end
    end
end

local previewCollapseButton = nil
local previewLinkOutfitButton = nil



local function GetOutfitCollectionWidth()
    local outfitCollection = transmogFrameModule:GetModule("OutfitCollection")
    if outfitCollection and outfitCollection.GetExpandedWidth then
        return outfitCollection:GetExpandedWidth()
    end

    local outfitCollectionFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(
        transmogFrameModule:GetFrame(),
        "OutfitCollection"
    )

    return outfitCollectionFrame and outfitCollectionFrame:GetWidth() or 0
end

local function ApplyOutfitSwapResizeBounds(previewWidth)
    local outfitWidth = GetOutfitCollectionWidth()
    local totalWidth = outfitWidth + (previewWidth or 0)

    if totalWidth > 0 then
        transmogFrameModule:SetMinFrameWidth(totalWidth)
        transmogFrameModule:SetMaxFrameWidth(totalWidth)
    end
end

local function SetPreviewCollapsed(collapsed)
    local preview = Module:GetFrame()

    local accountDbModule = Core:GetModule("AccountDB");
    if accountDbModule then
        accountDbModule.DB:Get().TransmogFrame.CharacterPreviewCollapsedOutfit = collapsed and true or false
    end

    if collapsed then
        preview:Hide()
        preview:SetWidth(Module.Settings.HiddenFrameWidth)
        ApplyOutfitSwapResizeBounds(0)
        return
    end

    preview:Show()
    local width = CharacterPreviewFrame_UpdateWidth()
    ApplyOutfitSwapResizeBounds(width)
end

local function AddCollapseButton()
    local transmogFrame = transmogFrameModule:GetFrame();
    local characterPreviewFrame = Module:GetFrame();
    local outfitCollectionFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(
        transmogFrame,
        "OutfitCollection"
    )

    if (not transmogFrame or not characterPreviewFrame or not outfitCollectionFrame) then
        Module:DebugLog("TransmogFrame not found, cannot add CharacterPreview collapse button.")
        return
    end

    previewCollapseButton = Core.Libs.LibRu.Frames.CollapseExtendCheckButton.New(
        outfitCollectionFrame,
        "CharacterPreview_CollapseExtendButton",
        "bag-arrow",
        Module.Settings.CollapseButton.Size
    )

    characterPreviewFrame.CharacterPreviewCollapseButton = previewCollapseButton

    previewCollapseButton:SetPoint(
        "TOPRIGHT",
        previewCollapseButton:GetParent(),
        "TOPRIGHT",
        -Module.Settings.CollapseButton.OffsetX,
        Module.Settings.CollapseButton.OffsetY
    )
    previewCollapseButton:SetFrameStrata(Module.Settings.CollapseButton.FrameStrata)

    previewCollapseButton:AddScript("OnClick", function(self)
        local checked = self:GetChecked();

        SetPreviewCollapsed(checked)
    end)

    previewCollapseButton:Hide(); -- hide by default
end

local function AddLinkOutfitButton()
    local characterPreviewFrame = Module:GetFrame()

    previewLinkOutfitButton = CreateFrame(
        "Button",
        "BetterTransmog_CharacterPreview_LinkOutfitButton",
        characterPreviewFrame,
        "UIPanelButtonTemplate"
    )

    characterPreviewFrame.LinkOutfitButton = previewLinkOutfitButton

    previewLinkOutfitButton:SetSize(Module.Settings.LinkOutfitButton.Width, Module.Settings.LinkOutfitButton.Height)
    previewLinkOutfitButton:SetText("Link Outfit")
    previewLinkOutfitButton:SetFrameStrata(Module.Settings.LinkOutfitButton.FrameStrata)

    previewLinkOutfitButton:SetPoint(
        "BOTTOMLEFT",
        characterPreviewFrame,
        "BOTTOMLEFT",
        Module.Settings.LinkOutfitButton.OffsetX,
        Module.Settings.LinkOutfitButton.OffsetY
    )


    previewLinkOutfitButton:SetScript("OnClick", function()
        local selectedTransmogInfoList = characterPreviewFrame.ModelScene:GetPlayerActor():GetItemTransmogInfoList()

        local hyperlink = C_TransmogCollection.GetCustomSetHyperlinkFromItemTransmogInfoList(selectedTransmogInfoList);

        if hyperlink then
            local activeEditBox = ChatFrameUtil.GetActiveWindow()
            if activeEditBox then
                ChatFrameUtil.InsertLink(hyperlink)
            else
                local lastActiveEditBox = ChatFrameUtil.GetLastActiveWindow()
                if lastActiveEditBox and lastActiveEditBox:IsShown() then
                    ChatFrameUtil.ActivateChat(lastActiveEditBox)
                    ChatFrameUtil.InsertLink(hyperlink)
                else
                    ChatFrameUtil.OpenChat(hyperlink)
                end
            end
        end
    
    end)
end

---@param eventFrame Frame
---@param handle any
---@param displayMode string
local function ApplyDisplayMode(eventFrame, handle, displayMode)
    if not transmogFrameModule:IsValidDisplayMode(displayMode) then
        Module:DebugLog("UnimplmentedDisplayMode: " .. tostring(displayMode))
        return
    end

    local characterPreviewFrame = Module:GetFrame();
    if not characterPreviewFrame then
        Module:DebugLog("characterPreviewFrame frame not found, cannot adjust for display mode change.");
        return
    end

    if displayMode == transmogFrameModule.Enum.DISPLAY_MODE.FULL then
        characterPreviewFrame:Show();
        CharacterPreviewFrame_UpdateWidth();
        SetSlotButtonsVisible(true)

        if characterPreviewFrame.HideIgnoredToggle then
            characterPreviewFrame.HideIgnoredToggle:Show()
        end

        if characterPreviewFrame.CharacterPreviewCollapseButton then
            characterPreviewFrame.CharacterPreviewCollapseButton:Hide();
            characterPreviewFrame.CharacterPreviewCollapseButton:Disable();
        end
    elseif displayMode == transmogFrameModule.Enum.DISPLAY_MODE.OUTFIT_SWAP then
        Module:DebugLog("Showing characterPreviewFrame frame for OUTFIT_SWAP display mode.");
        characterPreviewFrame:Show();
        SetSlotButtonsVisible(false)

        if characterPreviewFrame.HideIgnoredToggle then
            characterPreviewFrame.HideIgnoredToggle:Hide()
        end

        local accountDbModule = Core:GetModule("AccountDB");

        if characterPreviewFrame.CharacterPreviewCollapseButton then
            local collapsed = (accountDbModule and accountDbModule.DB:Get().TransmogFrame.CharacterPreviewCollapsedOutfit)
                or false

            characterPreviewFrame.CharacterPreviewCollapseButton:SetCollapsed(collapsed)
            characterPreviewFrame.CharacterPreviewCollapseButton:Show();
            characterPreviewFrame.CharacterPreviewCollapseButton:Enable();
        end
        
        
        local collapsed = (accountDbModule and accountDbModule.DB:Get().TransmogFrame.CharacterPreviewCollapsedOutfit)
            or false
        SetPreviewCollapsed(collapsed)
    end
end

function Module:OnInitialize()
    Module:DebugLog("Applying changes.")

    Module:FixAnchors();
    
    CharacterPreviewFrame_HookReset();
    CharacterPreviewFrame_UpdateWidth();

    AddCollapseButton();
    AddLinkOutfitButton();

    -- hook on show, fix camera every time, show resets the camera settings
    transmogFrameModule:GetFrame():HookScript("OnShow", function(self)
        CharacterPreviewFrame_FixCamera();
    end)

    Core.EventFrame:AddScript("OnTransmogFrameDisplayModeChanged", ApplyDisplayMode)
end


function Module:FixAnchors()
    local outfitCollectionModule = transmogFrameModule:GetModule("OutfitCollection");
    local outfitCollectionFrame = nil;

    if outfitCollectionModule then
        outfitCollectionFrame = outfitCollectionModule:GetFrame();
    else
        outfitCollectionFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(
            transmogFrameModule:GetFrame(),
            "OutfitCollection"
        );
    end

    local characterPreviewFrame = Module:GetFrame();

    Module:DebugLog(outfitCollectionFrame)
    characterPreviewFrame:ClearAllPoints()
    characterPreviewFrame:SetPoint("TOPLEFT", outfitCollectionFrame, "TOPRIGHT")
    characterPreviewFrame:SetPoint("BOTTOMLEFT", outfitCollectionFrame, "BOTTOMRIGHT")

    local bg = characterPreviewFrame.Background
    bg:SetAllPoints(characterPreviewFrame)

    characterPreviewFrame.Gradients.GradientLeft:SetPoint("TOPLEFT", characterPreviewFrame)
    characterPreviewFrame.Gradients.GradientLeft:SetPoint("BOTTOMLEFT", characterPreviewFrame)

    characterPreviewFrame.Gradients.GradientRight:SetPoint("TOPRIGHT", characterPreviewFrame)
    characterPreviewFrame.Gradients.GradientRight:SetPoint("BOTTOMRIGHT", characterPreviewFrame)
end

function Module:GetFrame()
    if _characterPreviewFrame then return _characterPreviewFrame end;

    _characterPreviewFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(transmogFrameModule:GetFrame(), "CharacterPreview");
    
    if not _characterPreviewFrame then
        error("CharacterPreview frame is not found. Is the frame available yet?")
    end

    return _characterPreviewFrame
end