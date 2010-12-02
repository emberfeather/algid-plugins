<!--- Make sure that the user is in the correct mode for installing --->
<cfif transport.theApplication.managers.singleton.getApplication().isProduction()>
	<cfthrow type="forbidden" message="Cannot update plugins in production mode" detail="When running in production mode the plugins cannot be updated" />
</cfif>

<cfset servPlugin = services.get('plugins', 'plugin') />

<cfif cgi.request_method eq 'post'>
	<!--- Update the URL and redirect --->
	<cfloop list="#form.fieldnames#" index="field">
		<cfset theURL.set('', field, form[field]) />
	</cfloop>
	
	<cfset theURL.redirect() />
</cfif>
