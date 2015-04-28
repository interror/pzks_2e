require 'task_model.rb'
require 'controller_model.rb'

class ProcessorElement

	attr_accessor :id, :links, :task, :stay_time, :controller, :memory, :result, :wait_data, :active_forwards

	def initialize(top, physical_links, connection)
		@id = top
		@links = []
		@controller = ControllerModel.new(id, connection, physical_links) # Add controller
		#@work = false # true / false
		@wait_data = false
		@stay_time = 0
		@task = nil
		@memory = {}
		@result = "Result Of Operation"
		@active_forwards = []
	end

	def active_forwards_done?
		if !@active_forwards.empty?
			@active_forwards.each do |link|
				return false if link.done == false
			end
			return true
		end
		return false
	end

end


class SystemModel

	attr_accessor :model

	def initialize(tops_lst,schema,coef_of_work_for_all_procs=1,physical_links = 2, connection=:fullduplex)
		@coeficient = coef_of_work_for_all_procs
		@history_cache = {} # Processor ID : Task Top
		@model = []
		@connection_type = connection
		tops_lst.each { |i| @model << ProcessorElement.new(i, physical_links, connection) }
		create_links(schema)
		@model.each{|prc| @history_cache[prc.id] =  [] } # Create processor id in history cache
		ControllerModel.duplicate_links(@model)
	end

	def show
		@model.each do |elm|
			print "#{elm.id} -["
			elm.links.each {|el| print "#{el.id} " }
			print "]\n"
		end
	end

	def start(task_graph)
		working_model(task_graph)
	end

	def construct_gant_diagram
		pos = @gantDiagram.max_by{|k,v| v.length}.last.length
		processors_array = []
		@gantDiagram.each do |k,v| 
			v[0] = k
			v[pos] = nil
			processors_array << v
		end
		array = (0..pos).to_a
		processors_array.insert(0, array)
		transfer_array = []
		@hash_of_transfering.each do |key, val|
			val[0] = key
			val[pos] = nil
			transfer_array << val
		end
		transfer_array.insert(0, array)
		return [processors_array, transfer_array]
	end

private

	def create_links(schema)
		schema.each do |link|
			for i in 0..@model.length-1
				if link[0] == @model[i].id
					elm1 = @model[i]
				end
				if link[1] == @model[i].id
					elm2 = @model[i]
				end
			end
			elm1.links << elm2
			elm2.links << elm1
		end
	end

	def show_work(working_array)
		working_array.each do |elm|
			if elm.class == ProcessorElement
				print "ID: #{elm.id} "
				print "TASK:[TOP:#{elm.task.top}, W:#{elm.task.weight}, C:#{elm.task.work_counter}] #{elm.task.status}\n"
			elsif elm.class == Transfer
				print "(#{elm.link.from.id}->#{elm.link.to.id})" 
				print "SEND to: #{elm.send_connect.send.id}: GET from:#{elm.get_connect.get.id}:"
				print "C: #{elm.work_counter}\n"
			end
		end
	end


	def working_model(task_graph)	
		n = @model.length #Count of processors in system model
		@coef = @coeficient * 1 # Coeficient of Processor work
		ready_array = []
		task_graph.order_list.each{|elm| ready_array << elm if (elm.status_is_ready? && ready_array.length < n) }
		for i in 0..ready_array.length-1
			@model[i].task = ready_array[i]
		end
		work_array = []
		@model.each{|prc| work_array << prc if prc.task != nil}
		# Stay time counter
		@model.each {|prc| prc.stay_time += 1 if prc.task == nil}
		ready_array = []
		ready_for_send = []
		# show_work(work_array)  # SHOW
		# puts "==="

		takts = 0
		# @gantDiagram = Array.new(n) { |i| i = Array.new }
		@gantDiagram = {}
		@model.each{|prc| @gantDiagram[prc.id] = [] }
		@hash_of_transfering = {}
		initialize_transfering_diagram
		## START CYCLE
		while !work_array.empty?
			takts += 1
			# Task Counter -1
			for i in 0..work_array.length-1
				# Work counter
				if work_array[i].class == ProcessorElement
					if work_array[i].task.status != :wait_data
						work_array[i].task.work_counter -= @coef 						#Sub coef of work in processor
						# @gantDiagram[work_array[i].id][takts] = "#{work_array[i].task.top}"
						buffer = @gantDiagram[work_array[i].id]
						buffer[takts] = "#{work_array[i].task.top}"
						@gantDiagram[work_array[i].id] = buffer
					elsif work_array[i].task.status == :wait_data && !work_array[i].wait_data
						send = initialize_sending(work_array[i])
						send.each do |elm|
							res = []
							lr = []
							find_path(elm.from, elm.to, res, lr)
							min_path = lr.min_by { |i| i.length }
							elm.path = min_path
							# elm.path.each{|i| print"#{i.id} "}
							# print "\n"
							ready_for_send << elm
							work_array[i].active_forwards << elm
							
						end
						work_array[i].wait_data = true
					end

					if work_array[i].task.work_counter <= 0
						# Write result data to Memory in Proc. Elm
						work_array[i].memory[work_array[i].task.top] = work_array[i].result
						# Write in history of model
						@history_cache[work_array[i].id] << work_array[i].task.top
						# Task is DONE
						work_array[i].task.done_status
						# kill this task
						work_array[i] = nil
					end
				end

				if work_array[i].class == Transfer
					work_array[i].work_counter -= 1
					#@gantDiagram[work_array[i].get_connect.get.id+n][takts-1] = "#{work_array[i].send_connect.send.id}(#{work_array[i].link.to.task.top})"
					arr = @hash_of_transfering["#{work_array[i].get_connect.get.id}-#{work_array[i].send_connect.send.id}"]
					arr[takts-1] = "#{work_array[i].link.to.task.top}"
					if work_array[i].work_counter <= 0
						work_array[i].link.add = false

						work_array[i].send_connect.send = nil
						work_array[i].get_connect.get = nil

						if (work_array[i].get_connect.get == nil && work_array[i].get_connect.send == nil)&&(work_array[i].send_connect.send == nil && work_array[i].send_connect.get == nil)
							work_array[i].get_connect.status = false
							work_array[i].send_connect.status = false
						end

						
						if work_array[i].link.final == true
							# work_array[i].link.to.task.ready_status
							work_array[i].link.done = true
							if work_array[i].link.to.active_forwards_done?
								work_array[i].link.to.task.ready_status
								work_array[i].link.to.active_forwards = []
								work_array[i].link.to.wait_data = false
								work_array[i].link.to.task.work_counter -= @coef 						#Sub coef of work in processor
								#@gantDiagram[work_array[i].link.to.id][takts] = "#{work_array[i].link.to.task.top}"
								buffer = @gantDiagram[work_array[i].link.to.id]
								buffer[takts] = "#{work_array[i].link.to.task.top}"
								@gantDiagram[work_array[i].link.to.id] = buffer
							end
							work_array[i].link.final == false
						end
						work_array[i] = nil
					end
				end

			end

			# all with done status is NIL
			@model.each{|prc| prc.task = nil if prc.task != nil && prc.task.status == :done}
			# Stay time counter
			@model.each {|prc| prc.stay_time += 1 if prc.task == nil}

			# Create ARRAY for ready tasks
			task_graph.order_list.each{|elm| ready_array << elm if (elm.all_parent_task_done? && elm.status_is_ready? && elm.weight == elm.work_counter && !include_task?(elm)) }
			task_graph.order_list.each{|elm| ready_array << elm if elm.status == :wait_data && !include_wait_top?(elm, work_array) }

			# Add connects for counter (WORK ARRAY)
			for i in 0..ready_for_send.length-1
				if !ready_for_send[i].path.empty? && !ready_for_send[i].add
					send(ready_for_send[i], work_array, takts) == false
				end
			end

			# Delete nil OBJECTS fro work array
			work_array.delete(nil)

			

			# Add tasks from READY ARRAY to WORK ARRAY
			for i in 0..ready_array.length-1
				if any_empty_processor?
					processor = find_max_stay_processor
					processor.task = ready_array[i]
					processor.stay_time = 0
					ready_array[i] = nil
					work_array << processor
				end
			end
					


			#p @history_cache
			# @model.each do |proc|
			# 	print "proc_id: #{proc.id}"
			# 	proc.active_forwards.each {|fwd| print "(#{fwd.from.id}-#{fwd.to.id})" }
			# 	print "\n"
			# end
			ready_array = []
			#show_work(work_array) #SHOW
			# puts "Stay time"
			# @model.each{|elm| puts elm.stay_time }
			#puts "==="
		end
		## END CYCLE
		#p takts
		#@model.each{|elm| puts elm.stay_time }

	end


	def initialize_transfering_diagram
		@model.each do |prc_from|
			prc_from.links.each do |prc_to|
				@hash_of_transfering["#{prc_from.id}-#{prc_to.id}"]=[]
			end
		end
	end


	def find_max_stay_processor
		return @model.max_by{ |elm| elm.stay_time }
	end

	def any_empty_processor?
		@model.each do |prc|
			return true if prc.task == nil
		end
		return false
	end

	def find_path(prc1, prc2, result, lr)
		result = result+[prc1]
		lr << result if prc1 == prc2
		prc1.links.each do |v|
			find_path(v,prc2,result,lr) if ! result.include?(v)
		end
	end

	def initialize_sending(prc)
		array_links = []
		elm = prc.task.in_links
		for i in 0..elm.length-1
			@history_cache.each do |key, val|
				array_links << [key,prc.id, prc.task.in_links_weight[i]] if val.include?(elm[i].top)
			end
		end

		for i in 0..array_links.length-1
			for j in 0..@model.length-1
				array_links[i][0] = @model[j] if array_links[i][0] == @model[j].id
				array_links[i][1] = @model[j] if array_links[i][1] == @model[j].id
			end
		end
		result_array = []
		array_links.each {|lnk| result_array << Link.new(lnk[0], lnk[1], lnk[2]) }
		return result_array
	end

	def include_wait_top?(top, array)
		array.each do |elm|
			if elm != nil && elm.class == ProcessorElement
				return true if elm.task == top
			end
		end
		return false
	end

	def send(lnk, work_array, takts)
		if lnk.path.length == 1
			lnk.done = true
			if lnk.to.active_forwards_done?
				lnk.to.task.ready_status
				lnk.to.active_forwards = []
				lnk.to.wait_data = false
				lnk.to.task.work_counter -= @coef 						#Sub coef of work in processor
				#@gantDiagram[lnk.to.id][takts] = "#{lnk.to.task.top}"
				buffer = @gantDiagram[lnk.to.id]
				buffer[takts] = "#{lnk.to.task.top}"
				@gantDiagram[lnk.to.id] = buffer
			end
		elsif !lnk.path.empty?
			if @connection_type == :halfduplex
				connect1 = lnk.path[0].controller.get_free_connect
				connect2 = lnk.path[1].controller.get_free_connect
			else
				connects = get_duplex_connection(lnk.path[0], lnk.path[1], work_array)
				connect1 = connects[0]
				connect2 = connects[1]
			end
		end
		if connect1 && connect2
			connect1.status = true
			connect1.send = lnk.path[1]

			connect2.status = true
			connect2.get = lnk.path[0]

			transfer_model = Transfer.new(connect1, connect2)
			transfer_model.work_counter = lnk.weight
			transfer_model.link = lnk
			if no_such_connection?(transfer_model, work_array)
				work_array.push(transfer_model) 
				lnk.add = true
				lnk.final = true if lnk.path[1] == lnk.to
				lnk.path.delete_at(1) if lnk.path[1] == lnk.to
				lnk.path.delete_at(0)
				return true
			end
			connect1.status = false
			connect1.send = nil

			connect2.status = false
			connect2.get = nil
			return false			
		end
		return false
	end

	def get_duplex_connection(c1, c2, work_array)
		work_array.each do |elm|
			if elm.class == Transfer
				if (elm.send_connect.send == c1 && elm.get_connect.get == c2)&&(elm.send_connect.get == nil && elm.get_connect.send == nil)
					connect2 = elm.send_connect
					connect1 = elm.get_connect
					return [connect1, connect2]
				end
			end
		end
		connect1 = c1.controller.get_free_connect
		connect2 = c2.controller.get_free_connect
		return [connect1, connect2]
	end

	def no_such_connection?(transfer, work_array)
		condition1 = transfer.send_connect.send
		condition2 = transfer.get_connect.get
		if @connection_type == :fullduplex
			for i in 0..work_array.length-1
				if work_array[i].class == Transfer
					return false if (work_array[i].send_connect.send == condition1) && (work_array[i].get_connect.get == condition2)
				end
			end
		return true
		else
			for i in 0..work_array.length-1
				if work_array[i].class == Transfer
					return false if (work_array[i].send_connect.send == condition1) && (work_array[i].get_connect.get == condition2)
					return false if (work_array[i].send_connect.send == condition2) && (work_array[i].get_connect.get == condition1)
				end
			end
		return true
		end
	end


	def include_task?(task)
		@model.each do |prc|
			return true if prc.task == task
		end
		return false
	end

	def correct_link?(link)
		return false if link.from == link.to
	return true
	end

end



# arr = [0, 1, 2, 3, 4, 5, 6]
# arr_of_links = [[0, 1], [1, 2], [2, 5], [4, 5], [4, 3], [0, 3], [1, 4], [6, 5]]
# # arr = [0,1]
# # arr_of_links = [[0,1]]

# arr_tops = [[0, "5"], [1, "4"], [2, "3"], [3, "6"], [4, "2"],[5,"1"],[6, "2"],[7,"4"]]
# arr_tops_links = [[0, 2, "2"], [0, 1, "3"], [4, 2, "2"], [1, 3, "5"], [2, 3, "2"],[5, 6, "3"],[3,7,"3"]]
# sort_arr = [7,2,3,0,4,1,5,6]

# :fullduplex
# 2
# 1
# arr_tops = [[0, "2"], [1, "3"], [2, "2"], [3, "5"], [4, "7"]]
# arr_tops_links = [[0, 2, "2"], [1, 2, "3"], [1, 3, "6"], [2, 4, "2"], [3, 4, "1"]]
# arr = [0, 2, 3, 4, 5]
# arr_of_links = [[0, 4], [2, 4], [3, 4], [4, 5]]
# sort_arr = [2, 1, 3, 4, 0]


# taskGraph = TaskGraphModel.new(arr_tops,arr_tops_links,sort_arr)
# taskGraph.order_graph
# #taskGraph.show

# systemModel = SystemModel.new(arr,arr_of_links,1,2,:fullduplex)
# #systemModel.show


# systemModel.start(taskGraph)
# #taskGraph.show
# systemModel.construct_gant_diagram