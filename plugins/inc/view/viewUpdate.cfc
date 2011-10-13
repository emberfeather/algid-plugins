component extends="algid.inc.resource.base.view" {
	public string function datagrid(required any data, struct options = {}) {
		var datagrid = '';
		var executeForm = '';
		var html = '';
		var i18n = '';
		var theForm = '';
		var theUrl = '';
		
		theUrl = variables.transport.theRequest.managers.singleton.getURL();
		arguments.options.theURL = theUrl;
		i18n = variables.transport.theApplication.managers.singleton.getI18N();
		datagrid = variables.transport.theApplication.factories.transient.getDatagrid(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale());
		
		// Add the resource bundle for the view
		datagrid.addBundle('plugins/plugins/i18n/inc/view', 'viewPlugin');
		datagrid.addBundle('plugins/plugins/i18n/inc/view', 'viewUpdate');
		
		datagrid.addColumn({
			key = 'title',
			label = 'plugin'
		});
		
		datagrid.addColumn({
			key = 'version',
			label = 'version'
		});
		
		html = datagrid.toHTML( arguments.data, arguments.options );
		
		if( structCount(arguments.data) ) {
			theForm = variables.transport.theApplication.factories.transient.getForm('executeUpdate', i18n);
			
			// Add the resource bundle for the view
			theForm.addBundle('plugins/plugins/i18n/inc/view', 'viewUpdate');
			
			theForm.addElement('password', {
				name = 'webAdminPassword',
				label = 'webAdminPassword',
				required = true,
				value = ''
			});
			
			html &= theForm.toHTML(theURL.get(), { submit: 'executeUpdate' });
		}
		
		return html;
	}
	
	public string function updateUrl(struct request) {
		var i18n = '';
		var theForm = '';
		var theURL = '';
		
		i18n = variables.transport.theApplication.managers.singleton.getI18N();
		theURL = variables.transport.theRequest.managers.singleton.getUrl();
		theForm = variables.transport.theApplication.factories.transient.getForm('updateUrl', i18n);
		
		// Add the resource bundle for the view
		theForm.addBundle('plugins/plugins/i18n/inc/view', 'viewUpdate');
		
		theForm.addElement('text', {
			name = "updateUrl",
			label = "updateUrl",
			value = ( structKeyExists(arguments.request, 'updateUrl') ? arguments.request.updateUrl : '' )
		});
		
		return theForm.toHTML(theURL.get());
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
