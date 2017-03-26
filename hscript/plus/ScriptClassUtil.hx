package hscript.plus;

class ScriptClassUtil {
	public static var CLASS_NAME = Type.getClassName(ScriptClassUtil).split(".")[1];
	public static var create_FUNC_NAME = "create";
	public static var classExtends_FUNC_NAME = "classExtends";

	public static function create(baseClass:Dynamic, ?args:Array<Dynamic>):Dynamic {
		if (args == null) args = [];
		var _this = Reflect.copy(baseClass);
		
		for (fieldName in Reflect.fields(_this)) {
			var field = Reflect.field(_this, fieldName);
			if (!Reflect.isFunction(field)) continue;
			
			// call `new()`
			if (fieldName == "new") {
				Reflect.callMethod(_this, field, [_this].concat(args));
				continue;
			}
			
			var boundMethod = // bind `_this` to method
			function(?args:Array<Dynamic>) return Reflect.callMethod(_this, field, [_this].concat(args));
			Reflect.setField(_this, fieldName, Reflect.makeVarArgs(boundMethod));
		}
		
		return _this;
	}
	
	public static function classExtends(baseClass:Dynamic, ?body:Dynamic):Dynamic {
		var newClass = Reflect.copy(baseClass);
		newClass.__superClass = baseClass;
		
		if (body != null)
			for (fieldName in Reflect.fields(body))
				Reflect.setField(newClass, fieldName, Reflect.field(body, fieldName));
		
		var statics:Array<String> = baseClass.__statics;
		if (statics != null) {
			for (field in statics)
				Reflect.deleteField(newClass, field);
		}
		
		return newClass;
	}
}