<cfset viewUpdate = views.get('plugins', 'update') />

<!--- Output a listing of all the plugins --->
<cfset updates = servUpdate.getUpdates() />

<cfoutput>#viewUpdate.execute(updates)#</cfoutput>
