(function($) {
  $.sortable = function(t) {
    $.sortable.init(t)
  }
  
  $.extend($.sortable, {
    settings: {
      inited          : false,
      parent_ul       : null,
      sortable_fields : [],
      _timer          : null,
      dateRegexp      : /^(\d\d?)[\/\.-](\d\d?)[\/\.-]((\d\d)?\d\d)$/,
      dateRegexpRuby  : /(\d{4})-(\d{2})-(\d{2})[T ]?(\d{2}):(\d{2}):(\d{2})/
    },
    
    init: function(parent_ul) {
      if ($.sortable.settings.inited) return true
      else $.sortable.settings.inited = true
      
      if ($.sortable.settings._timer) clearInterval($.sortable.settings._timer);
      $.sortable.settings.parent_ul = parent_ul
      $.sortable.makeSortable()
    },
    
    makeSortable: function() {
      // work through each field and calculate its type
      sortable_fields = getSortableFields($.sortable.settings.parent_ul);
      for (var i=0; i<sortable_fields.length; i++) {
        sortable_fields[i].sortfunction = guessType(sortable_fields[i].toString(), $.sortable.settings.parent_ul);
      }
      $.sortable.settings.sortable_fields = sortable_fields;
    },
    
    sort: function(field, name) {
      sortable_field = getSortableField(field)

      if(sortable_field) {
        row_array = [];
        parent_ul = $.sortable.settings.parent_ul
        rows = parent_ul.find("li");
        for (var j=0; j<rows.length; j++) {
          row_array[row_array.length] = [$(rows[j]).attr(field), rows[j]];
        }

        $.sortable.stable_sort(row_array, sortable_field.sortfunction);
        parent_ul.fadeOut('normal', function() {
          parent_ul.empty()
          for (var j=0; j<row_array.length; j++) {
            parent_ul.append(row_array[j][1])
          }
          parent_ul.fadeIn()
          delete row_array
        })
      }
      
      return false
    },
    
    /* sort functions
       each sort function takes two parameters, a and b
       you are comparing a[0] and b[0] */
    sort_numeric: function(a,b) {
      aa = parseFloat(a[0].replace(/[^0-9.-]/g,''));
      if (isNaN(aa)) aa = 0;
      bb = parseFloat(b[0].replace(/[^0-9.-]/g,'')); 
      if (isNaN(bb)) bb = 0;
      return bb-aa;
    },
    sort_alpha: function(a,b) {
      if (a[0]==b[0]) return 0;
      if (a[0]<b[0]) return -1;
      return 1;
    },
    sort_rubydate: function(a,b) {
      mtch = a[0].match($.sortable.settings.dateRegexpRuby);
      y = mtch[1]; m = mtch[2]; d = mtch[3]; 
      h = mtch[4]; min = mtch[5]; s = mtch[6];
      if (m.length == 1) m = '0'+m;
      if (d.length == 1) d = '0'+d;
      if (h.length == 1) h = '0'+h;
      if (min.length == 1) min = '0'+min;
      if (s.length == 1) s = '0'+s;
      dt1 = y+m+d+h+min+s;
      mtch = b[0].match($.sortable.settings.dateRegexpRuby);
      y = mtch[1]; m = mtch[2]; d = mtch[3]; 
      h = mtch[4]; min = mtch[5]; s = mtch[6];
      if (m.length == 1) m = '0'+m;
      if (d.length == 1) d = '0'+d;
      if (h.length == 1) h = '0'+h;
      if (min.length == 1) min = '0'+min;
      if (s.length == 1) s = '0'+s;
      dt2 = y+m+d+h+min+s;
      if (dt1==dt2) return 0;
      if (dt1>dt2) return -1;
      return 1;
    },
    sort_ddmm: function(a,b) {
      mtch = a[0].match($.sortable.settings.dateRegexp);
      y = mtch[3]; m = mtch[2]; d = mtch[1];
      if (m.length == 1) m = '0'+m;
      if (d.length == 1) d = '0'+d;
      dt1 = y+m+d;
      mtch = b[0].match($.sortable.settings.dateRegexp);
      y = mtch[3]; m = mtch[2]; d = mtch[1];
      if (m.length == 1) m = '0'+m;
      if (d.length == 1) d = '0'+d;
      dt2 = y+m+d;
      if (dt1==dt2) return 0;
      if (dt1>dt2) return -1;
      return 1;
    },
    sort_mmdd: function(a,b) {
      mtch = a[0].match($.sortable.settings.dateRegexp);
      y = mtch[3]; d = mtch[2]; m = mtch[1];
      if (m.length == 1) m = '0'+m;
      if (d.length == 1) d = '0'+d;
      dt1 = y+m+d;
      mtch = b[0].match($.sortable.settings.dateRegexp);
      y = mtch[3]; d = mtch[2]; m = mtch[1];
      if (m.length == 1) m = '0'+m;
      if (d.length == 1) d = '0'+d;
      dt2 = y+m+d;
      if (dt1==dt2) return 0;
      if (dt1>dt2) return -1;
      return 1;
    },
    stable_sort: function(list, comp_func) {
      // A stable sort function to allow multi-level sorting of data
      // see: http://en.wikipedia.org/wiki/Cocktail_sort
      // thanks to Joseph Nahmias
      var b = 0;
      var t = list.length - 1;
      var swap = true;

      while(swap) {
          swap = false;
          for(var i = b; i < t; ++i) {
              if ( comp_func(list[i], list[i+1]) > 0 ) {
                  var q = list[i]; list[i] = list[i+1]; list[i+1] = q;
                  swap = true;
              }
          } // for
          t--;

          if (!swap) break;

          for(var i = t; i > b; --i) {
              if ( comp_func(list[i], list[i-1]) < 0 ) {
                  var q = list[i]; list[i] = list[i-1]; list[i-1] = q;
                  swap = true;
              }
          } // for
          b++;

      } // while(swap)
    }
  })
  
  function guessType(sortable_field, parent_ul) {
    // guess the type of a column based on its first non-blank row
    sortfn = null
    
    parent_ul.find("li["+sortable_field+"!='']:lt(2)").each(function() {
      if(sortfn == null) {
        text = $(this).attr(sortable_field)

        if (text.match(/^-?[£$¤]?[\d,.]+%?$/)) {
          sortfn = $.sortable.sort_numeric;
        }
        
        // check for Ruby date format - 2011-03-28 19:29:53 UTC
        rubydate = text.match($.sortable.settings.dateRegexpRuby)
        if (rubydate) {
          sortfn = $.sortable.sort_rubydate;
        }
        
        // check for a date: dd/mm/yyyy or dd/mm/yy 
        // can have / or . or - as separator
        // can be mm/dd as well
        possdate = text.match($.sortable.settings.dateRegexp)
        if (possdate) {
          // looks like a date
          first = parseInt(possdate[1]);
          second = parseInt(possdate[2]);
          if (first > 12) {
            // definitely dd/mm
            sortfn = $.sortable.sort_ddmm;
          } else if (second > 12) {
            sortfn = $.sortable.sort_mmdd;
          } else {
            // looks like a date, but we can't tell which, so assume
            // that it's dd/mm (English imperialism!) and keep looking
            // sortfn = $.sortable.sort_ddmm;
          }
        }
      }
    })
    if(sortfn==null)
      sortfn = $.sortable.sort_alpha;
    return sortfn;
  }
  
  function getSortableFields(parent_ul) {
    sortable_fields = []
    raw_arr = parent_ul.attr('sortable_fields').split(",")
    
    for(i=0;i<raw_arr.length;i++) {
      sortable_fields[i] = new String(raw_arr[i])
    }
    
    return sortable_fields;
  }
  
  function getSortableField(field) {
    sortable_fields = $.sortable.settings.sortable_fields
    for(i=0;i<sortable_fields.length;i++) {
      if(sortable_fields[i] == field)
        return sortable_fields[i];
    }
    return false
  }
  
})(jQuery);

jQuery(document).ready(function() {
  $('ul.sortable_options_ul').each(function() {
    $.sortable($(this));
  })
})