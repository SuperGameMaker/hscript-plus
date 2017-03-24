package cases;

import utest.Assert;
import hscript.plus.ScopeManager;

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
        scope.openScope(CLASS_SCOPE, "Object");
        Assert.isTrue(scope.isInClass());
    }

    public function testClassScopeField() {
        scope.openScope(CLASS_SCOPE, "Object");
        scope.addField("mass");
        Assert.isTrue(scope.hasField("mass"));
    }

    public function testFunctionScope() {
        scope.openScope(CLASS_SCOPE, "Object");
        scope.openScope(FUNCTION_SCOPE, "new");
        Assert.isTrue(scope.isInFunction());
    }

    public function testFunctionScopeField() {
        scope.openScope(CLASS_SCOPE, "Object");
        scope.openScope(FUNCTION_SCOPE, "new");
        scope.addField("mass");        
        Assert.isTrue(scope.hasField("mass"));
    }

    public function testAnonymousScope() {
        scope.openScope(CLASS_SCOPE, "Object");
        scope.openScope(FUNCTION_SCOPE, "new");
        scope.openScope(ANONYMOUS_SCOPE, "");
        Assert.isTrue(scope.isAnonymous());
    }

    public function testAnonymousScope_AddFieldFails() {
        scope.openScope(CLASS_SCOPE, "Object");
        scope.openScope(FUNCTION_SCOPE, "new");
        scope.openScope(ANONYMOUS_SCOPE, "");
        scope.addField("velocity");
        Assert.isFalse(scope.addField("velocity"));
    }
}