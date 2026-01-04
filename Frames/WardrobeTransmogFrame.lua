-- transmog model scene logic here

if not _G.BetterTransmog then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
end

--- @type LibRu
local LibRu = _G.LibRu

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end


-- convert wardrobe transmog frame to a eventframe
WardrobeTransmogFrame = LibRu.EventFrame.New(WardrobeTransmogFrame);

-- Button arrays for positioning
local buttonsLeft = {
    WardrobeTransmogFrame.HeadButton,
    WardrobeTransmogFrame.ShoulderButton,
    WardrobeTransmogFrame.BackButton,
    WardrobeTransmogFrame.ChestButton,
    WardrobeTransmogFrame.ShirtButton,
    WardrobeTransmogFrame.TabardButton,
    WardrobeTransmogFrame.WristButton
};

local buttonsRight = {
    WardrobeTransmogFrame.HandsButton,
    WardrobeTransmogFrame.WaistButton,
    WardrobeTransmogFrame.LegsButton,
    WardrobeTransmogFrame.FeetButton
}

-- Position left side buttons
local function PositionLeftButtons(yOffset, ySpacing)
    -- first left button
    buttonsLeft[1]:SetPoint("TOPLEFT", WardrobeTransmogFrame, "TOPLEFT", 28, -yOffset);
    
    -- other left buttons
    for i = 2, (#buttonsLeft) do
        buttonsLeft[i]:SetPoint("TOP", buttonsLeft[i - 1], "BOTTOM", 0, -ySpacing);
    end
end

-- Position right side buttons
local function PositionRightButtons(yOffset, ySpacing)
    -- first right button
    buttonsRight[1]:SetPoint("TOPRIGHT", WardrobeTransmogFrame, "TOPRIGHT", -28, -yOffset);

    -- other right buttons
    for i = 2, (#buttonsRight) do
        buttonsRight[i]:SetPoint("TOP", buttonsRight[i - 1], "BOTTOM", 0, -ySpacing);
    end
end

-- Position secondary shoulder button
local function PositionSeperateShoulderButton()
    WardrobeTransmogFrame.SecondaryShoulderButton:ClearAllPoints();
    WardrobeTransmogFrame.SecondaryShoulderButton:SetPoint("LEFT", WardrobeTransmogFrame.ShoulderButton, "RIGHT", 15, 0);
end

-- Position weapon buttons
local function PositionWeaponButtons()
    -- main hand + mainEnchant
    WardrobeTransmogFrame.MainHandButton:ClearAllPoints();
    WardrobeTransmogFrame.MainHandButton:SetPoint("BOTTOM", WardrobeTransmogFrame, "BOTTOM", -28, 24);
    
    WardrobeTransmogFrame.MainHandEnchantButton:ClearAllPoints();
    WardrobeTransmogFrame.MainHandEnchantButton:SetPoint("BOTTOM", WardrobeTransmogFrame.MainHandButton, "TOP", 0, -5);

    -- off-hand + offEnchant
    WardrobeTransmogFrame.SecondaryHandButton:ClearAllPoints();
    WardrobeTransmogFrame.SecondaryHandButton:SetPoint("BOTTOM", WardrobeTransmogFrame, "BOTTOM", 28, 24);
    
    WardrobeTransmogFrame.SecondaryHandEnchantButton:ClearAllPoints();
    WardrobeTransmogFrame.SecondaryHandEnchantButton:SetPoint("BOTTOM", WardrobeTransmogFrame.SecondaryHandButton, "TOP", 0, -5);
end

-- Handle overall sizing and button positioning
local function HandleButtonSizing(width, height)
    local yOffsetScalar = 0.1;
    local yOffset = height * yOffsetScalar;
    local ySpacing = (height * (1 - yOffsetScalar) - (#buttonsLeft * 60)) / #buttonsLeft
   
    PositionLeftButtons(yOffset, ySpacing);
    PositionSeperateShoulderButton();
    PositionRightButtons(yOffset, ySpacing);
    PositionWeaponButtons();
    
    -- double shoulder xmog toggle
    WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:ClearAllPoints();
    WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:SetPoint("BOTTOMLEFT", WardrobeCollectionFrame, "BOTTOMLEFT", 20, 20);
end

-- Initialize button positioning
WardrobeTransmogFrame.HeadButton:ClearAllPoints();

-- set new anchor points
WardrobeTransmogFrame:ClearAllPoints();
WardrobeTransmogFrame:SetPoint("TOPLEFT", WardrobeFrame, "TOPLEFT", 4, -86);
WardrobeTransmogFrame:SetPoint("BOTTOMLEFT", WardrobeFrame, "BOTTOMLEFT", 4, 25);

local InsetBG = WardrobeTransmogFrame.Inset.BG;
InsetBG:ClearAllPoints();
InsetBG:SetPoint("TOPLEFT", WardrobeTransmogFrame.Inset, "TOPLEFT", 1, -1);
InsetBG:SetPoint("BOTTOMRIGHT", WardrobeTransmogFrame.Inset, "BOTTOMRIGHT", -1, 1);

WardrobeFrame:AddScript("OnSizeChanged", function(handle, width, height)
    local TransmogFrameConfig = _G.BetterTransmog.DB.Account.TransmogFrame;
    local newWidth = TransmogFrameConfig.CharacterModelWidthPercent / 100 * width;
    WardrobeTransmogFrame:SetWidth(newWidth);
    
    -- Position buttons based on new size
    HandleButtonSizing(newWidth, height);
end)

_G.BetterTransmog.EventFrame:AddScript("OnAccountDBInitialized", function(handle)
    -- Initial button positioning
    local width = WardrobeTransmogFrame:GetWidth();
    local height = WardrobeFrame:GetHeight();
    HandleButtonSizing(width, height);
end)

