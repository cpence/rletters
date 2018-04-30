// ---------------------------------------------------------------------------
// Asset upload form support (submit as soon as a file is chosen)
function onAssetUpload() {
  $('.asset-upload-field').on('change', function(event) {
    if (confirm('Would you like to upload the file "' + this.files[0].name + '"?')) {
      this.form.submit();
    }
  });
}

$(onAssetUpload);
