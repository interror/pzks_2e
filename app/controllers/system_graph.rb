class TopSys

	attr_accessor :top, :links, :status

	def initialize(top)
		@top = top
		@links = []
		@status = 'wait'
	end

end

class GraphSys

	def initialize(tops_lst,schema)
		@graph = tops_lst
		test_graph(schema)
	end

	def test_graph(schema)
		create_links(schema)
		connection_test
		holistic_graph?
	end

	def show
		@graph.each do |elm|
			print "#{elm.top} -"
			elm.links.each {|el| print " #{el.top}" }
			print " - #{elm.status}"
			print "\n"
		end
	end

	def holistic_graph?
		for i in 0..@graph.length-1
			if @graph[i].status == "wait"
				return false
			end
		end
	return true
	end

private

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
			elm1.links << elm2
			elm2.links << elm1
		end
	end

	def connection_test
		cycle_array = [@graph[0]]
		connection_array = [1]
		while connection_array.empty? == false
			connection_array = []
			cycle_array.each do |elm|
				elm.status = "check"
				elm.links.each do |link_elm|
					connection_array << link_elm if link_elm.status == "wait"
				end
			end
			cycle_array = connection_array
		end
	end

end






# arr = [0,1,2,3,4,5]
# arr_of_links = [[0, 1], [1, 3], [1, 2], [2, 4], [2, 5]]
# array_of_objects = []

# arr.each { |i| array_of_objects << TopSys.new(i) }

# graph = GraphSys.new(array_of_objects,arr_of_links)
# p graph.holistic_graph?
# graph.show