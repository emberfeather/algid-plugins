component extends="algid.inc.resource.plugin.configure" {
	public void function onApplicationStart(required struct theApplication) {
		var i = '';
		var navigation = '';
		var plugin = '';
		var storagePath = '';
		
		// Get the plugin
		plugin = arguments.theApplication.managers.plugin.getPlugins();
		
		storagePath = plugin.getStoragePath();
		
		// Make sure the directories exist
		for (i in ['downloads', 'backups', 'upload']) {
			if (!directoryExists(storagePath & '/' & i)) {
				directoryCreate(storagePath & '/' & i);
			}
		}
	}
}
