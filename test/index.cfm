<cfset project = listLast(getDirectoryFromPath(expandPath('../')), '/') />
<cfset basePath = '/test' />
<cfset paths = '/test/inc' />
<cfset title = 'unit tests' />
<cfset filter = '*.cfc' />
<cfset isUnitTest = true />

<!--- Allow for a url var to override path to preview template --->
<cfparam name="pathRoot" default="/c/" />

<cfinclude template="#pathRoot#preview/index.cfm" />
