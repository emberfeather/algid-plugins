component {
	public component function init() {
		variables.changeStack = createObject('component', 'plugins.plugins.inc.resource.utility.updateStack').init();
		variables.changes = {};
		
		return this;
	}
	
	public void function mark( required any info, boolean isPlugin = true ) {
		var i = '';
		
		if(not isArray(arguments.info)) {
			arguments.info = [ arguments.info ];
		}
		
		for(i = 1; i <= arrayLen(arguments.info); i++) {
			arguments.info[i].isPlugin = arguments.isPlugin;
			variables.changes[arguments.info[i].key] = arguments.info[i];
			
			variables.changeStack.push(arguments.info[i].key);
		}
	}
	
	public any function get( string plugin = '' ) {
		if(arguments.plugin eq '') {
			return variables.changes;
		}
		
		return variables.changes[arguments.plugin];
	}
	
	public void function has( required string plugin ) {
		return structKeyExists(variables.changes, arguments.plugin);
	}
	
	public boolean function isEmpty() {
		return variables.changeStack.isEmpty();
	}
	
	public struct function pop() {
		var key = '';
		var plugin = '';
		
		key = variables.changeStack.pop();
		plugin = get(key);
		
		structDelete(variables.changes, key);
		
		return plugin;
	}
	
	public void function unmark( required string plugin ) {
		if(structKeyExists(variables.changes, arguments.plugin)) {
			structDelete(variables.changes, arguments.plugin);
		}
		
		variables.changeStack.remove(arguments.plugin);
	}
}
