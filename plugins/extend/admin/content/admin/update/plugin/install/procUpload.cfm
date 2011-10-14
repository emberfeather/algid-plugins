<cfset servUpdate = services.get('plugins', 'update') />

<cfset archiveFile = '' />

<cfif cgi.request_method eq 'post'>
	<!--- Process the form submission --->
	<cfsetting requesttimeout="300" />
	
	<!--- Upload files --->
	<cfloop list="#form.fieldnames#" index="archive">
		<cfif reFind('^archiveFile', archive) and len(trim(form[archive]))>
			<cffile action="upload" filefield="#archive#" destination="#transport.theApplication.managers.plugin.getPlugins().getStoragePath()#/upload" result="archiveUpload" nameConflict="overwrite" accept="application/zip,application/x-gtar,application/x-gzip">
			
			<cfset archiveInfo = servUpdate.uploadArchive(archiveUpload.serverDirectory & '/' & archiveUpload.serverFile) />
			
			<cfset servUpdate.markForUpdate(archiveInfo) />
		</cfif>
	</cfloop>
	
	<!--- Redirect to the update overview --->
	<cfset theURL.setRedirect('_base', '/admin/update/plugin/update/execute') />
	<cfset theURL.removeRedirect('plugin') />
	<cfset theURL.redirectRedirect() />
</cfif>
