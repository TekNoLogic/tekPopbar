

local myname, ns = ...


local BINDING_OFFSET = 27


function ns.GetBinding(id)
  local _, _, keybind = GetBinding(BINDING_OFFSET + id)
  return keybind
end


function ns.SetBinding(id)
  if id > 12 then return end

  local keybind = ns.GetBinding(id)
  SetOverrideBindingClick(UIParent, nil, keybind, "tekPopbar"..id)
end
