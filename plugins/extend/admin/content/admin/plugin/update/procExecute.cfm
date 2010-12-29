<!--- Make sure that the user is in the correct mode for installing --->
<cfif transport.theApplication.managers.singleton.getApplication().isProduction()>
	<cfset session.managers.singleton.getWarning().addMessages('Cannot update plugins while running in production mode.') />
</cfif>

<cfset servUpdate = services.get('plugins', 'update') />

<cfif cgi.request_method eq 'post'>
	<!--- TODO Execute Update Process --->
</cfif>
