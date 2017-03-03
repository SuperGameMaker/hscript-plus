package hscript_plus;

class ScriptClassUtil {
	public static var CLASS_NAME = Type.getClassName(ScriptClassUtil).split(".")[1];
	
	public static function create(baseClass:Dynamic, ?constructorArgs:Array<Dynamic>):Dynamic {
		var table = Reflect.copy(baseClass);
		
		for (fieldName in Reflect.fields(table)) {
			var field = Reflect.field(table, fieldName);
			if (!Reflect.isFunction(field)) continue;
			
			// call `new()`
			if (fieldName == "new") {
				try {
					Reflect.callMethod(table, field, [table].concat(constructorArgs));
					continue;
				}
				catch (e:Dynamic) {
					printError("create", e);
				}
			}
			
			try { // bind `table` to method
				var bindedMethod = function(?args:Array<Dynamic>) return Reflect.callMethod(table, field, [table].concat(args));
				Reflect.setField(table, fieldName, Reflect.makeVarArgs(bindedMethod));
			}
			catch (e:Dynamic) {
				printError("create", e);
			}
		}
		
		return table;
	}
	
	static function printError(functionName:String, e:Dynamic) {
		trace('$CLASS_NAME.$functionName(): $e');
	}
	
	public static function classExtends(baseClass:Dynamic, ?body:Dynamic):Dynamic {
		var newClass = Reflect.copy(baseClass);
		newClass.__superClass = baseClass;
		
		if (body != null)
			for (fieldName in Reflect.fields(body))
				Reflect.setField(newClass, fieldName, Reflect.field(body, fieldName));
		
		return newClass;
	}
}