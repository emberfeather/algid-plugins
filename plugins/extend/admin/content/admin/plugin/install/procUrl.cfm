<cfset servUpdate = services.get('plugins', 'update') />

<cfset archiveFile = '' />

<cfif cgi.request_method eq 'post'>
	<!--- Process the form submission --->
	<cfset archiveInfo = servUpdate.retrieveArchive(transport.theForm.updateUrl) />
	
	<!--- TODO Remove --->
	<cfdump var="#archiveInfo#" />
	<cfabort />
</cfif>
