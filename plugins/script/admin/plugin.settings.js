require([ 'jquery' ], function(jQuery) {
	(function($){
		$(function() {
			if(JSON.stringify) {
				$('.form .element.settings textarea').change(function() {
					var element = $(this);
					var value = $.trim(element.val());
					
					if(!value.length) {
						value = '{}';
					}
					
					try{
						element.val(JSON.stringify(JSON.parse(value), null, "\t"));
					} catch(e) {
						if(window.console) {
							window.console.error(e);
						}
					}
				}).change();
			}
		});
	}(jQuery));
});
