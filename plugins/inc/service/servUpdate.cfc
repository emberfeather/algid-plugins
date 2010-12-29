<cfcomponent extends="algid.inc.resource.base.service" output="false">
	<cffunction name="init" access="public" returntype="component" output="false">
		<cfargument name="transport" type="struct" required="true" />
		
		<cfset super.init(argumentCollection = arguments) />
		
		<cfif not variables.transport.theSession.managers.singleton.hasUpdateManager()>
			<cfset variables.transport.theSession.managers.singleton.setUpdateManager( variables.transport.theApplication.factories.transient.getUpdateManager() ) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="determineExtension" access="public" returntype="string" output="false">
		<cfargument name="filename" type="string" required="true" />
		
		<!--- Determine correct extension the archive by filename --->
		<cfif right(arguments.filename, 4) eq '.zip'>
			<cfreturn '.zip' />
		<cfelseif right(arguments.filename, 4) eq '.tar'>
			<cfreturn '.tar' />
		<cfelseif right(arguments.filename, 7) eq '.tar.gz'>
			<cfreturn '.tar.gz' />
		</cfif>
		
		<!--- If the filename is a url check if it is a specific type --->
		<cfif findNoCase('/zipball/', arguments.filename)>
			<cfreturn '.zip' />
		<cfelseif findNoCase('/tarball/', arguments.filename)>
			<cfreturn '.tar.gz' />
		</cfif>
		
		<cfreturn '' />
	</cffunction>
	
	<cffunction name="determineProtocol" access="public" returntype="string" output="false">
		<cfargument name="filename" type="string" required="true" />
		
		<cfset var protocol = '' />
		
		<!--- Determine correct protocol for accessing archive --->
		<cfif right(arguments.filename, 4) eq '.zip'>
			<cfset protocol = 'zip://' />
		<cfelseif right(arguments.filename, 4) eq '.tar'>
			<cfset protocol = 'tar://' />
		<cfelseif right(arguments.filename, 7) eq '.tar.gz'>
			<cfset protocol = 'tgz://' />
		</cfif>
		
		<cfreturn protocol />
	</cffunction>
	
	<cffunction name="executeUpdates" access="public" returntype="void" output="false">
		<cfargument name="request" type="struct" required="true" />
		
		<cfset var pluginInfo = '' />
		<cfset var updateManager = '' />
		<cfset var updateOrder = '' />
		
		<cfset updateManager = variables.transport.theSession.managers.singleton.getUpdateManager() />
		
		<cfif updateManager.isEmpty()>
			<cfthrow type="validation" message="No plugins updates marked" detail="No plugins were marked for updating" />
		</cfif>
		
		<cfloop condition="not updateManager.isEmpty()">
			<cfset pluginInfo = updateManager.pop() />
			
			<cftry>
				<cfcatch type="any">
					<!--- Mark in update manager since it didn't complete successfully --->
					<cfset updateManager.mark(pluginInfo) />
					
					<cfrethrow />
				</cfcatch>
			</cftry>
		</cfloop>
	</cffunction>
	
	<cffunction name="getUpdates" access="public" returntype="struct" output="false">
		<cfset var updateManager = '' />
		
		<cfset updateManager = variables.transport.theSession.managers.singleton.getUpdateManager() />
		
		<cfreturn updateManager.get() />
	</cffunction>
	
	<cffunction name="markForUpdate" access="public" returntype="void" output="false">
		<cfargument name="pluginInfo" type="any" required="true" />
		
		<cfset var updateManager = '' />
		
		<!--- Ensure argument format --->
		<cfif not isArray(arguments.pluginInfo)>
			<cfset arguments.pluginInfo = [ arguments.pluginInfo ] />
		</cfif>
		
		<cfset updateManager = variables.transport.theSession.managers.singleton.getUpdateManager() />
		
		<cfset updateManager.mark(arguments.pluginInfo) />
	</cffunction>
	
	<cffunction name="performUpgrade" access="private" returntype="void" output="false">
		<cfargument name="archivePath" type="string" required="true" />
		<cfargument name="archiveFile" type="string" required="true" />
		
		<cfset var archiveInfo = {} />
		<cfset var i = '' />
		<cfset var installedPlugin = '' />
		<cfset var pluginInfo = '' />
		<cfset var raw = '' />
		<cfset var results = '' />
		<cfset var versions = '' />
		
		<cfset archiveInfo = retrieveInfoFromArchive(arguments.archivePath, arguments.archiveFile) />
		
		<!--- Read out the plugin information --->
		<cfset raw = fileRead(arguments.archivePath & archiveInfo.key & '/config/project.json.cfm') />
		
		<cfif not isJson(raw)>
			<cfthrow type="validation" message="Config file not in correct format" detail="The project.json.cfm file not a JSON formatted file" />
		</cfif>
		
		<cfset pluginInfo = deserializeJson(raw) />
		
		<!--- Check the prerequisites for the release --->
		<cfloop list="#structKeyList(pluginInfo.prerequisites)#" index="i">
			<cfif not variables.transport.theApplication.managers.plugin.has(i)>
				<cfthrow type="validation" message="Missing required plugin" detail="The '#i#' plugin is required as a prerequisite with a #pluginInfo.prerequisites[i]# version" />
			</cfif>
			
			<cfset versions = variables.transport.theApplication.managers.singleton.getVersions() />
			
			<cfset installedPlugin = variables.transport.theApplication.managers.plugin.get(i) />
			
			<cfif versions.compareVersions(installedPlugin.getVersion(), pluginInfo.prerequisites[i]) lt 0>
				<cfthrow type="validation" message="Plugin upgrade required" detail="The '#i#' plugin is required to be at least at version #pluginInfo.prerequisites[i]#" />
			</cfif>
		</cfloop>
		
		<!--- TODO Backup the existing release --->
		<!--- TODO Copy over existing files --->
		<!--- TODO Clear trusted template cache --->
		<!--- TODO Reinitialize application --->
		
		<!--- TODO Remove --->
		<cfdump var="#results#" />
		<cfdump var="#archiveInfo#" />
		<cfdump var="#pluginInfo#" />
		<cfabort />
	</cffunction>
	
	<cffunction name="retrieveArchive" access="public" returntype="struct" output="false">
		<cfargument name="updateUrl" type="string" required="true" />
		
		<cfset var archiveFile = '' />
		<cfset var archivePath = '' />
		<cfset var archiveInfo = '' />
		<cfset var results = '' />
		
		<!--- Set a longer timeout for the request --->
		<cfsetting requesttimeout="600" />
		
		<!--- Download the plugin information --->
		<cfhttp url="#arguments.updateUrl#" result="results" />
		
		<cfif results.status_code neq 200>
			<cfthrow type="validation" message="Unable to retrieve update information" detail="The update url `#arguments.updateUrl#` returned a #results.statuscode#" />
		</cfif>
		
		<cfif not isJson(results.fileContent)>
			<cfthrow type="validation" message="Update site not formatted correctly" detail="The update url `#arguments.updateUrl#` returned a value that was not formatted as JSON" />
		</cfif>
		
		<cfset archiveInfo = deserializeJson(results.fileContent) />
		
		<cfif not structKeyExists(archiveInfo, 'archive')>
			<cfthrow type="validation" message="Update site did not contain an archive" detail="The update url `#arguments.updateUrl#` did not contain an archive" />
		</cfif>
		
		<cfset archiveInfo['archivePath'] = variables.transport.theApplication.managers.plugin.getPlugins().getStoragePath() & '/downloads' />
		<cfset archiveInfo['archiveFile'] = archiveInfo.key & '-' & archiveInfo.version & determineExtension(archiveInfo.archive) />
		
		<!--- Retrieve if not already downloaded --->
		<cfif not fileExists(archiveInfo.archivePath & '/' & archiveInfo.archiveFile)>
			<!--- Download the archive from the update site --->
			<cfhttp url="#archiveInfo.archive#" method="get" file="#archiveInfo.archiveFile#" path="#archiveInfo.archivePath#" getAsBinary="true" />
		</cfif>
		
		<cfreturn archiveInfo />
	</cffunction>
	
	<cffunction name="retrieveArchives" access="public" returntype="array" output="false">
		<cfargument name="plugins" type="array" default="#[]#" />
		
		<cfset var i = '' />
		<cfset var pluginSites = '' />
		<cfset var results = [] />
		<cfset var servPlugin = '' />
		
		<cfset servPlugin = getService('plugins', 'plugin') />
		
		<!--- Use the update url for the plugin to update --->
		<cfset pluginSites = servPlugin.getPluginSites() />
		
		<!--- Allow for retrieving all plugins --->
		<cfif !arrayLen(arguments.plugins)>
			<cfset arguments.plugins = listToArray(structKeyList(pluginSites.plugins)) />
		</cfif>
		
		<cfloop from="1" to="#arrayLen(arguments.plugins)#" index="i">
			<cfif not structKeyExists(pluginSites.plugins, arguments.plugins[i]) or not structKeyExists(pluginSites.plugins[arguments.plugins[i]], 'versionUrl')>
				<cfthrow type="validation" message="Cannot find update site url" detail="No update site url found for the #arguments.plugins[i]# plugin" />
			</cfif>
			
			<cfset arrayAppend(results, retrieveArchive(pluginSites.plugins[arguments.plugins[i]].versionUrl)) />
		</cfloop>
		
		<cfreturn results />
	</cffunction>
	
	<cffunction name="retrieveInfoFromArchive" access="private" returntype="struct" output="false">
		<cfargument name="archivePath" type="string" required="true" />
		<cfargument name="archiveFile" type="string" required="true" />
		
		<cfset var archiveInfo = '' />
		<cfset var raw = '' />
		<cfset var results = '' />
		
		<!--- Retrieve the version file information --->
		<cfdirectory action="list" directory="#determineProtocol(arguments.archiveFile)##arguments.archivePath#/#arguments.archiveFile#" name="results" recurse="true" filter="version.json" />
		
		<cfif not results.recordCount>
			<cfthrow type="validation" message="No version file found in archive" detail="The version.json file was not found in the archive" />
		</cfif>
		
		<!--- Read out the version information --->
		<cfset raw = fileRead(results.directory & '/version.json') />
		
		<cfif not isJson(raw)>
			<cfthrow type="validation" message="Version file not in correct format" detail="The version.json file not a JSON formatted file" />
		</cfif>
		
		<cfset archiveInfo = deserializeJson(raw) />
		
		<!--- Get the archive information for installing --->
		<cfset archiveInfo['archiveRoot'] = results.directory & '/' />
		<cfset archiveInfo['archivePath'] = arguments.archivePath />
		<cfset archiveInfo['archiveFile'] = arguments.archiveFile />
		
		<cfreturn archiveInfo />
	</cffunction>
	
	<cffunction name="uploadArchive" access="public" returntype="struct" output="false">
		<cfargument name="uploadFile" type="string" required="true" />
		
		<cfset var updateInfo = '' />
		<cfset var uploadPath = '' />
		
		<cfset uploadPath = getDirectoryFromPath(arguments.uploadFile) />
		<cfset arguments.uploadFile = getFileFromPath(arguments.uploadFile) />
		
		<cfset updateInfo = retrieveInfoFromArchive(uploadPath, arguments.uploadFile) />
		
		<cfset updateInfo['archivePath'] = expandPath(variables.transport.theApplication.managers.plugin.getPlugins().getStoragePath() & '/downloads') />
		<cfset updateInfo['archiveFile'] = updateInfo.key & '-' & updateInfo.version & determineExtension(arguments.uploadFile) />
		
		<cfset fileMove(uploadPath & arguments.uploadFile, updateInfo.archivePath & '/' & updateInfo.archiveFile) />
		
		<!--- Refresh the update info to recapture the archiveRoot --->
		<cfset updateInfo = retrieveInfoFromArchive(updateInfo.archivePath, updateInfo.archiveFile) />
		
		<cfreturn updateInfo />
	</cffunction>
</cfcomponent>
