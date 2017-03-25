package hscript.plus;

import hscript.Expr;
import hscript.Parser.Token;

class Parser extends hscript.Parser {
	var access:Array<Access> = [];

	public function new() {
		super();
		allowTypes = true;
	}

	override function parseStructure(id:String) {
		var ret = super.parseStructure(id);

		if (ret != null) {
			switch (ret) {
				case EFunction(args, e, name, r, a):
					a = [while (access.length > 0) access.pop()];
					ret = mk(EFunction(args, e, name, r, a));
				default:
			}

			return ret;
		}

		return switch(id) {
			case "class":
				var tk = token();
				var name = null;
				
				switch (tk) {
					case TId(id): name = id;
					default: push(tk);
				}

				var baseClass = null;
				tk = token();
				switch (tk) {
					case TId(id) if (id == "extends"):
						tk = token();
						switch (tk) {
							case TId(id): baseClass = id;
							default: unexpected(tk);
						}
					default:
					push(tk);
				}

				var body = parseExpr();
				mk(EClass(name, body, baseClass));

			case "public": pushAndParseNext(APublic);
			case "private": pushAndParseNext(APrivate);
			case "static": pushAndParseNext(AStatic);
			case "override": pushAndParseNext(AOverride);
			case "dynamic": pushAndParseNext(ADynamic);
			case "inline": pushAndParseNext(AInline);

			default: null;
		}
	}

	function pushAndParseNext(a:Access) {
		access.push(a);
		var tk = token();
		return switch (tk) {
			case TId(id): parseStructure(id);
			default: unexpected(tk);
		}
	}
}