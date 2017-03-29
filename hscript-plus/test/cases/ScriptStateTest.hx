package cases;

import utest.Assert;
import hscript.plus.ScriptState;

class ScriptStateTest {
    var state:ScriptState;

    public function new() {}

    public function setup() {
        state = new ScriptState();
    }

    public function testReadmeUsageExample() {
        var script = "
        class Object {
            public static function main() {
                var object = new Object(10, 10);
                object.name = NAME;
                Assert.equals('Ball', object.name);
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
            public static function main() {
                object = new Object(10);
                Assert.equals(10, object.mass);
            }

            public var mass:Float = 0;

            public function new(mass)
                this.mass = mass;
        }        
        ';
        state.set("Assert", Assert);
        state.executeString(script);
    }

    public function testFunction() {
		var script = '
		class Object {
			public static function main()
				Assert.pass();
		}
		';
		state.set("Assert", Assert);
		state.executeString(script);
	}

    public function testExecuteFile_Import() {
        state.executeFile("hscript-plus/test/scripts/ExecuteFile_Import.hx");
    }
}