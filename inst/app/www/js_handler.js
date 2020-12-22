$( document ).ready(function() {
  Shiny.addCustomMessageHandler('fun', function(arg) {
    arg.this + arg.that;
  });
});
