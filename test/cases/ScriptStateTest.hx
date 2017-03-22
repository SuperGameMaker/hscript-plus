package cases;

import utest.Assert;
import hscript_plus.ScriptState;

class ScriptStateTest {
    var state:ScriptState;

    public function new() {}

    public function setup() {
        state = new ScriptState();
    }

    public function testReadmeUsageExample() {
        var script = "
        class Object {
            // main() is called automatically when script is executed
            public static function main() {
                var object = new Object(10, 10);
                object.name = NAME;
                Assert.equals('Ball', object.name);
                Assert.equals(10, object.x);
                Assert.equals(10, object.y);
            }
            
            public var x:Float = 0;
            public var y:Float = 0;

            public function new(x:Float, y:Float) {
                this.x = x;
                this.y = y;
            }
        }
        ";
        state.set("Assert", Assert);
        state.set("NAME", "Ball"); // set a global variable
        state.executeString(script); // executes a String

        // get a global variable
        var Object = state.get("Object"); // get a global variable
        Object.main();
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