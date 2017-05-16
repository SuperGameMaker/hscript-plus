package cases;

import utest.Assert;
import hscript.plus.ClassUtil;

class ClassUtilTest {
    public function new() {}

    public function testCreate_Constructor() {
        var Player = ClassUtil.createClass({ "name": "" });
        // set new()
        Reflect.setField(Player, "new", (_this, name) -> _this.name = name);

        var name = "Bob";
        var point = ClassUtil.create(Player, [name]);

        Assert.equals(name, point.name);
    }

    public function testCreate_SuperObject_NotNull() {
        var Player = ClassUtil.createClass(TestSprite);
        var player = ClassUtil.create(Player);
        Assert.notNull(player.__super);
    }
    
    public function testCreate_SuperObjectField() {
        var Player = ClassUtil.createClass(TestSprite);
        var player = ClassUtil.create(Player);
        Assert.equals("", player.__super.name);
    }

    public function testCreateClass_Name() {
        var className = "ClassName";
        var Class = ClassUtil.createClass(className);
        Assert.equals(className, Class.className);
    }

    public function testClassExtends_SuperClass() {
        var Controller = {};
        var Keyboard = ClassUtil.createClass(Controller);
        
        Assert.equals(Controller, Keyboard.__super);
    }

    public function testCreateClass_SuperClass_RealClass() {
        var Test = ClassUtil.createClass(ClassUtilTest);
        
        Assert.equals(ClassUtilTest, Test.__super);
    }

    public function testCreateClass_BodyParameter() {
        var Controller = {};
        var Keyboard = ClassUtil.createClass(Controller, { enable:false });
        
        Assert.notNull(Keyboard.enable);
    }

    public function testClassExtends_StaticFieldsRemoved() {
        var Entity:Dynamic = { pop:0, __statics:["pop"] };
        var Enemy:Dynamic = ClassUtil.createClass(Entity);

        Assert.isNull(Enemy.pop);
    }
}

class TestSprite {
    public var name:String;
    public function new() {
        name = "";
    }
}