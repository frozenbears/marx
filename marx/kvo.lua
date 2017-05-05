
module('marx.kvo', package.seeall)

local index = {}
local empty = function() end

function build_metatable(on_read, on_write)
  local mt = {
    __index = function(t,k)
      on_read(k)
      return t[index][k]
    end, __newindex = function(t,k,v)
      on_write(k,v)
      t[index][k] = v
    end
  }
  return mt
end

function proxy(t)
  local p = {}
  p[index] = t
  setmetatable(p, build_metatable(empty, empty))
  return p
end

