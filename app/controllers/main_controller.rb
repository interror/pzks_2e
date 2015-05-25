class MainController < ApplicationController
	require 'system_graph'
	require 'task_graph'
	require 'graph_generator'
	require 'system_model'

	skip_before_action :verify_authenticity_token

	def menu
		
	end

	def gant
		data = params['gant_data']	
		arrays = []
		data[4..7].each{|elm| arrays.push(JSON.parse(elm))}
		arrays.map! do |array|
			array.map! { |e| e = e[1..-1] }
		end
		tops_array = arrays[0]
		links_array = arrays[1].map{|e| e = e[0..1] }
		array_of_objects = []
		tops_array.each {|elm| array_of_objects << TopTask.new(elm[0],elm[1].to_i) }
		graph = TaskGraph.new(array_of_objects,links_array)
		if data[2] == "sort1"
			graph.sort1
			sort_array = graph.array_res1
		elsif data[2] == "sort2"
			graph.sort2
			sort_array = graph.array_res2
		elsif data[2] == "sort3"
			graph.sort3
			sort_array = graph.array_res3
		end
		#Get All arguments
		if data[0] == "false"
			duplex = :halfduplex
		else 
			duplex = :fullduplex
		end
		p duplex
		p phys_links = data[1].to_i
		p coef = data[3].to_f
		p array_of_tops = arrays[0]
		p array_of_links = arrays[1]
		p array_of_processors = arrays[2].flatten
		p array_of_connects = arrays[3]
		p sort_array

		# Create model of task graph
		taskGraph = TaskGraphModel.new(array_of_tops, array_of_links, sort_array)
		taskGraph.order_graph

		# Create system model
		systemModel = SystemModel.new(array_of_processors, array_of_connects, coef, phys_links, duplex)
		if data[8] == "var1"
			systemModel.start(taskGraph)
		elsif data[8] == "var2"
			systemModel.start2(taskGraph)
		end
		out = systemModel.construct_gant_diagram
		respond_to do |format|
			format.json {render json: out }
    end
	end


	def generate_graph
		data = params['generator_data']
		generator = TaskGraphGenerator.new(data[0].to_i,data[1].to_i,data[2].to_i,data[3].to_f)
		new_graph = generator.generate_graph
		nodes_message = "Nodes -> "
		for i in 0..(new_graph[:nodes]).length-1
			nodes_message << "#{new_graph[:nodes][i]}(#{new_graph[:nodes_weights][i]}) "
		end
		
		array_of_objects = []
		for i in 0..(new_graph[:nodes]).length-1
			array_of_objects << TopTask.new(new_graph[:nodes][i],new_graph[:nodes_weights][i])
		end

		graph = TaskGraph.new(array_of_objects,new_graph[:links])

 		levels = ""
 		graph.levels.each{|elm| levels << "|#{elm.to_s[1..-2]}|"}
 		nodes =	new_graph[:nodes].to_s[1..-2]
 		weight_nodes = new_graph[:nodes_weights].to_s[1..-2]
 		links = ""
 		new_graph[:links].each{ |elm| links << "|#{elm.to_s[1..-2]}|"}
 		weight_links = new_graph[:links_weights].to_s[1..-2]

		
		links_message = "Links -> "
		for i in 0..(new_graph[:links]).length-1
			links_message << "#{new_graph[:links][i].first}(#{new_graph[:links_weights][i]})#{new_graph[:links][i].last} "
		end
		

		max_node = new_graph[:nodes].max+1;
		render js: "$('#generator_bar .generator_output_n').html('#{nodes_message}');
								$('#generator_bar .generator_output_l').html('#{links_message}');
								drowGenerateGraph('#{levels}','#{nodes}','#{weight_nodes}','#{links}','#{weight_links}','#{max_node}');"
	end

	def sort1
		arrtask = params['sort1_data']
		data_task = []
			arrtask.each do |elm|
				data_task.push(JSON.parse(elm))
			end
			array_of_tops = []
			array_of_links = []
			data_task.first.each do |elm|
				array_of_tops.push([elm[1],elm[2]])
			end
			data_task.last.each do |elm|
				array_of_links.push([elm[1],elm[2]])
			end
			array_of_objects = []
			array_of_tops.each {|elm| array_of_objects << TopTask.new(elm[0],elm[1].to_i) }
			graph = TaskGraph.new(array_of_objects,array_of_links)
			graph.sort1
			message = graph.sort_res1
		render js: "addResultMessageToSortBar('#{message}')"
	end

	def sort2
		arrtask = params['sort2_data']
		data_task = []
			arrtask.each do |elm|
				data_task.push(JSON.parse(elm))
			end
			array_of_tops = []
			array_of_links = []
			data_task.first.each do |elm|
				array_of_tops.push([elm[1],elm[2]])
			end
			data_task.last.each do |elm|
				array_of_links.push([elm[1],elm[2]])
			end
			array_of_objects = []
			array_of_tops.each {|elm| array_of_objects << TopTask.new(elm[0],elm[1].to_i) }
			graph = TaskGraph.new(array_of_objects,array_of_links)
			graph.sort2
			message = graph.sort_res2
		render js: "addResultMessageToSortBar('#{message}')"
	end

	def sort3
		arrtask = params['sort3_data']
		data_task = []
			arrtask.each do |elm|
				data_task.push(JSON.parse(elm))
			end
			array_of_tops = []
			array_of_links = []
			data_task.first.each do |elm|
				array_of_tops.push([elm[1],elm[2]])
			end
			data_task.last.each do |elm|
				array_of_links.push([elm[1],elm[2]])
			end
			array_of_objects = []
			array_of_tops.each {|elm| array_of_objects << TopTask.new(elm[0],elm[1].to_i) }
			graph = TaskGraph.new(array_of_objects,array_of_links)
			graph.sort3
			message = graph.sort_res3
		render js: "addResultMessageToSortBar('#{message}')"
	end


	def tests
		arr = params['sys_data']
		arrtask =  params['task_data']
		if arr != nil && arr.first != "[]"
			data_sys = []
			arr.each do |elm|
				data_sys.push(JSON.parse(elm))
			end
			array_of_tops = []
			array_of_links = []
			data_sys.first.each do |elm|
				array_of_tops.push(elm[1])
			end
			data_sys.last.each do |elm|
				array_of_links.push([elm[1],elm[2]])
			end
			array_of_objects = []
			# p array_of_tops
			# p array_of_links
			array_of_tops.each { |i| array_of_objects << TopSys.new(i) }

			graph = GraphSys.new(array_of_objects,array_of_links)
			# RENDER JS FUNCTION (MESSAGE)
			if graph.holistic_graph?
				message = "Check: Connected Graph"
				render js: "resultMessage('#{message}',true);"
			else
				message = "Error: Not Connected Graph"
				render js: "resultMessage('#{message}',false);"
			end

		elsif arrtask != nil && arrtask.first != "[]"
			data_task = []
			arrtask.each do |elm|
				data_task.push(JSON.parse(elm))
			end
			array_of_tops = []
			array_of_links = []
			data_task.first.each do |elm|
				array_of_tops.push([elm[1],elm[2]])
			end
			data_task.last.each do |elm|
				array_of_links.push([elm[1],elm[2]])
			end
			# p array_of_tops
			# p array_of_links
			array_of_objects = []
			array_of_tops.each {|elm| array_of_objects << TopTask.new(elm[0],elm[1].to_i) }
			graph = TaskGraph.new(array_of_objects,array_of_links)
			# RENDER JS FUNCTION (MESSAGE)
			unless  graph.cyclic?(array_of_links)
				message = "Check: Graph Has No Cycle"
				render js: "resultMessage('#{message}',true);"				
			else
				message = "Error: Graph Has Cycle"
				render js: "resultMessage('#{message}',false);"
			end
		else
			message = "Nothing to Test =("
			render js: "resultMessage('#{message}',false);"
		end

	end
end