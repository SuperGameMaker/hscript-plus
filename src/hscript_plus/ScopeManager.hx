package hscript_plus;

typedef Record = Array<Scope>;

@:build(hscript_plus.macro.GetSetterMacro.build())
class ScopeManager {
	public var name(get, set):String;
	public var type(get, set):ScopeType;
	public var fields(get, null):Array<String> = [];
	
	public var parent(get, set):Scope;
	public var child(get, set):Scope;

	public var record(default, null):Record = [];

	var _scope(default, set__scope):Scope; function set__scope(newScope:Scope) {
		_scope = newScope;
		record.push(newScope);
		return newScope;
	}

	public function new() {
		_scope = new Scope(ROOT_SCOPE, "");
	}

	public inline function isRoot() return _scope.isRoot();
	public inline function isInClass() return _scope.isInClass();
	public inline function isInFunction() return _scope.isInFunction();
	public function isAnonymous() return _scope.isAnonymous();

	public inline function parentIs(scope:Scope):Bool return _scope.parentIs(scope);
	public inline function childIs(scope:Scope):Bool return _scope.childIs(scope);

	public inline function addField(name:String):Bool return _scope.addField(name);
	public inline function hasField(name:String):Bool return _scope.hasField(name);
	
	public inline function openScope(?type:ScopeType, ?name:String = ""):Scope {
		var childScope = new Scope(type, name);
		
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
	
	public function new(?type:ScopeType, name:String) {
		if (type == null) type = ANONYMOUS_SCOPE;
		
		this.name = name;
		this.type = type;
	}

	public inline function isRoot() return type == ROOT_SCOPE;
	public inline function isInClass() return type == CLASS_SCOPE;
	public inline function isInFunction() return type == FUNCTION_SCOPE;
	public inline function isAnonymous() return type == ANONYMOUS_SCOPE;

	public inline function parentIs(scope:Scope):Bool return scope == parent;
	public inline function childIs(scope:Scope):Bool return scope == child;

	public inline function addField(name:String):Bool {
		if (hasField(name)) return false; 
		fields.push(name);
		return true;
	}
	public inline function hasField(name:String):Bool return fields.indexOf(name) > -1;
}

enum ScopeType {
	ROOT_SCOPE;
	CLASS_SCOPE;
	FUNCTION_SCOPE;
	ANONYMOUS_SCOPE;
}