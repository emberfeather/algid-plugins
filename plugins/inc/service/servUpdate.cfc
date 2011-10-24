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
		<cfset var info = '' />
		<cfset var updateManager = '' />
		<cfset var updateOrder = '' />
		<cfset var observer = '' />
		
		<!--- Get the event observer --->
		<cfset observer = getPluginObserver('plugins', 'update') />
		
		<cfset updateManager = variables.transport.theSession.managers.singleton.getUpdateManager() />
		
		<cfif updateManager.isEmpty()>
			<cfthrow type="validation" message="No updates marked" detail="No updates were marked for updating" />
		</cfif>
		
		<cfset observer.beforeUpdates(variables.transport) />
		
		<cfloop condition="not updateManager.isEmpty()">
			<cfset info = updateManager.pop() />
			
			<cfset observer.beforeUpdate(variables.transport, info) />
			
			<cftry>
				<cfset performUpdate(info) />
				
				<cfcatch type="any">
					<!--- Mark in update manager since it didn't complete successfully --->
					<cfset updateManager.mark(info) />
					
					<cfrethrow />
				</cfcatch>
			</cftry>
			
			<cfset observer.afterUpdate(variables.transport, info) />
		</cfloop>
		
		<cfset observer.afterUpdates(variables.transport) />
		
		<!--- Clear template cache --->
		<cfset pagePoolClear() />
	</cffunction>
	
	<cffunction name="getSources" access="public" returntype="array" output="false">
		<cfset local.plugin = variables.transport.theApplication.managers.plugin.get('plugins') />
		
		<cfreturn local.plugin.getSources() />
	</cffunction>
	
	<cffunction name="getUpdates" access="public" returntype="struct" output="false">
		<cfset var updateManager = '' />
		
		<cfset updateManager = variables.transport.theSession.managers.singleton.getUpdateManager() />
		
		<cfreturn updateManager.get() />
	</cffunction>
	
	<cffunction name="markForUpdate" access="public" returntype="void" output="false">
		<cfargument name="info" type="any" required="true" />
		
		<!--- Ensure argument format --->
		<cfif not isArray(arguments.info)>
			<cfset arguments.info = [ arguments.info ] />
		</cfif>
		
		<cfset local.observer = getPluginObserver('plugins', 'update') />
		
		<cfset local.observer.beforeMark(variables.transport, arguments.info) />
		
		<cfset local.updateManager = variables.transport.theSession.managers.singleton.getUpdateManager() />
		<cfset local.updateManager.mark(arguments.info) />
		
		<cfset local.observer.afterMark(variables.transport, arguments.info) />
	</cffunction>
	
	<cffunction name="performUpdate" access="private" returntype="void" output="false">
		<cfargument name="info" type="struct" required="true" />
		<cfargument name="isPlugin" type="boolean" default="true" />
		
		<cfset local.fileStamp = dateFormat(now(), 'yyyy-mm-dd') & '-' & timeformat(now(), 'HH:mm:ss') />
		
		<cfset local.basePath = (arguments.isPlugin ? '/plugins/' : '/') & arguments.info.key />
		
		<cfset local.sourceBase = arguments.info.archiveRoot & arguments.info.key />
		<cfset local.sourceBaseLen = len(local.sourceBase) />
		
		<!--- Retrieve the list of files --->
		<cfdirectory action="list" directory="#local.sourceBase#" name="local.results" recurse="true" type="file" />
		
		<cfif not local.results.recordCount>
			<cfthrow type="validation" message="Archive did not contain files" detail="The archive file for `#arguments.info.key#` did not contain any files" />
		</cfif>
		
		<!--- Backup the existing release --->
		<cfif directoryExists(local.basePath)>
			<cfset directoryRename(
				local.basePath,
				variables.transport.theApplication.managers.plugin.getPlugins().getStoragePath() & '/backups/' & arguments.info.key & '-' & local.fileStamp
			) />
		</cfif>
		
		<cfif not directoryExists(local.basePath)>
			<cfset directoryCreate(local.basePath) />
		</cfif>
		
		<!--- Copy all the files from the archive into the application --->
		<cfloop query="local.results">
			<cfset local.filePath = local.basePath />
			
			<cfif len(local.results.directory) gt local.sourceBaseLen>
				<cfset local.filePath &= right(local.results.directory, len(local.results.directory) - local.sourceBaseLen) />
			</cfif>
			
			<cfif not directoryExists(local.filePath)>
				<cfset directoryCreate(local.filePath) />
			</cfif>
			
			<cfset fileCopy(local.results.directory & '/' & local.results.name, local.filePath & '/' & local.results.name) />
		</cfloop>
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
		
		<cfset archivePath = variables.transport.theApplication.managers.plugin.getPlugins().getStoragePath() & '/downloads' />
		<cfset archiveFile = archiveInfo.key & '-' & archiveInfo.version & determineExtension(archiveInfo.archive) />
		
		<!--- Retrieve if not already downloaded --->
		<cfif not fileExists(archivePath & '/' & archiveFile)>
			<!--- Download the archive from the update site --->
			<cfhttp url="#archiveInfo.archive#" method="get" file="#archiveFile#" path="#archivePath#" getAsBinary="true" />
		</cfif>
		
		<cfset archiveInfo = retrieveInfoFromArchive(expandPath(archivePath), archiveFile) />
		
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
				<cfthrow type="validation" message="Cannot find update site url for #arguments.plugins[i]#" detail="No update site url found for the #arguments.plugins[i]# plugin" />
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
		
		<cfif right(arguments.archivePath, 1) neq '/'>
			<cfset arguments.archivePath &= '/' />
		</cfif>
		
		<!--- Retrieve the version file information --->
		<cfdirectory action="list" directory="#determineProtocol(arguments.archiveFile)##arguments.archivePath##arguments.archiveFile#" name="results" recurse="true" filter="version.json" />
		
		<cfif not results.recordCount>
			<cfset fileDelete(arguments.archivePath & '/' & arguments.archiveFile) />
			
			<cfthrow type="validation" message="No version file found in archive" detail="The version.json file was not found in the archive" />
		</cfif>
		
		<!--- Read out the version information --->
		<cfset raw = fileRead(results.directory & '/version.json') />
		
		<cfif not isJson(raw)>
			<cfset fileDelete(arguments.archivePath & '/' & arguments.archiveFile) />
			
			<cfthrow type="validation" message="Version file not in correct format" detail="The version.json file not a JSON formatted file" />
		</cfif>
		
		<cfset archiveInfo = deserializeJson(raw) />
		
		<!--- Get the archive information for installing --->
		<cfset archiveInfo['archiveRoot'] = results.directory & '/' />
		<cfset archiveInfo['archivePath'] = arguments.archivePath />
		<cfset archiveInfo['archiveFile'] = arguments.archiveFile />
		
		<!--- TODO Remove when no longer has the !// --->
		<cfset archiveInfo['archiveRoot'] = replace(archiveInfo['archiveRoot'], '!//', '!/') />
		
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
