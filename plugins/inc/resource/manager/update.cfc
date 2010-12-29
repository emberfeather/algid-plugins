component {
	public component function init() {
		variables.changeStack = createObject('component', 'plugins.plugins.inc.resource.utility.updateStack').init();
		variables.changes = {};
		
		return this;
	}
	
	public void function mark( required any pluginInfo ) {
		var i = '';
		
		if(not isArray(arguments.pluginInfo)) {
			arguments.pluginInfo = [ arguments.pluginInfo ];
		}
		
		for(i = 1; i <= arrayLen(arguments.pluginInfo); i++) {
			variables.changes[arguments.pluginInfo[i].key] = arguments.pluginInfo[i];
			
			variables.changeStack.push(arguments.pluginInfo[i].key);
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
	
	public void function unmark( required string plugin ) {
		if(structKeyExists(variables.changes, arguments.plugin)) {
			structDelete(variables.changes, arguments.plugin);
		}
		
		variables.changeStack.remove(arguments.plugin);
	}
}
