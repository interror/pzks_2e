INF = 1<<32
matrix = [[0,1,0,1,0,0,0],
					[1,0,1,0,1,0,0],
					[0,1,0,0,0,1,0],
					[1,0,0,0,1,0,0],
					[0,1,0,1,0,1,0],
					[0,0,1,0,1,0,1],
					[0,0,0,0,0,1,0]]					


for i in 0..matrix.length-1
	for j in 0..matrix[i].length-1
		if i != j
			matrix[i][j] = INF if matrix[i][j] == 0
		end
	end
end


def floyd_worshel(matr)
vnum = matr.length
dist = matr
	for k in 0..vnum-1
		for i in 0..vnum-1
			for j in 0..vnum-1
				dist[i][j] = [dist[i][j], (dist[i][k] + dist[k][j])].min
			end
		end
	end
 dist.each{|i| p i}
end

floyd_worshel(matrix)