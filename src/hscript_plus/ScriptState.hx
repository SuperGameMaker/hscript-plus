package hscript_plus;

import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

using StringTools;

class ScriptState {
	public static var CLASS_NAME = Type.getClassName(ScriptState).split(".")[1];
	
	var _preprocessor:ScriptCompiler;
	var _parser:Parser;
	var _interp:Interp;
	
	// '$packageName.$moduleName$' -> DynamicClass
	var _classes:Map<String, Dynamic>;
	
	public var script:String = "";
	public var program:#if hscriptPos ExprDef #else Expr #end;

	public function new() {
		_preprocessor = new ScriptCompiler();
		
		_parser = new Parser();
		_parser.allowTypes = true;
		
		_interp = new Interp();
		
		_classes = new Map<String, Dynamic>();

		setClassUtilFunctions();
	}

	function setClassUtilFunctions() {
		var c = ScriptClassUtil;
		set(c.create_FUNC_NAME, c.create);
		set(c.classExtends_FUNC_NAME, c.classExtends);
	}
	
	public inline function get(name:String):Dynamic {
		return _interp.variables.get(name);
	}
	
 	public inline function set(name:String, ref:Dynamic) {
		_interp.variables.set(name, ref);
	}

	public function executeFile(path:String) {
		var script = sys.io.File.getContent(path);
		execute(script, path);
	}
	
	public inline function executeString(script:String) {
		execute(script);
	}

	function execute(script:String, ?path:String = "") {
		var
		program:Expr,
		imports:Array<String>;
		
		script = _preprocessor.process(script);
		
		program = tryParseScript(script);
		imports = _preprocessor.imports;

		this.script += script;
		this.program = program;
		
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
	
	function importClasses(imports:Array<String>, ?path:String) {
		for (typePath in imports) {
			var lastDotIndex = typePath.lastIndexOf(".");
			var className = typePath.substr(lastDotIndex + 1);
			
			var classType:Dynamic = Type.resolveClass(typePath);
			if (classType == null) {
				var pathName = typePath.replace(".", "/");
				executeFile('assets/$pathName.hx');
				classType = _classes.get(typePath);
				if (classType == null) {
					if (path != null)
						path = ' $path:';
					trace('$CLASS_NAME.importClasses():$path $className not found');
					return false;
				}
			}
			
			set(className, classType);
		}
		return true;
	}
	
	function tryExecuteProgram(program:Expr, path:String = ""):Bool {
		try {
			_interp.execute(program);
			// automatically call main()
			var main = get("main");
			try {
				if (Reflect.isFunction(main))
					main();
				else if (main != null) throw 'tryExecuteProgram(): main is not a function';
			}
			catch (e:Dynamic) {
				if (path != "")
					path += ":";
				var error = 'tryExecuteProgram(): $path Failed to execute main(): ' + 
					e;
				trace(error);
				return false;
			}
		}
		catch (e:Dynamic) {
			var error = 'tryExecuteProgram(): ' +
				#if hscriptPos 'characters ${e.pmin} - ${e.pmax} : ${e.e}'
				#else e #end;
			trace(error);
			trace(this.script);
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
			trace('tryParseScript(): line $line: ' + #if hscriptPos 'characters ${e.pmin} - ${e.pmax} : ${e.e}' #else e #end);
			trace(script);
			return null;
		}
		return program;
	}
}