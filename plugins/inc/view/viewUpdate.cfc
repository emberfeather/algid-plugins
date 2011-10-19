component extends="algid.inc.resource.base.view" {
	public string function datagrid(required any data, struct options = {}) {
		arguments.options.theURL = variables.transport.theRequest.managers.singleton.getURL();
		local.i18n = variables.transport.theApplication.managers.singleton.getI18N();
		local.datagrid = variables.transport.theApplication.factories.transient.getDatagrid(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale());
		
		local.datagrid.addBundle('plugins/plugins/i18n/inc/view', 'viewPlugin');
		
		local.datagrid.addColumn({
			key = 'name',
			label = 'sourceName'
		});
		
		local.datagrid.addColumn({
			key = 'sourceUrl',
			label = 'sourceUrl',
			format = {
				'url': true
			}
		});
		
		return datagrid.toHTML( arguments.data, arguments.options );
	}
	
	public string function execute(required any updates, struct options = {}) {
		local.theUrl = variables.transport.theRequest.managers.singleton.getURL();
		arguments.options.theURL = local.theUrl;
		local.i18n = variables.transport.theApplication.managers.singleton.getI18N();
		local.locale = variables.transport.theSession.managers.singleton.getSession().getLocale();
		
		local.theForm = variables.transport.theApplication.factories.transient.getForm('executeUpdate', local.i18n, local.locale);
		local.theForm.addBundle('plugins/plugins/i18n/inc/view', 'viewUpdate');
		
		// Separate out the plugins and projects for the listing
		local.plugins = [];
		local.projects = [];
		local.keys = listToArray(structKeyList(arguments.updates));
		arraySort(local.keys, 'text');
		
		for(local.i = 1; local.i <= arrayLen(local.keys); local.i++) {
			if(arguments.updates[local.keys[local.i]].isPlugin) {
				arrayAppend(local.plugins, arguments.updates[local.keys[local.i]]);
			} else {
				arrayAppend(local.projects, arguments.updates[local.keys[local.i]]);
			}
		}
		
		// Plugins
		local.datagrid = variables.transport.theApplication.factories.transient.getDatagrid(local.i18n, local.locale);
		local.datagrid.addBundle('plugins/plugins/i18n/inc/view', 'viewUpdate');
		
		local.datagrid.addColumn({
			key = 'title',
			label = 'plugins'
		});
		
		local.datagrid.addColumn({
			key = 'version',
			label = 'version'
		});
		
		// Make sure that the datagrid can use the form
		local.datagrid.setForm(local.theForm);
		
		local.theForm.addElement('datagrid', {
			name = "plugins",
			label = "plugins",
			value = local.plugins,
			datagrid = local.datagrid
		});
		
		// Plugins
		local.datagrid = variables.transport.theApplication.factories.transient.getDatagrid(local.i18n, local.locale);
		local.datagrid.addBundle('plugins/plugins/i18n/inc/view', 'viewUpdate');
		
		local.datagrid.addColumn({
			key = 'title',
			label = 'projects'
		});
		
		local.datagrid.addColumn({
			key = 'version',
			label = 'version'
		});
		
		// Make sure that the datagrid can use the form
		local.datagrid.setForm(local.theForm);
		
		local.theForm.addElement('datagrid', {
			name = "projects",
			label = "projects",
			value = local.projects,
			datagrid = local.datagrid
		});
		
		local.theForm.addElement('password', {
			name = 'webAdminPassword',
			label = 'webAdminPassword',
			required = true,
			value = ''
		});
		
		return local.theForm.toHTML(local.theURL.get(), { submit: 'executeUpdate' });
	}
	
	public string function updateUrl(struct request) {
		local.i18n = variables.transport.theApplication.managers.singleton.getI18N();
		local.theURL = variables.transport.theRequest.managers.singleton.getUrl();
		local.theForm = variables.transport.theApplication.factories.transient.getForm('updateUrl', local.i18n);
		
		// Add the resource bundle for the view
		local.theForm.addBundle('plugins/plugins/i18n/inc/view', 'viewUpdate');
		
		local.theForm.addElement('text', {
			name = "updateUrl",
			label = "updateUrl",
			value = ( structKeyExists(arguments.request, 'updateUrl') ? arguments.request.updateUrl : '' )
		});
		
		return local.theForm.toHTML(local.theURL.get());
	}
	
	public string function upload() {
		var i18n = '';
		var theForm = '';
		var theURL = '';
		
		i18n = variables.transport.theApplication.managers.singleton.getI18N();
		theURL = variables.transport.theRequest.managers.singleton.getUrl();
		theForm = variables.transport.theApplication.factories.transient.getForm('pluginUpload', i18n);
		
		// Add the resource bundle for the view
		theForm.addBundle('plugins/plugins/i18n/inc/view', 'viewUpdate');
		
		theForm.addElement('file', {
			name = "archiveFile",
			class = "allowDuplication",
			label = "archiveFile"
		});
		
		return theForm.toHTML(theURL.get());
	}
}
