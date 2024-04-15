{%- extends 'basic.tpl' -%}

{%- block header -%}
{{ super() }}
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="ipynb_website:version" content="0.9.7" />
<meta name="viewport" content="width=device-width, initial-scale=1" />

<link rel="stylesheet" type="text/css" href="../css/jt.css">

<link rel="stylesheet" type="text/css" href="../css/toc2.css">

<link href="../site_libs/jqueryui-1.11.4/jquery-ui.css">
<link rel="stylesheet" href="../site_libs/bootstrap-3.3.5/css/cosmo.min.css" rel="stylesheet" />
<link rel="stylesheet" href="../site_libs/font-awesome-4.5.0/css/font-awesome.min.css" rel="stylesheet" />
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js"></script>
<script src="../site_libs/bootstrap-3.3.5/js/bootstrap.min.js"></script>
<script src="../site_libs/bootstrap-3.3.5/shim/html5shiv.min.js"></script>
<script src="../site_libs/bootstrap-3.3.5/shim/respond.min.js"></script>

<link rel="stylesheet"
      href="../site_libs/highlightjs/null.min.css"
      type="text/css" />

<script src="../site_libs/highlightjs/highlight.pack.js"></script>
<script>hljs.initHighlightingOnLoad();</script>
<script type="text/javascript">
if (window.hljs && document.readyState && document.readyState === "complete") {
   window.setTimeout(function() {
      hljs.initHighlighting();
   }, 0);
}
</script>

<script src="../js/doc_toc.js"></script>
<script src="../js/docs.js"></script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.2/MathJax.js?config=TeX-MML-AM_CHTML"></script>
<script>
    MathJax.Hub.Config({
        extensions: ["tex2jax.js"],
        jax: ["input/TeX", "output/HTML-CSS"],
        tex2jax: {
        inlineMath: [ ['$','$'], ["\\(","\\)"] ],
        displayMath: [ ['$$','$$'], ["\\[","\\]"] ],
        processEscapes: true
        },
        "HTML-CSS": {
            preferredFont: "TeX",
            availableFonts: ["TeX"],
            styles: {
                scale: 110,
                ".MathJax_Display": {
                    "font-size": "110%",
                }
            }
        }
    });
</script>
<script>
function filterDataFrame(id) {
    var input = document.getElementById("search_" + id);
    var filter = input.value.toUpperCase();
    var table = document.getElementById("dataframe_" + id);
    var tr = table.getElementsByTagName("tr");
    // Loop through all table rows, and hide those who don't match the search query
    for (var i = 1; i < tr.length; i++) {
        for (var j = 0; j < tr[i].cells.length; ++j) {
            var matched = false;
            if (tr[i].cells[j].innerHTML.toUpperCase().indexOf(filter) != -1) {
                tr[i].style.display = "";
                matched = true
                break;
            }
            if (!matched)
                tr[i].style.display = "none";
        }
    }
}
function sortDataFrame(id, n, dtype) {
    var table = document.getElementById("dataframe_" + id);
    var tb = table.tBodies[0]; // use `<tbody>` to ignore `<thead>` and `<tfoot>` rows
    var tr = Array.prototype.slice.call(tb.rows, 0); // put rows into array
    if (dtype === 'numeric') {
        var fn = function(a, b) { 
            return parseFloat(a.cells[n].textContent) <= parseFloat(b.cells[n].textContent) ? -1 : 1;
        }
    } else {
        var fn = function(a, b) {
            var c = a.cells[n].textContent.trim().localeCompare(b.cells[n].textContent.trim()); 
            return c > 0 ? 1 : (c < 0 ? -1 : 0) }
    }
    var isSorted = function(array, fn) {
        if (array.length < 2)
            return 1;
        var direction = fn(array[0], array[1]); 
        for (var i = 1; i < array.length - 1; ++i) {
            var d = fn(array[i], array[i+1]);
            if (d == 0)
                continue;
            else if (direction == 0)
                direction = d;
            else if (direction != d)
                return 0;
            }
        return direction;
    }
    var sorted = isSorted(tr, fn);
    if (sorted == 1 || sorted == -1) {
        // if sorted already, reverse it
        for(var i = tr.length - 1; i >= 0; --i)
            tb.appendChild(tr[i]); // append each row in order
    } else {
        tr = tr.sort(fn);
        for(var i = 0; i < tr.length; ++i)
            tb.appendChild(tr[i]); // append each row in order
    }
}
</script>

<script>
$( document ).ready(function(){
            var cfg={'threshold':{{ nb.get('metadata', {}).get('toc', {}).get('threshold', '3') }},     // depth of toc (number of levels)
             'number_sections': false,
             'toc_cell': false,          // useless here
             'toc_window_display': true, // display the toc window
             "toc_section_display": "block", // display toc contents in the window
             'sideBar':true,       // sidebar or floating window
             'navigate_menu':false       // navigation menu (only in liveNotebook -- do not change)
            }
            var st={};                  // some variables used in the script
            st.rendering_toc_cell = false;
            st.config_loaded = false;
            st.extension_initialized=false;
            st.nbcontainer_marginleft = $('#notebook-container').css('margin-left')
            st.nbcontainer_marginright = $('#notebook-container').css('margin-right')
            st.nbcontainer_width = $('#notebook-container').css('width')
            st.oldTocHeight = undefined
            st.cell_toc = undefined;
            st.toc_index=0;
            // fire the main function with these parameters
            table_of_contents(cfg, st);
            var file=notebooksDict[$("h1:first").attr("id")];
            $("#toc-level0 a").css("color","#126dce");
            $('a[href="#'+$("h1:first").attr("id")+'"]').hide()
            var docs=notebooksArray;
            var docs_map=notebooksArrayMap;
            var pos=notebooksArray.indexOf(file);
            for (var a=pos;a>=0;a--){
                  $('<li><a href="'+docs[a]+'.html"><font color="#073642"><b>'+docs_map[docs[a]].replace(/_/g," ")+'</b></font></a></li>').insertBefore("#toc-level0 li:eq(0)");
            }
            $('a[href="'+file+'.html'+'"]').css("color","#126dce");
            for (var a=pos+1;a<docs.length;a++){
                  $(".toc #toc-level0").append('<li><a href="'+docs[a]+'.html"><font color="#073642"><b>'+docs_map[docs[a]].replace(/_/g," ")+'</b></font></a></li>');
            }
            // $("#toc-header").hide(); // comment out because it prevents search bar from displaying
    });
</script>

<script>
// manage active state of menu based on current page
$(document).ready(function () {
  // active menu anchor
  href = window.location.pathname
  href = href.substr(href.lastIndexOf('/') + 1)
  if (href === "")
    href = "index.html";
  var menuAnchor = $('a[href="' + href + '"]');
  // mark it active
  menuAnchor.parent().addClass('active');
  // if it's got a parent navbar menu mark it active as well
  menuAnchor.closest('li.dropdown').addClass('active');
});
</script>
<div class="container-fluid main-container">
<!-- tabsets -->
<script src="../site_libs/navigation-1.1/tabsets.js"></script>
<script>
$(document).ready(function () {
  window.buildTabsets("TOC");
});
</script>



<title>Statistical Genetics Tutorials</title>

<style type = "text/css">
body {
  font-family: "Droid Sans";
  padding-top: 66px;
  padding-bottom: 40px;
}
</style>
</head>

<body>
<div tabindex="-1" id="notebook" class="border-box-sizing">
<div class="container" id="notebook-container">

<!-- code folding -->

<div class="navbar navbar-default  navbar-fixed-top" role="navigation">
  <div class="container">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar">
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="../index.html">Statistical Genetics Tutorials</a>
    </div>
    <div id="navbar" class="navbar-collapse collapse">
      <ul class="nav navbar-nav">
        
<li>
  <a href="../index.html">Overview</a>
</li>
        
<li>
  <a href="../notebooks.html">Notebooks</a>
</li>
        
      </ul>
        
<ul class="nav navbar-nav navbar-right">
<li>
   <a href="http://github.com/statgenetics/statgen-courses"> <span class="fa fa-github"></span> </a>
</li>
</ul>
        
      </div><!--/.nav-collapse -->
  </div><!--/.container -->
</div><!--/.navbar -->

{%- endblock header -%}

{% block footer %}
<hr>
&copy 2019 Center for Statistical Genetics, Department of Neurology, Columbia University
</div>
</div>
</body>
</html>
{% endblock %}