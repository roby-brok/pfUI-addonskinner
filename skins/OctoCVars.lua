pfUI.addonskinner:RegisterSkin("OctoCVars", function()
  if pfUI and pfUI.api and pfUI_config then
    local penv = pfUI:GetEnvironment()
    local CreateBackdrop, CreateBackdropShadow = penv.CreateBackdrop, penv.CreateBackdropShadow
    local SkinButton, SkinCloseButton = penv.SkinButton, penv.SkinCloseButton
    local SkinCheckbox, SkinScrollbar = penv.SkinCheckbox, penv.SkinScrollbar

    local frame = _G["OctoCVarsFrame"]
    if not frame then
      pfUI.addonskinner:UnregisterSkin("OctoCVars")
      return
    end

    frame:SetBackdrop(nil)
    CreateBackdrop(frame, nil, nil, 0.9)
    CreateBackdropShadow(frame)

    if SkinCloseButton and _G["OctoCVarsFrameClose"] then
      SkinCloseButton(_G["OctoCVarsFrameClose"], frame.backdrop, -6, -6)
    end
    for _, name in ipairs({ "OctoCVarsFrameSet", "OctoCVarsFrameReset" }) do
      if _G[name] then SkinButton(_G[name]) end
    end
    if SkinCheckbox and _G["OctoCVarsFrameChanged"] then
      SkinCheckbox(_G["OctoCVarsFrameChanged"])
    end
    for _, name in ipairs({ "OctoCVarsFrameSearch", "OctoCVarsFrameEdit" }) do
      local e = _G[name]
      if e then
        for _, region in ipairs({ e:GetRegions() }) do
          if region.GetTexture and region.Hide then region:Hide() end
        end
        CreateBackdrop(e, nil, true)
      end
    end
    if SkinScrollbar and _G["OctoCVarsFrameScrollScrollBar"] then
      SkinScrollbar(_G["OctoCVarsFrameScrollScrollBar"])
    end
  end
  pfUI.addonskinner:UnregisterSkin("OctoCVars")
end)
