<cfset viewPlugin = views.get('plugins', 'plugin') />

<cfoutput>
	#viewPlugin.edit(pluginSettings)#
</cfoutput>
