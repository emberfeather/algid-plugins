<cfset servUpdate = services.get('plugins', 'update') />

<cfif cgi.request_method eq 'post'>
	<!--- Process the form submission --->
	
	<!--- Read uploaded file --->
	<cfset servUpdate.uploadPlugin(transport.theSession.managers.singleton.getUser(), form.archiveFile) />
	
	<!--- Add a success message --->
	<!--- TODO Use i18n --->
	<cfset transport.theSession.managers.singleton.getSuccess().addMessages('The plugin was successfully installed.') />
	
	<!--- Redirect --->
	<cfset theURL.setRedirect('_base', '/admin/plugin/install/list') />
	<cfset theURL.redirectRedirect() />
</cfif>
