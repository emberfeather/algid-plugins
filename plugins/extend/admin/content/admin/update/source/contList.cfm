<cfset viewUpdate = views.get('plugins', 'update') />

<cfset sources = servUpdate.getSources() />

<cfset paginate = variables.transport.theApplication.factories.transient.getPaginate(arrayLen(sources), session.numPerPage, theURL.searchID('onPage')) />

<cfoutput>#viewMaster.datagrid(transport, sources, viewUpdate, paginate)#</cfoutput>
