class TopTask

	attr_accessor :top, :in, :out, :status

	def initialize(top)
		@top = top
		@in = []
		@out = []
		@status = "wait"
	end

end

class TaskGraph

	def initialize(tops_lst,schema)
		@graph = tops_lst
		run_program(schema)
	end

	def run_program(schema)
		create_links(schema)
		# create_matrix
		p cyclic?(schema)
		
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
			elm1.out << elm2
			elm2.in << elm1
		end
	end

	def create_matrix
		@matrix = Array.new(@graph.length) { |i| i = Array.new(@graph.length) { |i| i = 0 } }

		@graph.each do |elm|
			x = @graph.index {|tops| tops.top == elm.top }
			elm.out.each do |elm_out|
				y = @graph.index {|tops| tops.top == elm_out.top }
				@matrix[x][y] = 1
			end
		end
		@matrix.each {|arr| p arr}
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

end

# arr = [0, 3, 4, 5, 6, 8, 9, 10]
# arr_links = [[0, 5], [3, 5], [3, 6], [5, 8], [4, 8], [6, 8], [9,10]]
# arr_obj = []

# arr.each {|elm| arr_obj << TopTask.new(elm) }
# graph = TaskGraph.new(arr_obj,arr_links)
# graph.show

