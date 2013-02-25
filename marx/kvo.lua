
module('marx.kvo', package.seeall)
require 'marx.push'

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

function bind(p)
  local subject = marx.push.subject()
  setmetatable(p, build_metatable(function(k)
    subject.on_next(k)
  end, function(k, v)
    subject.on_next(k, v)
  end))
  return subject
end

