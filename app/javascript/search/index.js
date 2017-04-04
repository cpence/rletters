import './index.scss';
require('./advanced');

// ---------------------------------------------------------------------------
// Infinite scroll support for search#index

window.jQuery(function() {
  window.jQuery('#jscroll').jscroll({
    autoTrigger: true,
    loadingHtml: '<strong>Loading...</strong>',//'<img src="loading.gif" alt="Loading" /> Loading...',
    padding: 20,
    nextSelector: 'a.jscroll-next:last',
    debug: true
  });

  if (window.jQuery('#back-to-top').length !== 0) {
    window.jQuery(document).scroll(function() {
      var y = window.jQuery(this).scrollTop();
      if (y > 800)
        window.jQuery('#back-to-top').fadeIn();
      else
        window.jQuery('#back-to-top').fadeOut();
    });
  }
});
