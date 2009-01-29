function SortableTable(table_element_id) {
  this.init(table_element_id);
}

function TableSortSpec(col_idx, td_element) {
  this.idx = col_idx;
  this.ele = td_element;
}

TableSortSpec.sortable_function = function(rows, idx) {
  var str_map_fun = function(item) {
    return(String(item.getElementsByTagName("td")[idx].innerHTML).stripTags());
  };
  var num_map_fun = function(item) {
    return(parseFloat(String(item.getElementsByTagName("td")[idx].innerHTML).stripTags().replace(/[,$%]/g, "")));
  };
  var td_vals = rows.map(str_map_fun);

  var val = null;
  var clean_str = null;

  var all_are_numeric = !td_vals.any(function(item) {
    clean_str = item.replace(/[,$%]/g, "");
      if ((/[^-]-/g).test(clean_str)) {
          return(true);
      }
    val = parseFloat(clean_str);
    return(isNaN(val));
  });
  if (all_are_numeric) {
    return(num_map_fun);
  }
  return(str_map_fun);
};

SortableTable.prototype = {
init : function(table_element_id) {
         this._t_element_id = table_element_id;
         this._columns = [];
         this.sortables = this._find_sortables($(table_element_id));
         this._set_sorting_links(table_element_id, this.sortables);
         this._current_sort_index = null;
         this.inverted = false;
       },
getTable: function() {
  return($(this._t_element_id));
},
should_invert : function(sort_idx) {
                  var val = false;
                  if (this._current_sort_index != sort_idx) {
                    val = false;
                  } else {
                    if (this.inverted) {
                      val = false;
                    } else {
                      val = true;
                    }
                  }
                  this.inverted = val;
                  this._current_sort_index = sort_idx;
                  return(val);
                },
_find_sortables: function(table_element) {
                   var header_container = table_element.getElementsByTagName("thead")[0];
                   var header_row = header_container.getElementsByTagName("tr")[0]
                     var header_tds = Array.from(header_row.getElementsByTagName("td"));
                   header_tds.each( function (item) {
                       item.normalize();
                       });
                   var valid_headers = header_tds.select(function(item) {
                       return(
                         (!Array.from(item.childNodes).any( function(elem) {
                                                            return(elem.nodeType == Node.ELEMENT_NODE);
                                                            }))           
                         );
                       });
                   return(
                       valid_headers.map( function(valid_h) {
                         return(new TableSortSpec(header_tds.indexOf(valid_h), valid_h));
                         })
                       );
                 },
_set_sorting_links : function(sortable_element_id, sortables) {
                       var st = this;
                       sortables.each( function(item) {
                           var col_name = item.ele.innerHTML;
                           var item_children = Array.from(item.ele.childElements());
                           SortableTableUtil.remove_all_children(item_children);
                           item.ele.innerHTML = "<a href=\"#\">" + item.ele.innerHTML + "</a>";
                           var col_link = item.ele.getElementsByTagName("a")[0];
                           col_link.onclick = function () {
                           SortableTableUtil.sort_records(st, item.idx);
                           return(false); 
                           };
                           });
                     },
};

var SortableTableUtil = {
remove_all_children : function(child_collection) {
                        child_collection.each(function(item) {
                            Element.remove(item);
                            });
                      },
sort_records : function(st, idx) {
                 var table_ele = st.getTable();
                 var table_body_ele = table_ele.getElementsByTagName("tbody")[0];
                 var rows = Array.from(table_body_ele.getElementsByTagName("tr"));
                 var sort_meth = TableSortSpec.sortable_function(rows, idx);
                 var sorted_rows = rows.sortBy(sort_meth);
                 if (st.should_invert(idx)) {
                   sorted_rows = sorted_rows.reverse(false);
                 }
                 SortableTableUtil.remove_all_children(rows);
                 var row_counter = 0;
                 sorted_rows.each( function(item) {
                     item.className = SortableTableUtil.pick_row_class(row_counter);
                     table_body_ele.appendChild(item);
                     row_counter = row_counter + 1;    
                 });
               },
pick_row_class : function(row_inc) {
    if ((row_inc % 2) == 1) {
	return("som_table_odd"); 
    } else {
	return("som_table_even");
    }
},
};
