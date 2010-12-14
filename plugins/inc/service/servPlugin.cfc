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
		<cfset var pluginUrls = '' />
		<cfset var randomPrefix = 'p-' & left(createUUID(), 8) & '-' />
		<cfset var results = '' />
		<cfset var tempObj = '' />
		<cfset var useThreaded = false />
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
		
		<cfset useThreaded = app.getUseThreaded() />
		
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
	
	<!---
		Install from the update url
	--->
	<cffunction name="installPlugin" access="public" returntype="void" output="false">
		<cfargument name="currUser" type="component" required="true" />
		<cfargument name="pluginUrl" type="string" required="true" />
		
		<cfset var observer = '' />
		
		<!--- Check to make sure that we are not in production mode --->
		<cfif variables.transport.theApplication.managers.singleton.getApplication().isProduction()>
			<cfthrow type="validation" message="Cannot install plugin while running in production mode" detail="Change environment to the maintenance mode to intall a plugin" />
		</cfif>
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('plugins', 'plugin') />
		
		<!--- Before Install Event --->
		<cfset observer.beforeInstall(variables.transport, arguments.currUser, arguments.pluginUrl) />
		
		<!--- Use the plugin url for the plugin to update --->
		<cfset performUpgradeFromUrl(arguments.pluginUrl) />
		
		<!--- After Install Event --->
		<cfset observer.afterInstall(variables.transport, arguments.currUser, arguments.pluginUrl) />
	</cffunction>
	
	<!---
		Does the actual heavy lifting when updating or installing
	--->
	<cffunction name="performUpgrade" access="private" returntype="void" output="false">
		<cfargument name="updateDirectory" type="string" required="true" />
		
		<!--- TODO Check the prerequisites for the release --->
		<!--- TODO Backup the existing release --->
		<!--- TODO Copy over existing files --->
		<!--- TODO Clear trusted template cache --->
		<!--- TODO Reinitialize application --->
	</cffunction>
	
	<cffunction name="performUpgradeFromArchive" access="private" returntype="void" output="false">
		<cfargument name="archivePath" type="string" required="true" />
		<cfargument name="archiveFile" type="string" required="true" />
		
		<cfif !fileExists(arguments.archivePath & '/' & arguments.archiveFile)>
			<cfthrow type="validation" message="Plugin archive file does not exist" />
		</cfif>
		
		<!--- TODO Unarchive the release file to a temporary directory --->
		
		<cfset performUpgrade() />
	</cffunction>
	
	<cffunction name="performUpgradeFromUrl" access="private" returntype="void" output="false">
		<cfargument name="updateUrl" type="string" required="true" />
		
		<cfset var archiveFile = '' />
		<cfset var archivePath = '' />
		<cfset var updateInfo = '' />
		<cfset var results = '' />
		
		<!--- Set a longer timeout for the request --->
		<cfsetting requesttimeout="300" />
		
		<!--- Download the plugin information --->
		<cfhttp url="#arguments.updateUrl#" result="results" />
		
		<cfif results.status_code neq 200>
			<cfthrow type="validation" message="Unable to retrieve update information" detail="The update url `#arguments.updateUrl#` returned a #results.statuscode#" />
		</cfif>
		
		<cfif not isJson(results.fileContent)>
			<cfthrow type="validation" message="Update site not formatted correctly" detail="The update url `#arguments.updateUrl#` returned a value that was not formatted as JSON" />
		</cfif>
		
		<cfset updateInfo = deserializeJson(results.fileContent) />
		
		<cfif not structKeyExists(updateInfo, 'archive')>
			<cfthrow type="validation" message="Update site did not contain an archive" detail="The update url `#arguments.updateUrl#` did not contain an archive" />
		</cfif>
		
		<cfset archivePath = variables.transport.theApplication.managers.plugin.getPlugins().getStoragePath() />
		<cfset archiveFile = '#updateInfo.key#-#updateInfo.version#.tar.gz' />
		
		<!--- Cache if already retrieved --->
		<cfif not fileExists(archivePath & '/' & archiveFile)>
			<!--- Download the archive from the update site --->
			<cfhttp url="#updateInfo.archive#" method="get" file="#archiveFile#" path="#archivePath#" />
		</cfif>
		
		<cfset performUpgradeFromArchive(archivePath, archiveFile) />
	</cffunction>
	
	<!---
		Upgrade from the update url
	--->
	<cffunction name="updatePlugin" access="public" returntype="void" output="false">
		<cfargument name="currUser" type="component" required="true" />
		<cfargument name="plugin" type="string" required="true" />
		
		<cfset var observer = '' />
		<cfset var pluginSites = '' />
		
		<!--- Check to make sure that we are not in production mode --->
		<cfif variables.transport.theApplication.managers.singleton.getApplication().isProduction()>
			<cfthrow type="validation" message="Cannot update plugin while running in production mode" detail="Change environment to the maintenance mode to update a plugin" />
		</cfif>
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('plugins', 'plugin') />
		
		<!--- Use the update url for the plugin to update --->
		<cfset pluginSites = getPluginSites() />
		
		<cfif not structKeyExists(pluginSites.plugins, arguments.plugin) or not structKeyExists(pluginSites.plugins[arguments.plugin], 'versionUrl')>
			<cfthrow type="validation" message="Cannot find update site url" detail="No update site url found for the #arguments.plugin# plugin" />
		</cfif>
		
		<!--- Before Update Event --->
		<cfset observer.beforeUpdate(variables.transport, arguments.currUser, arguments.plugin) />
		
		<cfset performUpgradeFromUrl(pluginSites.plugins[arguments.plugin].versionUrl) />
		
		<!--- After Update Event --->
		<cfset observer.afterUpdate(variables.transport, arguments.currUser, arguments.plugin) />
	</cffunction>
	
	<!---
		Install from the uploaded archive
	--->
	<cffunction name="uploadPlugin" access="public" returntype="void" output="false">
		<cfargument name="currUser" type="component" required="true" />
		<cfargument name="archiveFile" type="string" required="true" />
		
		<cfset var observer = '' />
		
		<!--- Check to make sure that we are not in production mode --->
		<cfif variables.transport.theApplication.managers.singleton.getApplication().isProduction()>
			<cfthrow type="validation" message="Cannot upload plugin while running in production mode" detail="Change environment to the maintenance mode to upload a plugin" />
		</cfif>
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('plugins', 'plugin') />
		
		<!--- Before Upload Event --->
		<cfset observer.beforeUpload(variables.transport, arguments.currUser, arguments.archiveFile) />
		
		<cfset performUpgradeFromFile(arguments.archiveFile) />
		
		<!--- After Upload Event --->
		<cfset observer.afterUpload(variables.transport, arguments.currUser, arguments.archiveFile) />
	</cffunction>
</cfcomponent>
