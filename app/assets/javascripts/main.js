var taskGraph = new joint.dia.Graph;

var taskPaper = new joint.dia.Paper({
    el: $('#task_container'),
    width: 800,
    height: 500,
    model: taskGraph,
    gridSize: 1
});

var systemGraph = new joint.dia.Graph;

var systemPaper = new joint.dia.Paper({
    el: $('#system_container'),
    width: 800,
    height: 500,
    model: systemGraph,
    gridSize: 30
});

// $(window).resize(function(event) {
//   var new_h = $(window).height();
//   var new_w = $(window).width();
//   taskPaper.setDimensions(new_w, new_h)
//   systemPaper.setDimensions(new_w, new_h)
// });

$("#hide_show").click(function(){
var $div1 = $('#task_container')
var $div2 = $('#system_container')
$div1.hide();
$div2.show();
});

$("#hide_show2").click(function(){
var $div1 = $('#task_container')
var $div2 = $('#system_container')
$div2.hide();
$div1.show();
});

// Attributes
attrs = {
	topDefault: {
	    circle: { fill: 'white' }
	},
	topSelect: {
		circle: {fill: '#e1e1e8'}
	},
  sysElmDefault: {
      rect: { fill: 'white' }
  },
  sysElmSelect: {
      rect: {fill: '#e1e1e8'}
  }
}

var textTask = ""
var textSys = ""
function handleFileSelect(event) {
	var files_lst = event.target.files
	file = files_lst[0]
	var reader = new FileReader();
	reader.onload = function(e) {
    buffer = reader.result.split("~::~");
    console.log(buffer)
		if (event.target.id == "file_task") {
      arrayOfTopsTask = []
      arrayOfLinksTask = []
      buffer[1] = buffer[1].split(",");
      buffer[2] = buffer[2].split(",");
      for (i=0; i<buffer[1].length;i=i+3){
        arrayOfTopsTask.push([buffer[1][i],parseInt(buffer[1][i+1]),buffer[1][i+2]]);
      }
      for (i=0; i<buffer[2].length;i=i+4){
        arrayOfLinksTask.push([buffer[2][i],parseInt(buffer[2][i+1]),parseInt(buffer[2][i+2]),buffer[2][i+3]]);
      }
      iTopsTask = parseInt(buffer[3]);
      textTask = buffer[0];
    }
		else if (event.target.id == "file_sys") {
      arrayOfTopsSys = []
      arrayOfLinksSys = []
      buffer[1] = buffer[1].split(",");
      buffer[2] = buffer[2].split(",");
      for (i=0; i<buffer[1].length;i=i+2){
        arrayOfTopsSys.push([buffer[1][i],parseInt(buffer[1][i+1])]);
      }
      for (i=0; i<buffer[2].length;i=i+3){
        arrayOfLinksSys.push([buffer[2][i],parseInt(buffer[2][i+1]),parseInt(buffer[2][i+2])]);
      }
      iTopsSys = parseInt(buffer[3]);
      textSys = buffer[0];
    }
	}
	reader.readAsText(file);
	document.ready;
}

options = {disconnectLinks : false}
dialogLinkTask = false;
dialogTopTask = false;

function resultMessage(message) {
  $('#background_message').show();
  $('#message_bar').show('fast');
  $('#message_bar h3').html(message);
  $('#background_message').css('z-index','100');
}

$('#close_message_bar').click(function(){
  $('#background_message').hide('fast');
  $('#message_bar').hide('fast');
  $('#background_message').css('z-index','-100');
})