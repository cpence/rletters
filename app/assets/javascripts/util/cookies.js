// Some of the code here from https://github.com/Wruczek/Bootstrap-Cookie-Alert
function setCookie(cname, cvalue, exdays) {
  var cookie = cname + "=" + cvalue + ";path=/";

  if (exdays > 0) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));

    var expires = ";expires=" + d.toUTCString();
    cookie += expires;
  }

  document.cookie = cookie;
}

function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) === ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) === 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

function eraseCookie(name) {
    document.cookie = name + '=; Max-Age=-99999999;';
}

function acceptedCookies() {
  setCookie('accept-cookies', true, 365);

  window.jQuery('html').removeClass('declined-cookies');
  showAndEnable('#sign-in-remember');
}

function declinedCookies() {
  eraseCookie('accept-cookies');

  window.jQuery('html').addClass('declined-cookies');
  hideAndDisable('#sign-in-remember');
}

window.jQuery(function() {
  if (!getCookie('accept-cookies')) {
    window.jQuery('#cookie-alert').fadeIn();
    declinedCookies();
  }

  window.jQuery('#accept-cookies-btn').on('click', function() {
    acceptedCookies();
    window.jQuery('#cookie-alert').fadeOut();
  });
  window.jQuery('#decline-cookies-btn').on('click', function() {
    declinedCookies();
    window.jQuery('#cookie-alert').fadeOut();
  });
});
