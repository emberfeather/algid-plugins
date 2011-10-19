component extends="algid.inc.resource.base.event" {
	public void function afterUpdate( required struct transport, required struct info ) {
		arguments.transport.theSession.managers.singleton.getSuccess().addMessages('The plugin ''' & arguments.info.key & ''' was successfully updated.');
	}
	
	public void function afterMark( required struct transport, required array info ) {
		for(local.i = 1; local.i <= arrayLen(arguments.info); local.i++) {
			arguments.transport.theSession.managers.singleton.getSuccess().addMessages('The plugin ''' & arguments.info[local.i].key & ''' was marked for update.');
		}
	}
	
	public void function afterUpdates( required struct transport ) {
		arguments.transport.theSession.managers.singleton.getWarning().addMessages('The plugins may not be enabled until the application configuration file is updated.');
	}
}
