
module('marx.pull', package.seeall)

function sequence(on_next)
  local t = {}
  t.next = on_next

  t.map = function(transform)
    local composition = sequence(function(value)
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
    local composition = sequence(function(value)
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
  
  return t
end

function constant(x)
  return sequence(function()
    return x
  end)
end





