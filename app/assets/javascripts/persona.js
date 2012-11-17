persona = {};
persona.login_action = '/persona/login';
persona.loggedInEmail = null;

persona.default_login_callback = function(assertion){
    $.ajax({
        type: 'POST',
        url: persona.login_action,
        data: {assertion: assertion, referer: document.URL},
        success: function(res) { window.location = res; },
        error: function(xhr, status, err) { alert("Login failure: " + err); }
    });
};

persona.default_logout_callback = function(){
    $.post('/persona/logout').complete(function(){
        window.location.reload()
    });
};

persona.login_callback = persona.default_login_callback;
persona.logout_callback = persona.default_logout_callback;


persona.login = function(func){
    persona.login_callback = (func || persona.default_login_callback);
    navigator.id.request();
};

persona.logout = function(func){
    persona.logout_callback = (func || persona.default_logout_callback);
    navigator.id.logout();
};


$(document).ready(function(){
    $('#login').click(function(event){
        persona.login();
        event.preventDefault();
    });
    $('#login_add').click(function(event){
        persona.login_action = '/persona/login_and_add_email';
        persona.login();
        event.preventDefault();
    });
    /*$('#login_create').click(function(event){
        ProsNCons.persona.login_action = 'persona/create_account';
        event.preventDefault();
    });*/
    $('#logout').click(function(event){
        persona.logout();
        event.preventDefault();
    });
    $('#logout_follow_link').click(function(event){
        persona.logout(function(){$.post('/persona/logout');});
        // no reload: the link gets followed
    });

    navigator.id.watch({
        loggedInUser: persona.loggedInEmail,
        onlogin: function(ass) {
            persona.login_callback(ass);
            persona.login_callback = persona.default_login_callback;
        },
        onlogout: function() {
            persona.logout_callback();
            persona.logout_callback = persona.default_logout_callback;
        }
    });

    if (persona.shouldLogOut)
        persona.logout(function(){});
});

