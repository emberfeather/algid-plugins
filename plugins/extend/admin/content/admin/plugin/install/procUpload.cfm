<cfset servUpdate = services.get('plugins', 'update') />

<cfset archiveFile = '' />

<cfif cgi.request_method eq 'post'>
	<!--- Process the form submission --->
	
	<!--- Upload file --->
	<cffile action="upload" filefield="archiveFile" destination="#transport.theApplication.managers.plugin.getPlugins().getStoragePath()#/upload" result="archiveUpload" nameConflict="overwrite" accept="application/zip,application/x-gtar,application/x-gzip">
	
	<cfset uploadInfo = servUpdate.uploadArchive(archiveUpload.serverDirectory & '/' & archiveUpload.serverFile) />
	
	<!--- TODO Remove --->
	<cfdump var="#uploadInfo#" />
	<cfabort />
</cfif>
