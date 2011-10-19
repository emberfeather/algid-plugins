<cfcomponent extends="algid.inc.resource.base.service" output="false">
	<cffunction name="checkVersion" access="private" returntype="struct" output="false">
		<cfargument name="plugin" type="string" required="true" />
		<cfargument name="versionUrl" type="string" required="true" />
		<cfargument name="refreshCache" type="boolean" default="false" />
		
		<cfset var currentPlugin = '' />
		<cfset var source = '' />
		<cfset var version = '' />
		
		<cfif variables.transport.theApplication.managers.plugin.has(arguments.plugin)>
			<cfset currentPlugin = variables.transport.theApplication.managers.plugin.get(arguments.plugin) />
			
			<cfset arguments.refreshCache = arguments.refreshCache or not currentPlugin.hasRemoteVersion() />
		</cfif>
		
		<cfif arguments.refreshCache>
			<cfhttp method="get" url="#arguments.versionUrl#" result="source" />
			
			<!--- Don't cache it if we didn't find the correct format --->
			<cfif not isJSON(source.fileContent)>
				<cfreturn {
					"releaseNotes": "",
					"archive": "",
					"URL": "",
					"version": "N/A"
				} />
			</cfif>
			
			<cfset version = deserializeJson(source.fileContent) />
			
			<cfif isObject(currentPlugin)>
				<cfset currentPlugin.setRemoteVersion(version) />
			</cfif>
		<cfelse>
			<cfset version = currentPlugin.getRemoteVersion() />
		</cfif>
		
		<cfreturn version />
	</cffunction>
	
	<cffunction name="getPlugin" access="public" returntype="component" output="false">
		<cfargument name="plugin" type="string" required="true" />
		
		<cfset var tempObj = '' />
		
		<cfif variables.transport.theApplication.managers.plugin.has(arguments.plugin)>
			<cfreturn variables.transport.theApplication.managers.plugin.get(arguments.plugin) />
		</cfif>
		
		<cfset tempObj = variables.transport.theApplication.factories.transient.getPlugin() />
		
		<cfset tempObj.setPlugin(arguments.plugin) />
		<cfset tempObj.setKey(arguments.plugin) />
		
		<cfreturn tempObj />
	</cffunction>
	
	<cffunction name="getPlugins" access="public" returntype="query" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		<cfargument name="options" type="struct" default="#{}#" />
		
		<cfset var app = '' />
		<cfset var currThreads = '' />
		<cfset var i = '' />
		<cfset var plugin = '' />
		<cfset var plugins = '' />
		<cfset var pluginSites = '' />
		<cfset var pluginUrl = '' />
		<cfset var randomPrefix = 'p-' & left(createUUID(), 8) & '-' />
		<cfset var results = '' />
		<cfset var tempObj = '' />
		<cfset var version = '' />
		
		<cfset arguments.filter = variables.extend({
			orderBy: '',
			search: ''
		}, arguments.filter) />
		
		<cfset arguments.options = variables.extend({
			checkForUpdates: false,
			refreshCache: false,
			showInstalled: true,
			showNotInstalled: false
		}, arguments.options) />
		
		<cfset app = variables.transport.theApplication.managers.singleton.getApplication() />
		<cfset tempObj = variables.transport.theApplication.factories.transient.getObject() />
		
		<cfset pluginSites = getPluginSites(arguments.options.refreshCache) />
		
		<!--- Determine which plugins to show --->
		<cfif arguments.options.showInstalled>
			<cfset tempObj.addUniquePlugins(argumentCollection = app.getPlugins()) />
		</cfif>
		
		<cfif arguments.options.showNotInstalled>
			<cfset plugins = app.getPlugins() />
			
			<cfloop list="#structKeyList(pluginSites.plugins)#" index="i">
				<cfif not arrayFind(plugins, i)>
					<cfset tempObj.addUniquePlugins(i) />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfset plugins = tempObj.getPlugins() />
		
		<cfset results = queryNew('key,plugin,versionCurrent,versionAvailable') />
		
		<cfloop from="1" to="#arrayLen(plugins)#" index="i">
			<cfset queryAddRow(results) />
			
			<cfif variables.transport.theApplication.managers.plugin.has(plugins[i])>
				<cfset plugin = variables.transport.theApplication.managers.plugin.get(plugins[i]) />
				
				<cfset querySetCell(results, 'key', plugin.getKey()) />
				<cfset querySetCell(results, 'plugin', plugin.getPlugin()) />
				<cfset querySetCell(results, 'versionCurrent', plugin.getVersion()) />
			<cfelse>
				<cfset querySetCell(results, 'key', plugins[i]) />
				<cfset querySetCell(results, 'plugin', plugins[i]) />
				<cfset querySetCell(results, 'versionCurrent', '—') />
			</cfif>
		</cfloop>
		
		<!--- Check against the update sources to see if there is an update available. --->
		<cfif arguments.options.checkForUpdates>
			<cfloop from="1" to="#arrayLen(plugins)#" index="i">
				<cfif not structKeyExists(pluginSites.plugins, plugins[i])>
					<cfset querySetCell(results, 'versionAvailable', '—', i ) />
					
					<cfcontinue />
				</cfif>
				
				<cfset pluginUrl = pluginSites.plugins[plugins[i]].versionUrl />
				
				<cfset version = checkVersion(plugins[i], pluginUrl, arguments.options.refreshCache) />
				
				<cfset querySetCell(results, 'versionAvailable', version.version, i ) />
			</cfloop>
		</cfif>
		
		<cfquery name="results" dbtype="query">
			SELECT key, plugin, versionCurrent, versionAvailable
			FROM results
			WHERE 1 = 1
			
			<cfif arguments.filter.search neq ''>
				AND plugin LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.filter.search#%" />
			</cfif>
			
			<cfif arguments.options.checkForUpdates>
				AND versionCurrent <> versionAvailable
			</cfif>
			
			ORDER BY
			<cfswitch expression="#arguments.filter.orderBy#">
				<cfdefaultcase>
					plugin ASC
				</cfdefaultcase>
			</cfswitch>
		</cfquery>
		
		<cfreturn results />
	</cffunction>
	
	<cffunction name="getPluginSettings" access="public" returntype="string" output="false">
		<cfargument name="plugin" type="component" required="true" />
		
		<cfset local.observer = getPluginObserver('plugins', 'plugin') />
		
		<cfset local.observer.beforeGetPluginSettings(variables.transport, arguments.plugin) />
		
		<cfset local.settings = fileRead('/plugins/#arguments.plugin#/config/settings.json.cfm') />
		
		<cfset local.observer.afterGetPluginSettings(variables.transport, arguments.plugin) />
		
		<cfreturn local.settings />
	</cffunction>
	
	<cffunction name="getPluginSites" access="public" returntype="struct" output="false">
		<cfargument name="refreshCache" type="boolean" default="false" />
		
		<cfset var i = '' />
		<cfset var plugin = '' />
		<cfset var pluginSites = {} />
		<cfset var sources = '' />
		<cfset var source = '' />
		
		<cfset plugin = variables.transport.theApplication.managers.plugin.get('plugins') />
		
		<cfif arguments.refreshCache or not plugin.hasPluginSites()>
			<cfset sources = plugin.getSources() />
			
			<!--- Retrieve the current update URL for plugins --->
			<cfloop from="1" to="#arrayLen(sources)#" index="i">
				<cfhttp method="get" url="#sources[i].sourceUrl#" result="source" />
				
				<cfset pluginSites = variables.extend(pluginSites, deserializeJson(source.fileContent)) />
			</cfloop>
			
			<cfset plugin.setPluginSites(pluginSites) />
		<cfelse>
			<cfset pluginSites = plugin.getPluginSites() />
		</cfif>
		
		<cfreturn pluginSites />
	</cffunction>
	
	<cffunction name="setPluginSettings" access="public" returntype="void" output="false">
		<cfargument name="plugin" type="component" required="true" />
		<cfargument name="raw" type="string" required="true" />
		
		<cfif not isJson(arguments.raw)>
			<cfthrow type="validation" message="Plugin settings not in JSON format" detail="Settings provided for the #arguments.plugin# plugin were not in the JSON format" />
		</cfif>
		
		<cfif not fileExists('/plugins/#arguments.plugin#/config/settings.json.cfm')>
			<cfthrow message="Unable to find the settings file" detail="Unable to find the #arguments.plugin# settings file" />
		</cfif>
		
		<cfset local.settings = deserializeJson(arguments.raw) />
		
		<cfset local.observer = getPluginObserver('plugins', 'plugin') />
		
		<cfset local.observer.beforeSetPluginSettings(variables.transport, arguments.plugin, local.settings) />
		
		<!--- Update the loaded --->
		<cfset local.plugin = variables.transport.theApplication.managers.plugin.get(arguments.plugin) />
		
		<cfloop list="#structKeyList(local.settings)#" index="local.i">
			<cfset local.plugin['set' & local.i](local.settings[local.i]) />
		</cfloop>
		
		<!--- Write the plugin changes to the file system --->
		<cfset fileWrite('/plugins/#arguments.plugin#/config/settings.json.cfm', serializeJson(local.settings)) />
		
		<cfset local.observer.afterSetPluginSettings(variables.transport, arguments.plugin, local.settings) />
	</cffunction>
</cfcomponent>
