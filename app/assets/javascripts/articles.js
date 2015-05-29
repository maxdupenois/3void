var Void = Void || {};
;(function($){
  $(function(){
    //Void.setupMasonry();
    //$(document).on('page:change', Void.setupMasonry);
  });
  Void.setupMasonry = function(){
    var container = $('#articles');
    container.masonry({
      columnWidth: 200,
      itemSelector: '.article-block'
    });
    container.masonry('bindResize');
  };
})(jQuery);
