function drowGantDiagram(array){
	var params = "width=800,height=500, resizable=yes,scrollbars=yes"
	var opened = window.open("","",params);
	opened.document.write("<html><head><link rel='stylesheet' type='text/css' href='gant.css'><link rel='stylesheet' type='text/css' href='joint.css'><title>Diagram</title></head><body style='overflow:auto'><table class='processors'></table><div id='gant_task_container'><table class='routes'></table></div></body></html>");
	prc_table = opened.document.querySelector(".processors");
	routes_table = opened.document.querySelector(".routes");
	// routes_table.style.float = "right"
	// prc_table.style.float = "left"



	array_of_processor = array[0]
	array_of_routes = array[1]

	for (i=0; i < array_of_processor[0].length; i++){
		row = prc_table.insertRow(-1);
		for (j=0; j < array_of_processor.length; j++){
			cell = row.insertCell(-1);
			if (i == 0 && j == 0){
				cell.innerHTML = "N"
			}
			else{
				cell.innerHTML = array_of_processor[j][i]
				if (array_of_processor[j][i] != null && i!=0 && j!=0){
					cell.style.background = "green"
				}
				else if (array_of_processor[j][i] != null && i!=0 && j==0){
					cell.style.background = "#e7e7e7"
				}
			}
		}
	}

	for (i=0; i < array_of_routes[0].length; i++){
		row = routes_table.insertRow(-1);
		for (j=0; j < array_of_routes.length; j++){
			cell = row.insertCell(-1);
			if (i == 0 && j == 0){
				cell.innerHTML = "N"
			}
			else{
				cell.innerHTML = array_of_routes[j][i]
				if (array_of_routes[j][i] != null && i!=0 && j!=0){
					cell.style.background = "yellow"
				}
				else if (array_of_routes[j][i] != null && i!=0 && j==0){
					cell.style.background = "#e7e7e7"
				}
			}
		}
	}
};