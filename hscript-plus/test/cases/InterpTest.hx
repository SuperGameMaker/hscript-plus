package cases;

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

	public function testNotNull() {
		var script = 'class Object {}';
		var ast = parser.parseString(script);
		interp.execute(ast);
		var object = interp.variables.get("Object");
		Assert.notNull(object);
	}

	public function testVariable() {
		var script = '
		class Object {
			var mass:Float = 10;
		}
		';
		var ast = parser.parseString(script);
		interp.execute(ast);
		var object = interp.variables.get("Object");
		Assert.equals(10, object.mass);
	}

	public function testFunction() {
		var script = '
		class Object {
			public static function main() {
				Assert.pass();
			}
		}
		';
		var ast = parser.parseString(script);
		interp.variables.set("Assert", Assert);
		interp.execute(ast);
		var object = interp.variables.get("Object");
		object.main();
	}
}