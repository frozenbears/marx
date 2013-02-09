
module('marx.push', package.seeall)

function observer(on_next)
  local t = {}
  t.on_next = on_next
  return t
end

function sequence(on_subscription)
  local t = {}
  t.observers = {}
  
  t._subscribe = function(observer)
    table.insert(t.observers, observer)
    on_subscription(observer)
  end
 
  t.subscribe = function(arg)
    if type(arg) == "table" then
      t._subscribe(arg)
    else
      t._subscribe(observer(arg))
    end
    return t
  end

  t.map = function(transform)
    local composition = sequence(function(observer)
      t.subscribe(function(value)
        observer.on_next(transform(value))
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
      end)
    end)
    return composition
  end
  return t
end

function range(min, max)
  return sequence(function(observer)
    for i = min,max do
      observer.on_next(i)
    end
  end)
end
