component extends="cf-compendium.inc.resource.utility.stack" {
	/**
	 * This stack makes the priority higher each time the item is added
	 * by making it the new last item.
	 **/
	public void function push(required any value) {
		var index = '';
		
		index = arrayFind(variables.stack, arguments.value);
		
		if(index) {
			arrayDeleteAt(variables.stack, index);
		}
		
		super.push(arguments.value);
	}
	
	public void function remove(required any value) {
		var index = '';
		
		index = arrayFind(variables.stack, arguments.value);
		
		if(index) {
			arrayDeleteAt(variables.stack, index);
		}
	}
}
