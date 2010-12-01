<!--- Output a listing of all the plugins --->
<cfset plugins = servPlugin.getPlugins( filter, { checkForUpdates: true, refreshCache: theUrl.searchBoolean('refreshCache') } ) />

<!--- Remove the refesh after it has been completed --->
<cfset theUrl.remove('refreshCache') />

<cfset paginate = variables.transport.theApplication.factories.transient.getPaginate(plugins.recordcount, session.numPerPage, theURL.searchID('onPage')) />

<cfoutput>#viewMaster.datagrid(transport, plugins, viewPlugin, paginate, filter, { showVersionAvailable: true, showUpdate: true })#</cfoutput>
