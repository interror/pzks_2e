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
		selectELements[0].attr(attrs.topDefault);
		selectELements[1].attr(attrs.topDefault);
		selectELements = []
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
	arrayOfLinksTask = []
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
	$("#file_task").trigger( "click" );
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

$('#sort_task_graph').click(function(){
	$('#background_sort').show();
  $('#sort_bar').show('fast');
})
$('#close_sort_bar').click(function(){
  $('#background_sort').hide('fast');
  $('#sort_bar').hide('fast');
});

function addResultMessageToSortBar(message){
	$("#sort_bar p").html(message);
}

$('#sort1').click(function(){
	$.ajax({
	  type: "POST",
	  url: "/sort1",
	  data: { sort1_data: [JSON.stringify(arrayOfTopsTask),JSON.stringify(arrayOfLinksTask)]}
	});	
});

$('#sort2').click(function(){
	$.ajax({
	  type: "POST",
	  url: "/sort2",
	  data: { sort2_data: [JSON.stringify(arrayOfTopsTask),JSON.stringify(arrayOfLinksTask)]}
	});	
});

$('#sort3').click(function(){
	$.ajax({
	  type: "POST",
	  url: "/sort3",
	  data: { sort3_data: [JSON.stringify(arrayOfTopsTask),JSON.stringify(arrayOfLinksTask)]}
	});	
});

$("#graph_generator").click(function(){
	$('#background_generator').show();
  $('#generator_bar').show('fast');
});

$("#close_graph_generator").click(function(){
  $('#background_generator').hide('fast');
  $('#generator_bar').hide('fast');
});

$("#generate").click(function(){
	minWeight = $("#generator_bar input[name='minWeight']").val()
	maxWeight = $("#generator_bar input[name='maxWeight']").val()
	num = $("#generator_bar input[name='num']").val()
	correlation = $("#generator_bar input[name='correlation']").val()
	if ($.isNumeric(minWeight) && $.isNumeric(maxWeight) && $.isNumeric(num) && $.isNumeric(correlation)){
		$("#generator_bar").css('border-color','black');
		$.ajax({
		  type: "POST",
		  url: "/generate",
		  data: { generator_data: [minWeight, maxWeight, num, correlation]}
		});
	}
	else{
		$("#generator_bar").css('border-color','red');
	}
});

function drowGenerateGraph(levelsM, nodesM, wnodesM, linksM, wlinksM, maxTop){
	
	nodes = nodesM.split(",") // Nodes
	for (i=0; i < nodes.length; i++){
		nodes[i] = parseInt(nodes[i])
	}
	
	levels = levelsM.split("|") // LEVELS
	levels = _.without(levels, "");
	for (i = 0; i < levels.length ; i++) {
		levels[i] = levels[i].split(",")
		for (j=0; j<levels[i].length; j++){
			levels[i][j] = parseInt(levels[i][j])
		}
	};
	weight_nodes = wnodesM.split(",") // Weight for nodes
	links = linksM.split("|") // LINKS
	links = _.without(links, "");
	for (i=0; i<links.length; i++) {
		links[i] = links[i].split(",")
		for (j=0; j<links[i].length; j++){
			links[i][j] = parseInt(links[i][j])
		}
	}
	weight_links = wlinksM.split(",") // Weights LINKS

	iTopsTask = parseInt(maxTop);

	// console.log(nodes)
	// console.log(weight_nodes)
	// console.log(links)
	// console.log(weight_links)

	if (nodes.length <= 10){
		posX = 20
		posY = 20
		arrayTopsWithId = []

		for (i=0; i<levels.length; i++){
			for (j=0; j<levels[i].length; j++){
				indexTop = levels[i][j]
				indexVal = nodes.indexOf(indexTop)
				value = weight_nodes[indexVal]

			  var top = (new joint.shapes.basic.newCircle({
				    position: { x: posX, y: posY },
				    size: { width: 50, height: 50 },
				    id_top: indexTop,
				    attrs: { circle: { fill: 'white', class: 'taskTop', 'stroke-width': 2 }}
				})).addTo(taskGraph);
				top.attr('.topValue/text', value);
				top.attr('.topName/text', indexTop.toString());
				arrayOfTopsTask.push([top.id, top.attributes.id_top, value]); // Write to ARRAY OF TOPS
				posX = posX + 60 + 50
			}
			posX = 20
			posY = posY + 50 + 50
		}

		for (i=0; i<links.length;i++){
			
			for (j=0; j<arrayOfTopsTask.length; j++){
				var cell_1;
				var cell_2;
				if (links[i][0] == arrayOfTopsTask[j][1]){
					cell_1 = arrayOfTopsTask[j][0]
				}
				if (links[i][1] == arrayOfTopsTask[j][1]){
					cell_2 = arrayOfTopsTask[j][0]
				}
			}

				src = taskGraph.getCell(cell_1)
			  trg = taskGraph.getCell(cell_2)

					var link = (new joint.dia.Link({
				    source: { id: src.id },
				    target: { id: trg.id },
				    attrs: {
				    	'.connection': { 'stroke-width': 2 },
				      '.marker-target': { d: 'M 10 0 L 0 5 L 10 10 z' }
				    },
				    labels: [
				        { position: .5, attrs: { text: { text: weight_links[i] } } }
				    ]
					})).addTo(taskGraph);
					arrayOfLinksTask.push([link.id, src.attributes.id_top, trg.attributes.id_top, weight_links[i]])

		}
	}
	else {
		for (i=0; i<nodes.length; i++){
			arrayOfTopsTask.push(["none", nodes[i], weight_nodes[i]]);
		}
		for (i=0; i<links.length; i++){
			arrayOfLinksTask.push(["none", links[i][0], links[i][1], weight_links[i]])
		}
	}
}

$("#gant").click(function(){
	coef = $("#coefficient").val()
	phys_links = $("#phys_links").val()
 	// console.log(phys_links)	
	// console.log(duplex)
	sort_var = $( "input:radio[name=sort]:checked" ).val();
  // console.log(sort_var)
  tops = JSON.stringify(arrayOfTopsTask)
  links = JSON.stringify(arrayOfLinksTask)
  procs = JSON.stringify(arrayOfTopsSys)
  connections =  JSON.stringify(arrayOfLinksSys)
  // console.log(arrayOfTopsTask)
  // console.log(arrayOfLinksTask)
  // console.log(arrayOfTopsSys)
  // console.log(arrayOfLinksSys)
  $.ajax({
		  type: "POST",
		  url: "/gant",
		  data: { gant_data: [duplex, phys_links, sort_var, coef, tops, links, procs, connections]},
		  success: function (data) {
        drowGantDiagramK(data);
      }
		});
});
