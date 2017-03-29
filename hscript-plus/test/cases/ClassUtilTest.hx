package cases;

import utest.Assert;
import hscript.plus.ClassUtil;

class ClassUtilTest {
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
        var point = ClassUtil.create(Point, [x, y]);

        Assert.equals(x, point.x);
        Assert.equals(y, point.y);
    }

    public function testCreate_newCalled() {
        var Point = { x: 0 };
        // set new()
        Reflect.setField(Point, "new", function(_this) {
            Assert.pass();
        });

        ClassUtil.create(Point);
    }

    public function testClassExtends_SuperClass() {
        var Controller = {};
        var Keyboard = ClassUtil.classExtends(Controller);
        
        Assert.equals(Controller, Keyboard.__superClass);
    }

    public function testClassExtends_BodyParameter() {
        var Controller = {};
        var Keyboard = ClassUtil.classExtends(Controller, { enable:false });
        
        Assert.notNull(Keyboard.enable);
    }

    public function testClassExtends_StaticFieldsRemoved() {
        var Entity:Dynamic = { pop:0, __statics:["pop"] };
        var Enemy:Dynamic = ClassUtil.classExtends(Entity);

        Assert.isNull(Enemy.pop);
    }
}