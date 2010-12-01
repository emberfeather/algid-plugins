<cfset viewPlugin = views.get('plugins', 'plugin') />

<cfset filter = {
	'search' = theURL.search('search'),
	'refreshCache' = theURL.searchBoolean('refreshCache')
} />

<cfoutput>
	#viewPlugin.filter( filter )#
</cfoutput>
