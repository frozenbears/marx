
require 'lunit'
require 'marx.pull'

module('marx.pull_tests', package.seeall, lunit.testcase)

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

-- (pull iteration is destructive to the sequence)
-- todo: setup function?
function numbers()
  return marx.pull.range(1,4)
end

--compare a pull sequence with an expected result value
function compare(seq, v)
 
  -- if we exect a table, buid one by inserting elements of the sequence
  -- as they are puled
  if type(v) == 'table' then
      local results = {}

      for item in seq.iterator() do
        table.insert(results, item)
      end

      return equiv(results, v)
  else
      local result = nil
   
      -- otherwise just pul the first value and return an equality comparison
      return v == seq.next() 
  end
end

---------------------------

function test_pull_range()
  assert_true(compare(numbers(), {1,2,3,4}))
end

function test_pull_sequence_map()
  assert_true(compare(numbers().map(function(value)
    return value * 3
  end), {3,6,9,12}))  
end

function test_pull_sequence_filter()
  assert_true(compare(numbers().filter(function(value)
    return value % 2 == 0
  end), {2,4}))
end

function test_pull_sequence_fold()
  assert_true(compare(numbers().fold(0, function(accum, value)
    return accum + value
  end), 10))
end

function test_pull_sequence_concat()
  local seq = marx.pull.range(5,6)
  assert_true(compare(numbers().concat(seq), {1,2,3,4,5,6}))
end
