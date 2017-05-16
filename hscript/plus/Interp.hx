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
		e = Tools.map(e, accessThis);
		e = Tools.map(e, accessSuper);

		var ret = super.expr(e);
		if (ret != null) return ret;

		switch (edef(e)) {
			case EPackage(path):
				packageName = path.join(".");
			case EImport(path):
				importClass(path.join("."));
			case EClass(name, e, baseClass):
				var baseClassObj = baseClass == null ? null : variables.get(baseClass);
				var cls = ClassUtil.createClass(name, baseClassObj, { __statics:new Array<String>() });

				variables.set(name, cls);

				switch (edef(e)) {
					case EFunction(_, _), EVar(_):
						addClassFields(cls, e);
					case EBlock(exprList):
						for (e in exprList)
							addClassFields(cls, e);
					default:
				}
			ret = cls;
			default:
		}

		return ret;
	}

	// TODO: import anonymous structure class
	function importClass(path:String) {
		var className = path.split(".").pop();
		var cls = Type.resolveClass(path);

		if (cls == null)
			throw '$path not found';
		
		variables.set(className, cls);
	}

	function addClassFields(cls:Dynamic, e:Expr) {
		switch (edef(e)) {
			case EFunction(args, _, name, _, access):
				if (!isStatic(access))
					args.unshift({ name:"this" });
				setClassField(cls, name, e, access);
			case EVar(name, _, e, access):
				setClassField(cls, name, e, access);
			default:
		}
	}

	function setClassField(object:Dynamic, name:String, e:Expr, access:Array<Access>) {
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
		var val = resolveInThis(id);
		
		return
		if (val != null)
			val;
		else super.resolve(id);
	}
	
	function resolveInThis(id:String) {
		var _this = locals.get("this");
		var val = null;
		
		if (_this != null)
			_this = _this.r;
		else return val;
		
		if (!locals.exists(id) && Reflect.hasField(_this, id))
			val = Reflect.field(_this, id);
		
		return val;
	}

	function accessThis(e:Expr) {
		switch (edef(e)) {
			case EIdent(id) if (!locals.exists(id) && !variables.exists(id)):
				var _this = locals.get("this");
				if (_this != null) {
					_this = _this.r;
					e = mk(EField(EIdent("this"), id));
				}
			default:
		}
		return e;
	}

	function accessSuper(e:Expr):Expr {
		switch (edef(e)) {
			case EField(ident, fieldName):
				switch (ident) {
					case EIdent(objectName):
						var object = expr(ident);
						if (superHasField(object, fieldName))
							return mk(EField(EField(EIdent(objectName), "__super"), fieldName), e);
					default:
				}
			default:
		}
		return e;
	}

	inline function mk(e, ?expr:Expr) : Expr {
		#if hscriptPos
		if( e == null ) return null;
		return { e : e, pmin: expr.pmin, pmax: expr.pmax, line: expr.line, origin: expr.origin };
		#else
		return e;
		#end
	}

	function superHasField(object:Dynamic, fieldName:String) {
		return object != null 
		&& ClassUtil.isStructure(object) 
		&& object.__super != null && Reflect.hasField(object.__super, fieldName);
	}
}