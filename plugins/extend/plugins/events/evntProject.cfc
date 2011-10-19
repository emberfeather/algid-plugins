component extends="algid.inc.resource.base.event" {
	public void function afterGetProjectSettings( required struct transport, required string project ) {
		local.eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		local.user = arguments.transport.theSession.managers.singleton.getUser();
		local.eventLog.logEvent('projects', 'settingsRetrieve', 'Retrieved the settings for the ''#arguments.project#'' project.', local.user.getUserID());
	}
	
	public void function afterSetProjectSettings( required struct transport, required string project, required struct settings ) {
		local.eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		local.user = arguments.transport.theSession.managers.singleton.getUser();
		local.eventLog.logEvent('projects', 'settingsChanged', 'Changed the settings for the ''#arguments.project#'' project.', local.user.getUserID());
		
		arguments.transport.theSession.managers.singleton.getSuccess().addMessages('The project ''' & arguments.project & ''' settings were successfully saved.');
	}
}
