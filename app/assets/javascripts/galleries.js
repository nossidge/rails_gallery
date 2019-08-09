// Update the label of the file input with the filename.
$(document).ready(function() {
  $('#image_file').on('change', function() {
    var fileName = $(this).val();
    var baseName = fileName.split(/[\\/]/).pop();
    $(this)
      .next('.custom-file-label')
      .html(baseName);
  });
});

// Enable drag & drop of top-level divs in the id='sort_images' container.
// https://www.kindleman.com.au/blog/drag-and-drop-with-rails-and-html5/
$(document).on('turbolinks:load', function() {
  sortable('#sort_images', {
    items: 'div'
  });
  if (typeof sortable('#sort_images')[0] != 'undefined') {
    sortable('#sort_images')[0].addEventListener('sortupdate', function(e) {
      var dataIDList = $(this)
        .children()
        .map(function(index, elem) {
          return 'image[]=' + $(elem).data('id');
        })
        .get()
        .join('&');
      Rails.ajax({
        url: $(this).data('url'),
        type: 'PATCH',
        dataType: 'script',
        data: dataIDList
      });
    });
  }
});
