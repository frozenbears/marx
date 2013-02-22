
module('marx.push', package.seeall)

function observer(on_next, on_complete, on_error)
  local t = {}
  local empty = function() end
  t.on_next = on_next
  t.on_complete = on_complete or  empty
  t.on_error = on_error or empty
  return t
end

function sequence(on_subscription)
  local t = {}
  t.observers = {}

  t.subscribe_observer = function(observer)
    table.insert(t.observers, observer)
    on_subscription(observer)
  end
 
  t.subscribe = function(on_next, on_complete, on_error)
    t.subscribe_observer(observer(on_next, on_complete, on_error))
    return t
  end

  t.map = function(transform)
    local composition = sequence(function(observer)
      t.subscribe(function(value)
        observer.on_next(transform(value))
      end, function()
        observer.on_complete()
      end, function(e)
        observer.on_error(e)
      end)
    end)
    return composition
  end

  t.filter = function(predicate)
    local composition = sequence(function(observer)  
      t.subscribe(function(value)
        if predicate(value) then
          observer.on_next(value)
        end
      end, function()
        observer.on_complete()
      end, function(e)
        observer.on_error(e)
      end)
    end)
    return composition
  end
  
  t.concat = function(seq)
    local composition = sequence(function(observer)
      t.subscribe(function(value)
        observer.on_next(value)
      end, function()
        seq.subscribe(function(value)
          observer.on_next(value)
        end, function()
          observer.on_complete()
        end, function(e)
          observer.on_error(e)
        end)
      end, function(e)
        observer.on_error(e)
      end)
    end)
    return composition
  end

  t.fold = function(accum, comparator)
    local composition = sequence(function(observer)
      t.subscribe(function(value)
        accum = comparator(accum, value)
      end, function()
        observer.on_next(accum)
      end, function(e)
        observer.on_error(e)
      end)
    end)
    return composition  
  end

  setmetatable(t, {
    __eq = function(t, other)
      for k,v in pairs(t) do
        if other[k] ~= v then
          return false
        end
      end

      for k,v in pairs(other) do
        if t[k] ~= v then
          return false
        end
      end
    return true
    end
  })
  
  return t
end

function subject()
  local t = sequence(function()end)
  t.on_next = function(...)
    for i,observer in ipairs(t.observers) do
      observer.on_next(...)
    end
  end
  t.on_error = function(e)
    for i,observer in ipairs(t.observers) do
      observer.on_error(e)
    end
  end
  t.on_complete = function()
    for i,observer in ipairs(t.observers) do
      observer.on_complete()
    end
  end
  return t
end

function range(min, max)
  return sequence(function(observer)
    for i = min,max do
      observer.on_next(i)
    end
    observer.on_complete()
  end)
end
