import hscript_plus.*;

import utest.Runner;
import utest.ui.Report;
import utest.Assert;
import utest.TestResult;

import cases.ScriptPreprocessorTest;
import cases.ScriptStateTest;

class TestAll  {
	public static function main() {
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);
		runner.run();
	}

	static function addTests(runner:Runner) {
		runner.addCase(new ScriptStateTest());
		runner.addCase(new ScriptPreprocessorTest());
	}
	
}