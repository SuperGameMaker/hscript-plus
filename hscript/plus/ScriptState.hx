package hscript.plus;

import hscript.Expr;
import hscript.plus.Parser;
import hscript.plus.Interp;

using StringTools;

class ScriptState {
	public static var CLASS_NAME = Type.getClassName(ScriptState).split(".")[1];
	
	public var variables(get, null):Map<String, Dynamic>; function get_variables() return _interp.variables;
	public var getFileContent:String->String #if !flash = sys.io.File.getContent #end; 

	public var ast:Expr;

	var _parser:hscript.plus.Parser;
	var _interp:hscript.plus.Interp;

	public function new() {
		_parser = new Parser();
		_parser.allowTypes = true;
		
		_interp = new Interp();
	}
	
	public inline function get(name:String):Dynamic {
		return _interp.variables.get(name);
	}
	
 	public inline function set(name:String, val:Dynamic) {
		_interp.variables.set(name, val);
	}

	public function executeFile(path:String) {
		if (getFileContent == null)
			throw "Provide a getFileContent function first!";
		var script = getFileContent(path);
		execute(script, path);
	}
	
	public inline function executeString(script:String) {
		execute(script);
	}

	function execute(script:String, ?path:String = "") {
		this.ast = parseScript(script);
		return executeProgram(this.ast);
	}
	
	function executeProgram(ast:Expr) {
		_interp.execute(ast);
		var main = get("main");
		if (main != null && Reflect.isFunction(main))
			main();
	}
	
	function parseScript(script:String):Null<Expr> {
		return _parser.parseString(script);
	}
}