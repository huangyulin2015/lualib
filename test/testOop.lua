--
-- Created by IntelliJ IDEA.
-- User: linlin.huang
-- Date: 14-3-15
-- Time: 下午2:58
-- To change this template use File | Settings | File Templates.
--

local class = require"src/lib/middleclass"



describe("Oops Test", function()
    it("extend", function()
        local A, B

        before_each(function()
            A = class('A')
            A.static.foo = 'foo'

            B = class('B', A)
        end)

        it('are available after being initialized', function()
            assert.are.equal(A.foo, 'foo')
        end)

        it('are available for subclasses', function()
            assert.are.equal(B.foo, 'foo')
        end)

        it('are overridable by subclasses, without affecting the superclasses', function()
            B.static.foo = 'chunky bacon'
            assert.are.equal(B.foo, 'chunky bacon')
            assert.are.equal(A.foo, 'foo')
        end)
    end)
end)


