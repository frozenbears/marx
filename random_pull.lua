
require 'marx.pull'

-- bootstrap the psuedorandom number generator
math.randomseed(os.time())
for i=1,5 do
  math.random()
end

----------------------------------------------

randoms = marx.pull.sequence(function()
  return math.random()
end)

coinflip = randoms.map(function(value)
  return value > 0.5
end)

percentages = randoms.map(function(value)
  return value * 100
end)

ninetieth_percentile = percentages.filter(function(value)
  return value >= 90
end)

---------------------------------------------------------

function dorange(seq, min, max)
  for i = min, max do
    print(seq.next())
  end
end

print("\nrandom numbers between 0 and 1\n")
dorange(randoms, 1, 5)

print("\ncoin flips\n")
dorange(coinflip, 1, 5)

print("\npercentages\n")
dorange(percentages, 1, 5)

print("\nninetieth percentile\n")
dorange(ninetieth_percentile, 1, 5)



