// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

function vote(action, id, diff) {
    id = Number(id);
    var url = '/pages/votes/'+id+'/'+action;

    $.ajax({
        type: 'POST',
        url: url,
        success: function(res) { $('#votes'+id).html(res) }
    });
}

$(document).ready(function(){
    $("tr").click(function(){
        /* personally I would throw a url attribute (<tr url="http://www.hunterconcepts.com">) on the tr and pull it off on click */
        window.location = $(this).attr("url");
    }).mouseover(function(){
        $(this).addClass('hovered');
    }).mouseout(function(){
        $(this).removeClass('hovered');
    });
})