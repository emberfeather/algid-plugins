<!--- Redirect to the list page if no selection made --->
<cfif theUrl.search('plugin') eq ''>
	<cfset theURL.setRedirect('_base', '/admin/update/plugin/install/list') />
	<cfset theURL.redirectRedirect() />
</cfif>

<!--- Make sure that the user is in the correct mode for installing --->
<cfif transport.theApplication.managers.singleton.getApplication().isProduction()>
	<cfthrow type="forbidden" message="Cannot update plugins in production mode" detail="When running in production mode the plugins cannot be updated" />
</cfif>

<cfset servPlugin = services.get('plugins', 'plugin') />
<cfset servUpdate = services.get('plugins', 'update') />

<cfset currentPlugin = theUrl.search('plugin') />

<cfset archiveInfo = servUpdate.retrieveArchives([ currentPlugin ]) />

<cfset servUpdate.markForUpdate(archiveInfo) />

<!--- Redirect to the update overview --->
<cfset theURL.setRedirect('_base', '/admin/update/plugin/update/execute') />
<cfset theURL.removeRedirect('plugin') />
<cfset theURL.redirectRedirect() />
