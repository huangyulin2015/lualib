--
-- Created by IntelliJ IDEA.
-- User: linlin.huang
-- Date: 14-3-22
-- Time: 下午4:07
-- To change this template use File | Settings | File Templates.
--
local Event = require"src/Event"
local View = class('View')
View:include(Event)
function View:initialize(models, options)
    models = models or {}
    options = options or {}
    assert(type(models) == 'table', 'Expected attributes to be a table')
    --    self.models = {}
    --    self:set(models)
end

function View.static:extend(options)
    assert(type(self) == 'table', 'Ensure you are calling model:extend and not model.extend')
    assert(type(options) == 'table', 'Expected an options table')
    assert(options.model:isInstanceOf(app.Model), 'Expected an options.model')
    local klass = class(options.table, self)
    klass.model = options.model
    return klass
end

return View
