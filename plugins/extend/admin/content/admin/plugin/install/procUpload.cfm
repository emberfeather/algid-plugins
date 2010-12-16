<cfset servUpdate = services.get('plugins', 'update') />

<cfif cgi.request_method eq 'post'>
	<!--- Process the form submission --->
	
	<!--- Upload file --->
	<cffile action="upload" filefield="archiveFile" destination="/storage/plugins" result="archiveUpload" nameConflict="overwrite" accept="application/zip,application/x-gtar,application/x-gzip">
	
	<cfset servUpdate.uploadPlugin(transport.theSession.managers.singleton.getUser(), archiveUpload.serverDirectory & '/' & archiveUpload.serverFile) />
	
	<!--- Add a success message --->
	<!--- TODO Use i18n --->
	<cfset transport.theSession.managers.singleton.getSuccess().addMessages('The plugin was successfully installed.') />
	
	<!--- Redirect --->
	<cfset theURL.setRedirect('_base', '/admin/plugin/install/list') />
	<cfset theURL.redirectRedirect() />
</cfif>
