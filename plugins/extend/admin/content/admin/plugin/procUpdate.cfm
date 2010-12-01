<!--- Redirect to the list page if no selection made --->
<cfif theUrl.searchUrl('plugin') eq ''>
	<cfset theURL.setRedirect('_base', '/admin/plugin/update/list') />
	<cfset theURL.redirectRedirect() />
</cfif>
