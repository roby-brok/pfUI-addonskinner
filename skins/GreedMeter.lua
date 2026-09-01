pfUI.addonskinner:RegisterSkin("GreedMeter", function()
  local penv = pfUI:GetEnvironment()
  local CreateBackdrop, CreateBackdropShadow = penv.CreateBackdrop, penv.CreateBackdropShadow
  local StripTextures, SetHighlight, HookScript = penv.StripTextures, penv.SetHighlight, penv.HookScript
  local SkinButton, SkinCloseButton = penv.SkinButton, penv.SkinCloseButton
  local SkinCheckbox, SkinSlider, SkinDropDown = penv.SkinCheckbox, penv.SkinSlider, penv.SkinDropDown
  local GetNoNameObject = penv.GetNoNameObject

  local UI = GreedMeter and GreedMeter.UI
  if not UI then
    pfUI.addonskinner:UnregisterSkin("GreedMeter")
    return
  end

  local font = pfUI.font_default
  local font_size = tonumber(pfUI_config.global.font_size) or 11

  -- [ windows ] --
  -- Legacy backdrop, per the fork note in the README: the meter, settings and
  -- detail windows all sit on a raised strata, and the default path parents the
  -- backdrop one frame level below the window, which on those lands behind it
  -- and leaves the body transparent.
  --
  -- It also keeps GreedMeter's own "Window Opacity" slider working. The addon
  -- repaints its background from that slider on every refresh
  -- (ApplyFrameBackgroundOpacity), and with the backdrop on the frame itself
  -- those repaints drive the pfUI backdrop instead of being swallowed by a
  -- frame that no longer has one. Only the border write is dropped -- GreedMeter
  -- fades it towards nothing as opacity falls, which would take pfUI's border
  -- with it.
  local function SkinWindow(f)
    if not f or f.pfSkinnedWindow then return end
    f.pfSkinnedWindow = true

    f:SetBackdrop(nil)
    CreateBackdrop(f, nil, true)
    CreateBackdropShadow(f)
    f.SetBackdropBorderColor = function() return end
  end

  -- GreedMeter's own dropdown is built on first use rather than at load, so it
  -- is skinned from the click that creates it.
  local function SkinOwnDropdown()
    SkinWindow(_G["GreedMeterDropDownFrame"])
  end

  -- [ header buttons ] --
  -- Reset / Segment / Mode / Name / Announce / + / - are plain Buttons carrying
  -- a hand-rolled backdrop and a loose FontString. SkinButton is the wrong tool
  -- for them: it drives normal/pushed/disabled textures and a button font that
  -- these widgets do not have.
  local function SkinHeaderButton(button, label)
    if not button or button.pfSkinnedButton then return end
    button.pfSkinnedButton = true

    button:SetBackdrop(nil)
    CreateBackdrop(button, nil, true)
    SetHighlight(button)
    if label then label:SetFont(font, font_size, "OUTLINE") end
    HookScript(button, "OnClick", SkinOwnDropdown)
  end

  local function ButtonTexture(button)
    if not button.GetNormalTexture then return nil end
    local texture = button:GetNormalTexture()
    return texture and texture.GetTexture and texture:GetTexture() or nil
  end

  -- [ generic widget pass ] --
  -- The settings window is four pages of Blizzard templates nested several
  -- frames deep, so it is walked and skinned by object type rather than by name.
  -- Each widget gets its own pcall: the skinner wraps a whole skin in a single
  -- pcall, so without this one odd widget abandons every widget after it, and
  -- silently unless notifications are on.
  local function SkinWidget(widget, otype, parent)
    if otype == "CheckButton" then
      SkinCheckbox(widget)
    elseif otype == "Slider" then
      SkinSlider(widget)
    elseif otype == "EditBox" then
      StripTextures(widget)
      CreateBackdrop(widget, nil, true)
    elseif otype == "Button" then
      local texture = ButtonTexture(widget)
      -- Colour swatches are deliberately skipped: the swatch is its texture, so
      -- skinning it would hide the colour it exists to show. They carry no
      -- normal texture, so this test excludes them on its own.
      if texture and strfind(texture, "MinimizeButton") then
        StripTextures(widget)
        SkinCloseButton(widget, parent, -4, -4)
      elseif texture and strfind(texture, "UI%-Panel%-Button") then
        SkinButton(widget)
      end
    elseif otype == "Frame" then
      -- UIDropDownMenuTemplate: SkinDropDown reaches for <name>Button, so both
      -- the name and that child have to exist before it is safe to call.
      local name = widget.GetName and widget:GetName()
      if name and _G[name .. "Button"] then SkinDropDown(widget) end
    end
  end

  local function SkinWidgets(frame, depth)
    if not frame or not frame.GetChildren or depth > 6 then return end

    for _, child in ipairs({ frame:GetChildren() }) do
      if not child.pfSkinnedWidget then
        child.pfSkinnedWidget = true
        pcall(SkinWidget, child, child.GetObjectType and child:GetObjectType(), frame)
      end
      SkinWidgets(child, depth + 1)
    end
  end

  -- [ meter windows ] --
  local function SkinMeterFrame(f)
    if not f or f.pfSkinnedMeter then return end
    f.pfSkinnedMeter = true

    SkinWindow(f)

    SkinHeaderButton(f.resetBtn, f.resetLabel)
    SkinHeaderButton(f.segBtn, f.segLabel)
    SkinHeaderButton(f.modeBtn, f.modeLabel)
    SkinHeaderButton(f.nameBtn, f.nameLabel)
    SkinHeaderButton(f.announceBtn, f.announceLabel)
    SkinHeaderButton(f.addBtn, f.addLabel)
    SkinHeaderButton(f.removeBtn, f.removeLabel)

    if f.title then f.title:SetFont(font, font_size, "OUTLINE") end
    if f.emptyLabel then f.emptyLabel:SetFont(font, font_size, "OUTLINE") end

    -- Bar textures and bar fonts are left alone on purpose. GreedMeter owns both
    -- through its own Appearance page and re-applies them on every layout pass,
    -- so anything set here is overwritten at the next refresh while the addon's
    -- own settings quietly stop describing what is on screen. Its "Flat" bar
    -- style is the one that sits best next to pfUI.
  end

  local function SkinDetailFrame()
    local f = _G["GreedMeterDetail"]
    if not f then return end

    if not f.pfSkinnedWindow then
      SkinWindow(f)
      if f.title then f.title:SetFont(font, font_size + 1, "OUTLINE") end
      if f.subtitle then f.subtitle:SetFont(font, font_size, "OUTLINE") end

      local close = GetNoNameObject(f, "Button", nil, "UI-Panel-MinimizeButton-Up")
      if close then
        close.pfSkinnedWidget = true
        StripTextures(close)
        SkinCloseButton(close, f, -4, -4)
      end

      -- ability rows are built as the window is filled, so re-walk on show
      HookScript(f, "OnShow", function() SkinWidgets(this, 1) end)
    end

    SkinWidgets(f, 1)
  end

  local function SkinSettingsFrame()
    local f = _G["GreedMeterSettings"]
    if not f then return end

    if not f.pfSkinnedWindow then
      SkinWindow(f)
      -- the colour palette and the media dropdowns are only built when their
      -- page is first opened
      HookScript(f, "OnShow", function()
        SkinWidgets(this, 1)
        SkinOwnDropdown()
      end)
    end

    SkinWidgets(f, 1)
    SkinOwnDropdown()
  end

  -- [ apply ] --
  if UI.frames then
    for i = 1, table.getn(UI.frames) do
      SkinMeterFrame(UI.frames[i])
    end
  end
  SkinDetailFrame()
  SkinSettingsFrame()

  -- Meter windows are added at runtime with the + button (up to six), and the
  -- settings and detail windows are only built on first open, so the three
  -- constructors are wrapped to skin whatever they hand back. Wrapped rather
  -- than hooksecurefunc'd because the frame comes back as the return value.
  if not UI.pfSkinnerHooked then
    UI.pfSkinnerHooked = true

    local CreateMeterFrame = UI.CreateMeterFrame
    if CreateMeterFrame then
      UI.CreateMeterFrame = function(self, isPrimary, copyFrom)
        local f = CreateMeterFrame(self, isPrimary, copyFrom)
        SkinMeterFrame(f)
        return f
      end
    end

    local CreateDetailFrame = UI.CreateDetailFrame
    if CreateDetailFrame then
      UI.CreateDetailFrame = function(self)
        local f = CreateDetailFrame(self)
        SkinDetailFrame()
        return f
      end
    end

    local CreateSettingsFrame = UI.CreateSettingsFrame
    if CreateSettingsFrame then
      UI.CreateSettingsFrame = function(self)
        local f = CreateSettingsFrame(self)
        SkinSettingsFrame()
        return f
      end
    end
  end

  pfUI.addonskinner:UnregisterSkin("GreedMeter")
end)
