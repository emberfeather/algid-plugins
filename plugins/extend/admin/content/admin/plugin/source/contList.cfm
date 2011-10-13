<cfset viewPlugin = views.get('plugins', 'plugin') />

<cfset sources = servPlugin.getPluginSources() />

<cfset paginate = variables.transport.theApplication.factories.transient.getPaginate(arrayLen(sources), session.numPerPage, theURL.searchID('onPage')) />

<cfoutput>#viewMaster.datagrid(transport, sources, viewPlugin, paginate, {}, { function: 'datagridSource' })#</cfoutput>
