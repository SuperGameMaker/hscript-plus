package hscript.plus.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

class GetSetterMacro {
	public static macro function build():Array<Field> {
		var fields = Context.getBuildFields();
		var _scope = fields.filter(function(field) return field.name == "_scope")[0];

		for (field in fields) {
			switch field.kind {
				case FProp(get, set, t, _):
					var name = field.name;
					if (get == "get")
						fields.push({
							name: 'get_$name',
							pos: Context.currentPos(),
							kind: FFun({ args:[], ret:t, expr:macro return _scope.$name })
						});
					if (set == "set")
						fields.push({
							name: 'set_$name',
							pos: Context.currentPos(),
							kind: FFun({ args:[ {name:"value", type:t} ], ret:t, expr:macro return _scope.$name = value })
						});
				case _:
			}
		}

		return fields;
	}
}