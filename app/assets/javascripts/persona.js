// default value
ProsNCons = {persona:{login_action: '/persona/login',
                      redirect_on_logout: true
}};

$(document).ready(function(){
    $('#login').click(function(event){
        //ProsNCons.persona.login_action = 'persona/login';
        navigator.id.request();
        event.preventDefault();
    });
    $('#login_add').click(function(event){
        ProsNCons.persona.login_action = '/persona/login_and_add_email';
        navigator.id.request();
        event.preventDefault();
    });
    /*$('#login_create').click(function(event){
        ProsNCons.persona.login_action = 'persona/create_account';
        event.preventDefault();
    });*/
    $('#logout').click(function(event){
        navigator.id.logout();
        event.preventDefault();
    });
    $('#logout_follow_link').click(function(event){
        ProsNCons.persona.redirect_on_logout = false;
        navigator.id.logout();
    });
});

var currentUser = 'bob@example.com';

navigator.id.watch({
    loggedInUser: loggedInEmail,
    onlogin: function(assertion) {
        $.ajax({
            type: 'POST',
            url: ProsNCons.persona.login_action,
            data: {assertion: assertion, referer: document.URL},
            success: function(res, status, xhr) { window.location = res; },
            error: function(xhr, status, err) { alert("Login failure: " + err); }
        });

    },
    onlogout: function() {
        $.ajax({
            type: 'POST',
            url: '/persona/logout',
            data: {referer: document.URL},
            success: function(res, status, xhr) {
                if (ProsNCons.persona.redirect_on_logout)
                    window.location = res;
                // reset for next call (might not be needed..)
                ProsNCons.persona.redirect_on_logout = true;
            },
            error: function(xhr, status, err) { alert("Logout failure: " + err); }
        });
    }
});