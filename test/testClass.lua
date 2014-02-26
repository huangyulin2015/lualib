require("Class")

local Object = Class:create({
    init = function(self)
        print('init object')
    end,
    say = function()
        print('say Object')
    end
})

--local SubObj = Object:create({
--    init = function(self)
--        print("init SubObj")
--    end
--})
--
--local obj1 = Object:new()
--
--local obj2 = SubObj:new()
--
--obj1.say()
--obj2.say()
for _, v in pairs(Object) do
    print(_, v)
end
