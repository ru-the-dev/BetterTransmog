-- if not _G.BetterTransmog then
--     error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
-- end

-- --- @type LibRu
-- local LibRu = _G.LibRu

-- if not LibRu then
--     error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
-- end


-- -- convert wardrobe frame to a eventframe
-- CollectionsJournal = LibRu.EventFrame.New(CollectionsJournal);

-- -- Configure the UI panel layout to work with our custom frame
-- UIPanelWindows["CollectionsJournal"] = {
--     area = "center",         -- Center so it doesn't push other panels
--     pushable = 0,            -- Don't let other panels push us around
--     whileDead = 1,           -- Can be shown while dead
--     width = CollectionsJournal:GetWidth(), -- Use actual width
--     xOffset = 0,
--     yOffset = 0,
--     allowOtherPanels = 1     -- Allow other panels to be open
-- }

-- -- set the CollectionsJournal to be movable
-- CollectionsJournal:SetMovable(true);
-- CollectionsJournal:EnableMouse(true);
-- CollectionsJournal:SetClampedToScreen(true);
-- CollectionsJournal:SetUserPlaced(true); -- Remember user position
-- CollectionsJournal:SetFrameStrata("HIGH"); -- Always on top of other UI panels

-- -- Update UIPanelWindows width when resized
-- CollectionsJournal:AddScript("OnSizeChanged", function(handle, width, height)
--     if UIPanelWindows["CollectionsJournal"] then
--         UIPanelWindows["CollectionsJournal"].width = width
--     end
-- end)

-- CollectionsJournal.TitleContainer:SetScript("OnMouseDown", function()
--     CollectionsJournal:StartMoving();
-- end)

-- CollectionsJournal.TitleContainer:SetScript("OnMouseUp", function()
--     CollectionsJournal:StopMovingOrSizing();
-- end)

-- -- enable resizing
-- LibRu.CreateResizeButton(CollectionsJournal, CollectionsJournal, 16);
-- -- TODO: Set minimum and maximum size constraints

-- _G.BetterTransmog.EventFrame:AddScript("OnAccountDBInitialized", function(handle)
--     if name ~= "BetterTransmog" then return end;
    
-- end)