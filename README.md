# hscript-plus

Adds class to [hscript](https://github.com/HaxeFoundation/hscript) through the use of anonymous structure aka. Dynamic in Haxe, which is equivalent to table in Lua.

## Getting Started
### Installing
```
haxelib git hscript-plus https://github.com/DleanJeans/hscript-plus/
```

### Dependencies
#### hscript
##### Installing
```
haxelib install hscript
```

##### Document
Go read hscript's [README](https://github.com/HaxeFoundation/hscript/blob/master/README.md)

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

	public var new(x:Float = 0, y:Float = 0) {
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
- [`hscript_plus.ScriptState`](https://github.com/DleanJeans/hscript-plus/blob/master/hscript_plus/ScriptState.hx): executes scripts and stores global variables in them
- [`hscript_plus.ScriptClassUtil`](https://github.com/DleanJeans/hscript-plus/blob/master/hscript_plus/ScriptClassUtil.hx): has two static functions `create()` and `classExtends()` for creating new object and new child class, respectively
- [`hscript_plus.ScriptPreprocessor`](https://github.com/DleanJeans/hscript-plus/blob/master/hscript_plus/ScriptPreprocessor.hx): processes the scripts before getting executed
- [`hscript_plus.ScopeManager`](https://github.com/DleanJeans/hscript-plus/blob/master/hscript_plus/ScopeManager.hx): used in `ScriptPreprocessor` to store fields in class or function scopes

(more details soon)

## Limitations
- You need to access class members from `this` 
- No wildcard importing
- No string interpolation

## Todos
- [ ] Unit tests
- [ ] Refactor and clean code
- [ ] Call variables and functions calling `this`
- [ ] Try catch interpreting error
- [ ] Filter out static fields in ScriptClassUtil.create() and classExtends()
- [ ] Cache classes or not
- [ ] String interpolation