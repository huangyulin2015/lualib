
local Db = class('Db')

function Db:initialize(options)
    options = options or {}
    assert(type(self) == 'table', 'called .new instead of :new')
    assert(type(options) == 'table', 'Expected options to be a table')

    if options.location == 'memory' then
        -- for testing purposes
        self.db = sqlite.open_memory()
    else
        options.name = options.name or 'db'
        options.location = options.location or system.DocumentsDirectory

        local path = system.pathForFile(options.name .. '.sqlite', options.location)
        self.db = sqlite.open(path)
    end

    if options.migration then
        assert(type(options.migration) == 'function', 'Expected migration to be a function')
        self:migrate(options.migration)
    end
    --	Db.Model.static.db = self.db
end


function Db:schemaVersion()
    local stmt = self.db:prepare'PRAGMA user_version'
    assert(stmt, 'Failed to prepare statement')

    local step = stmt:step()
    assert(step == sqlite.ROW, 'Error while getting version')

    local version = stmt:get_value(0)
    assert(version, 'Failed to get version')

    stmt:finalize()
    return version
end

function Db:exec(sql, args)
    local ret
    if not args then
        ret = self.db:exec(sql)
        assert(ret == sqlite.OK, '[SQL] Failed(' .. ret .. '): ' .. sql)
    else
        local stmt = self.db:prepare(sql)
        assert(type(args) == 'table', 'expected parameter args to be a table')

        stmt:bind_names(args)
        ret = stmt:step()
        assert(ret == sqlite.DONE, '[SQL] failed to execute sql ' .. ret)
    end
end

function Db:migrate(fn)
    assert(type(self) == 'table', 'Called .migrate instead of :migrate')
    assert(type(fn) == 'function', 'Expected arg to be a function')

    local function exec(sql, args)
        self:exec(sql, args)
    end

    local currentVersion = self:schemaVersion()
    local migratedVersion = fn(currentVersion, exec)

    if not migratedVersion then
        migratedVersion = currentVersion
    end
    assert(type(migratedVersion) == 'number', 'Expected migratedVersion to return the migrated version number')
    assert(migratedVersion >= currentVersion, 'The migration function return value cant be lower than the current version')
    self:exec('PRAGMA user_version=' .. migratedVersion)

    return migratedVersion
end

function Db:find(sql)
    assert(type(sql) == 'string', 'Expected arg to be a string')
    local result = {}
    for row in self.db:nrows(sql) do
        result[#result + 1] = row
    end
    return result
end

return Db
