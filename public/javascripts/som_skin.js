//SomSkin Javascript



//HierarchyNav
// -Apple Finder like navigation of heirachacal structures
// 


//Stack Interface
// -Stacked Sectons with headings and content
//


var StackInterface = Class.create();

StackInterface.prototype = {
  initialize: function() {
  }
}

var CollectionReceiver = Class.create();

CollectionReceiver.prototype = {
  initialize: function(id, options_for_droppables, url) {
    this.receiver = $(id);
    this.options_for_droppables = options_for_droppables;
    this.url = url;
    if (!(this.options_for_droppables.onDrop)) {
      this.options_for_droppables.onDrop = this.basic_drop_method();
    }
    Droppables.add(id, this.options_for_droppables);
  },

  basic_drop_method: function(id) {
    var url = this.url
    return function(element) {
      new Ajax.Request(url, {
        method: 'post',
	parameters: element.server_side_attributes,
        onSuccess: function(transport) {
	    eval(transport.responseText);
	  }
	});
    };
  }
}
