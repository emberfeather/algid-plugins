<cfcomponent extends="algid.inc.resource.base.view" output="false">
	<cffunction name="datagrid" access="public" returntype="string" output="false">
		<cfargument name="data" type="any" required="true" />
		<cfargument name="options" type="struct" default="#{}#" />
		
		<cfset var datagrid = '' />
		<cfset var i18n = '' />
		<cfset var timeago = '' />
		
		<cfparam name="arguments.options.showVersionAvailable" default="false" />
		<cfparam name="arguments.options.showInstall" default="false" />
		<cfparam name="arguments.options.showUpdate" default="false" />
		
		<cfset arguments.options.theURL = variables.transport.theRequest.managers.singleton.getURL() />
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset datagrid = variables.transport.theApplication.factories.transient.getDatagrid(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset datagrid.addBundle('plugins/plugins/i18n/inc/view', 'viewPlugin') />
		
		<cfset datagrid.addColumn({
			key = 'plugin',
			label = 'plugin',
			link = {
				'plugin' = 'key',
				'_base' = '/admin/plugin'
			}
		}) />
		
		<cfset datagrid.addColumn({
			key = 'versionCurrent',
			label = 'versionCurrent'
		}) />
		
		<cfif arguments.options.showVersionAvailable>
			<cfset datagrid.addColumn({
				key = 'versionAvailable',
				label = 'versionAvailable'
			}) />
		</cfif>
		
		<cfif arguments.options.showInstall>
			<cfset datagrid.addColumn({
				class = 'phantom align-right width-min',
				value = [ 'install' ],
				link = {
					'plugin' = 'key',
					'_base' = '/admin/plugin/install'
				},
				title = 'plugin'
			}) />
		</cfif>
		
		<cfif arguments.options.showUpdate>
			<cfset datagrid.addColumn({
				class = 'phantom align-right width-min',
				value = [ 'update' ],
				link = {
					'plugin' = 'key',
					'_base' = '/admin/plugin/update'
				},
				title = 'plugin'
			}) />
		</cfif>
		
		<cfreturn datagrid.toHTML( arguments.data, arguments.options ) />
	</cffunction>
	
	<cffunction name="datagridSource" access="public" returntype="string" output="false">
		<cfargument name="data" type="any" required="true" />
		<cfargument name="options" type="struct" default="#{}#" />
		
		<cfset var datagrid = '' />
		<cfset var i18n = '' />
		<cfset var timeago = '' />
		
		<cfset arguments.options.theURL = variables.transport.theRequest.managers.singleton.getURL() />
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset datagrid = variables.transport.theApplication.factories.transient.getDatagrid(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset datagrid.addBundle('plugins/plugins/i18n/inc/view', 'viewPlugin') />
		
		<cfset datagrid.addColumn({
			key = 'name',
			label = 'sourceName'
		}) />
		
		<cfset datagrid.addColumn({
			key = 'sourceUrl',
			label = 'sourceUrl'
		}) />
		
		<cfreturn datagrid.toHTML( arguments.data, arguments.options ) />
	</cffunction>
	
	<cffunction name="edit" access="public" returntype="string" output="false">
		<cfargument name="settings" type="string" required="true" />
		
		<cfset var i18n = '' />
		<cfset var theForm = '' />
		<cfset var theURL = '' />
		
		<cfset i18n = variables.transport.theApplication.managers.singleton.getI18N() />
		<cfset theURL = variables.transport.theRequest.managers.singleton.getUrl() />
		<cfset theForm = variables.transport.theApplication.factories.transient.getForm('plugin', i18n) />
		
		<!--- Add the resource bundle for the view --->
		<cfset theForm.addBundle('plugins/plugins/i18n/inc/view', 'viewPlugin') />
		
		<cfset theForm.addElement('textarea', {
			name = "settings",
			label = "settings",
			elementClass = "tall",
			value = arguments.settings
		}) />
		
		<cfreturn theForm.toHTML(theURL.get()) />
	</cffunction>
	
	<cffunction name="filterActive" access="public" returntype="string" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<cfset var filterActive = '' />
		<cfset var options = '' />
		<cfset var results = '' />
		
		<cfset filterActive = variables.transport.theApplication.factories.transient.getFilterActive(variables.transport.theApplication.managers.singleton.getI18N()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset filterActive.addBundle('plugins/plugins/i18n/inc/view', 'viewPlugin') />
		
		<cfreturn filterActive.toHTML(arguments.filter, variables.transport.theRequest.managers.singleton.getURL()) />
	</cffunction>
	
	<cffunction name="filter" access="public" returntype="string" output="false">
		<cfargument name="values" type="struct" default="#{}#" />
		
		<cfset var filter = '' />
		<cfset var options = '' />
		
		<cfset filter = variables.transport.theApplication.factories.transient.getFilterVertical(variables.transport.theApplication.managers.singleton.getI18N()) />
		
		<!--- Add the resource bundle for the view --->
		<cfset filter.addBundle('plugins/plugins/i18n/inc/view', 'viewPlugin') />
		
		<!--- Search --->
		<cfset filter.addFilter('search') />
		
		<cfreturn filter.toHTML(variables.transport.theRequest.managers.singleton.getURL(), values) />
	</cffunction>
</cfcomponent>
