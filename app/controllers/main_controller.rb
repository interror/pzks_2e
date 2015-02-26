class MainController < ApplicationController
	require 'system_graph'
	require 'task_graph'
	skip_before_action :verify_authenticity_token

	def menu

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

			array_of_tops.each { |i| array_of_objects << TopSys.new(i) }

			graph = GraphSys.new(array_of_objects,array_of_links)
			# RENDER JS FUNCTION (MESSAGE)
			if graph.holistic_graph?
				message = "Check: Connected Graph"
				render js: "resultMessage('#{message}');"
			else
				message = "Error: Not Connected Graph"
				render js: "resultMessage('#{message}');"
			end

		elsif arrtask != nil && arrtask.first != "[]"
			data_task = []
			arrtask.each do |elm|
				data_task.push(JSON.parse(elm))
			end
			array_of_tops = []
			array_of_links = []
			data_task.first.each do |elm|
				array_of_tops.push(elm[1])
			end
			data_task.last.each do |elm|
				array_of_links.push([elm[1],elm[2]])
			end
			array_of_objects = []
			array_of_tops.each {|elm| array_of_objects << TopTask.new(elm) }
			graph = TaskGraph.new(array_of_objects,array_of_links)
			# RENDER JS FUNCTION (MESSAGE)
			unless  graph.cyclic?(array_of_links)
				message = "Check: Graph Has No Cycle"
				render js: "resultMessage('#{message}');"				
			else
				message = "Error: Graph Has Cycle"
				render js: "resultMessage('#{message}');"
			end
		else
			message = "Nothing to Test =("
			render js: "resultMessage('#{message}');"
		end

	end
end