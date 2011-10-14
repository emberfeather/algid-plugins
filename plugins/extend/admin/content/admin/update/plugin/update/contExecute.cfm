<cfset viewPlugin = views.get('plugins', 'update') />

<!--- Output a listing of all the plugins --->
<cfset plugins = servUpdate.getUpdates() />

<!--- Remove the refesh after it has been completed --->
<cfset theUrl.remove('refreshCache') />

<cfset paginate = variables.transport.theApplication.factories.transient.getPaginate(structCount(plugins), session.numPerPage, theURL.searchID('onPage')) />

<cfoutput>#viewMaster.datagrid(transport, plugins, viewPlugin, paginate)#</cfoutput>
