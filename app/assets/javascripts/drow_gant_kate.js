function drowGantDiagramK(data){
	var opened = window.open("");
	opened.document.write("<html><head><title>Gant</title></head><body><canvas id='gant_canvas'></canvas></body></html>");
	gant = opened.document.getElementById('gant_canvas');
	context = gant.getContext('2d');
	var x_width = (data[0][0].length * 40)+40;
	gant.width = x_width;
	gant.height = ((data[0].length + data[1].length)*30)+60;
	var x = 20;
	var y = 20;

	context.beginPath();
  context.rect(x, y, x_width - 40, 30);
  context.fillStyle = 'gray';
  context.fill();
  context.lineWidth = 2;
  context.strokeStyle = 'black';
  context.stroke();
	context.font="bold 18px Georgia";
  context.fillStyle = 'black';
  context.fillText("Processors work", ((x_width - 40)/2-25), y+20);
  y += 30;
	for (i=0;i<data.length;i++){
		for (j=0; j<data[i].length;j++){
			for (k=0; k<data[i][j].length;k++){
				if (i == 0 && j == 0) {
					context.beginPath();
				  context.rect(x, y, 40, 30);
				  context.fillStyle = 'gray';
				  context.fill();
				  context.lineWidth = 2;
				  context.strokeStyle = 'black';
				  context.stroke();
				  if (k==0) {
					  context.font="16px Georgia";
					  context.fillStyle = 'black';
					  context.fillText("Takts", x+2, y+20);
				  } else {
				  	context.font="16px Georgia";
					  context.fillStyle = 'black';
					  context.fillText(data[i][j][k], x+10, y+20);	
				  };
				  x += 40;
				} else if (i == 0) {
					if (k == 0){
						context.beginPath();
					  context.rect(x, y, 40, 30);
					  context.fillStyle = 'gray';
					  context.fill();
					  context.lineWidth = 2;
					  context.strokeStyle = 'black';
					  context.stroke();
				  	context.font="16px Georgia";
					  context.fillStyle = 'black';
					  context.fillText("#"+data[i][j][k], x+10, y+20);
				  } else {
				  	context.beginPath();
					  context.rect(x, y, 40, 30);
					  if (data[i][j][k] == null) {
						  context.fillStyle = 'white';
						  context.fill();
						  context.lineWidth = 2;
						  context.strokeStyle = 'black';
						  context.stroke();
					  } else {
					  	context.fillStyle = 'blue';
						  context.fill();
						  context.lineWidth = 2;
						  context.strokeStyle = 'black';
						  context.stroke();
						  context.font="16px Georgia";
						  context.fillStyle = 'black';
						  context.fillText(data[i][j][k], x+10, y+20);
					  }
				  } 
				  x += 40;
				} else if (i == 1){
					if (j != 0){
						if (k == 0){
							context.beginPath();
						  context.rect(x, y, 40, 30);
						  context.fillStyle = 'gray';
						  context.fill();
						  context.lineWidth = 2;
						  context.strokeStyle = 'black';
						  context.stroke();
					  	context.font="16px Georgia";
						  context.fillStyle = 'black';
						  context.fillText(data[i][j][k], x+10, y+20);
						} else {
							context.beginPath();
					  	context.rect(x, y, 40, 30);
							if (data[i][j][k] == null) {
							  context.fillStyle = 'white';
							  context.fill();
							  context.lineWidth = 2;
							  context.strokeStyle = 'black';
							  context.stroke();
						  } else {
						  	context.fillStyle = 'pink';
							  context.fill();
							  context.lineWidth = 2;
							  context.strokeStyle = 'black';
							  context.stroke();
							  context.font="16px Georgia";
							  context.fillStyle = 'black';
							  context.fillText(data[i][j][k], x+10, y+20);
						  };
						};
						x += 40
					} else if (j == 0 && k == 0) {
						context.beginPath();
					  context.rect(x, y, x_width - 40, 30);
					  context.fillStyle = 'gray';
					  context.fill();
					  context.lineWidth = 2;
					  context.strokeStyle = 'black';
					  context.stroke();
				  	context.font="bold 18px Georgia";
					  context.fillStyle = 'black';
					  context.fillText("Routes", (x_width - 40)/2, y+20);
					};
				};
			};
			y += 30
			x = 20
		};
  };

};