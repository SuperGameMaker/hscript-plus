package;

import utest.Runner;
import utest.ui.Report;

import cases.ScriptClassUtilTest;
import cases.ScriptStateTest;
import cases.ParserTest;
import cases.InterpTest;

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
		runner.addCase(new ParserTest());
		runner.addCase(new InterpTest());
	}
	
}