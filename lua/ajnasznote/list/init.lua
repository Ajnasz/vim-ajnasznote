local function tailhelper(head, ...)
  if (#{...} > 0) then
    return {...}
  else
    return nil
  end
end
local function tail(t)
  return tailhelper((table.unpack or unpack)(t))
end
local function any(cb, list)
  if (not list or (0 == #list)) then
    return false
  else
    if cb(list[1]) then
      return true
    else
      return any(cb, tail(list))
    end
  end
end
local function every(cb, list)
  if (not list or (0 == #list)) then
    return true
  else
    if cb(list[1]) then
      return every(cb, tail(list))
    else
      return false
    end
  end
end
local function find(cb, list)
  if (not list or (0 == #list)) then
    return nil
  else
    if cb(list[1]) then
      return list[1]
    else
      return find(cb, tail(list))
    end
  end
end
local function has_common(list1, list2)
  local function _8_(list1_item)
    local function _9_(_241)
      return (list1_item == _241)
    end
    return any(_9_, list2)
  end
  return any(_8_, list1)
end
local function has_all(list1, list2)
  local function _10_(list1_item)
    local function _11_(_241)
      return (list1_item == _241)
    end
    return any(_11_, list2)
  end
  return every(_10_, list1)
end
return {tail = tail, any = any, find = find, has_common = has_common, every = every, has_all = has_all}
