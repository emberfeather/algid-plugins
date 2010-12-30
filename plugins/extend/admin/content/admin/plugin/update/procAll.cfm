<cfset servUpdate = services.get('plugins', 'update') />

<cfset archiveInfo = servUpdate.retrieveArchives() />

<cfset servUpdate.markForUpdate(archiveInfo) />

<!--- Redirect to the update overview --->
<cfset theURL.setRedirect('_base', '/admin/plugin/update/execute') />
<cfset theURL.removeRedirect('plugin') />
<cfset theURL.redirectRedirect() />
