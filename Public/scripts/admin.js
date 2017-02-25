$( document ).ready(function() {

  $.ajaxSetup({ async: false });

  $("body input[type=checkbox]").click(function(event) {

    var mainElement = $(this).parent().parent();
    var idShot = mainElement.attr("data-idShot");

    if(this.checked){
      $.post( "admin/category", { "shot-id": idShot, "category-id": $(this).val()} );
    }

  });

});
