<cfcomponent extends="algid.inc.resource.base.service" output="false">
	<cffunction name="getPlugins" access="public" returntype="query" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<cfset var plugin = '' />
		<cfset var plugins = '' />
		<cfset var results = '' />
		
		<cfparam name="arguments.filter.orderBy" default="" />
		<cfparam name="arguments.filter.search" default="" />
		
		<cfset results = queryNew('plugin,versionCurrent') />
		
		<cfloop array="#variables.transport.theApplication.managers.singleton.getApplication().getPlugins()#" index="plugin">
			<cfset queryAddRow(results) />
			
			<cfset querySetCell(results, 'plugin', plugin) />
			<cfset querySetCell(results, 'versionCurrent', variables.transport.theApplication.managers.plugin.get(plugin).getVersion()) />
		</cfloop>
		
		<cfquery name="results" dbtype="query">
			SELECT plugin, versionCurrent
			FROM results
			WHERE 1 = 1
			
			<cfif arguments.filter.search neq ''>
				AND plugin LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.filter.search#%" />
			</cfif>
			
			ORDER BY
			<cfswitch expression="#arguments.filter.orderBy#">
				<cfdefaultcase>
					plugin DESC
				</cfdefaultcase>
			</cfswitch>
		</cfquery>
		
		<cfreturn results />
	</cffunction>
</cfcomponent>
