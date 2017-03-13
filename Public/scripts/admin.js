$( document ).ready(function() {

  $.ajaxSetup({ async: false });

  $(".category-checkbox").click(function(event) {

    var mainElement = $(this).parent().parent();
    var idShot = mainElement.attr("data-idShot");
    var data = { "shot-id": idShot, "category-id": $(this).val() };

    if(this.checked){
      $.ajax({ url: "admin/category", type: 'POST', data: data});
    } else {
      $.ajax({ url: "admin/category", type: 'DELETE', data: data});
    }

  });

  $(".contacted-checkbox").click(function(event) {

    var idUser = $(this).val();
    var data = { "id": idUser };

    if(this.checked){
      $.ajax({ url: "/admin/contacted", type: 'POST', data: data});
    } else {
      $.ajax({ url: "/admin/contacted", type: 'DELETE', data: data});
    }

  });
                    
  $('.user-status').on('change', function() {
      var data = { "user_id": $(this).attr("data-userid"), "status": this.value};
    $.ajax({ url: "/admin/status", type: 'POST', data: data});
  })

});
