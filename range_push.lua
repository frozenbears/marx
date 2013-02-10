
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
   if value then
     print("All numbers: "..value)
   else
     print("done!")
   end
end)

evens.subscribe(function(value)
  if value then
    print("All even numbers: " .. value)
  else
    print("done!!")
  end
end)

abloobloobloo.subscribe(function(value)
  if value then
    print(value)
  else
    print("done!!!")
  end
end)
