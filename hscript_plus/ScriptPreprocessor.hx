package hscript_plus;

import hscript_plus.ScopeManager;
import hscript_plus.ScriptClassUtil;

typedef ScriptClass = {
	name:String,
	members:Array<String>,
	statics:Array<String>
}

class ScriptPreprocessor {
	public static inline var NEWLINE = #if windows "\r\n" #else "\n" #end;
	
	/**
	 * I recommend this website to write regular expressions
	 * http://regexr.com/
	 */
	public static var packageRegex:EReg = ~/package\s?([^;]+)?;/g;
	public static var importRegex:EReg = ~/import\s+([^;]+);/g;
	public static var classRegex:EReg = ~/class\s+(\w+)(?:\s+extends\s+(\w+))?\s*({?)/g;
	public static var superRegex:EReg = ~/super(?:\.(\w+))?\((.*)\);/g;
	public static var newObjectRegex:EReg = ~/new\s+(\w+)\s*\((.*)\)/g;
	public static var functionRegex:EReg = ~/(?:(override)\s+)?(?:(public|private)\s+)?(?:(static)\s+)?(?:(inline)\s+)?function\s+(\w+)\((.*)\)\s*(\{+)?/g;
	public static var varRegex:EReg = ~/(?:(public|private)?\s+)?(?:(static)\s+)?(?:(inline)\s+)?var\s+(\w+)\s*(?::\s*(?:\w+)\s*)?(\s*=\s*[^\s].*)?/g;
	public static var bracketRegex:EReg = ~/({|})/g;
	
	public var imports:Array<String>;
	public var packageName:String;
	public var classes:Array<String> = [];
	
	var className:String;

	var lines:Array<String>;
	var line:String;
	var index:Int;
	
	var scope:ScopeManager = new ScopeManager();
	var scopeName:String;
	var scopeType:ScopeType;
	
	public function new() {}
	
	public function process(script:String):String {
		index = 0;
		lines = script.split(NEWLINE);
		packageName = "";
		imports = [];
		classes = [];
		
		for (line in lines) {
			this.line = line;

			// package *
			match(packageRegex, compilePackage);
			// import *.*
			match(importRegex, compileImport);
			// class A -> A = {}
			// class A extends B -> A = classExtends(B)
			match(classRegex, compileClass);
			// super.*()
			match(superRegex, compileSuper);
			// new *()
			match(newObjectRegex, compileNewObject);
			// function
			match(functionRegex, compileFunction);
			// var
			match(varRegex, compileVar);
			// { }
			match(bracketRegex, compileBracket);
			
			// reset scope data
			scopeName = "";
			scopeType = ANONYMOUS_SCOPE;
			index++;
		}
		
		script = lines.join(NEWLINE);
		return script;
	}

	inline function match(regex:EReg, compile:EReg->Void) {
		if (regex.match(line))
			compile(regex);
	}

	inline function setCurrentLine(?s:String = "") {
		lines[index] = s;
	}

	function compilePackage(regex:EReg) {
		packageName = regex.matched(1);
		setCurrentLine();
	}

	function compileImport(regex:EReg) {
		imports.push(regex.matched(1));
		setCurrentLine();
	}

	function compileClass(regex:EReg) {
		className = classRegex.matched(1);
		var baseClass = classRegex.matched(2);
		var bracket = classRegex.matched(3);
		var classExtendingFuncName = ScriptClassUtil.classExtends_FUNC_NAME;

		var compiled = '$className = ' +
		if (baseClass == null)
			'{};';
		else '$classExtendingFuncName($baseClass);';
				
		compiled += ' $bracket';
		compiled = classRegex.replace(line, compiled);

		setCurrentLine(compiled);
		
		scopeName = className;
		scopeType = CLASS_SCOPE;
		classes.push(className);
	}

	function compileSuper(regex:EReg) {
		var superFunction = superRegex.matched(1);
		var args = superRegex.matched(2);
		
		if (superFunction == null)
			superFunction = "new";
		if (args != "")
			args = ', $args';
		
		var compiled = '$className.__superClass.$superFunction(this$args);';
		compiled = superRegex.replace(line, compiled);
				
		setCurrentLine(compiled);
	}
	
	function compileNewObject(regex:EReg) {
		className = newObjectRegex.matched(1);
		var args = newObjectRegex.matched(2);
		var objectCreatorFuncName = ScriptClassUtil.create_FUNC_NAME;
		var compiled = '$objectCreatorFuncName($className, [$args])';
		compiled = newObjectRegex.replace(line, compiled);

		setCurrentLine(compiled);
	}
	
	function compileFunction(regex:EReg) {
		var isOverriden = functionRegex.matched(1) != null;
		var isPublic = functionRegex.matched(2) == "public";
		var isStatic = functionRegex.matched(3) != null;
		var funcName = functionRegex.matched(5);
		var params = functionRegex.matched(6);
		var bracket = functionRegex.matched(7);
		
		if (bracket == null)
			bracket = "";
		
		var classFunctionAssign = "";
		
		scopeName = funcName;
		scopeType = FUNCTION_SCOPE;

		if (scope.type == CLASS_SCOPE) {
			classFunctionAssign = '$className.$funcName =';
			if (!isStatic) {
				// comma trailing `this` parameter
				var comma = params != "" ? ", " : "";
				// add `this` as the first parameter
				params = 'this$comma' + params;
			}
		}

		// if function is in a root scope, or does not belong to any class
		if (scope.type == ROOT_SCOPE || funcName == "main")
			funcName = ' $funcName';
		else funcName = "";

		var compiled = '$classFunctionAssign function$funcName($params) $bracket';
		compiled = functionRegex.replace(line, compiled);

		setCurrentLine(compiled);
	}
	
	function compileVar(regex:EReg) {
		var isPublic = varRegex.matched(1) == "public";
		var isStatic = varRegex.matched(2) != null;
		var varName = varRegex.matched(4);
		var assignment = varRegex.matched(5);
		
		/*if (scope.type == CLASS_SCOPE) {
			if (isStatic)
				scriptClass.statics.push(varName);
			else scriptClass.members.push(varName);
		}*/
		
		if (scope.type == CLASS_SCOPE) {
			var compiled = '$className.$varName $assignment';
			compiled = varRegex.replace(line, compiled);
			setCurrentLine(compiled);
		}
	}
	
	function compileBracket(regex:EReg) {
		var bracket:String = bracketRegex.matched(1);
		var pos:Int = 0;

		do {
			if (bracket == "{")
				scope.openScope(scopeName, scopeType);
			else if (bracket == "}")
				scope.closeScope();
			
			// stops if no more bracket matched
			line = bracketRegex.matchedRight();
			pos = bracketRegex.matchedPos().pos;
			
			// without this, it would crash on neko, at least
			if (pos >= line.length) break;
		}
		while (bracketRegex.matchSub(line, pos));
	}
}