package cases;

import utest.Assert;
import hscript_plus.ScriptState;

class ScriptStateTest {
    var state:ScriptState;

    public function new() {}

    public function setup() {
        state = new ScriptState();
    }

    public function testClassCreated() {
        var script = '
        class Object {
            public function new(mass) {
                this.mass = mass;
            }
        }

        object = new Object(10);
        ';
        state.executeString(script);
        var object = state.get("object");
        Assert.equals(10, object.mass);
        trace(state.script);
        trace(state.program);
    }

    public function testMainFunctionInClassCalled() {
        var script = '
        class Object {
            public static function main()
                Assert.pass();
        }
        ';
        state.set("Assert", Assert);
        state.executeString(script);
    }

    public function testMainFunctionOutsideClassCalled() {
        var script = '
        public static function main()
            Assert.pass();
        ';
        state.set("Assert", Assert);
        state.executeString(script);
    }
}