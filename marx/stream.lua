
module('marx.stream', package.seeall)

function sequence()
  local t = {}
  
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
      return function(v)
        return f(v)
      end
    end)
  end

  t.flatten = function()
    return t.flatten_map(function(v)
      return v
    end)
  end

  t.map = function(f)
    return t.flatten_map(function(v)
      return t.returns(f(v))
    end)
  end

  t.map_replace = function(v)
    return t.map(function()
      return v
    end)
  end

  t.filter = function(predicate)
    return t.flatten_map(function(v)
      if predicate(v) then
        return t.returns(v)
      else
        return t.empty()
      end
    end)
  end

  return t
end

-- abstract core sequence types
function empty()
  return nil
end

function returns(v)
  return nil
end
