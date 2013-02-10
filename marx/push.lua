
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
      t.subscribe(function(value, error)
        if value and not error then 
          value = transform(value) end
        observer.on_next(value, error)
      end)
    end)
    return composition
  end

  t.filter = function(predicate)
    local composition = sequence(function(observer)
      t.subscribe(function(value, error)
        if value then
          if predicate(value) then
            observer.on_next(value)
          end
        else
          observer.on_next(nil, error)
        end
      end)
    end)
    return composition
  end
  
  t.concat = function(seq)
    local composition = sequence(function(observer)
      t.subscribe(function(value, error)
        if value then
          observer.on_next(value)
        else
          if error then
            observer.on_next(nil, error)
          else
            seq.subscribe(function(value, error)
              if value then
                observer.on_next(value)
              else
                observer.on_next(value, error)
              end
            end)
          end
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
    observer.on_next(nil)
  end)
end
