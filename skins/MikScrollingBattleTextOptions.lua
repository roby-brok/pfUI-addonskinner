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
          elseif name and string.find(name, "Tab%d") then
            if SkinTab then SkinTab(child) end
            child.pfSkinned = true
          elseif name and string.find(name, "ColorSwatch") then
            -- a colour swatch IS its texture; skinning it would hide the colour
          else
            SkinButton(child)
            child.pfSkinned = true
          end

        elseif otype == "CheckButton" then
          if SkinCheckbox then SkinCheckbox(child) end
          child.pfSkinned = true

        elseif otype == "EditBox" then
          -- pfUI has no SkinEditBox; the convention elsewhere is to strip the
          -- Blizzard art and give it the standard backdrop.
          StripTextures(child)
          if child.SetBackdrop then child:SetBackdrop(nil) end
          CreateBackdrop(child, nil, nil, .8)
          child.pfSkinned = true

        elseif otype == "Slider" then
          if SkinSlider then SkinSlider(child) end
          child.pfSkinned = true

        elseif otype == "ScrollFrame" then
          if SkinScrollbar then SkinScrollbar(child) end
          child.pfSkinned = true

        elseif otype == "Frame" and name and string.find(name, "Dropdown") then
          if SkinDropDown then SkinDropDown(child) end
          child.pfSkinned = true
        end
      end

      -- recurse regardless: tab frames hold most of the real widgets
      if child and child.GetChildren then SkinChildren(child, depth + 1) end
    end
  end

  local function SkinWindow(frame)
    if not frame or frame.pfSkinned then return end

    StripTextures(frame)
    if frame.SetBackdrop then frame:SetBackdrop(nil) end
    if frame.SetBackdropColor then frame:SetBackdropColor(0, 0, 0, 0) end
    CreateBackdrop(frame, nil, nil, .8)
    CreateBackdropShadow(frame)

    if frame.backdrop then
      frame.backdrop:SetBackdropColor(0, 0, 0, .8)
      local er, eg, eb, ea = GetStringColor(pfUI_config.appearance.border.color)
      frame.backdrop:SetBackdropBorderColor(er, eg, eb, ea)
    end

    local close = _G[frame:GetName() .. "CloseButton"]
    if close then SkinCloseButton(close, frame.backdrop) end

    SkinChildren(frame, 0)
    frame.pfSkinned = true
  end

  -- The four windows the options addon can put on screen. The three scroll-area
  -- mover frames are deliberately left alone: they are drag handles the user
  -- positions the scroll areas with, and their art is the affordance.
  local windows = {
    "MSBTFrameOptions",
    "MSBTFontSettingsFrame",
    "MSBTTriggerConfigFrame",
    "MSBTScrollAreaMoverControlFrame",
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
