
module('marx', package.seeall)
require 'marx.core'
require 'socket'

Scheduler = marx.Object:new()

function Scheduler.schedule(f)
  assert(nil, "schedule must be overridden")
end

function Scheduler.schedule_at(f, time)
  assert(nil, "schedule_at must be overridden")
end

function Scheduler.schedule_after(f, delay)
  assert(nil, "schedule_after must be overridden")
end

--

CoroutineScheduler = Scheduler:new{tasks={}}

function CoroutineScheduler:create_task(f, t)
  t = t or {}
  t.thread = t.thread or coroutine.wrap(f)
  t.at = t.at or socket.gettime()
  return t
end

function CoroutineScheduler:enqueue_task(t)
  table.insert(self.tasks, t)
  table.sort(self.tasks, function(x,y) 
    return x.at < y.at 
  end)
end

function CoroutineScheduler:schedule(f)
  self:enqueue_task(self:create_task(f))
end

function CoroutineScheduler:schedule_at(f, time)
  self:enqueue_task(self:create_task(f, {at=time}))
end

function CoroutineScheduler:schedule_after(f, sec)
  self:enqueue_task(self:create_task(f, {at=socket.gettime()+sec}))
end

function CoroutineScheduler:step()
  local now = socket.gettime()
  if #self.tasks > 0 then
    if self.tasks[1].at <= now then
      local task = table.remove(self.tasks, 1)
      task.thread(now - task.at, now)
    else
      return(self.tasks[1].at - now)
    end
  else
    return nil, true
  end
end

function CoroutineScheduler:spin()
  while true do
    delta, empty = self:step()
    if delta then socket.sleep(delta) end
    if empty then break end
  end
end

