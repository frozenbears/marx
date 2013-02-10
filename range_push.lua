
require('marx.push')

numbers = marx.push.range(1, 12)  

evens = numbers.filter(function(value)
  return (value % 2 == 0)
end)

abloobloobloo = evens.map(function(value)
  return value .. "abloobloobloo"
end)

-----------------------------------------------------

numbers.subscribe(function(value)
  print("All numbers: "..value)
end, function()
  print("done!")
end)

evens.subscribe(function(value)
  print("All even numbers: " .. value)
end, function()
  print("done!!!")
end)

abloobloobloo.subscribe(function(value)
  print(value)
end, function()
  print("DONE! <3 <3 <3")
end)
