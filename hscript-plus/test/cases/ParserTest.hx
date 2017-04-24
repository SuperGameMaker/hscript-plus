package cases;

import utest.Assert;
import hscript.Expr;
import hscript.plus.Parser;

@:access(hscript.plus.Parser.expr)
class ParserTest {
	var parser:Parser;

	public function new() {}

	public function setup() {
		parser = new Parser();
	}

	inline function getAst(script:String) {
		return parser.parseString(script);
	}

	public function testClassName() {
		var script = 'class Box {}';
		var ast = getAst(script);
		
		switch (parser.expr(ast)) {
			case EClass(name, _, _):
				Assert.equals("Box", name);
			default:
				Assert.fail();
		}
	}

	public function testBaseClassName() {
		var script = 'class Box extends Cardboard {}';
		var ast = getAst(script);
		
		switch (parser.expr(ast)) {
			case EClass(_, _, baseClass):
				Assert.equals("Cardboard", baseClass);
			default:
				Assert.fail();
		}
	}

	public function testClassBody() {
		var script = 'class Box {
			var mass:Float = 10;

			function new(this) {}
		}';
		var ast = getAst(script);
		
		switch (parser.expr(ast)) {
			case EClass(_, e, _):
				switch (parser.expr(e)) {
					case EBlock(_): Assert.pass();
					default: Assert.fail();
				}
			default:
				Assert.fail();
		}
	}

	public function testAccessModifiers() {
		var script = 'public static function main() {}';
		var ast = getAst(script);
		
		switch (parser.expr(ast)) {
			case EFunction(_, _, _, _, access):
				Assert.contains(AStatic, access);
			default: Assert.fail();
		}
	}

	public function testPackage() {
		var script = 'package test;';
		var ast = getAst(script);
		
		switch (parser.expr(ast)) {
			case EPackage(path):
				Assert.equals("test", path[0]);
			default: Assert.fail();
		}
	}

	public function testImports() {
		var packages = ["test.TestClass", "physics.Box"];
		var script = '
		import ${packages[0]};
		import ${packages[1]};
		';
		var ast = getAst(script);

		switch (parser.expr(ast)) {
			case EBlock(exprList):
				var index = 0;
				for (e in exprList) {
					switch (parser.expr(e)) {
						case EImport(path):
							Assert.same(packages[index], path.join('.'));
						default: Assert.fail();
					}
					index++;
				}
			default: Assert.fail();
		}
	}

	public function testEmptyPackageName() {
		var script = 'package;';
		var ast = getAst(script);

		switch (parser.expr(ast)) {
			case EPackage(path):
				Assert.equals("", path.join("."));
			default:
				Assert.fail();
		}
	}

	public function testStringInterpolation() {
		var script = //" 'This is $projectName ${lastVersion + 1}' ";
		"var s = 'This is ' + projectName + ' version ' + 'lastVersion + 1'; ";

		var ast = getAst(script);
		Assert.pass();
	}
}