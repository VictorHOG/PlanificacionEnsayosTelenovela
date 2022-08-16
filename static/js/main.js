/**
 * Author: Victor Hugo Ortega Gomez
 */
/*---------------------------------------Funcones Auxiliares---------------------------------------*/
/*
* switchColumns permuta dos columnas de una tabla
*/
$.fn.switchColumns = function (col1, col2) {
  // Obtener todas las filas de la tabla
  var $this = this,
    $tr = $this.find('tr');

  // Recorrer cada fila
  $tr.each(function (i, ele) {
    // Buscar todas las TD
    var $ele = $(ele),
      $td = $ele.find('td'),
      $tdt;

    // Clonar la celda de la columna 1
    // Mover la celda de la columna 2 en la posicion de la columna 1
    // insertar la celda clonada en la posicion de la columna 2
    $tdt = $td.eq(col1).clone();
    $td.eq(col1).html($td.eq(col2).html());
    $td.eq(col2).html($tdt.html());

    // Obtener todas las TH
    var $el2 = $(ele),
      $th = $el2.find('th'),
      $tht;

    $tht = $th.eq(col1).clone();
    $th.eq(col1).html($th.eq(col2).html());
    $th.eq(col2).html($tht.html());
  });
};

/*
* buildDropDowns agrega una lista de opciones (sizes) a múltiples elementos <select>
* Se obtiene los elementos <select> por medio de su identificador de clase getElementsByClassName
* Devuelve un arreglo de elementos, los recorre y añade las opciones invocando a la función createOption 
*/
function buildDropDowns(sizes) {
  var selections = document.getElementsByClassName('resourceSize');
  for (var i = 0; i < selections.length; i++) {
    for (var j = 0; j < sizes.length; j++) {
      selections[i].options.add(createOption(sizes[j], sizes[j]));
    }
  }
}

/*
* createOption permite configurar la opcion de un elemento <select> añadiendo el atributo value
*/
function createOption(option, label) {
  var option = document.createElement("option");
  //option.setAttribute("value", option); // error [object HTMLOptionElement]
  option.innerHTML = label;

  return option;
}

/*
 * generateAndCreateOptions a partir del valor asociado al numero de actores genera un arreglo 
 * con igual numero de opciones e invoca buildDropDowns para construir los menús desplegables
 */
function generateAndCreateOptions() {
  var numeroActores = document.getElementById("actores").value;
  var opciones = [];
  for (let i = 1; i <= numeroActores; i++) {
    var opcion = "Actor" + i;
    opciones.push(opcion);
  }
  // Eliminar todas las opciones de los elementos <select> asociados a un identificador de clase con jQuery
  $(".resourceSize").empty();
  // Agregar opción seleccionada deshabilitada en el menú de selección a través de jQuery
  $(".resourceSize").prepend("<option disabled selected value> -- select an option -- </option>");
  buildDropDowns(opciones);
}


/*---------------------------------------Funcones Principales---------------------------------------*/
/*
* asignarEscenas
*/
function asignarEscenas() {
  var numeroEscenas = document.getElementById("escenas").value;
  var numeroColumnas = $("#dataTable tr th").length;

  if (numeroEscenas > 0 && numeroEscenas <= 50) {

    if (numeroColumnas - 2 > numeroEscenas) {

      $('#dataTable').switchColumns(numeroColumnas - 2, numeroColumnas - 1);

      $('#dataTable tr').find('th:last-child, td:last-child').remove();
    } else {
      $('#dataTable').find('tr').not(':last').each(function () {
        var header = '<th>' + numeroEscenas + '</th>';
        var rowEscena = '<td><input type="number" name="escena" class="form-control coordinates" min="0" required></td>';
        $(this).find('th').eq(numeroColumnas - 2).after(header);
        $(this).find('td').eq(numeroColumnas - 2).after(rowEscena);
      });

      var rowDuracion = '<td><input type="number" name="duracion" class="form-control coordinates" min="0" required></td>';
      $('#dataTable').find('tr:last').find('td:last').before(rowDuracion);
    }
  }
}

/*
* asignarActores
*/
function asignarActores() {
  var numeroActores = document.getElementById("actores").value;
  var numeroFilas = $("#dataTable tr").length;

  var newRowDataTable = $('#fixedRowDataTable').clone();
  var newRowDisponibilidad = $('#fixedRowDisponibilidad').clone();

  if (numeroActores > 0 && numeroActores <= 20) {

    if (numeroActores <= numeroFilas - 2) {

      var row = $('#dataTable tr:last');
      row.insertBefore(row.prev());

      $('#dataTable tr:last').remove();
      $('#disponibilidad tr:last').remove();

    } else {

      var actorNumber = $("#dataTable tr").length;
      var number = actorNumber - 1;

      newRowDataTable.find('.actorNumber').html("Actor " + number);

      var row = $('#dataTable tr:last');
      newRowDataTable.insertBefore(row);

      newRowDisponibilidad.find('.actorNumber').html("Actor " + number);
      $('#disponibilidad').append(newRowDisponibilidad);
    }

    generateAndCreateOptions();
  }

}

/*
* El código incluido en el interior solo se ejecutará una vez que la página Document Object Model (DOM) 
* esté lista para que se ejecute el código JavaScript. 
*/
$(document).ready(function () {

  const inputEscenas = document.getElementById('escenas');
  const inputActores = document.getElementById('actores');

  // permitir la entrada del input haciendo clic en los botones de flecha tanto del input como del teclado, y NO escribiendo.
  // allow up/down keyboard cursor buttons
  inputEscenas.addEventListener("keydown", e => e.keyCode != 38 && e.keyCode != 40 && e.preventDefault());
  inputActores.addEventListener("keydown", e => e.keyCode != 38 && e.keyCode != 40 && e.preventDefault());

  //
  inputEscenas.addEventListener('input', asignarEscenas);
  inputActores.addEventListener('input', asignarActores);

  //
  $('[name="options"]').on('change', function () {
    if ($(this).val() === "option2") {
      $('#collapseOne').collapse('show')
      $('.disponibilidad').attr('required', '');

      generateAndCreateOptions();

    } else {
      $('#collapseOne').collapse('hide')
      $('.disponibilidad').removeAttr('required');
    }
  });

  //
  $('.btn-add').click(function () {
      addRow();
  })

  $(document).on('click', '.btn-remove', function () {
    removeRow(this);
  });

  function addRow() {
    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'btn btn-primary btn-remove';
    btn.textContent = '-';
    var newRowEvitar = $('#fixedRowEvitar').clone();
    newRowEvitar.find('.remove').append(btn); 
    $('#table-evitar').append(newRowEvitar);
  }

  function removeRow(btn) {
    $(btn).parent().parent().remove();
  }

})