<!--- Redirect to the list page if no selection made --->
<cfif theUrl.searchUrl('plugin') eq ''>
	<cfset theURL.setRedirect('_base', '/admin/plugin/install/list') />
	<cfset theURL.redirectRedirect() />
</cfif>

<!--- Make sure that the user is in the correct mode for installing --->
<cfif transport.theApplication.managers.singleton.getApplication().isProduction()>
	<cfthrow type="forbidden" message="Cannot update plugins in production mode" detail="When running in production mode the plugins cannot be updated" />
</cfif>

<cfset servPlugin = services.get('plugins', 'plugin') />

<!--- Retrieve the object --->
<cfset plugin = servPlugin.getPlugin( theURL.search('plugin') ) />

<!--- Add to the current levels --->
<cfset template.addLevel(plugin.getPlugin(), plugin.getPlugin(), theUrl.get(), 0, true) />
