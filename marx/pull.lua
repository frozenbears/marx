
module('marx.pull', package.seeall)

function sequence(on_next)
  local t = {}
  t.next = on_next

  t.map = function(transform)
    local composition = sequence(function()
      local result, error = t.next()
      if result then 
        result = transform(result)
        return result
      end
      return nil, error
    end)
    return composition
  end

  t.filter = function(predicate)
    local composition = sequence(function()
      while true do
        local result, error = t.next()
        if result then
          if predicate(result) then
            return result
          end
        else
          return nil, error
        end
      end
    end)
    return composition
  end

  t.concat = function(seq)
    local composition = sequence(function()
      local result, error = t.next()
      if not result and not error then
        result, error = seq.next()
      end
      return result, error
    end)
    return composition
  end

  t.iterator = function()
    local iter = function(seq)
      return  seq.next()
    end
    return iter, t
  end
  
  return t
end

function constant(x)
  return sequence(function()
    return x
  end)
end





