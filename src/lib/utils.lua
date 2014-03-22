--
-- Created by IntelliJ IDEA.
-- User: linlin.huang
-- Date: 14-3-21
-- Time: 下午12:41
-- To change this template use File | Settings | File Templates.
--
local file = require"src/lib/file"
local Utils = {
    getModelPaths = function()
        local paths = {}
        if CCFileUtils then
            local path = string.sub(CCFileUtils:sharedFileUtils():fullPathForFilename("main.lua"), 1, string.find(CCFileUtils:sharedFileUtils():fullPathForFilename("main.lua"), "main.lua") - 1)
            os.execute("ls '" .. path .. "scripts/common' > '" .. LeverLuaSQLite:getBasePath() .. "paths.txt'")
            for lien in io.lines(LeverLuaSQLite:getBasePath() .. "paths.txt") do
                _.push(paths, line)
            end
        else
            for line in io.popen('ls src/model'):lines() do
                _.push(paths, line)
            end
        end
        return paths
    end,
    firstUpper = function(self,s)
        return string.upper(string.sub(s, 1, 1)) .. string.sub(s, 2)
    end
}


return Utils