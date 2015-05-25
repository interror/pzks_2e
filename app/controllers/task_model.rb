class TopModel

	attr_accessor :top, :in_links, :out_links, :status, :weight, :work_counter, :in_links_weight, :out_links_weight

	def initialize(top, weight)
		@top = top
		@in_links = []
		@in_links_weight = []
		@out_links = []
		@out_links_weight = []
		@weight = weight
		@status = :wait # WAIT, READY, DONE
		@work_counter = weight
	end

	def ready_status
		@status = :ready
	end

	def status_is_ready?
		return true if @status == :ready
		return false
	end

	def done_status
		@status = :done
	end

	def all_parent_task_done?
		if @status == :wait
			for i in 0..@in_links.length-1
				return false if @in_links[i].status != :done
			end
			@status = :wait_data
			return true
		end
		return true
	end


end


class TaskGraphModel
	
	attr_accessor :graph, :order_list

	def initialize(tops_lst,schema,sort_lst)
		@order_list = sort_lst.clone
		@graph = []
		tops_lst.each{|node| @graph << TopModel.new(node[0],node[1].to_i)}
		create_links(schema)
		ready_for_work
	end

	def show
		@order_list.each do |elm|
			print "#{elm.top} - in ["
			elm.in_links.each {|el| print " #{el.top}" }
			print "] out ["
			elm.out_links.each {|el| print " #{el.top}"}
			print "]"
			print " - #{elm.status}"
			print "\n"
		end
	end

	def order_graph
		for i in 0..@order_list.length-1
			for j in 0..@graph.length-1
				if @order_list[i] == @graph[j].top
					@order_list[i] = @graph[j]
				end
			end
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
			elm1.out_links << elm2
			elm1.out_links_weight << link[2].to_i
			elm2.in_links << elm1
			elm2.in_links_weight << link[2].to_i
		end
	end

	def ready_for_work
		@graph.each{|elm| elm.ready_status if elm.in_links.empty?}
	end


end