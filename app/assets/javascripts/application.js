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

ProsNCons = {};

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
    // make whole table rows links
    // TODO only do if they follow a certain class
    $("tr").click(function(){
        var newLocation = $(this).attr('url');
        if (newLocation)
            window.location = newLocation;
    }).mouseover(function(){
        $(this).addClass('hovered');
    }).mouseout(function(){
        $(this).removeClass('hovered');
    });

    // votes
    $('.vote-up').click(function() {
        var votes = $(this).parent('.votes');
        if (votes.hasClass('up-voted')) {
            // undo vote
            votes.removeClass('up-voted');
        } else {
            // the class either has no vote or a down vote
            // in either case vote up
            votes.removeClass('down-voted'); // might do nothing
            votes.addClass('up-voted');
        }
    });
    // analogous as an up-vote
    $('.vote-down').click(function() {
        var votes = $(this).parent('.votes');
        if (votes.hasClass('down-voted')) {
            // undo vote
            votes.removeClass('down-voted');
        }
        else {
            votes.removeClass('up-voted');
            votes.addClass('down-voted');
        }
    });
});