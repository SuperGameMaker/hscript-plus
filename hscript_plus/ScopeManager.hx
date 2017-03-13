package hscript_plus;

@:forward(name, type, fields, parent, child)
abstract ScopeManager(Scope) {
	public function new() {
		this = new Scope("", ROOT_SCOPE);
	}
	
	public inline function openScope(name:String = "", ?type:ScopeType):Scope {
		var childScope = new Scope(name, type);
		
		childScope.parent = this;
		this.child = childScope;
		return this = childScope;
	}
	
	public inline function closeScope() {
		var oldScope = this;
		this = this.parent;
		return oldScope;
	}
}

class Scope {
	public var name(default, null):String;
	public var type(default, null):ScopeType;
	public var fields(default, null):Array<String> = [];
	
	public var parent:Scope;
	public var child:Scope;
	
	public function new(name:String, ?type:ScopeType) {
		if (type == null) type = ANONYMOUS_SCOPE;
		
		this.name = name;
		this.type = type;
	}
}

enum ScopeType {
	ROOT_SCOPE;
	CLASS_SCOPE;
	FUNCTION_SCOPE;
	ANONYMOUS_SCOPE;
}