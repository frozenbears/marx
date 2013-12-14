
module('marx', package.seeall)
require 'marx.core'

Stream = marx.Object:new()

-- abstract constructors/operators

function Stream:empty()
  assert(nil, "empty must be overridden")
end

function Stream:wrap(...)
  assert(nil, "wrap must be overridden")
end

function Stream:bind(binding)
  assert(nil, "bind must be overridden")
end

function Stream:concat(s)
  assert(nil, "concat must be overridden")
end

function Stream:zip(s)
  assert(nil, "zip must be overridden")
end

-- concrete operators

function Stream:flatten_map(f)
  return self:bind(function()
    return function(...)
      local stream = f(...)
      --an assert would be good here
      --though it would necessitate reflection
      return stream
    end
  end)
end

function Stream:flatten()
  return self:flatten_map(function(...)
    return ...
  end)
end

function Stream:map(f)
  return self:flatten_map(function(...)
    return self:wrap(f(...))
  end)
end

function Stream:map_replace(...)
  local args = {...}
  return self:map(function(_)
    return unpack(args)
  end)
end

function Stream:filter(predicate)
  return self:flatten_map(function(...)
    if predicate(...) then
      return self:wrap(...)
    else
      return self:empty()
    end
  end)
end

function Stream:ignore(...)
  local args = {...}
  return self:filter(function(...)
    local inner = {...}
    return not table.eq(inner,args)
  end)
end

function Stream:start_with(...)
  return self:wrap(...):concat(self)
end

function Stream:skip(n)
  return self:bind(function()
    local skipped = 0
    return function(...)
      if skipped >= n then return self:wrap(...) end
      skipped = skipped + 1
      return self:empty()
    end
  end)
end

function Stream:take(n)
  return self:bind(function()
    local taken = 0
    return function(...)
      local result = self:empty()
      local stop = nil
      
      if taken < n then result = self:wrap(...) end
      taken = taken + 1
      if taken >= n then stop = true end
      
      return result
    end
  end)
end
