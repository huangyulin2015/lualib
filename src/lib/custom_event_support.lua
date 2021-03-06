local CustomEventSupport = { static = {} }

CustomEventSupport.static.event_listeners = nil

function CustomEventSupport.static:bind(event_type, event_handler)
  local found, listeners

  if not self.static.event_listeners then
    self.static.event_listeners = {}
  end

  if not self.static.event_listeners[event_type] then
    self.static.event_listeners[event_type] = {}
  end

  found = false

  listeners = self.static.event_listeners[event_type]
  for i, v in ipairs(listeners) do
    if v == event_handler then
      found = true
      break
    end
  end

  if not found then
    table.insert(self.static.event_listeners[event_type], event_handler)
  end

  return self.static

end

function CustomEventSupport.static:unbind(event_type, event_handler)
  local found, listeners, counter

  if not self.static.event_listeners then
    self.static.event_listeners = {}
  end

  if not self.static.event_listeners[event_type] then
    self.static.event_listeners[event_type] = {}
  end

  found = false

  listeners = self.static.event_listeners[event_type]
  for i, v in ipairs(listeners) do
    if v == event_handler then
      found = true
      counter = i
      break
    end
  end

  if found then
    table.remove(self.static.event_listeners[event_type], counter)
  end

  return self.static
end

function CustomEventSupport.static:dispatch(event_type, data)
  local event, listeners, instance, i

  if not self.static.event_listeners then
    self.static.event_listeners = {}
  end

  if not data then
    data = {}
  end

  if not data.target then
    data.target = self
  end

  -- Create new CustomEvent
  event = CustomEvent:new(event_type, data)
  listeners = self.static.event_listeners[event_type] or {}
  instance = self.static

  for i, v in ipairs(listeners) do
    v(instance, event)
    if event.are_immediate_handlers_prevented == true then
      break
    end
  end
end

CustomEventSupport.event_listeners = nil

function CustomEventSupport:bind(event_type, event_handler)
  local found, listeners

  if not self.event_listeners then
    self.event_listeners = {}
  end

  if not self.event_listeners[event_type] then
    self.event_listeners[event_type] = {}
  end

  found = false

  listeners = self.event_listeners[event_type]
  for i, v in ipairs(listeners) do
    if v == event_handler then
      found = true
      break
    end
  end

  if not found then
    table.insert(self.event_listeners[event_type], event_handler)
  end

  return self

end

function CustomEventSupport:unbind(event_type, event_handler)
  local found, listeners, counter

  if not self.event_listeners then
    self.event_listeners = {}
  end

  if not self.event_listeners[event_type] then
    self.event_listeners[event_type] = {}
  end

  found = false

  listeners = self.event_listeners[event_type]
  for i, v in ipairs(listeners) do
    if v == event_handler then
      found = true
      counter = i
      break
    end
  end

  if found then
    table.remove(self.event_listeners[event_type], counter)
  end

  return self
end

function CustomEventSupport:dispatch(event_type, data)
  local event, listeners, instance, i

  if not self.event_listeners then
    self.event_listeners = {}
  end

  if not data then
    data = {}
  end

  if not data.target then
    data.target = self
  end

  -- Create new CustomEvent
  event = CustomEvent:new(event_type, data)
  listeners = self.event_listeners[event_type] or {}
  instance = self

  for i, v in ipairs(listeners) do
    v(instance, event)
    if event.are_immediate_handlers_prevented == true then
      break
    end
  end
end

return CustomEventSupport
