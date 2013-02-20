
require 'lunit'
require 'marx.push'

module('marx.tests', package.seeall, lunit.testcase)

-- table equality by value (useful below)
function equiv(t1, t2)
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

numbers = marx.push.range(1,4)


--compare a push sequence with an expected result value
function compare(seq, v)
 
  -- if we exect a table, buid one by inserting elements of the sequence
  -- as they arrive
  if type(v) == 'table' then
      local results = {}

      -- overload equality operator with comparison by value
      setmetatable(results, {__eq = equiv})
      setmetatable(v, {__eq = equiv})

      seq.subscribe(function(value)
        table.insert(results, value)
      end)
  
      assert_equal(results, v)
  else
      local result = nil
   
      -- otherwise just store the value
      seq.subscribe(function(value)
        result = value
      end)
      
      assert_equal(result, v)
  end
end

---------------------------

function test_push_observer()
  local on_next = function(value)
  end
  local on_complete = function(value)
  end
  local on_error = function(e)
  end

  local observer = marx.push.observer(on_next, on_complete, on_error)

  assert_equal(observer.on_next, on_next)
  assert_equal(observer.on_complete, on_complete)
  assert_equal(observer.on_error, on_error)
  
  -- only the first argument is strictly necessary, the others default
  -- to no-op functions
  local light_observer = marx.push.observer(on_next)

  assert_equal(light_observer.on_next, on_next)
  assert_equal(type(light_observer.on_next), 'function')
  assert_equal(type(light_observer.on_error), 'function')
end

function test_push_sequence_subscribe_observer()
  local v = 0
  local done = false

  local obs = marx.push.observer(function(value)
    v = 1
  end, function()
    done = true 
  end)  

  local seq = marx.push.sequence(function(observer)
     observer.on_next(v)
     observer.on_complete()
  end)

  seq.subscribe_observer(obs)

  assert_equal(v, 1)
  assert_true(done)
end


function test_push_sequence_subscribe()
  local v = 0
  local done = false

  local seq = marx.push.sequence(function(observer)
     observer.on_next(v)
     observer.on_complete()
  end)

  seq.subscribe(function(value)
    v = 1
  end, function()
    done = true
  end)

  assert_equal(v, 1)
  assert_true(done)
end

function test_push_range()
  compare(numbers, {1,2,3,4})
end

function test_push_sequence_map()
  compare(numbers.map(function(value)
    return value * 3
  end), {3,6,9,12})
end

function test_push_sequence_filter()
  compare(numbers.filter(function(value)
    return value % 2 == 0
  end), {2,4})
end

function test_push_sequence_fold()
  compare(numbers.fold(0, function(accum, value)
    return accum + value
  end), 10)
end

function test_push_sequence_concat()
  local seq = marx.push.range(5,6)
  compare(numbers.concat(seq), {1,2,3,4,5,6})
end
