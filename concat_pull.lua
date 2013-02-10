
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

x = arrayseq{1,2,3}
y = arrayseq{4,5,6}
z = x.concat(y)
a = arrayseq{444,555,666}
b = z.concat(a)

for value in b.iterator() do
  print(value)
end
