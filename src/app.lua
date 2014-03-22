--
-- Created by IntelliJ IDEA.
-- User: linlin.huang
-- Date: 14-3-17
-- Time: 下午6:09
-- To change this template use File | Settings | File Templates.
--
class = require"src/lib/middleclass"
_ = require"src/lib/underscore"
utils = require"src/lib/utils"
sqlite = require'lsqlite3'
local namespace = function(name)
    if type(name) ~= "string" then
        error("name must string object")
    else
        local spaces = Novo._.split(name, "%.")
        local o = _G
        for i = 1, #spaces do
            o[spaces[i]] = o[spaces[i]] or {}
            o = o[spaces[i]]
        end
        return o
    end
end
app = app or {
    _initConfig = function(self)
        self._models = {}
        self.Model = require"src/model"
        self.Collection = require"src/collection"
        local Db = require"src/lib/db"
        self.db = Db:new{
            location = app.Config.db.name
        }
        self.Model.static.db = app.db.db
        self:_loadModels()
    end,
    _loadModels = function(self)
        local paths = utils:getModelPaths()
        self.model = {}
        _.each(paths, function(path)
            local path = string.sub(path, 1, string.find(path, ".lua") - 1)
            self.model[utils:firstUpper(path)] = require("src/model/" .. path)
        end)
    end,
    start = function(self)
        self:_initConfig()
    end,
    unitTest = function(self)
    --        local Player = require"src/model/player"
    --        local Card = require"src/model/card"
    --        --        local Player = self.Model:extend{ table = 'players' }
    --        --
        local player = self.model.Player:new{
            id = 1,
            name = "aaaaaa"
        }


        local card = self.model.Card:new{
            id = 1,
            name = "1111"
        }


--        local list = self.Collection:new{ player, card }
--        list:on("update", function()
--
--        end)
--        list:push(self.model.Card:new{
--
--        })
        print(player:get('id'))
--        list:each(function(model)
--            print(model)
--        end)

    --        --
    --        --                player:set('id', "fdsaf")
    --        --        --
    --        --                player:save()
    --        --
    --        --
    --        --
    --        --            local pls = Player:findAll()
    --        --            if type(pls) == "table" then
    --        --                _.each(pls, function(pl)
    --        --                --            print(pl.id, pl.name)
    --        --                    print(pl:get('id'), pl:get('name'))
    --        --                end)
    --        --            else
    --        --                print(pls)
    --        --            end
    --        --        Player:trigger("update")
    --        --        Card:trigger("update")
    --        for _, model in pairs(self._models) do
    --            model:trigger('update')
    --        end


    --        player:delete(true)
    --        print(player._deleted)

    --                player:on("update", function(evt)
    --                    print(evt.data.name,"player.1    ")
    --                end)
    --
    --                player:trigger("update", { name = 'aaaa' })
    --
    --
    --                local player2 = Player:new{}
    --
    --                player2:on("update", function(evt)
    --                    print(evt.data.name,"player.2  ")
    --                end)
    --
    --                player2:trigger("update", { name = '22222' })
    --        self.Model:trigger("update")
    --        Player:trigger("update")
    end
}
require"src/config"

app:start()
app:unitTest()



