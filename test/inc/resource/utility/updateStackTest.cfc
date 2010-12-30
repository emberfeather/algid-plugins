component extends="mxunit.framework.TestCase" {
	public void function setup() {
		variables.theStack = createObject('component', 'plugins.plugins.inc.resource.utility.updateStack').init();
	}
	
	/**
	 * Tests the length function with multiple  duplicate values
	 */
	public void function testLengthMultipleWithDuplicates() {
		variables.theStack.push('test1');
		variables.theStack.push('test2');
		variables.theStack.push('test3');
		variables.theStack.push('test2');
		variables.theStack.push('test3');
		
		assertEquals(3, variables.theStack.length());
	}
	
	/**
	 * Tests the pop function with multiple values
	 */
	public void function testPopMultipleWithDuplicates() {
		variables.theStack.push('test1');
		variables.theStack.push('test2');
		variables.theStack.push('test3');
		variables.theStack.push('test2');
		
		assertEquals('test2', variables.theStack.pop());
		assertEquals('test3', variables.theStack.pop());
		assertEquals('test1', variables.theStack.pop());
	}
	
	public void function testRemove() {
		variables.theStack.push('test1');
		variables.theStack.push('test2');
		variables.theStack.push('test3');
		
		assertEquals(3, variables.theStack.length());
		
		variables.theStack.remove('test2');
		
		assertEquals(2, variables.theStack.length());
	}
	
	public void function testRemoveWithDuplicates() {
		variables.theStack.push('test1');
		variables.theStack.push('test2');
		variables.theStack.push('test3');
		variables.theStack.push('test2');
		variables.theStack.push('test3');
		
		assertEquals(3, variables.theStack.length());
		
		variables.theStack.remove('test2');
		
		assertEquals(2, variables.theStack.length());
	}
}
