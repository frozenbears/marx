
module('marx.stream', package.seeall)

function sequence()
  local t = {}
  t.type = marx.stream

  --abstract operators
  t.bind = function(binding)
    return nil
  end

  t.concat = function(stream)
    return nil
  end

  t.zip = function(stream)
    return nil
  end

  --concrete operators
  t.flatten_map = function(f)
    return t.bind(function()
      return function(term, ...)
        return f(...)
      end
    end)
  end

  t.flatten = function()
    return t.flatten_map(function(...)
      return ...
    end)
  end

  t.map = function(f)
    return t.flatten_map(function(...)
      return t.type.returns(...)
    end)
  end

  t.map_replace = function(object)
    return t.map(function()
      return object
    end)
  end

  t.filter = function(predicate)
    return t.flatten_map(function(...)
      if predicate(...) then
        return t.type.returns(...)
      else
        return t.type.empty()
      end
    end)
  end

  return t
end

-- abstract core sequence types
function empty()
  return nil
end

function returns(...)
  return nil
end
