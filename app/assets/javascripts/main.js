var taskGraph = new joint.dia.Graph;

var taskPaper = new joint.dia.Paper({
    el: $('#task_container'),
    width: 800,
    height: 550,
    model: taskGraph,
    gridSize: 1
});

var systemGraph = new joint.dia.Graph;

var systemPaper = new joint.dia.Paper({
    el: $('#system_container'),
    width: 800,
    height: 550,
    model: systemGraph,
    gridSize: 1
});


$("#hide_show").click(function(){
var $div1 = $('#task_container')
var $div2 = $('#system_container')
  if ($div1.is(':visible')) {
  	$div1.hide();
  	$div2.show();
  }
  else if ($div2.is(':visible')) {
  	$div2.hide();
  	$div1.show();
  }
});

// Attributes
attrs = {
	topDefault: {
	    circle: { fill: 'green' }
	},
	topSelect: {
		circle: {fill: 'red'}
	},
  sysElmDefault: {
      rect: { fill: 'yellow' }
  },
  sysElmSelect: {
      rect: {fill: 'red'}
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