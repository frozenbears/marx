
require('marx.push')

numbers = marx.push.range(1, 12)  
othernumbers = marx.push.range(33,50)

concatenated = numbers.concat(othernumbers)

-----------------------------------------------------

concatenated.subscribe(function(value)
  print(value)
end, function()
  print("done")
end)
