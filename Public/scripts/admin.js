$( document ).ready(function() {

  $.ajaxSetup({ async: false });

  $("body input[type=checkbox]").click(function(event) {

    var mainElement = $(this).parent().parent();
    var idShot = mainElement.attr("data-idShot");
    var data = { "shot-id": idShot, "category-id": $(this).val() };

    if(this.checked){
      $.ajax({ url: "admin/category", type: 'POST', data: data});
    } else {
      $.ajax({ url: "admin/category", type: 'DELETE', data: data});
    }

  });

});
