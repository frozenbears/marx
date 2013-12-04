
module('marx.push', package.seeall)

require 'marx.stream'

function observer(on_next, on_complete, on_error)
  local t = {}
  local empty = function() end
  t.on_next = on_next
  t.on_complete = on_complete or empty
  t.on_error = on_error or empty
  return t
end

function sequence(on_subscription)
  local t = marx.stream.sequence()
  
  t.subscribe_observer = function(observer)
    on_subscription(observer)
  end
 
  t.subscribe = function(on_next, on_complete, on_error)
    return t.subscribe_observer(observer(on_next, on_complete, on_error))
  end

  t.map = function(transform)
    local composition = sequence(function(observer)
      t.subscribe(function(v)
        observer.on_next(transform(v))
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
      t.subscribe(function(v)
        if predicate(v) then
          observer.on_next(v)
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
      t.subscribe(function(v)
        observer.on_next(v)
      end, function()
        seq.subscribe(function(v)
          observer.on_next(v)
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
      t.subscribe(function(v)
        accum = comparator(accum, v)
      end, function()
        observer.on_next(accum)
        observer.on_complete()
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

-- only applicable to subject at the moment 
function disposable(subscribable, observer)
  local t = {}
  t._subscribable = subscribable
  t._observer = observer
  t.dispose = function()
    for i,v in pairs(t._subscribable.observers) do
      if v == t._observer then
        table.remove(t._subscribable.observers, i)
      end
    end
  end
  return t
end

function subject()
  local t = sequence(function()end)
  t.observers = {}
  t._completed = false
  
  t.subscribe_observer = function(observer)
    table.insert(t.observers, observer)
    return disposable(t, observer)
  end
 
  t.on_next = function(v)
    if not t._completed then
      for i,observer in ipairs(t.observers) do
        observer.on_next(v)
      end
    end
  end
  t.on_error = function(e)
    for i,observer in ipairs(t.observers) do
      observer.on_error(e)
    end
    t._completed = true
  end
  t.on_complete = function()
    for i,observer in ipairs(t.observers) do
      observer.on_complete()
    end
    t._completed = true
  end
  return t
end

function returns(v)
  local a = arg
  return sequence(function(observer)
    observer.on_next(unpack(a))
    observer.on_complete()
  end)
end

function empty()
  return sequence(function(observer)
    observer.on_complete()
  end)
end

function never()
  return sequence(function(observer)end)
end

function error(e)
  return sequence(function(observer)
    observer.on_error(e)
  end)
end

function generate(initial, cond, iterator, selector)
  return sequence(function(observer)
    local state = initial
    while not cond(state) do
      observer.on_next(selector(state))
      state = iterator(state)
    end
    observer.on_complete()
  end)
end

function range(min, max)
  return sequence(function(observer)
    for i = min,max do
      observer.on_next(i)
    end
    observer.on_complete()
  end)
end
