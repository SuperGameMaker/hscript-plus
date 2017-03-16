package cases;

import utest.Assert;
import hscript_plus.ScopeManager;

class ScopeManagerTest {
    var scope:ScopeManager;

    public function new() {}

    public function setup() {
        scope = new ScopeManager();
    }

    public function testRootScope() {
        Assert.isTrue(scope.isRoot());
    }

    public function testClassScope() {
        scope.openScope("Object", CLASS_SCOPE);
        Assert.isTrue(scope.isInClass());
    }

    public function testClassScopeField() {
        scope.openScope("Object", CLASS_SCOPE);
        scope.addField("mass");
        Assert.isTrue(scope.hasField("mass"));
    }

    public function testFunctionScope() {
        scope.openScope("Object", CLASS_SCOPE);
        scope.openScope("new", FUNCTION_SCOPE);
        Assert.isTrue(scope.isInFunction());
    }

    public function testFunctionScopeField() {
        scope.openScope("Object", CLASS_SCOPE);
        scope.openScope("new", FUNCTION_SCOPE);
        scope.addField("mass");        
        Assert.isTrue(scope.hasField("mass"));
    }

    public function testAnonymousScope() {
        scope.openScope("Object", CLASS_SCOPE);
        scope.openScope("new", FUNCTION_SCOPE);
        scope.openScope("", ANONYMOUS_SCOPE);
        Assert.isTrue(scope.isAnonymous());
    }

    public function testAnonymousScope_AddFieldFails() {
        scope.openScope("Object", CLASS_SCOPE);
        scope.openScope("new", FUNCTION_SCOPE);
        scope.openScope("", ANONYMOUS_SCOPE);
        scope.addField("velocity");
        Assert.isFalse(scope.addField("velocity"));
    }
}