<!--- Make sure that the user is in the correct mode for installing --->
<cfif transport.theApplication.managers.singleton.getApplication().isProduction()>
	<cfset session.managers.singleton.getWarning().addMessages('Cannot update plugins while running in production mode.') />
</cfif>

<cfset servUpdate = services.get('plugins', 'update') />

<cfif cgi.request_method eq 'post'>
	<!--- Execute Update Process --->
	<cfset servUpdate.executeUpdates(form) />
	
	<!--- Add a success message --->
	<!--- TODO use i18n --->
	<cfset session.managers.singleton.getSuccess().addMessages('The plugins were successfully upgraded.') />
	<cfset session.managers.singleton.getWarning().addMessages('The plugins may not be enabled until the application configuration file is updated.') />
	
	<!--- Redirect to the overview --->
	<cfset theURL.setRedirect('_base', '/admin/plugin') />
	<cfset theURL.redirectRedirect() />
</cfif>
