
module('marx.pull', package.seeall)

function sequence(on_next)
  local t = {}
  t.next = on_next

  t.map = function(transform)
    local composition = sequence(function()
      local result, e = t.next()
      if result then 
        result = transform(result)
        return result
      end
      return nil, e
    end)
    return composition
  end

  t.filter = function(predicate)
    local composition = sequence(function()
      while true do
        local result, e = t.next()
        if result then
          if predicate(result) then
            return result
          end
        else
          return nil, e
        end
      end
    end)
    return composition
  end

  t.concat = function(seq)
    local composition = sequence(function()
      local result, e = t.next()
      if not result and not e then
        result, e = seq.next()
      end
      return result, e
    end)
    return composition
  end

  t.fold = function(accum, comparator)
    local done = false
    local composition = sequence(function()
      while true do
        local result, e = t.next()
        if result then
          accum = comparator(accum, result)
        else
          if not done then
            done = true
            return accum
          else
            return nil, e
          end
        end
      end
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

function range(min, max)
  local i = min
  return sequence(function()
    local ret = nil
    if i <= max then ret = i end
    i = i + 1
    return ret
  end)
end





