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
        class TestObject {
            public static function main() {
                var object = new TestObject(10, 10);
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
        var TestObject = state.get("TestObject"); // get a global variable
        TestObject.main();
    }

    public function testClassCreated() {
        var script = '
        class ClassCreated {
            public static function main() {
                return new ClassCreated(10);
            }

            public var mass:Float = 0;

            public function new(mass)
                this.mass = mass;
        }        
        ';
        var testObject = 
        state.executeString(script);
        Assert.equals(10, testObject.mass);
    }

    public function testExecuteFile_Import() {
        state.executeFile("hscript-plus/test/scripts/ExecuteFile_Import.hx");
    }

    public function testMainFunctionAutoCalled() {
        var script = "
        import utest.Assert;

        class MainFunctionAutoCalled {
            public static function main() {
                Assert.pass();
            }
        }
        ";
        state.executeString(script);
    }

    public function parserErrorHandling() {
        var script = "class {}";
        state.executeString(script);
        Assert.pass();
    }
}   