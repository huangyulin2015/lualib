local _class = {}

Class = {}

function Class:create(sub)
    local class_type = sub or {}
    class_type.super = self
    class_type.new = function(...)
        local obj = {}
        do
            local _create = function(c, ...)
                if c.super then
                    _create(c.super, ...)
                end
                if c.init then
                    c.init(obj, ...)
                end
            end
            _create(class_type, ...)
        end
        setmetatable(obj, { __index = _class[class_type] })
        return obj
    end
    local vtbl = {}
    _class[class_type] = vtbl
    setmetatable(class_type, {
        __newindex =
        function(t, k, v)
            vtbl[k] = v
        end
    })
    setmetatable(vtbl, {
        __index =
        function(t, k)
            local ret = _class[self][k]
            vtbl[k] = ret
            return ret
        end
    })
    return class_type
end