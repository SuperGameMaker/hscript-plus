# hscript-plus

Adds class to [hscript](https://github.com/HaxeFoundation/hscript) through the use of anonymous structure aka. `Dynamic` in Haxe, which is equivalent to table in Lua.

## Getting Started
### Installing
```
haxelib git hscript-plus https://github.com/DleanJeans/hscript-plus/
```

### hscript
#### Installing
```
haxelib install hscript
```

#### Document
Go read hscript's [README](https://github.com/HaxeFoundation/hscript/blob/master/README.md)

#### Limitations
- No wildcard importing
- No string interpolation
- No parameter default value

## Features
Improved from hscript

- Anonymous structure (Dynamic) classes
- Optimized for code completion
- `package` and `import`

## Usage
```haxe
var scriptState = new ScriptState();
// executes script from a file
scriptState.executeFile(scriptPath);

var script = "
class Object {
	// main() is called automatically when script is executed
	public static function main() {
		var object = new Object(10, 10);
		object.name = NAME;
		trace('name: ' + object.name);
		trace('x: ' + object.x);
		trace('y: ' + object.y);
	}
	
	public var x:Float = 0;
	public var y:Float = 0;

	public function new(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}
}
";
scriptState.set("NAME", "Ball"); // set a global variable
scriptState.executeString(script); // executes a String
// name: Ball
// x: 10
// y: 10

// get a global variable
var Object = scriptState.get("Object"); // get a global variable
Object.main();
// name: Ball
// x: 10
// y: 10
```

## How it works
There are 4 classes in `hscript-plus`
- [`hscript_plus.ScriptState`](https://github.com/DleanJeans/hscript-plus/blob/master/hscript_plus/ScriptState.hx)
	- contains `hscript.Parser` and `hscript.Interp`
	- executes scripts and stores global variables in them
	- comes with some error handlings
- [`hscript_plus.ScriptClassUtil`](https://github.com/DleanJeans/hscript-plus/blob/master/hscript_plus/ScriptClassUtil.hx):
	- is the main class for class emulation
	- has two static functions `create()` and `classExtends()` for creating new object and new child class, respectively
- [`hscript_plus.ScriptCompiler`](https://github.com/DleanJeans/hscript-plus/blob/master/hscript_plus/ScriptCompiler.hx):
	- processes the scripts before getting executed to optimize the scripts for code completion/suggestion
	- processes package name
	- processes imports
	- turns class declarations to anonymous structure declarations
	- adds `this` as the first parameter for member functions
	- turns variable and function declarations to anonymous structure field assignment.
	- Example:
	```Haxe
	class Object {
		var name:String = "";
		public function new(name:String) {
			this.name = name;
		}
	}
	// to
	Object = {}; {
		Object.name = "";
		Object.new = function(this, name:String) {
			this.name = name;
		}
	}
	```
	- soon most of it will be replaced with an extended Parser
- [`hscript_plus.ScopeManager`](https://github.com/DleanJeans/hscript-plus/blob/master/hscript_plus/ScopeManager.hx):
	- used in `ScriptCompiler`
	- stores fields in class or function scopes so function and variable declarations can be decided to belong to an anonymous structure or not
- 

## Limitations
- You need to access class members from `this` 

## Todos
- [ ] Call variables and functions calling `this`
- [ ] Try catch interpreting error
- [ ] Filter out static fields in `ScriptClassUtil.classExtends()`
- [ ] String interpolation