-- Verbatim port of the BetterCharacterStats skin for OctoStats' paperdoll
-- block: same frame layout, renamed globals (OctoStatsDollFrame and the
-- OSStatFrame* dropdowns instead of BCSFrame / PlayerStatFrame*).
pfUI.addonskinner:RegisterSkin("OctoStats", function()
  if pfUI and pfUI.api and pfUI_config then
    local penv = pfUI:GetEnvironment()
    local GetStringColor, GetBorderSize = penv.GetStringColor, penv.GetBorderSize
    local SkinDropDown, HookScript = penv.SkinDropDown, penv.HookScript

    local dollframe = _G["OctoStatsDollFrame"]
    if not dollframe then
      pfUI.addonskinner:UnregisterSkin("OctoStats")
      return
    end

    local function ApplyDollSkin()
      for _, region in ipairs({dollframe:GetRegions()}) do
        if region and region.Hide then region:Hide() end
      end

      if not dollframe.pfborder then
        local rawborder, border = GetBorderSize()
        local er, eg, eb, ea = GetStringColor(pfUI_config.appearance.border.color)

        local b = CreateFrame("Frame", nil, dollframe:GetParent())
        b:SetFrameLevel(dollframe:GetFrameLevel() - 2)
        b:SetPoint("TOPLEFT", dollframe, "TOPLEFT", -border, border)
        b:SetPoint("BOTTOMRIGHT", dollframe, "BOTTOMRIGHT", border, -border)
        b:SetBackdrop(pfUI.backdrop)
        b:SetBackdropColor(0, 0, 0, .8)
        b:SetBackdropBorderColor(er, eg, eb, ea)
        dollframe.pfborder = b

        local shadow = CreateFrame("Frame", nil, dollframe:GetParent())
        shadow:SetFrameLevel(dollframe:GetFrameLevel() - 3)
        shadow:SetPoint("TOPLEFT", b, "TOPLEFT", -3, 3)
        shadow:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 3, -3)
        shadow:SetBackdrop({ bgFile = pfUI.media["img:blank"], tile = true, tileSize = 1 })
        shadow:SetBackdropColor(0, 0, 0, .5)
        dollframe.pfborder_shadow = shadow
      end
    end

    local function ApplyDropDownSkin()
      if dollframe.pfdropskinned then return end

      local left = _G["OSStatFrameLeftDropDown"]
      local right = _G["OSStatFrameRightDropDown"]

      if left and left:GetObjectType() == "Frame" then
        SkinDropDown(left, nil, nil, nil, true)
        if left.backdrop then
          left.backdrop:SetPoint("TOPLEFT", 19, -2)
          left.backdrop:SetPoint("BOTTOMRIGHT", -19, 7)
        end
      end

      if right and right:GetObjectType() == "Frame" then
        SkinDropDown(right, nil, nil, nil, true)
        if right.backdrop then
          right.backdrop:SetPoint("TOPLEFT", 19, -2)
          right.backdrop:SetPoint("BOTTOMRIGHT", -19, 7)
        end
      end

      dollframe.pfdropskinned = true
    end

    local dropper = CreateFrame("Frame", nil, UIParent)
    dropper:RegisterEvent("PLAYER_ENTERING_WORLD")
    dropper:SetScript("OnEvent", function()
      this:UnregisterAllEvents()
      ApplyDropDownSkin()
    end)

    HookScript(dollframe, "OnShow", ApplyDollSkin)
    ApplyDollSkin()
  end
  pfUI.addonskinner:UnregisterSkin("OctoStats")
end)
