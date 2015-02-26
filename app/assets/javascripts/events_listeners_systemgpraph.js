var arrayOfTopsSys = [] // [0] Original id of top, [1] Top ID (my id, get cell.attributes.id_top)
var arrayOfLinksSys = [] // [0] Original id of link, [1] Top Sourse id_top [2] Top Target id_top
var iTopsSys = 0;
// Change edit mode for system graph
var editModeSys;
$('#editModeSystem').on('change', function(evt) {
  editModeSys = $(evt.target).is(':checked');
  if (editModeSys) {
    $('#system_container .link-tool .tool-remove').css('display', 'block');
  }
  else{
    $('#system_container .link-tool .tool-remove').css('display', 'none');
  }
});

// Add new syselm in TaskGraph
systemPaper.on('blank:pointerdblclick', function(e, x, y) {
  if (editModeSys) {
    mouseX = x - 30
    mouseY = y - 30
    var top = new joint.shapes.basic.Rect({
        position: { x: mouseX, y: mouseY },
        size: { width: 60, height: 60 },
        id_top: iTopsSys,
        attrs: { rect: { fill: 'white', class: 'sysTop', rx: 10, ry: 10, 'stroke-width': 2}, text: {text: iTopsSys, fill: 'black'} }
    });
    systemGraph.addCell(top);
    iTopsSys++;
    arrayOfTopsSys.push([top.id, top.attributes.id_top]) // Write to Array of Tops SYS
  }
});

// Select tops on Task Graph
var selectSysELements = [];

systemPaper.on('cell:pointerclick', function(cellView, e){
    if (cellView.model.isLink()) return;
    if (editModeSys){
        cellView.model.attr(attrs.sysElmSelect);
        selectSysELements.push(cellView.model);
        jQuery.unique(selectSysELements);
        selectSysELements = selectSysELements.reverse();
        if (selectSysELements.length > 2){
            selectSysELements[0].attr(attrs.sysElmDefault);
            selectSysELements.shift();
        }
    }   
});

// Reset seletors on systemPaper
systemPaper.on('blank:pointerclick', function(){
    if (selectSysELements.length == 2) {
        selectSysELements[0].attr(attrs.sysElmDefault);
        selectSysELements[1].attr(attrs.sysElmDefault);
        selectSysELements = []
    }
});

// Add link between select system elements
key('q', function(){
  if (editModeSys){
    if (selectSysELements.length == 2) {
        src = selectSysELements[0]
        trg = selectSysELements[1]

            var link = new joint.dia.Link({
            source: { id: src.id },
            target: { id: trg.id },
            attrs: {
              '.connection': { 'stroke-width': 2 }
            }
        });
    systemGraph.addCell(link);
    arrayOfLinksSys.push([link.id, src.attributes.id_top, trg.attributes.id_top]) //Write to Array of links
    }
  }
});

// Remove top
systemPaper.on('cell:pointerdblclick', function(cellView, e){
  if (editModeSys){
    var delete_index;
    for (i=0; i < arrayOfTopsSys.length; i++){
      if (cellView.model.id == arrayOfTopsSys[i][0]){
        delete_index = i
      }
    }
    arrayOfTopsSys.splice(delete_index,1); // Delete from Array top
    cellView.model.remove(options);
  }
});

// Clear Graph Paper
$('#clear_sys_paper').click(function(){
  systemGraph.clear()
  arrayOfTopsSys = []
  iTopsSys = 0
});

//Graph to JSON
//Save to JSON
var jsonSysGraph;
$('#save_to_file_sys').click(function(){
  var file_name = prompt("File Name", "")
  var jsonSysGraph = systemGraph.toJSON();
  var jsonStringSys = JSON.stringify(jsonSysGraph);
  var blob = new Blob([jsonStringSys,'~::~',arrayOfTopsSys.toString(),"~::~",arrayOfLinksSys.toString(),"~::~",iTopsSys], {type: "text/plain;charset=utf-8"});
  saveAs(blob, file_name + "_system.json");
});

// Load from JSON
//Lestener on files ID
document.getElementById('file_sys').addEventListener('change', handleFileSelect, false);
//Load on paper JSON object
$('#load_from_file_sys').click(function(){
  jsonObjectSys = JSON.parse(textSys);
  systemGraph.fromJSON(jsonObjectSys);
});

// Remove link event for System
systemGraph.on('remove', function(cellView){
  if (editModeSys){
    if (cellView.isLink()) {
      delete_index = 0;
      for (i=0; i < arrayOfLinksSys.length; i++){
        if (cellView.id == arrayOfLinksSys[i][0]){
          delete_index = i
        }
      }
      arrayOfLinksSys.splice(delete_index,1);
    }
  }
});

// Send on Serv
$('#test_sys').click(function(){
  $.ajax({
    type: "POST",
    url: "/",
    data: { sys_data: [JSON.stringify(arrayOfTopsSys),JSON.stringify(arrayOfLinksSys)]}
  }); 
})