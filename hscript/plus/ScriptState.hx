package hscript.plus;

import haxe.CallStack;

import hscript.Expr;
import hscript.plus.Parser;
import hscript.plus.Interp;

using StringTools;

class ScriptState {
	public static var CLASS_NAME = Type.getClassName(ScriptState).split(".")[1];
	
	public var variables(get, null):Map<String, Dynamic>; function get_variables() return _interp.variables;
	public var getFileContent:String->String #if !flash = sys.io.File.getContent #end; 

	public var ast:Expr;

	var _parser:Parser;
	var _interp:Interp;

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
		return execute(script, path);
	}
	
	public inline function executeString(script:String):Dynamic {
		return execute(script);
	}

	function execute(script:String, ?path:String = ""):Dynamic {
		try {
			this.ast = parseScript(script);
		}
		catch (e:Dynamic) {
			#if hscriptPos
			trace('$path:${e.line}: characters ${e.pmin} - ${e.pmax}: $e');
			#else
			trace(e);
			#end
			return {};
		}
		return executeProgram(this.ast);
	}
	
	function executeProgram(ast:Expr) {
		try {
			_interp.execute(ast);
			var main = get("main");
			if (main != null && Reflect.isFunction(main))
				return main();	
		}
		catch (e:Dynamic) {
			trace(e + CallStack.toString(CallStack.exceptionStack()));
		}
		return null;
	}
	
	function parseScript(script:String):Null<Expr> {
		return _parser.parseString(script);
	}
}