if not _G.BetterTransmog then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
end

--- @type LibRu
local LibRu = _G.LibRu

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end

-- convert wardrobe frame to a eventframe
WardrobeFrame = LibRu.EventFrame.New(WardrobeFrame);

-- -- set the WardrobeFrame to be movable
-- WardrobeFrame:SetMovable(true);
-- WardrobeFrame:EnableMouse(true);
-- WardrobeFrame:SetClampedToScreen(true);
-- WardrobeFrame.TitleContainer:SetScript("OnMouseDown", function()
--     WardrobeFrame:StartMoving();
-- end)

-- WardrobeFrame.TitleContainer:SetScript("OnMouseUp", function()
--     WardrobeFrame:StopMovingOrSizing();
-- end)


-- enable resizing
LibRu.CreateResizeButton(WardrobeFrame, WardrobeFrame, 16);

WardrobeFrame:AddScript("OnSizeChanged", function(handle, width, height)
   _G.BetterTransmog.DebugLog("WardrobeFrame size changed: " .. width .. "x" .. height);
    WardrobeFrame:SetAttribute("UIPanelLayout-width", width);
end)

-- TODO: Set minimum and maximum size constraints

_G.BetterTransmog.EventFrame:AddScript("OnAccountDBInitialized", function(handle)
    if name ~= "BetterTransmog" then return end;

end)

