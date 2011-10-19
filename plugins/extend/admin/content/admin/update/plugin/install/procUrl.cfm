<cfset servUpdate = services.get('plugins', 'update') />

<cfset archiveFile = '' />

<cfif cgi.request_method eq 'post'>
	<!--- Process the form submission --->
	<cfset archiveInfo = servUpdate.retrieveArchive(transport.theForm.updateUrl) />
	
	<cfset servUpdate.markForUpdate(archiveInfo) />
	
	<!--- Redirect to the update overview --->
	<cfset theURL.setRedirect('_base', '/admin/update/execute') />
	<cfset theURL.removeRedirect('plugin') />
	<cfset theURL.redirectRedirect() />
</cfif>
