package cases;

import utest.Assert;
import hscript_plus.ScriptPreprocessor;

using StringTools;

class ScriptPreprocessorTest {
    public static var NEWLINE = ScriptPreprocessor.NEWLINE;

    var processor:ScriptPreprocessor;

    var script:String;
    var expected:String;
    var value:String;

    public function new() {}

    public function setup() {
        processor = new ScriptPreprocessor();
        script = "";
        expected = "";
        value = "";
    }

    function processScript(script:String, ?line:Int = -1):String {
        var processed = processor.process(script);
        if (line >= 0)
            processed = processed.split(NEWLINE)[line].trim();
        return processed;
    }

    public function testPackageRegex() {
        script = "package basic;";
        expected = "";
        value = processScript(script, 0);

        Assert.equals(expected, value);
        Assert.equals("basic", processor.packageName);
    }

    public function testImportRegex() {
        var imports = ["math.Vector2", "event.EventManager"];
        script = '
        import ${imports[0]};
        import ${imports[1]};
        ';
        processScript(script);

        Assert.same(imports, processor.imports);
    }

    public function testClassRegex() {
        script = "class Object {}";
        expected = "Object = {}; {}";
        value = processScript(script);

        Assert.same(expected, value);
    }

    public function testSuperRegex_Constructor() {
        script = "
        class Object {
            public function new() {
                super();
            }
        }
        ";
        expected = "
        Object = {}; {
            Object.new = function(this) {
                Object.__superClass.new(this);
            }
        }
        ";
        value = processScript(script);

        Assert.equals(expected, value);
    }

    public function testSuperRegex_Method() {
        script ="
        class Object {
            public function moveTo(x:Float, y:Float) {
                super.moveTo(x, y);
            }
        }
        ";
        expected = "
        Object = {}; {
            Object.moveTo = function(this, x:Float, y:Float) {
                Object.__superClass.moveTo(this, x, y);
            }
        }
        ";
        var value = processScript(script);

        Assert.equals(expected, value);
    }

    public function testConstructorCallRegex() {
        script = "var object = new Object(x, y);";
        expected = "var object = create(Object, [x, y]);";
        value = processScript(script);

        Assert.equals(expected, value);
    }

    public function testFunctionRegex_NoParameters() {
        script = "
        class Object {
            public function stop() {}
        }
        ";
        expected = "Object.stop = function(this) {}";
        value = processScript(script, 2);

        Assert.equals(expected, value);
    }

    public function testFunctionRegex_YesParameters() {
        script = "
        class Object {
            public function stop(x:Float, y:Float) {}
        }
        ";
        expected = "Object.stop = function(this, x:Float, y:Float) {}";
        value = processScript(script, 2);

        Assert.equals(expected, value);
    }
    
    public function testFunctionRegex_ClassStaticFunction() {
        script = "
        class Object {
            public static function main() {}
        }
        ";
        expected = "Object.main = function main() {}";
        value = processScript(script, 2);

        Assert.equals(expected, value);
    }

    public function testVarRegex_ClassMember() {
        var script = "
        class Object {
            public var mass:Float = 10;
        }
        ";
        var expected = "Object.mass = 10;";
        var value = processScript(script, 2);

        Assert.equals(expected, value);
    }

    public function testVarRegex_NonClassMember() {
        var script = "
        class Object {
            public static function main() {
                var name = 'Rock';
            }
        }
        ";
        var expected = "var name = 'Rock';";
        var value = processScript(script, 3);

        Assert.equals(expected, value);
    }

    // FAILING
    public function testFunctionRegex_FuncLocalVar_NoBrackets() {
        var script = "
        class Object {
            public static function main()
                createObject();
        }
        ";
        var expected = "createObject();";
        var value = processScript(script, 3);

        Assert.equals(expected, value);
    }

    public function testBracketRegex() {
        // maybe put this in the ScopeManagerTest
        Assert.isTrue(true);
    }
    
    public function disabledTestEverything() {
        var packageName = "basic";
        var imports = ["math.Vector2"];
        var script = '
        package $packageName;

        import ${imports[0]};

        class Object extends Basic {
            public var pos:Vector2;
            public var vel:Vector2 = new Vector2();

            public function new(x:Float = 0, y:Float = 0) {
                super();
                pos = new Vector2(x, y);
            }

            public function update(delta:Float) {
                this.pos.add(this.vel.scale(delta));
            }
        }
        ';
        var expected = "
        

        

        Object = classExtends(Basic); {
            public var pos:Vector2;
            public var vel:Vector2 = new Vector2();

            Object.new = function(this, x:Float, y:Float) {
                Object.__superClass.new(this);
                pos = new Vector2(x, y);
            }

            Object.update = function(this, delta:Float) {
                Object.__superClass.update(this, delta);
                this.pos.add(this.vel.scale(delta));
            }
        }
        ";
        var value = processScript(script);

        Assert.equals(expected, value);
        Assert.equals(packageName, processor.packageName);
        Assert.same(imports, processor.imports);
    }  
}