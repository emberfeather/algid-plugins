<cfset servPlugin = services.get('plugins', 'plugin') />
<cfset servUpdate = services.get('plugins', 'update') />

<cfset plugins = servPlugin.getPlugins( {}, { checkForUpdates: true, refreshCache: theUrl.searchBoolean('refreshCache') } ) />

<cfset archiveInfo = servUpdate.retrieveArchives(listToArray(valueList(plugins.key))) />

<cfset servUpdate.markForUpdate(archiveInfo) />

<!--- Redirect to the update overview --->
<cfset theURL.setRedirect('_base', '/admin/plugin/update/execute') />
<cfset theURL.removeRedirect('plugin') />
<cfset theURL.redirectRedirect() />
