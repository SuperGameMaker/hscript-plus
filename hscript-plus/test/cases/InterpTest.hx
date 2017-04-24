package cases;

import hscript.plus.ClassUtil;
import utest.Assert;
import hscript.plus.Interp;
import hscript.plus.Parser;

class InterpTest {
	var parser:Parser;
	var interp:Interp;

	public function new() {}

	public function setup() {
		interp = new Interp();
		parser = new Parser();
	}

	inline function get(name:String) {
		return interp.variables.get(name);
	}

	inline function set(name:String, value:Dynamic) {
		interp.variables.set(name, value);
	}

	inline function execute(ast) {
		return interp.execute(ast);
	}

	inline function getAst(script:String) {
		return parser.parseString(script);
	}

	public function testNotNull() {
		var script = 'class Object {}';
		var ast = getAst(script);
		execute(ast);
		var object = get("Object");
		Assert.notNull(object);
	}

	public function testVariable() {
		var script = '
		class Object {
			var mass:physics.Mass = 10;
		}
		';
		var ast = getAst(script);
		execute(ast);
		var object = get("Object");
		Assert.equals(10, object.mass);
	}

	public function testFunction() {
		var script = '
		public function main()
			pass();
		';
		var ast = getAst(script);
		set("pass", Assert.pass);
		execute(ast);
		var main = get("main");
		main();
	}

	public function testPackage() {
		var script = 'package test;';
		var ast = getAst(script);
		execute(ast);

		Assert.equals("test", interp.packageName);
	}

	public function testImports() {
		var script = '
		import utest.Assert;

		Assert.pass();
		';
		var ast = getAst(script);
		execute(ast);
	}

	public function testNew() {
		var script = '
		class Object {
			public function new()
				Assert.pass();
		}
		';
		var ast = getAst(script);
		set("Assert", Assert);
		var Object = execute(ast);

		script = 'new Object();';
		ast = getAst(script);
		execute(ast);
	}

	public function testThisKeyword() {
		var script = '
		class Object {
			var mass:Float = 0;
			public function new(mass:Float) {
				this.mass = mass;
			}

			public function assert(value) {
				Assert.equals(value, mass);
			}
		}
		';
		var ast = getAst(script);
		set("Assert", Assert);
		execute(ast);

		var Object = get("Object");
		var object = ClassUtil.create(Object, [20]);
		object.assert(20);
	}

	public function testStaticFunctionWithVarDeclare() {
		var script = "
		class Object {
            public static function main() {
                var x = 10;
            }
    	}
		";
		var ast = getAst(script);
		execute(ast);
		var main = get("main");
		main();
		Assert.pass();
	}

	public function testVariableDeclaredWithoutValue() {
		var script = "
		class Test {
			var sprite;
    	}
		";
		var ast = getAst(script);
		execute(ast);
		Assert.pass();
	}

	public function testWithoutThis() {
		var script = '
		class WithoutThis {
			var x:Int;
			public function new() {
				x = 0;
			}
		}
		';
		var ast = getAst(script);
		execute(ast);
		var WithoutThis = get("WithoutThis");
		var testObject = ClassUtil.create(WithoutThis);
		Assert.equals(0, testObject.x);
	}

	public function testSetGlobalField() {
		var script = '
		class SetGlobalField {
			public function new() {
				trace(this);
				pass = true;
			}
		}
		';
		var ast = getAst(script);
		execute(ast);
		var SetGlobalField = get("SetGlobalField");
		var testObject = ClassUtil.create(SetGlobalField);
		Assert.isTrue(testObject.pass);
	}

}