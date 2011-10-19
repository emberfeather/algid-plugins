component extends="algid.inc.resource.base.event" {
	public void function afterGetPluginSettings( required struct transport, required string plugin ) {
		local.eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		local.user = arguments.transport.theSession.managers.singleton.getUser();
		local.eventLog.logEvent('plugins', 'settingsRetrieve', 'Retrieved the settings for the ''#arguments.plugin#'' plugin.', local.user.getUserID());
	}
	
	public void function afterSetPluginSettings( required struct transport, required string plugin, required struct settings ) {
		local.eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		local.user = arguments.transport.theSession.managers.singleton.getUser();
		local.eventLog.logEvent('plugins', 'settingsChanged', 'Changed the settings for the ''#arguments.plugin#'' plugin.', local.user.getUserID());
		
		arguments.transport.theSession.managers.singleton.getSuccess().addMessages('The plugin ''' & arguments.plugin & ''' settings were successfully saved.');
	}
}
