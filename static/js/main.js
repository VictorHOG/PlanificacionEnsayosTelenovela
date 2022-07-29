// $(document).ready(function () {

//     $('#uploadFile').click(function () {
//         addRow();
//     })

//     $(document).on('click', '.btn-remove', function () {
        
//     });

//     function addRow() {
//        console.log("lo presione");
//     }

//     function removeRow(btn) {
       
//     }
// })

$('[name="options"]').on('change', function(){  
  if($(this).val()  === "option2"){
    $('#collapseOne').collapse('show')
    $('.disponibilidad').attr('required', '');
  
  }else{
     $('#collapseOne').collapse('hide')
     $('.disponibilidad').removeAttr('required');
  }
});


