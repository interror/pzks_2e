var arrayOfTopsTask = []; // [0] Original id of top, [1] Top ID (my id, get cell.attributes.id_top) [2] Top Weight
var arrayOfLinksTask = []; // [0] Original id of link, [1] Top Sourse id_top [2] Top Target id_top [3] Link Weight
var iTopsTask = 0;

joint.shapes.basic.newCircle = joint.shapes.basic.Generic.extend({

    markup: '<g class="rotatable"><g class="scalable"><circle/></g><text class="topName"/><text class="topValue"/></g>',
    
    defaults: joint.util.deepSupplement({

        type: 'basic.newCircle',
        size: { width: 60, height: 60 },
        attrs: {
            'circle': { fill: '#FFFFFF', stroke: 'black', r: 30, transform: 'translate(30, 30)' },
            'text': { 'font-size': 14, text: '', 'text-anchor': 'middle', 'ref-x': .5, 'ref-y': .5, ref: 'circle', 'y-alignment': 'middle', fill: 'black', 'font-family': 'Arial, helvetica, sans-serif' }
        }
    }, joint.shapes.basic.Generic.prototype.defaults)
});


// Add new top in TaskGraph
taskPaper.on('blank:pointerdblclick', function(e, x, y) {
	if (editModeTask) {
	  mouseX = x - 25
	  mouseY = y - 25
	  var top = (new joint.shapes.basic.newCircle({
		    position: { x: mouseX, y: mouseY },
		    size: { width: 50, height: 50 },
		    id_top: iTopsTask,
		    attrs: { circle: { fill: 'white', class: 'taskTop', 'stroke-width': 2 }}
		})).addTo(taskGraph);
		top.attr('.topValue/text', "1");
		top.attr('.topName/text', iTopsTask.toString());
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
key('q', function(){
	if (editModeTask) {
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
	}
});

//Dialog bar

function dialogBar(mess, value, posX, posY){
	$("#dialog_bar p").html(mess);
	$('#dialog_bar').css('top',posY+'px');
	$('#dialog_bar').css('left',posX+'px');
	$('#dialog_val').val(value);
	$('#dialog_bar').show('fast');
	$('#dialog_bar').css('z-index', '99');
}
var dialogCell;
$('#accept_dialog').click(function(){
	value = $('#dialog_val').val();
	if ((value % 1) === 0) {
		$('#dialog_bar').hide('fast');
		$('#dialog_bar').css('z-index', '-99');
		if (dialogTopTask) {
			dialogCell.attr('.topValue/text', value)
			for (i=0; i < arrayOfTopsTask.length; i++){
				if (dialogCell.id == arrayOfTopsTask[i][0]){
					arrayOfTopsTask[i][2] = value 	// Change VAL in Array
				}
			}
			dialogTopTask = false;
		}
		else if (dialogLinkTask) {
			dialogCell.label(0,{
				attrs: {
					text: {text: value}
				}
			})
			for (i=0; i < arrayOfLinksTask.length; i++) {
				if (dialogCell.id == arrayOfLinksTask[i][0]){
					arrayOfLinksTask[i][3] = value;
				}
			}
			dialogLinkTask = false;
		}		
	}
	else {
		$('#dialog_bar').css('border-color', 'red');
	}


})

//Change top value
taskPaper.on('cell:pointerdblclick', function(cellView, e){
	if (editModeTask == false){
		dialogTopTask = true;
		message = "Input top weight value"
		dialogCell = cellView.model;
		value = cellView.model.attr('.topValue/text')
		x = e.clientX
		y = e.clientY
		dialogBar(message, value, x, y);
	}
});

// Change link value
taskPaper.on('link:options', function(e,link){
	dialogCell = link.model
	dialogLinkTask = true;
	message = "Input link weight value"
	value = link.model.attributes.labels[0].attrs.text.text;
	x = e.clientX
	y = e.clientY
	dialogBar(message, value, x, y);	
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