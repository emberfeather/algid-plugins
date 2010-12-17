<cfset servUpdate = services.get('plugins', 'update') />

<cfset archiveInfo = servUpdate.retrieveArchives() />

<!--- TODO Remove --->
<cfdump var="#archiveInfo#" />
<cfabort />