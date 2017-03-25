package hscript.plus;

import hscript.Expr;

class Interp extends hscript.Interp {
	public function new() {
		super();
	}

	override public function expr(e:Expr):Dynamic {
		var ret = super.expr(e);
		if (ret != null) return ret;

		switch (e) {
			case EClass(name, e, baseClass):
				var cls:Dynamic = null; // class
				var baseClassObj = variables.get(baseClass);

				if (baseClassObj == null)
					cls = {};
				else cls = ScriptClassUtil.classExtends(baseClass);
				cls.__statics = new Array<String>();

				variables.set(name, cls);

				switch (e) {
					case EBlock(exprList):
						for (e in exprList) {
							switch (e) {
								case EFunction(args, _, name, _, access):
									var notStatic = access.indexOf(AStatic) == -1;
									if (notStatic)
										args.push({ name:"this"});
									setExprToField(cls, name, e, access);
								case EVar(name, _, e, access):
									setExprToField(cls, name, e, access);
								default:
							}
						}
					default:
				}
			ret = cls;
			default:
		}

		return ret;
	}

	inline function setExprToField(object:Dynamic, name:String, e:Expr, access:Array<Access>) {
		Reflect.setField(object, name, expr(e));
		var isStatic = access.indexOf(AStatic) > -1;
		if (isStatic)
			object.__statics.push(name);
	}
}