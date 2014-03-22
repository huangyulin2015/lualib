--
-- Created by IntelliJ IDEA.
-- User: linlin.huang
-- Date: 14-3-17
-- Time: 下午6:09
-- To change this template use File | Settings | File Templates.
--

local Event = require"src/Event"
local Model = class('Model')
Model:include(Event)

local Qub = require"src/lib/LuaQuB"

function Model:initialize(attributes, options)
    assert(type(self) == 'table', 'Called .new instead of :new')
    attributes = attributes or {}
    options = options or {}
    assert(type(attributes) == 'table', 'Expected attributes to be a table')

    self.changed = {}
    self.attributes = {}
    self._previousAttributes = {}
    for k, v in pairs(attributes) do
        if string.lower(k) == string.lower(self.class.idAttribute) then
            self.id = v
        elseif string.lower(k) == 'id' then
            self.id = v
        end
        self.attributes[k] = attributes[k]
    end

    --    if self.class.defaults then
    --        for k, v in pairs(self.class.defaults or {}) do
    --            if self.attributes[k] == nil then
    --                self.attributes[k] = self.class.defaults[k]
    --            end
    --        end
    --    end
    --
    --    if options.synced then
    for k, v in pairs(self.attributes) do
        self._previousAttributes[k] = v
    end
    if not self.class.static._subClasses then
        self.class.static._subClasses = {}
    end
    _.push(self.class.static._subClasses, self)
    self.class.static:on("update", function(evt)
        local object = evt.target
        _.each(object._subClasses, function(subClass)
            subClass:trigger("update")
        end)
    end)
    --    self:on("update", function()
    --        print('update....',self)
    --    end)
    --    end
end


function Model:save()
    assert(self.class.db, 'The database is closed')
    assert(self.class.db:isopen(), 'The database is closed')
    if not self.class._tableCreated then
        self:_createTable()
    end
    if self._created then
        self:_update()
    else
        self:_create()
    end
end

function Model:delete(forDatabase)
    if forDatabase then
        assert(self.class.db, 'The database is closed')
        assert(self.class.db:isopen(), 'The database is closed')
        self:_execSql(tostring(self.class.qb:delete():from(self.class.tableName):where({
            [(self.class.idAttribute)] = self.id
        })))
    end
    _.remove(self.class.static._subClasses, self)
    self._deleted = true
end


function Model:_execSql(sqlObject)
    self.class.db:exec(tostring(sqlObject))
end

function Model:get(attribute)
    assert(type(self) == 'table', 'Called .get instead of :get')
    return self.attributes[attribute]
end

function Model:set(key, val)
    assert(type(self) == 'table', 'Called .set instead of :set')

    local attrs, prev, current
    local changes = {}

    if key == nil then
        return self
    end

    if type(key) == 'table' then
        attrs = key
    else
        attrs = {}
        attrs[key] = val
    end

    current = self.attributes
    local flag = false
    for key, val in pairs(attrs) do
        if current[key] ~= val then
            flag = true
            changes[key] = true
            self.changed[key] = true
        end
        current[key] = val
    end
    if flag then
        self:trigger("set") --- 派发更新事件
    end
    return self
end

function Model:_create()
    if type(self.attributes) == "table" then
        self:_execSql(tostring(self.class.qb:insert(self.class.tableName, self.attributes)))
        self._created = true
    end
end

function Model:_createTable()
    if type(self.attributes) == "table" then
        self:_execSql(tostring(self.class.qb:create(self.class.tableName, self.attributes)))
        self.class._tableCreated = true
    end
end

function Model:_update()
    assert(self.id, 'Tried to run update on not inserted model')

    local sql = 'UPDATE %s SET %s WHERE %s=:modelId'

    local values = { modelId = self.id }
    local changes = {}

    for k, v in pairs(self.changed or {}) do
        --        if self.class.attrs[k] then
        table.insert(changes, k .. '=:' .. k)
        values[k] = self.attributes[k]
        --        end
    end

    if #changes == 0 then
        return true
    end

    sql = sql:format(self.class.tableName,
        table.concat(changes, ', '),
        self.class.idAttribute)

    local stmt = self.class.db:prepare(sql)
    assert(stmt, 'Failed to prepare update-model statement')
    assert(stmt:bind_names(values) == sqlite.OK, 'Failed to bind values')
    local step = stmt:step()
    stmt:finalize()
    stmt = nil

    if step == sqlite.DONE then
        local _previousValues = {}
        for k, v in pairs(values) do
            if k ~= modelId then
                _previousValues[k] = self._previousAttributes[k]
                self._previousAttributes[k] = v
            end
        end

        --        self:trigger('updated', {
        --            changes = self.changed,
        --            previousValues = _previousValues,
        --            values = values
        --        })
        --        self:trigger('saved', self)


        self.changed = {}
        return true
    else
        return nil, self.class.db:errmsg()
    end
end

function Model.static:findAll()
    local sql = tostring(self.qb:select("*"):from(self.tableName))
    --    local result = {}
    --    for row in self.db:nrows(tostring(sqlObject)) do
    --        result[#result + 1] = row
    --    end
    local list = {}
    for row in self.db:nrows(sql) do
        list[#list + 1] = self:new(row)
    end
    return list
end

function Model.static:findById(id)
    assert(id, "id not nil")
    local sqlObject = self.qb:select("*"):from(self.tableName):where(self.idAttribute .. ' = ', id)


    local stmt = self.db:prepare(tostring(sqlObject))
    assert(stmt, 'Failed to prepare select-id statement')


    local step = stmt:step()

    if step == sqlite.ROW then
        local attributes = stmt:get_named_values()
        return self:new(attributes)
    elseif step == sqlite.DONE then
        stmt:finalize()
        stmt = nil
        --        if options and options.required then
        error('The model was not found')
        --        end
        --        return nil
    end
end

function Model.static:extend(options)
    assert(type(self) == 'table', 'Ensure you are calling model:extend and not model.extend')
    assert(type(options) == 'table', 'Expected an options table')

    assert(options.table, 'model:extend should specify a table')

    --    if not options.attrs then
    --        if self.db then
    --            options.attrs = {}
    --            for row in self.db:nrows('PRAGMA table_info(' .. options.table .. ')') do
    --                options.attrs[row.name] = row.type
    --            end
    --        else
    --            options.attrs = {}
    --        end
    --    end

    -- TODO classify tableName
    local klass = class(options.table, self)
    klass.tableName = options.table
    klass.idAttribute = options.idAttribute or 'id'
    klass.attrs = options.attrs
    app._models[options.table] = klass
    return klass
end

Model.static.qb = Qub:new()



return Model