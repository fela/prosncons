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
//= require bootstrap
//= require_tree .

ProsNCons = {};

// id is the argument id
// action can be 'up', 'down' or 'undo'
function vote(id, action) {
    if (!persona.loggedInEmail) {
        alert('please log in to be able to vote');
        return false;
    }

    id = Number(id);
    var url = window.location.pathname + '/arguments/'+id+'/vote/'+action;

    $.ajax({
        type: 'POST',
        url: url,
        data: {'_method': 'put'},
        success: function(res) { $('#votes'+id).html(res) }
    });
    return true;
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
        var id = votes.data('id');
        if (votes.hasClass('up-voted')) {
            // undo vote
            if (vote(id, 'undo'))
                votes.removeClass('up-voted');
        } else {
            // the class either has no vote or a down vote
            // in either case vote up

            if ( vote(id, 'up') ) {
                votes.removeClass('down-voted'); // might do nothing
                votes.addClass('up-voted');
            }
        }
    });
    // analogous as an up-vote
    $('.vote-down').click(function() {
        var votes = $(this).parent('.votes');
        var id = votes.data('id');
        if (votes.hasClass('down-voted')) {
            // undo vote
            if (vote(id, 'undo')) {
                votes.removeClass('down-voted');
            }
        }
        else {
            if (vote(id, 'down')) {
                votes.removeClass('up-voted');
                votes.addClass('down-voted');
            }
        }
    });
});