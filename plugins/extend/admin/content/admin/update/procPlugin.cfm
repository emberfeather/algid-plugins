<!--- Redirect to the list page if no selection made --->
<cfif theUrl.searchUrl('plugin') eq ''>
	<cfset theURL.setRedirect('_base', '/admin/update/plugin/list') />
	<cfset theURL.redirectRedirect() />
</cfif>

<cfset servPlugin = services.get('plugins', 'plugin') />

<!--- Retrieve the object --->
<cfset plugin = servPlugin.getPlugin( theURL.search('plugin') ) />

<!--- Get the current settings --->
<cfset pluginSettings = servPlugin.getPluginSettings(plugin) />

<cfif cgi.request_method eq 'post'>
	<cfset pluginSettings = form.settings />
	
	<cfset servPlugin.setPluginSettings( plugin.getKey(), pluginSettings ) />
	
	<!--- Redirect --->
	<cfset theURL.setRedirect('_base', '/admin/update/plugin/list') />
	<cfset theURL.removeRedirect('plugin') />
	
	<cfset theURL.redirectRedirect() />
</cfif>

<!--- Add to the current levels --->
<cfset template.addLevel(plugin.getPlugin(), plugin.getPlugin(), theUrl.get(), 0, true) />
<cfset template.addScript(transport.theRequest.webroot & '/plugins/plugins/script/admin/plugin.settings.js') />
