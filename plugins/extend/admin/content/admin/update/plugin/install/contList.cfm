<!--- Output a listing of all the plugins --->
<cfset plugins = servPlugin.getPlugins( filter, { checkForUpdates: true, showInstalled: false, showNotInstalled: true, refreshCache: true } ) />

<cfset paginate = variables.transport.theApplication.factories.transient.getPaginate(plugins.recordcount, session.numPerPage, theURL.searchID('onPage')) />

<cfoutput>#viewMaster.datagrid(transport, plugins, viewPlugin, paginate, filter, { showInstall: not transport.theApplication.managers.singleton.getApplication().isProduction(), showVersionAvailable: true })#</cfoutput>
