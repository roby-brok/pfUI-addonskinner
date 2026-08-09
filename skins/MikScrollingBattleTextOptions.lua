-- Mik's Scrolling Battle Text -- the options window.
--
-- MSBT itself is scrolling text on the WorldFrame and has nothing to skin. Its
-- configuration lives in the load-on-demand MikScrollingBattleTextOptions
-- addon, which is a 2007-era Blizzard-art window: four top-level frames built
-- from UI-Character-General tiles, six tabs, and well over a hundred buttons,
-- checkboxes, editboxes, dropdowns and scrollbars.
--
-- Registered under the options addon's own folder name so ADDON_LOADED fires
-- the skin at the moment the window is first opened, rather than at login when
-- none of these frames exist yet.
pfUI.addonskinner:RegisterSkin("MikScrollingBattleTextOptions", function()
  if not (pfUI and pfUI.api and pfUI_config) then return end

  local penv = pfUI:GetEnvironment()
  local StripTextures, CreateBackdrop = penv.StripTextures, penv.CreateBackdrop
  local CreateBackdropShadow = penv.CreateBackdropShadow
  local SkinButton, SkinCloseButton = penv.SkinButton, penv.SkinCloseButton
  local SkinCheckbox = penv.SkinCheckbox
  local SkinDropDown, SkinScrollbar = penv.SkinDropDown, penv.SkinScrollbar
  local SkinSlider, SkinTab = penv.SkinSlider, penv.SkinTab
  local GetStringColor = penv.GetStringColor

  -- Isolate every widget. The skinner already wraps the whole skin in one
  -- pcall, which means a single bad call takes the rest of the window with it:
  -- passing a ScrollFrame to SkinScrollbar (it wants the scrollbar) aborted the
  -- walk on the first tab that had one, so the General tab came out perfect and
  -- every tab after it was left completely unskinned. One widget failing must
  -- not cost the other hundred and fifty.
  local function try(fn, a, b, c, d)
    if not fn then return end
    pcall(fn, a, b, c, d)
  end

  -- Enumerating names is hopeless here -- the event and trigger rows alone are
  -- generated from templates in the hundreds -- so walk the tree and skin by
  -- object type. Each widget is marked so reopening the window is a no-op.
  local function SkinChildren(frame, depth)
    if not frame or depth > 6 then return end

    local children = { frame:GetChildren() }
    for _, child in ipairs(children) do
      if child and not child.pfSkinned then
        local name = child.GetName and child:GetName() or nil
        local otype = child.GetObjectType and child:GetObjectType() or nil

        if otype == "Button" then
          if name and string.find(name, "CloseButton") then
            -- anchored to the backdrop by the caller, which owns it
          elseif name and string.find(name, "Tab%d+$") then
            -- Anchored to the END of the name on purpose. The six tab buttons
            -- are MSBTFrameOptionsTab1..Tab6, but every widget inside a tab is
            -- named through it -- MSBTFrameOptionsTab3FrameEvent1EditFontSettingsButton
            -- and so on -- so an unanchored "Tab%d" matched all of them and sent
            -- every button in the window through SkinTab instead of SkinButton.
            try(SkinTab, child)
            child.pfSkinned = true
          elseif name and string.find(name, "ColorSwatch") then
            -- a colour swatch IS its texture; skinning it would hide the colour
          else
            try(SkinButton, child)
            child.pfSkinned = true
          end

        elseif otype == "CheckButton" then
          try(SkinCheckbox, child)
          child.pfSkinned = true

        elseif otype == "EditBox" then
          -- pfUI has no SkinEditBox; the convention elsewhere is to strip the
          -- Blizzard art and give it the standard backdrop.
          try(StripTextures, child)
          if child.SetBackdrop then child:SetBackdrop(nil) end
          try(CreateBackdrop, child, nil, nil, .8)
          child.pfSkinned = true

        elseif otype == "Slider" then
          try(SkinSlider, child)
          child.pfSkinned = true

        elseif otype == "ScrollFrame" then
          -- SkinScrollbar wants the scrollbar, not the scroll frame. Handing it
          -- the frame is what broke every tab past General.
          try(StripTextures, child)
          if name then try(SkinScrollbar, _G[name .. "ScrollBar"]) end
          child.pfSkinned = true

        elseif otype == "Frame" and name and string.find(name, "Dropdown") then
          try(SkinDropDown, child)
          child.pfSkinned = true
        end
      end

      -- recurse regardless: tab frames hold most of the real widgets
      if child and child.GetChildren then SkinChildren(child, depth + 1) end
    end
  end

  local function SkinWindow(frame)
    if not frame or frame.pfSkinned then return end

    try(StripTextures, frame)

    -- Legacy backdrop, i.e. painted on the frame itself rather than into a
    -- child frame. The default path parents the backdrop to the window at
    -- frame level - 1, which on a toplevel frame (all four of these are) ends
    -- up behind the window instead of inside it, so the body rendered fully
    -- transparent with the game world showing through.
    try(CreateBackdrop, frame, nil, true, .9)
    try(CreateBackdropShadow, frame)

    if frame.SetBackdropColor then
      frame:SetBackdropColor(0, 0, 0, .9)
      local er, eg, eb, ea = GetStringColor(pfUI_config.appearance.border.color)
      frame:SetBackdropBorderColor(er, eg, eb, ea)
    end

    local close = _G[frame:GetName() .. "CloseButton"]
    if close then try(SkinCloseButton, close, frame) end

    SkinChildren(frame, 0)
    frame.pfSkinned = true
  end

  -- Only the main tabbed window.
  --
  -- MSBTFontSettingsFrame (350x270), MSBTTriggerConfigFrame (400x270) and
  -- MSBTScrollAreaMoverControlFrame (180x500) are all declared far smaller than
  -- the content they display -- they relied on Blizzard art that overflows the
  -- frame rect to look like windows at all. Strip that art and the backdrop
  -- covers only the true rect, so the widgets spill onto the game world: the
  -- font settings panel ended up a short black bar with its dropdowns and
  -- preview text hanging below it, and the scroll-area window a narrow column
  -- with dropdowns wider than the frame.
  --
  -- Fixing that means resizing and re-anchoring somebody else's layout by hand,
  -- which is a different job from skinning it. MSBTFrameOptions is 640x440 and
  -- honestly sized, so it is the one that gets skinned.
  --
  -- The three scroll-area mover frames stay untouched for a separate reason:
  -- they are drag handles, and their art is the affordance.
  local windows = {
    "MSBTFrameOptions",
  }

  for _, name in ipairs(windows) do
    local f = _G[name]
    if f then
      SkinWindow(f)
      -- Tab frames and trigger/event rows are created and populated lazily, so
      -- re-walk on every show to catch widgets that did not exist the first
      -- time. SkinChildren is a no-op for anything already marked.
      penv.HookScript(f, "OnShow", function()
        SkinChildren(this, 0)
      end)
    end
  end

  pfUI.addonskinner:UnregisterSkin("MikScrollingBattleTextOptions")
end)
