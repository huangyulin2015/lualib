--
-- Created by IntelliJ IDEA.
-- User: linlin.huang
-- Date: 14-3-18
-- Time: 上午11:43
-- To change this template use File | Settings | File Templates.
--

class = require"src/lib/middleclass"
_ = require"src/lib/underscore"


local Model, Db
Model = require"src/model"
Db = require"src/lib/db"
local Qub = require"src/lib/LuaQuB"
Model.static.db = Db:new{
    location = "memory"
}.db
Model.static.qb = Qub:new()


function Model:say()
    print('model sqy')
end

Player = Model:extend{ table = 'players' }

local player = Player:new{
    id = 1,
    name = "hhh"
}

player:save()

local pls = Player:find()
_.each(pls, function(pl)
    print(pl.id, pl.name)
end)




