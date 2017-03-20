package hscript_plus;

@:build(hscript_plus.AbstractMacro.buildGetSetters())
class ScopeManager {
	public var name(get, set):String;
	public var type(get, set):ScopeType;
	public var fields(get, null):Array<String> = [];
	
	public var parent(get, set):Scope;
	public var child(get, set):Scope;

	var _scope:Scope;

	public function new() {
		_scope = new Scope("", ROOT_SCOPE);
	}

	public inline function isRoot() return type == ROOT_SCOPE;
	public inline function isInClass() return type == CLASS_SCOPE;
	public inline function isInFunction() return type == FUNCTION_SCOPE;
	public function isAnonymous() return type == ANONYMOUS_SCOPE;

	public inline function parentIs(scope:Scope):Bool return scope == parent;
	public inline function childIs(scope:Scope):Bool return scope == child;

	public inline function addField(name:String):Bool {
		if (hasField(name)) return false; 
		fields.push(name);
		return true;
	}
	public inline function hasField(name:String):Bool return fields.indexOf(name) > -1;
	
	public inline function openScope(?name:String = "", ?type:ScopeType):Scope {
		var childScope = new Scope(name, type);
		
		childScope.parent = _scope;
		_scope.child = childScope;
		return _scope = childScope;
	}
	
	public inline function closeScope() {
		var oldScope = _scope;
		_scope = _scope.parent;
		return oldScope;
	}
}

class Scope {
	public var name:String;
	public var type:ScopeType;
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