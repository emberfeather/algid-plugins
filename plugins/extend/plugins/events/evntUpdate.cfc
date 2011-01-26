component extends="algid.inc.resource.base.event" {
	public void function afterUpdate( required struct transport, required struct pluginInfo ) {
		arguments.transport.theSession.managers.singleton.getSuccess().addMessages('The plugin ''' & arguments.pluginInfo.key & ''' was successfully updated.');
	}
	
	public void function afterUpdates( required struct transport ) {
		arguments.transport.theSession.managers.singleton.getWarning().addMessages('The plugins may not be enabled until the application configuration file is updated.');
	}
}
