<cfset viewPlugin = views.get('plugins', 'plugin') />

<cfset filter = {
		'search' = theURL.search('search')
	} />

<cfoutput>
	#viewPlugin.filter( filter )#
</cfoutput>