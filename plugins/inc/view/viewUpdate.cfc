component extends="algid.inc.resource.base.view" {
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
