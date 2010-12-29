component extends="algid.inc.resource.base.view" {
	public string function datagrid(required any data, struct options = {}) {
		var datagrid = ''
		var i18n = ''
		
		arguments.options.theURL = variables.transport.theRequest.managers.singleton.getURL();
		i18n = variables.transport.theApplication.managers.singleton.getI18N()
		datagrid = variables.transport.theApplication.factories.transient.getDatagrid(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale())
		
		// Add the resource bundle for the view
		datagrid.addBundle('plugins/plugins/i18n/inc/view', 'viewPlugin');
		
		datagrid.addColumn({
			key = 'title',
			label = 'plugin'
		});
		
		datagrid.addColumn({
			key = 'version',
			label = 'version'
		});
		
		return datagrid.toHTML( arguments.data, arguments.options );
	}
	
	public string function updateUrl(struct request) {
		var i18n = '';
		var theForm = '';
		var theURL = '';
		
		i18n = variables.transport.theApplication.managers.singleton.getI18N();
		theURL = variables.transport.theRequest.managers.singleton.getUrl();
		theForm = variables.transport.theApplication.factories.transient.getFormStandard('updateUrl', i18n);
		
		// Add the resource bundle for the view
		theForm.addBundle('plugins/plugins/i18n/inc/view', 'viewUpdate');
		
		theForm.addElement('text', {
			name = "updateUrl",
			label = "updateUrl",
			value = ( structKeyExists(arguments.request, 'updateUrl') ? arguments.request.updateUrl : '' )
		});
		
		return theForm.toHTML(theURL.get());
	}
	
	public string function upload(struct request) {
		var i18n = '';
		var theForm = '';
		var theURL = '';
		
		i18n = variables.transport.theApplication.managers.singleton.getI18N();
		theURL = variables.transport.theRequest.managers.singleton.getUrl();
		theForm = variables.transport.theApplication.factories.transient.getFormStandard('pluginUpload', i18n);
		
		// Add the resource bundle for the view
		theForm.addBundle('plugins/plugins/i18n/inc/view', 'viewUpdate');
		
		theForm.addElement('file', {
			name = "archiveFile",
			label = "archiveFile",
			value = ( structKeyExists(arguments.request, 'archiveFile') ? arguments.request.archiveFile : '' )
		});
		
		return theForm.toHTML(theURL.get());
	}
}
