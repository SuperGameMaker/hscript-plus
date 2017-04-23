package hscript.plus;

import hscript.Expr;

class Interp extends hscript.Interp {
	public var packageName(default, null):String;

	public function new() {
		super();
	}

	override public function execute(e:Expr):Dynamic {
		packageName = "";
		return super.execute(e);
	}

	override public function expr(e:Expr):Dynamic {
		var ret = super.expr(e);
		if (ret != null) return ret;

		switch (edef(e)) {
			case EPackage(path):
				packageName = path.join(".");
			case EImport(path):
				importClass(path.join("."));
			case EClass(name, e, baseClass):
				var cls:Dynamic = null; // class
				var baseClassObj = baseClass == null ? null : variables.get(baseClass);

				if (baseClassObj == null)
					cls = {};
				else cls = ClassUtil.classExtends(baseClass);
				cls.__statics = new Array<String>();

				variables.set(name, cls);

				switch (edef(e)) {
					case EFunction(_, _), EVar(_):
						processClassFields(cls, e);
					case EBlock(exprList):
						for (e in exprList)
							processClassFields(cls, e);
					default:
				}
			ret = cls;
			default:
		}

		return ret;
	}

	function processClassFields(cls:Dynamic, e:Expr) {
		switch (edef(e)) {
			case EFunction(args, _, name, _, access):
				if (!isStatic(access))
					args.unshift({ name:"this" });
				setExprToField(cls, name, e, access);
			case EVar(name, _, e, access):
				// if `e` is `null` then default it to "null"
				if (e == null) e = EConst(CString("null"));
				setExprToField(cls, name, e, access);
			default:
		}
	}

	// TODO: import anonymous structure class
	function importClass(path:String) {
		var className = path.split(".").pop();
		var cls = Type.resolveClass(path);

		if (cls == null)
			throw '$path not found';
		
		variables.set(className, cls);
	}

	function setExprToField(object:Dynamic, name:String, e:Expr, access:Array<Access>) {
		Reflect.setField(object, name, expr(e));
		if (isStatic(access))
			object.__statics.push(name);
	}

	inline function isStatic(access:Array<Access>) {
		return access != null && access.indexOf(AStatic) > -1;
	}

	override function cnew(cl:String, args:Array<Dynamic>):Dynamic {
		try {
			return super.cnew(cl, args);
		}
		catch (e:Dynamic) {
			var c = resolve(cl);
			return ClassUtil.create(c, args);
		}
	}

	override function resolve(id:String):Dynamic {
		var _this = locals.get("this");
		if (_this != null)
			_this = _this.r;
		
		return
		if (!locals.exists(id) && Reflect.hasField(_this, id))
			Reflect.field(_this, id);
		else super.resolve(id);
	}
}