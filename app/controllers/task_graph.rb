class TopTask

	attr_accessor :top, :in, :out, :status, :weight, :r, :links_count, :nki

	def initialize(top, weight)
		@top = top
		@in = []
		@out = []
		@status = :wait # :wait, :ready
		@weight = weight
		@nki = 0
		@r = 0
		@links_count = 0
	end

	def ready_stat
		@status = :ready
	end

end

class TaskGraph

	attr_accessor :sort_res1, :sort_res2, :sort_res3, :levels, :array_res1, :array_res2, :array_res3, :t_critical, :tops_sum

	def initialize(tops_lst,schema)
		@graph = tops_lst
		@sort_res1 = ""
		@sort_res2 = ""
		@sort_res3 = ""
		@array_res1 = []
		@array_res2 = []
		@array_res3 = []
		@levels = []
		@t_critical = 0
		@tops_sum = 0
		run_program(schema)
	end

	def sums_of_tops
		return @graph.inject(0){|acc, var| acc + var.weight}
	end

	def run_program(schema)
		create_links(schema)
		if cyclic?(schema) == false
			@graph.each do |elm|
				elm.links_count = (elm.in.length + elm.out.length)
			end
			construct_lvls(schema)
			create_links(fix_links)

			create_matrix

			@graph.pop(@fix_count)
		end
		@tops_sum = sums_of_tops
	end

	def construct_lvls(schema)
		@graph.each {|node| node.ready_stat if node.in.empty? }
		
		arrayOfGraph = @graph.dup
		arrayOfLoads = []
		levels = []
		arrayOfGraph.each{|node| arrayOfLoads << node if node.status == :ready }
		arrayOfLoads.each{|del| arrayOfGraph.delete(del) }
		levels << arrayOfLoads

		while !arrayOfGraph.empty?
			arrayOfLoads.each do |node|
				node.out.each do |out_node|
					if out_node.status == :wait
						out_node.ready_stat if all_in_node_ready?(out_node)
					end
				end
			end
			arrayOfLoads = []
			arrayOfGraph.each{|node| arrayOfLoads << node if node.status == :ready }
			arrayOfLoads.each{|del| arrayOfGraph.delete(del) }
			levels << arrayOfLoads
		end
		@levels = get_tops(levels)
	end

	def get_tops(array)
		res = []
		array.each do |arr|
			buf = []
			arr.each{|node| buf << node.top }
			res << buf
		end
		return res
	end

	def all_in_node_ready?(node)
		node.in.each{|in_node| return false if in_node.status == :wait }
		return true
	end


	def fix_links
		new_schema = []
		counter = []
		@graph.each {|elm| counter << elm.top }
		counter = counter.max
		@graph.each do |elm|
			if elm.out.empty?
				new_schema << [elm.top, counter+=1]
			end
		end
		new_schema.each{|elm| @graph << TopTask.new(elm[1],0)}
		@fix_count = new_schema.length
		return new_schema
	end


	def sort1
		matrix = Array.new(@matrix.length) { |i| i = Array.new(@matrix.length) { |i| i=0 } }
		
		make_copy(matrix, @matrix)
		weightsArray = []
		topsArray = []
		@graph.each {|elm| weightsArray << elm.weight; topsArray << elm.top }
		set_weights(matrix, weightsArray)
		

		matr_of_crit_paths = critical_path
		matr_of_weight_crit = critical_path_weight(matrix)

		arrayOfNki = []
		arrayOfTki = []

		matr_of_crit_paths.each{|arr| arrayOfNki << arr.max }
		arrayOfNki.pop(@fix_count)

		matr_of_weight_crit.each{|arr| arrayOfTki << arr.max }
		arrayOfTki.pop(@fix_count)

		globalTki = arrayOfTki.max
		@t_critical = globalTki
		globalNki = arrayOfNki.max

		
		for i in 0..@graph.length-1
			@graph[i].r = (arrayOfNki[i]/globalNki.to_f)+(arrayOfTki[i]/globalTki.to_f)
		end

		res = @graph.sort {|x,y| y.r <=> x.r }
		res.each {|x| @sort_res1 << "#{x.top}(#{x.r.round(2)}) " }
		res.each {|x| @array_res1 << x.top}
	end

	def sort2
		matrix = Array.new(@matrix.length) { |i| i = Array.new(@matrix.length) { |i| i=0 } }
		
		make_copy(matrix, @matrix)
		weightsArray = []
		topsArray = []
		@graph.each {|elm| weightsArray << elm.weight; topsArray << elm.top }
		set_weights(matrix, weightsArray)
		

		matr_of_crit_paths = critical_path

		arrayOfNki = []

		matr_of_crit_paths.each{|arr| arrayOfNki << arr.max }
		arrayOfNki.pop(@fix_count)
		
		for i in 0..@graph.length-1
			@graph[i].nki = arrayOfNki[i]
		end
		res = @graph.sort{|x,y| [y.links_count, y.nki] <=> [x.links_count, x.nki] }
		res.each {|x| @sort_res2 << "#{x.top}(#{x.links_count},#{x.nki}) " }
		res.each {|x| @array_res2 << x.top}
	end

	def sort3
		res = @graph.shuffle
		res.each {|x| @sort_res3 << "#{x.top}() " }
		res.each {|x| @array_res3 << x.top}
	end

	def make_copy(m1,m2)
		for i in 0..m1.length-1
			for j in 0..m1.length-1
				m1[i][j] = m2[i][j]
			end
		end
	end

	def set_weights(m1,weights)
		for i in 0..m1.length-1
			for j in 0..m1.length-1
				if m1[i][j] == 1
					m1[i][j] = weights[i]
				end
			end
		end
	end


	def show
		@graph.each do |elm|
			print "#{elm.top} - in ["
			elm.in.each {|el| print " #{el.top}" }
			print "] out ["
			elm.out.each {|el| print " #{el.top}"}
			print "]"
			print " - #{elm.status}"
			print "\n"
		end
	end


	
	def create_links(schema)
		schema.each do |link|
			for i in 0..@graph.length-1
				if link[0] == @graph[i].top
					elm1 = @graph[i]
				end
				if link[1] == @graph[i].top
					elm2 = @graph[i]
				end
			end
			elm1.out << elm2
			elm2.in << elm1
		end
	end

	def create_matrix
		@matrix = Array.new(@graph.length) { |i| i = Array.new(@graph.length) { |i| i = 0 } }
		endTopsCounter = 0
		@graph.each do |elm|
			x = @graph.index {|tops| tops.top == elm.top }
			endTopsCounter += 1 if elm.out.empty?

			elm.out.each do |elm_out|
				y = @graph.index {|tops| tops.top == elm_out.top }
				@matrix[x][y] = 1
			end
		end
	end

	def cyclic?(graph)
	  ## The set of edges that have not been examined
	  graph = graph.dup
	  n, m = graph.transpose
	  ## The set of nodes that are the supremum in the graph
	  sup = (n - m).uniq
	  while sup_old = sup.pop do
	    sup_old = graph.select{|n, _| n == sup_old}
	    graph -= sup_old
	    sup_old.each {|_, ssup| sup.push(ssup) unless graph.any?{|_, n| n == ssup}}
	  end
	  !graph.empty?
	end

	def self.matrix_show(matrix) #Printing matrix method
		matrix.each do |array| 
			array.each do |elm|
				if elm == -1
					print "@" + " "
 				else	
				print "#{elm}" + " "
				end
			end
			print "\n"
		end
	end

	def critical_path
		paths = Array.new(@matrix.length) { |i| i = Array.new(@matrix.length) { |i| i=0 } }
		for i in 0..paths.length-1
			for j in 0..paths.length-1
				if @matrix[i][j] > 0
					paths[i][j] = @matrix[i][j]
				else
					paths[i][j] = -1
				end
			end
			paths[i][i] = 0
		end


		for k in 0..paths.length-1
			for i in 0..paths.length-1
				for j in 0..paths.length-1
					if paths[i][k] >= 0 && paths[k][j] >= 0
						paths[i][j] = [paths[i][j],(paths[i][k] + paths[k][j])].max
					end
				end
			end
		end
		return paths
	end

	def critical_path_weight(matrix)
		paths = Array.new(matrix.length) { |i| i = Array.new(matrix.length) { |i| i=0 } }
		for i in 0..paths.length-1
			for j in 0..paths.length-1
				if matrix[i][j] > 0
					paths[i][j] = matrix[i][j]
				else
					paths[i][j] = -1
				end
			end
			paths[i][i] = 0
		end


		for k in 0..paths.length-1
			for i in 0..paths.length-1
				for j in 0..paths.length-1
					if paths[i][k] >= 0 && paths[k][j] >= 0
						paths[i][j] = [paths[i][j],(paths[i][k] + paths[k][j])].max
					end
				end
			end
		end
		return paths
	end



end

# arr_obj = []
# # arr = [[0, "3"], [1, "1"], [3, "2"], [4, "7"], [5, "6"], [6, "7"], [7, "5"], [8, "5"]]
# # arr_links = [[7, 0], [0, 8], [1, 8], [8, 5], [5, 6], [8, 4], [8, 3], [6, 3]]
# arr = [[0, "1"], [1, "1"], [2, "1"], [3, "1"], [4, "1"], [5, "1"],[6,"1"]]
# arr_links = [[0, 3], [1, 4], [1, 3], [2, 4], [3, 5], [4, 5]]




# arr.each {|elm| arr_obj << TopTask.new(elm[0], elm[1].to_i) }
# graph = TaskGraph.new(arr_obj,arr_links)
#graph.construct_lvls(arr_links)