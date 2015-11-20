// ---------------------------------------------------------------------------
// Infinite scroll support for search#index

$('#jscroll').jscroll({
  autoTrigger: true,
  loadingHtml: '<strong>Loading...</strong>',//'<img src="loading.gif" alt="Loading" /> Loading...',
  padding: 20,
  nextSelector: 'a.jscroll-next:last',
  debug: true
});

if ($('#back-to-top').length !== 0) {
  $(document).scroll(function() {
    var y = $(this).scrollTop();
    if (y > 800)
      $('#back-to-top').fadeIn();
    else
      $('#back-to-top').fadeOut();
  });
}
