$(document).ready(function() {

  $("[data-validate-passwords=true]").keyup(function(){
  	if($("#reset_password1").val().length >= 8){
  		$("#8char").removeClass("fa-remove");
  		$("#8char").addClass("fa-check");
  		$("#8char").css("color","#00A41E");
  	}else{
  		$("#8char").removeClass("fa-check");
  		$("#8char").addClass("fa-remove");
  		$("#8char").css("color","#FF0004");
  	}

  	if($("#reset_password1").val() == $("#reset_password2").val()){
  		$("#pwmatch").removeClass("fa-remove");
  		$("#pwmatch").addClass("fa-check");
  		$("#pwmatch").css("color","#00A41E");
  	}else{
  		$("#pwmatch").removeClass("fa-check");
  		$("#pwmatch").addClass("fa-remove");
  		$("#pwmatch").css("color","#FF0004");
  	}

    if(($("#reset_password1").val() == $("#reset_password2").val()) && ($("#reset_password1").val().length >= 8)) {
      $( ".validated-submit" ).prop( "disabled", false );
    }else{
      $( ".validated-submit" ).prop( "disabled", true );
    }
  });

});
