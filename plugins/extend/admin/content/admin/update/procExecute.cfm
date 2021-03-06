<!--- Make sure that the user is in the correct mode for installing --->
<cfif transport.theApplication.managers.singleton.getApplication().isProduction()>
	<cfset session.managers.singleton.getWarning().addMessages('Cannot update plugins while running in production mode.') />
</cfif>

<cfset servUpdate = services.get('plugins', 'update') />

<cfif cgi.request_method eq 'post'>
	<!--- Execute Update Process --->
	<cfset servUpdate.executeUpdates() />
	
	<!--- Redirect to the overview --->
	<cfset theURL.setRedirect('_base', '/admin/update/plugin') />
	<cfset theURL.redirectRedirect() />
</cfif>
