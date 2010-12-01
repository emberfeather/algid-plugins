<cfcomponent extends="algid.inc.resource.base.service" output="false">
	<cffunction name="checkVersion" access="private" returntype="struct" output="false">
		<cfargument name="plugin" type="string" required="true" />
		<cfargument name="versionUrl" type="string" required="true" />
		<cfargument name="refreshCache" type="boolean" default="false" />
		
		<cfset var currentPlugin = '' />
		<cfset var source = '' />
		
		<cfset currentPlugin = getPlugin(arguments.plugin) />
		
		<cfif arguments.refreshCache or not currentPlugin.hasRemoteVersion()>
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
			
			<cfset currentPlugin.setRemoteVersion(deserializeJson(source.fileContent)) />
		</cfif>
		
		<cfreturn currentPlugin.getRemoteVersion() />
	</cffunction>
	
	<cffunction name="getPlugin" access="public" returntype="component" output="false">
		<cfargument name="plugin" type="string" required="true" />
		
		<cfreturn variables.transport.theApplication.managers.plugin.get(arguments.plugin) />
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
		<cfset var pluginUrls = '' />
		<cfset var randomPrefix = 'p-' & left(createUUID(), 8) & '-' />
		<cfset var results = '' />
		<cfset var useThreaded = false />
		<cfset var version = '' />
		
		<cfparam name="arguments.filter.orderBy" default="" />
		<cfparam name="arguments.filter.search" default="" />
		<cfparam name="arguments.options.checkForUpdates" default="false" />
		<cfparam name="arguments.options.refreshCache" default="false" />
		
		<cfset app = variables.transport.theApplication.managers.singleton.getApplication() />
		
		<cfset plugins = app.getPlugins() />
		<cfset useThreaded = app.getUseThreaded() />
		
		<cfset results = queryNew('key,plugin,versionCurrent,versionAvailable') />
		
		<cfloop from="1" to="#arrayLen(plugins)#" index="i">
			<cfset plugin = getPlugin(plugins[i]) />
			
			<cfset queryAddRow(results) />
			
			<cfset querySetCell(results, 'key', plugin.getKey()) />
			<cfset querySetCell(results, 'plugin', plugin.getPlugin()) />
			<cfset querySetCell(results, 'versionCurrent', plugin.getVersion()) />
		</cfloop>
		
		<!--- Check against the update sources to see if there is an update available. --->
		<cfif arguments.options.checkForUpdates>
			<cfset pluginSites = getPluginSites(arguments.options.refreshCache) />
			
			<cfloop from="1" to="#arrayLen(plugins)#" index="i">
				<cfif not structKeyExists(pluginSites.plugins, plugins[i])>
					<cfset querySetCell(results, 'versionAvailable', '—', i ) />
					
					<cfcontinue />
				</cfif>
				
				<cfset pluginUrl = pluginSites.plugins[plugins[i]].versionUrl />
				
				<cfif useThreaded>
					<!--- Use a separate thread to read each check --->
					<cfthread action="run" name="#randomPrefix##i#" plugin="#plugins[i]#" pluginUrl="#pluginUrl#" results="#results#" index="#i#" checkVersion="#checkVersion#" refeshCache="#arguments.options.refreshCache#">
						<cfset var version = '' />
						
						<cfset version = attributes.checkVersion(attributes.plugin, attributes.pluginUrl, attributes.refeshCache) />
						
						<cfset querySetCell(attributes.results, 'versionAvailable', version.version, attributes.index ) />
					</cfthread>
					
					<cfset currThreads = listAppend(currThreads, '#randomPrefix##i#') />
				<cfelse>
					<cfset version = checkVersion(plugins[i], pluginUrl, arguments.options.refreshCache) />
					
					<cfset querySetCell(results, 'versionAvailable', version.version, i ) />
				</cfif>
			</cfloop>
			
			<!--- Join the threads so we don't return prematurely --->
			<cfif useThreaded>
				<cfthread action="join" name="#currThreads#" timeout="10000" />
				
				<cfloop list="#currThreads#" index="i">
					<cfif cfthread[i].status eq 'terminated'>
						<cfthrow message="#cfthread[i].error.message#" detail="#cfthread[i].error.detail#" extendedinfo="#cfthread[i].error.stacktrace#" />
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfquery name="results" dbtype="query">
			SELECT key, plugin, versionCurrent, versionAvailable
			FROM results
			WHERE 1 = 1
			
			<cfif arguments.filter.search neq ''>
				AND plugin LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.filter.search#%" />
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
	
	<cffunction name="getPluginSites" access="public" returntype="struct" output="false">
		<cfargument name="refreshCache" type="boolean" default="false" />
		
		<cfset var i = '' />
		<cfset var plugin = '' />
		<cfset var pluginSites = {} />
		<cfset var pluginSources = '' />
		<cfset var source = '' />
		
		<cfset plugin = variables.transport.theApplication.managers.plugin.get('plugins') />
		
		<cfif arguments.refreshCache or not plugin.hasPluginSites()>
			<cfset pluginSources = variables.transport.theApplication.managers.plugin.get('plugins').getPluginSources() />
			
			<!--- Retrieve the current update URL for plugins --->
			<cfloop from="1" to="#arrayLen(pluginSources)#" index="i">
				<cfhttp method="get" url="#pluginSources[i].sourceUrl#" result="source" />
				
				<cfset pluginSites = variables.extend(pluginSites, deserializeJson(source.fileContent)) />
			</cfloop>
			
			<cfset plugin.setPluginSites(pluginSites) />
		<cfelse>
			<cfset pluginSites = plugin.getPluginSites() />
		</cfif>
		
		<cfreturn pluginSites />
	</cffunction>
</cfcomponent>
