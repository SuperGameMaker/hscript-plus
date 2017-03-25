package;

import utest.Runner;
import utest.ui.Report;

import cases.ScriptClassUtilTest;
import cases.ScriptCompilerTest;
import cases.ScriptStateTest;
import cases.ScopeManagerTest;
import cases.ParserTest;

class TestAll {
	public static function main() {
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}

	static function addTests(runner:Runner) {
		runner.addCase(new ScriptClassUtilTest());
		runner.addCase(new ScriptStateTest());
		runner.addCase(new ScriptCompilerTest());
		runner.addCase(new ScopeManagerTest());
		runner.addCase(new ParserTest());
	}
	
}