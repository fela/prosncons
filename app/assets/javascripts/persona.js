$(document).ready(function(){
    $('#login').click(function(event){
        navigator.id.request();
        event.preventDefault();
    });
    $('#logout').click(function(event){
        navigator.id.logout();
        event.preventDefault();
    });
});

var currentUser = 'bob@example.com';

navigator.id.watch({
    loggedInUser: loggedInEmail,
    onlogin: function(assertion) {
        $.ajax({
            type: 'POST',
            url: '/persona/login',
            data: {assertion: assertion},
            success: function(res, status, xhr) { window.location.reload(); },
            error: function(xhr, status, err) { alert("Login failure: " + err); }
        });
    },
    onlogout: function() {
        $.ajax({
            type: 'POST',
            url: '/persona/logout',
            success: function(res, status, xhr) { window.location.reload(); },
            error: function(xhr, status, err) { alert("Logout failure: " + err); }
        });
    }
});