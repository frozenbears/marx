
module('marx', package.seeall)
require 'marx.stream'

Signal = marx.Stream:new()

function Signal:create(on_subscribe)
  local s = self:new()
  function s:subscribe_observer(observer)
    on_subscribe(observer)
  end
  return s
end

function Signal:subscribe_observer(observer)
  self:on_subscribe(observer)
end

function Signal:subscribe(on_next, on_complete, on_error)
  local observer = {}
  local empty = function() end
  observer.on_next = on_next or empty
  observer.on_complete = on_complete or empty
  observer.on_error = on_error or empty
  return self:subscribe_observer(observer)
end


--overrides

function Signal:wrap(...)
  local args = {...}
  return self:create(function(observer)
    observer.on_next(unpack(args))
    observer.on_complete()
  end)
end

function Signal:empty()
  return self:create(function(observer)
    observer.on_complete()
  end)
end

--[[

bind should:

- subscribe to the original signal of values
- any time the original signal sends a value, transform it using the bind function
- if the bind function returns a signal, subscribe to it pass all its values through to the
  observer as they're received
- if the bind function asks the bind to terminate, complete the *original* signal
- when *all* signals complete, send completed to the subscriber

]]

function Signal:bind(f)
  assert(f, "bind function must be non-nil")
  
  return Signal:create(function(observer)
    local binding = f()
    local signals = {}
    signals.count = 0
    
    local function complete_signal(s)
      signals[s] = nil
      signals.count = signals.count - 1
      if signals.count == 0 then
        observer.on_complete()
      end
    end

    local function add_signal(s)
      signals[s] = true
      signals.count = signals.count + 1
      
      s:subscribe(function(...)
        observer.on_next(...)
      end, function()
        complete_signal(s)
      end, function(err)
        observer.on_error(err)
      end)  
    end
    
    self:subscribe(function(...)
      local s, stop = binding(...)
      if (s) then add_signal(s) end
      if not s or stop then complete_signal(self) end
    end, function()
      complete_signal(self)  
    end, function(err)
      observer.on_error(err)
    end)
  end)
end







