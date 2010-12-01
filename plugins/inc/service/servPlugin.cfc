<cfcomponent extends="algid.inc.resource.base.service" output="false">
	<cffunction name="getPlugins" access="public" returntype="query" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		<cfargument name="options" type="struct" default="#{}#" />
		
		<cfset var app = '' />
		<cfset var currThreads = '' />
		<cfset var i = '' />
		<cfset var plugin = '' />
		<cfset var plugins = '' />
		<cfset var randomPrefix = 'p-' & left(createUUID(), 8) & '-' />
		<cfset var results = '' />
		<cfset var useThreaded = false />
		
		<cfparam name="arguments.filter.orderBy" default="" />
		<cfparam name="arguments.filter.search" default="" />
		<cfparam name="arguments.options.checkForUpdates" default="false" />
		
		<cfset app = variables.transport.theApplication.managers.singleton.getApplication() />
		
		<cfset plugins = app.getPlugins() />
		<cfset useThreaded = app.getUseThreaded() />
		
		<cfset results = queryNew('key,plugin,versionCurrent,versionAvailable') />
		
		<cfloop from="1" to="#arrayLen(plugins)#" index="i">
			<cfset plugin = variables.transport.theApplication.managers.plugin.get(plugins[i]) />
			
			<cfset queryAddRow(results) />
			
			<cfset querySetCell(results, 'key', plugin.getKey()) />
			<cfset querySetCell(results, 'plugin', plugin.getPlugin()) />
			<cfset querySetCell(results, 'versionCurrent', plugin.getVersion()) />
		</cfloop>
		
		<!--- Check against the update sources to see if there is an update available. --->
		<cfif arguments.options.checkForUpdates>
			<cfloop from="1" to="#arrayLen(plugins)#" index="i">
				<cfset plugin = plugins[i] />
				
				<cfif useThreaded>
					<!--- Use a separate thread to read each check --->
					<cfthread action="run" name="#randomPrefix##i#" plugin="#plugin#" results="#results#" index="#i#">
						<cfset querySetCell(attributes.results, 'versionAvailable', '1.0.0', attributes.index) />
					</cfthread>
					
					<cfset currThreads = listAppend(currThreads, '#randomPrefix##i#') />
				<cfelse>
					<cfset querySetCell(results, 'versionAvailable', '1.0.1', i) />
				</cfif>
			</cfloop>
			
			<!--- Join the threads so we don't return prematurely --->
			<cfif useThreaded>
				<cfthread action="join" name="#currThreads#" timeout="500" />
				
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
</cfcomponent>
