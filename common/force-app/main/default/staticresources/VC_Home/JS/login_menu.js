jQuery(document).ready(function( $ ) {

    var ulElement = $('.menu-item-7726').closest('ul');
    var liElement = $('.menu-item-7726');
    
    $.ajax({
        url: 'https://investor.venturecrowd.com.au/api/user/logged_in_user',
        type: 'GET',
        dataType: 'jsonp'
    })
    .done(function(data) {
        if (data.is_logged_in) {
            ulElement.append('<li class="menu-item menu-item-type-post_type menu-item-object-page"><a id="menu-button-dashboard" href="https://investor.venturecrowd.com.au/investor/dashboard/show" >DASHBOARD</a></li>');
            ulElement.append('<li class="menu-item menu-item-type-post_type menu-item-object-page"><a id="menu-button-user" href="https://investor.venturecrowd.com.au/investor/dashboard/show" > '+data.first_name+' '+data.last_name+' </a></li>');

            liElement.empty();
        } else {
            ulElement.append('<li class="menu-item menu-item-type-post_type menu-item-object-page menu-item-login-button button_bordered"><a id="menu-button-login" href="https://investor.venturecrowd.com.au/login?referer=http://investor.venturecrowd.com.au/investor/dashboard/index" >LOGIN</a></li>');
            ulElement.append('<li class="menu-item menu-item-type-custom menu-item-object-custom menu-item-register-button"><a id="menu-button-register" href="https://investor.venturecrowd.com.au/registration?referer=https://www.venturecrowd.com.au" >REGISTER</a></li>');

            liElement.empty();
        }
    });
});