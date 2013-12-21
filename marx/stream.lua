
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

function Stream:skip_until(predicate)
  return self:bind(function()
    local skipping = true
    return function(...)
      if skipping then
        if predicate(...) then
          skipping = false
        else
          return self:empty()
        end
      end
      return self:wrap(...)
    end
  end)
end

function Stream:skip_while(predicate)
  return self:skip_until(function(...)
    return not predicate(...)
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
      
      return result, stop
    end
  end)
end

function Stream:take_until(predicate)
  return self:bind(function()
    return function(...)
      local result = self:empty()
      local stop = nil
      if predicate(...) then
        stop = true
      else
        result = self:wrap(...)
      end
      return result, stop
    end
  end)
end

function Stream:take_while(predicate)
  return self:take_until(function(...)
    return not predicate(...)
  end)
end

function Stream:distinct_until_changed()
  return self:bind(function()
    local last = nil
    local initial = true
    return function(...)
      if not initial and table.eq(last, {...}) then
        return self:empty()
      end

      initial = false
      last = {...}
      return self:wrap(...)
    end
  end)
end

function Stream:join(streams, f)
  local current = nil
  for i,s in ipairs(streams) do
    if not current then
      current = s
    else
      current = f(current, s)
    end
  end

  if not current then
    return self:empty()
  else
    return current
  end
end

--this feels like a terrible naming convention but not sure
--how else to avoid a conflict with the instance method
--...maybe use param reflection to determine which implemenation to use?
function Stream:zip_all(streams)
  return self:join(streams, function(left, right)
    return left:zip(right)
  end)
end

function Stream:concat_all(streams)
  return self:join(streams, function(left, right)
    return left:concat(right)
  end)
end


--lack of an explicit tuple makes these a bit messy,
--since in order to support varargs we need to
--reverse the order of arguments and deal with vararg tables
--directly in the reduce function.

function Stream:scan(f, ...)
  local start = {...}
  return self:bind(function()
    local running = start
    return function(...)
      local next = {...}
      running = f(running, next)
      return self:wrap(unpack(running))
    end
  end)
end

function Stream:combine_previous(f, ...)
  local start = {...}
  return self:bind(function()
    local previous = start
    return function(...)
      local next = {...}
      local result = self:wrap(unpack(f(previous,next)))
      previous = next
      return result
    end
  end)
end

