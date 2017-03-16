package hscript_plus;

class ScriptClassUtil {
	public static var CLASS_NAME = Type.getClassName(ScriptClassUtil).split(".")[1];
	public static var create_FUNC_NAME = "create";
	public static var classExtends_FUNC_NAME = "classExtends";

	public static function create(baseClass:Dynamic, ?args:Array<Dynamic>):Dynamic {
		inline function printError(e:Dynamic)
			throw('$CLASS_NAME.create: $e');
		
		if (args == null) args = [];
		var table = Reflect.copy(baseClass);
		
		for (fieldName in Reflect.fields(table)) {
			var field = Reflect.field(table, fieldName);
			if (!Reflect.isFunction(field)) continue;
			
			// call `new()`
			if (fieldName == "new") {
				try {
					Reflect.callMethod(table, field, [table].concat(args));
					continue;
				}
				catch (e:Dynamic) {
					printError(e);
				}
			}
			
			try { // bind `table` to method
				var bindedMethod = function(?args:Array<Dynamic>) return Reflect.callMethod(table, field, [table].concat(args));
				Reflect.setField(table, fieldName, Reflect.makeVarArgs(bindedMethod));
			}
			catch (e:Dynamic) {
				printError(e);
			}
		}
		
		return table;
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