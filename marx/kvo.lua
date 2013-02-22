
module('marx.kvo', package.seeall)
require 'marx.push'

local index = {}

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

function build_proxy(t)
  local proxy = {}
  proxy[index] = t
  return proxy
end

function bind(proxy)
  local subject = marx.push.subject()
  setmetatable(proxy, build_metatable(function(k)
    subject.on_next(k)
  end, function(k, v)
    subject.on_next(k, v)
  end))
  return subject
end

