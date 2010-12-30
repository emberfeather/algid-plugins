<cfset viewPlugin = views.get('plugins', 'plugin') />

<cfset filter = {
	'search' = theURL.search('search')
} />

<cfoutput>
	#viewPlugin.filter( filter )#
</cfoutput>

<cfset theUrl.setRefreshCache('refreshCache', true) />

<cfoutput>
	<!--- TODO Better way to add boxes to side template --->
	</div>
	
	<div class="box">
		<a href="#theUrl.getRefreshCache()#">Refresh Cache</a>
</cfoutput>
