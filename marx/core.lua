
module('marx', package.seeall)

Object = {}

function Object:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function table.eq(t1, t2)
  for k,v in pairs(t1) do
    if t2[k] ~= v then
      return false
    end
  end

  for k,v in ipairs(t2) do
    if t1[k] ~= v then
      return false
    end
  end

  return true
end
