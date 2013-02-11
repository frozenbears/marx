
require 'marx.pull'

-- note: this is not an ideal implementation
-- of an array sequence but it will serve for the time being

function arrayseq(tab)
  local pos = 1
  local seq = marx.pull.sequence(function()
    local res = tab[pos]
    if pos <= #tab then
      pos = pos + 1
    else
      return nil
    end
    return res
  end)
  return seq
end

x = arrayseq{"john", "mary", "steve", "caitlin", "boris", "randi", "ferris", "amanda"}

y = x.fold("Announcing:", function(accum, value)
  return accum .. " " .. "the fabulous " .. value 
end)

print(y.next())
