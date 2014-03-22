--
-- Created by IntelliJ IDEA.
-- User: linlin.huang
-- Date: 14-3-22
-- Time: 上午11:28
-- To change this template use File | Settings | File Templates.
--
local Event = require"src/Event"
local Collection = class('Collection')
Collection:include(Event)
function Collection:initialize(models, options)
    models = models or {}
    options = options or {}
    assert(type(models) == 'table', 'Expected attributes to be a table')
    self.models = {}
    self:set(models)
end

function Collection:push(model)
    assert(model:isInstanceOf(app.Model), "model not instance collections.model")
    _.push(self.models, model)
    self:trigger("add", model)
    self:trigger("update")
end

function Collection:pop()
    local model = _.pop(self.models)
    self:trigger("pop", model)
    self:trigger("update")
    return model
end

function Collection:get(index)
    return _.get(index)
end

function Collection:shift()
    local model = _.shift(self.models)
    self:trigger("shift", model)
    self:trigger("update")

    return model
end

function Collection:unshift(models)
    assert(model:isInstanceOf(app.Model), "model not instance collections.model")
    _.unshift(self.models, model)
    self:trigger("add", model)
    self:trigger("update")
end

function Collection:sort(func)
    if func then
        _.sort(self.models, func)
    else
        _.sort(self.models)
    end
end

function Collection:remove(model)
    local model = _.remove(self.models, model)
    self:trigger("remove", model)
    self:trigger("update")
    return model
end

--function Collection:parse()
--    error("must impl")
--end

function Collection:each(func)
    assert(type(func) == "function", "func must a function")
    _.each(self.models, func)
end

function Collection:set(models)
    assert(_.isArray(models), "models not array")
    _.each(models, function(model)
        assert(model:isInstanceOf(app.Model), "model not instance collections.model")
        _.push(self.models, model)
    end)
end

function Collection.static:extend(options)
    assert(type(self) == 'table', 'Ensure you are calling model:extend and not model.extend')
    assert(type(options) == 'table', 'Expected an options table')
    assert(options.model:isInstanceOf(app.Model), 'Expected an options.model')
    local klass = class(options.table, self)
    klass.model = options.model
    return klass
end


return Collection