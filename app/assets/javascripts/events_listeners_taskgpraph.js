var arrayOfTopsTask = []; // [0] Original id of top, [1] Top ID (my id, get cell.attributes.id_top) [2] Top Weight
var arrayOfLinksTask = []; // [0] Original id of link, [1] Top Sourse id_top [2] Top Target id_top [3] Link Weight
var iTopsTask = 0;


// Add new top in TaskGraph
taskPaper.on('blank:pointerdblclick', function(e, x, y) {
	if (editModeTask) {
	  mouseX = x - 25
	  mouseY = y - 25
	  var top = (new joint.shapes.basic.Circle({
		    position: { x: mouseX, y: mouseY },
		    size: { width: 50, height: 50 },
		    id_top: iTopsTask,
		    attrs: { circle: { fill: 'green', class: 'taskTop', 'stroke-width': 2 }, text: { text: '1', fill: 'black'}}
		})).addTo(taskGraph);
		arrayOfTopsTask.push([top.id, top.attributes.id_top, "1"]); // Write to ARRAY OF TOPS
		iTopsTask++;
  }
});

// Active edit mode for Task Graph

var editModeTask;

$('#editModeTask').on('change', function(evt) {
	editModeTask = $(evt.target).is(':checked');
	$elmOpt = $('#task_container .link-tool .tool-options')
	$elmRem = $('#task_container .link-tool .tool-remove')
	if (editModeTask) {
		$elmOpt.css('display', 'none');
		$elmRem.css('display', 'block');
	}
	else{
		$elmOpt.css('display', 'block');
		$elmRem.css('display', 'none');
	}
	
});

// Select tops on Task Graph
var selectELements = [];

taskPaper.on('cell:pointerclick', function(cellView, e){
	if (cellView.model.isLink()) return;
	if (editModeTask){
		cellView.model.attr(attrs.topSelect);
		selectELements.push(cellView.model);
		jQuery.unique(selectELements);
		selectELements = selectELements.reverse();
		if (selectELements.length > 2){
			selectELements[0].attr(attrs.topDefault);
			selectELements.shift();
		}
	}	
});

// Reset selectors
taskPaper.on('blank:pointerclick', function(){
	if (selectELements.length == 2) {
		selectELements[0].attr(attrs.topDefault);
		selectELements[1].attr(attrs.topDefault);
 		selectELements = []
 	}
});

// Add link between select tops
$('#add_tops_connect').click(function(){
	if (selectELements.length == 2) {
	    src = selectELements[0]
	    trg = selectELements[1]

			var link = (new joint.dia.Link({
		    source: { id: src.id },
		    target: { id: trg.id },
		    attrs: {
		    	'.connection': { 'stroke-width': 2 },
		      '.marker-target': { d: 'M 10 0 L 0 5 L 10 10 z' }
		    },
		    labels: [
		        { position: .5, attrs: { text: { text: '1' } } }
		    ]
		})).addTo(taskGraph);
			arrayOfLinksTask.push([link.id, src.attributes.id_top, trg.attributes.id_top, "1"]) // Write to Array of Links
	}
});

//Change top value
taskPaper.on('cell:pointerdblclick', function(cellView, e){
	if (editModeTask == false){
		value = prompt('Change Value', "")
		cellView.model.attr({
			text: { text: value }
		});
		for (i=0; i < arrayOfTopsTask.length; i++){
			if (cellView.model.id == arrayOfTopsTask[i][0]){
				arrayOfTopsTask[i][2] = value 	// Change VAL in Array
			}
		}
	}
});

// Change link value
taskPaper.on('link:options', function(e,link){
	value = prompt('Change Value', "")
	link.model.label(0,{
		attrs: {
			text: {text: value}
		}
	})
	for (i=0; i < arrayOfLinksTask.length; i++) {
		if (link.model.id == arrayOfLinksTask[i][0]){
			arrayOfLinksTask[i][3] = value;
		}
	}
});

// Remove top
taskPaper.on('cell:pointerdblclick', function(cellView){
	if (editModeTask){
		var delete_index;
		for (i=0; i < arrayOfTopsTask.length; i++){
			if (cellView.model.id == arrayOfTopsTask[i][0]){
				delete_index = i
			}
		}
		arrayOfTopsTask.splice(delete_index,1); // Delete from Array top
		cellView.model.remove(options);
	}
});

// Clear Graph Paper
$('#clear_task_paper').click(function(){
	taskGraph.clear()
	arrayOfTopsTask = []
	iTopsTask = 0
});

//Graph to JSON
//Save to JSON
$('#save_to_file_task').click(function(){
	var file_name = prompt("File Name", "")
	var jsonTaskGraph = taskGraph.toJSON();
	var jsonStringTask = JSON.stringify(jsonTaskGraph);
	var blob = new Blob([jsonStringTask,"~::~",arrayOfTopsTask.toString(),"~::~",arrayOfLinksTask.toString(),"~::~",iTopsTask], {type: "text/plain;charset=utf-8"});
	saveAs(blob, file_name + "_task.json");
});
// Load from JSON
//Lestener on files ID
document.getElementById('file_task').addEventListener('change', handleFileSelect, false);
//Load on paper JSON object
$('#load_from_file_task').click(function(){
	jsonObjectTask = JSON.parse(textTask);
	taskGraph.fromJSON(jsonObjectTask);
});


$('#test_task').click(function(){
	$.ajax({
	  type: "POST",
	  url: "/",
	  data: { task_data: [JSON.stringify(arrayOfTopsTask),JSON.stringify(arrayOfLinksTask)]}
	});	
})

// Remove link event for Task
taskGraph.on('remove', function(cellView){
	if (editModeTask){
		if (cellView.isLink()) {
			delete_index = 0;
			for (i=0; i < arrayOfLinksTask.length; i++){
				if (cellView.id == arrayOfLinksTask[i][0]){
					delete_index = i
				}
			}
			arrayOfLinksTask.splice(delete_index,1);
		}
	}
});