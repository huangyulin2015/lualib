local CustomEvent = class('CustomEvent')

function CustomEvent:initialize(event_type, data)
  -- defaults
  self.bubbles = true
  self.cancelable = true
  self.current_target = nil
  self.timestamp = 0
  self.target = nil
  self.type = ''
  self.is_propagation_stopped = false
  self.is_default_prevented = false
  self.is_immediate_propagation_stopped = false
  self.are_immediate_handlers_prevented = false

  -- init
  self.type = event_type
  for k, v in pairs(data) do
    self[k] = v
  end
end

function CustomEvent:stop_propagation()
  self.is_propagation_stopped = true
end

function CustomEvent:prevent_default()
  self.is_default_prevented = true
end

function CustomEvent:stop_immediate_propagation()
  self.is_immediate_propagation_stopped = true
end

function CustomEvent:prevent_immediate_handlers()
  self.are_immediate_handlers_prevented = true
end

return CustomEvent;
