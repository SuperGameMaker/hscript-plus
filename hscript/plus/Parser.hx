package hscript.plus;

import hscript.Expr;
import hscript.Parser.Token;

class Parser extends hscript.Parser {
	var access:Array<Access> = [];

	public function new() {
		super();
		allowTypes = true;
	}

	override function isBlock(e:Expr) {
		var ret = super.isBlock(e);
		if (ret) return ret;

		return switch (expr(e)) {
			case EPackage(_), EImport(_): true;
			default: false;
		}
	}

	override function parseStructure(id:String) {
		var ret = super.parseStructure(id);

		if (ret != null) {
			switch (expr(ret)) {
				case EVar(name, t, e, access):
					ret = mk(EVar(name, t, e, this.access));
					this.access = [];
				case EFunction(args, e, name, r, a):
					ret = mk(EFunction(args, e, name, r, this.access));
					this.access = [];
				default:
			}

			return ret;
		}

		return switch(id) {
			case "package":
				var path = parsePath();
				mk(EPackage(path));
			case "import":
				var path = parsePath();
				mk(EImport(path));
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

	function parsePath():Array<String> {
		var tk = token();
		switch (tk) {
			case TId(id):
				var path = [id];
				while (true) {
					tk = token();
					if (tk != TDot)
						break;
					tk = token();
					switch (tk) {
						case TId(id):
							path.push(id);
						default:
							unexpected(tk);
					}
				}
				return path;
			default:
				unexpected(tk);
				return [];
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