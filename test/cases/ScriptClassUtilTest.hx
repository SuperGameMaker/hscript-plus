package cases;

import utest.Assert;
import hscript_plus.ScriptClassUtil;

class ScriptClassUtilTest {
    public function new() {}

    public function testCreate() {
        var Point = { x:0, y:0 };
        // set new()
        Reflect.setField(Point, "new", function(_this, x, y) {
            _this.x = x;
            _this.y = y;
        });

        var x = 10;
        var y = 10;
        var point = ScriptClassUtil.create(Point, [x, y]);

        Assert.equals(x, point.x);
        Assert.equals(y, point.y);
    }

    public function testCreate_newCalled() {
        var Point = { x: 0 };
        // set new()
        Reflect.setField(Point, "new", function(_this) {
            Assert.pass();
        });

        ScriptClassUtil.create(Point);
    }

    public function testClassExtends_SuperClass() {
        var Controller = {};
        var Keyboard = ScriptClassUtil.classExtends(Controller);
        
        Assert.equals(Controller, Keyboard.__superClass);
    }

     public function testClassExtends_BodyParameter() {
        var Controller = {};
        var Keyboard = ScriptClassUtil.classExtends(Controller, { enable:false });
        
        Assert.isFalse(Keyboard.enable);
    }
}