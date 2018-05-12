(function ($) {
  $.fn.extend({
    shuffle: function() {
      var i = this.length, j, t;
      while (i) {
        j = Math.floor(Math.random() * i);
        t = this[--i];
        this[i] = this[j];
        this[j] = t;
      }
      return this;
    }
  });

  $.shuffle = function(arr) {
    return $(arr).shuffle();
  };
})(jQuery);
