package cases;

import hscript.plus.ClassUtil;
import hscript.plus.Interp;
import hscript.plus.Parser;
import utest.Assert;

class RealClassStructureTest {
	var parser:Parser;
	var interp:Interp;
	
	var Player:Dynamic;
	var player:Dynamic;

	public function new() {
		Player = ClassUtil.createClass(Sprite);
	}

	inline function getAst(script:String) {
		return parser.parseString(script);
	}

	inline function execute(ast) {
		return interp.execute(ast);
	}

	inline function executeScript(script:String) {
		return execute(getAst(script));
	}

	inline function set(name:String, value:Dynamic) {
		interp.variables.set(name, value);
	}

	public function setup() {
		interp = new Interp();
		parser = new Parser();
		player = ClassUtil.create(Player);
		set("player", player);
	}

	public function testExpr() {
		Assert.equals(100, executeScript("player.__super.health"));
	}

	public function testAssignment() {
		executeScript('player.health = 50');
		Assert.equals(50, player.__super.health);
	}

	public function testIncrement() {
		executeScript('player.health++');
		Assert.equals(101, player.__super.health);
	}

	public function testDecrement() {
		var script = 'player.health--';
		var ast = getAst(script);
		execute(ast);

		Assert.equals(99, player.__super.health);
	}

	public function testPlusEqual() {
		var script = 'player.health += 50';
		var ast = getAst(script);
		execute(ast);

		Assert.equals(150, player.__super.health);
	}
}

class Sprite {
	public var health:Int;
	public function new() {
		health = 100;
	}
}