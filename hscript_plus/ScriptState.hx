package hscript_plus;

import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.Assets;

using StringTools;

class ScriptState {
	public static var CLASS_NAME = Type.getClassName(ScriptState).split(".")[1];
	
	var _preprocessor:ScriptPreprocessor;
	var _parser:Parser;
	var _interp:Interp;
	
	// '$packageName.$moduleName$' -> DynamicClass
	var _classes:Map<String, Dynamic>;
	
	public var script:String = "";

	public function new() {
		_preprocessor = new ScriptPreprocessor();
		
		_parser = new Parser();
		
		_interp = new Interp();
		set('${ScriptClassUtil.CLASS_NAME}', ScriptClassUtil);
		_parser.allowTypes = true;
		
		_classes = new Map<String, Dynamic>();
	}
	
	public inline function get(name:String):Dynamic {
		return _interp.variables.get(name);
	}
	
	public inline function set(name:String, ref:Dynamic) {
		_interp.variables.set(name, ref);
	}
	
	public function executeString(script:String) {
		var program = tryParseScript(script);
		tryExecuteProgram(program);
	}
	
	function tryExecuteProgram(program:Expr, path:String = ""):Bool {
		try {
			_interp.execute(program);
			// automatically call main()
			var main = get("main");
			try {
				if (Reflect.isFunction(main))
					main();
				else if (main != null) throw "$CLASS_NAME.tryExecuteProgram(): main is not a function";
			}
			catch (e:Dynamic) {
				if (path != "")
					path += ":";
				var error = '$CLASS_NAME.tryExecuteProgram(): $path Failed to execute main(): ' + 
					e;
				trace(error);
				return false;
			}
		}
		catch (e:Dynamic) {
			var error = '$CLASS_NAME.tryExecuteProgram(): ' +
				#if hscriptPos 'characters ${e.pmin} - ${e.pmax} : ${e.e}'
				#else e #end;
			trace(error);
			return false;
		}
		return true;
	}
	
	function tryParseScript(script:String):Null<Expr> {
		var program:Expr;
		try {
			program = _parser.parseString(script);
		}
		catch (e:Dynamic) {
			var line = _parser.line;
			trace('$CLASS_NAME.tryParseScript(): line $line: ' + #if hscriptPos 'characters ${e.pmin} - ${e.pmax} : ${e.e}' #else e #end);
			return null;
		}
		return program;
	}
	
	public function executeFile(path:String) {
		var
		script = Assets.getText(path),
		program:Expr,
		imports:Array<String>;
		
		script = _preprocessor.process(script);
		
		program = tryParseScript(script);
		imports = _preprocessor.imports;
		
		this.script += script;
		
		if (program == null ||
			!importClasses(imports, path) || // importing class fails
			!tryExecuteProgram(program, path)) // execution fails
				return false;
		
		for (className in _preprocessor.classes) {
			var pathComponents = path.split("/");
			var moduleName = pathComponents[pathComponents.length - 1];
			moduleName = moduleName.substr(0, moduleName.length - 3); // removes the ".hx"
			var packageName = _preprocessor.packageName;
			var value = get(className);
			if (className != moduleName)
				moduleName += '.$className';
			var key = '$packageName.$moduleName';
			_classes.set(key, value);
		}
		
		return true;
	}
	
	function importClasses(imports:Array<String>, path:String) {
		for (typePath in imports) {
			var lastDotIndex = typePath.lastIndexOf(".");
			var className = typePath.substr(lastDotIndex + 1);
			
			var classType:Dynamic = Type.resolveClass(typePath);
			if (classType == null) {
				var pathName = typePath.replace(".", "/");
				executeFile('assets/$pathName.hx');
				classType = _classes.get(typePath);
				if (classType == null) {
					trace('$CLASS_NAME.importClasses(): $path: $className not found');
					return false;
				}
			}
			
			set(className, classType);
		}
		return true;
	}
	
}