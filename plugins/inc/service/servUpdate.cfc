<cfcomponent extends="algid.inc.resource.base.service" output="false">
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
		<cfargument name="archiveFile" type="string" required="true" />
		
		<!--- TODO Check the prerequisites for the release --->
		<!--- TODO Backup the existing release --->
		<!--- TODO Copy over existing files --->
		<!--- TODO Clear trusted template cache --->
		<!--- TODO Reinitialize application --->
	</cffunction>
	
	<cffunction name="performUpgradeFromArchive" access="private" returntype="void" output="false">
		<cfargument name="archiveFile" type="string" required="true" />
		
		<cfif !fileExists(arguments.archiveFile)>
			<cfthrow type="validation" message="Plugin archive file does not exist" />
		</cfif>
		
		<cfset performUpgrade('tar://' & arguments.archiveFile) />
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
		
		<cfset performUpgradeFromArchive(expandPath(archivePath & '/' & archiveFile)) />
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
		
		<cfset performUpgradeFromArchive(arguments.archiveFile) />
		
		<!--- After Upload Event --->
		<cfset observer.afterUpload(variables.transport, arguments.currUser, arguments.archiveFile) />
	</cffunction>
</cfcomponent>
