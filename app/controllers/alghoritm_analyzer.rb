require_relative 'system_model.rb'
require_relative 'graph_generator.rb'
require_relative 'task_graph.rb'
require 'writeexcel'
# Входные данные:
# Связность 0.1 - 0.9
# Куб х1, х2, х3
# Т крит
#
# Выходные данные: (нужно для таблиц)
# Puts Такты (Тп)
# Время работы алгоритма
# Т1 - что является временем работы на одном процессоре (веса вершин)
# Puts Ткп = Т1/Тп
# Puts Теф.с = Ткп/N (Кол проц)
# Puts Теф.а = Ткрит/Тп
#

# Sort1Alg1, Sort1Alg2, Sort2Alg1, Sort2Alg2, Sort3Alg1, Sort3Alg2
def alghoritm_analyzer_first(array_top_sys, array_link_sys)
	workbook = WriteExcel.new('ruby.xls')
	generation_cycles = 5
	connectedness = (0.1..0.9).step(0.1).to_a.map{|num| num = num.round(1)}
	hash_of_results = {}
	num_of_prcs = 8
	5.times.each do
		connectedness.each do |correlation|
			buffer={}
			(1..6).to_a.each{|i| buffer[i] = [] }
			graph_number = 0
			generation_cycles.times.each do
				buffer_index = 1
				gen_graph = TaskGraphGenerator.new(1,10,num_of_prcs,correlation)
				graph_number += 1
				data_for_graph = gen_graph.generate_graph
				array_tops = []
				for i in 0..data_for_graph[:nodes].length-1
					array_tops << [data_for_graph[:nodes][i],data_for_graph[:nodes_weights][i]]
				end
				array_links = []
				for i in 0..data_for_graph[:links].length-1
					array_links << [data_for_graph[:links][i],data_for_graph[:links_weights][i]]
				end

				array_links.map!{|elm| elm = elm.flatten }
				array_obj = []
				array_tops.each{|elm| array_obj << TopTask.new(elm[0], elm[1]) }
				sort_graph = TaskGraph.new(array_obj, array_links.map{|elm| elm = [elm[0],elm[1]]})
				#First SORT RESULT
				sort_graph.sort1
				#Second SORT RESULT
				sort_graph.sort2
				#Third SORT RESULT
				sort_graph.sort3
				#Tops sum RESULT
				t1 = sort_graph.tops_sum # Work on 1 processor
				#T critical for graph RESULT
				t_crit = sort_graph.t_critical

				sort_array = [sort_graph.array_res1,sort_graph.array_res2,sort_graph.array_res3]

				#info_msg = "Graph(#{graph_number}),Correlation(#{correlation})"
				sort_array.each do |sorting|
					# Creating Graph for SORT and 1-st alghoritm
					taskGraph = TaskGraphModel.new(array_tops, array_links, sorting)
					taskGraph.order_graph
					system = SystemModel.new(array_top_sys,array_link_sys,1,1,:halfduplex)
					system.start(taskGraph)
					takts = system.construct_gant_diagram[0][0].length - 2
					k_burst = (t1/takts.to_f).round(4) #Coef burst
					k_es = (k_burst / num_of_prcs.to_f).round(4) #Coef effect. system
					k_ea = (t_crit / takts.to_f).round(4) #Coef effect. of alghoritm

					buffer[buffer_index].push([takts, k_burst, k_es, k_ea, system.alghoritm_work_time])

					buffer_index += 1
					# Creating Graph for SORT and 2-st alghoritm
					taskGraph = TaskGraphModel.new(array_tops, array_links, sorting)
					taskGraph.order_graph
					system = SystemModel.new(array_top_sys,array_link_sys,1,1,:halfduplex)
					system.start2(taskGraph)
					takts = system.construct_gant_diagram[0][0].length - 2
					k_burst = (t1/takts.to_f).round(4) #Coef burst
					k_es = (k_burst / num_of_prcs.to_f).round(4) #Coef effect. system
					k_ea = (t_crit / takts.to_f).round(4) #Coef effect. of alghoritm

					buffer[buffer_index].push([takts, k_burst, k_es, k_ea, system.alghoritm_work_time])

					buffer_index += 1
					#puts "=========="
				end
			end
			# Average of all coeff
			buffer.each do |key, val|
				res = val.transpose.map{|elm| elm.inject{|mem, val| mem + val } }.map{|elm| elm = (elm/generation_cycles).round(4) }
				hash_of_results["Research(#{key}) Correlation(#{correlation})"] = res
			end
		end
		sorted_hash = hash_of_results.sort_by{|key| key }
		#worksheet = "worksheet#{num_of_prcs}"
		write_to_xl(sorted_hash, workbook, num_of_prcs)
		hash_of_results = {}
		num_of_prcs += 8
	end
	workbook.close
end

def alghoritm_analyzer_second

end

def write_to_xl(hash, workbook, num)
	worksheet = workbook.add_worksheet
	worksheet.write(0,0, num)
	row = 1
	col = 1
	hash.each do |key, val|
		worksheet.write(row, col, key)
		col += 1
		val.each do |res|
			worksheet.write(row, col, res)
			col += 1
		end
		row += 1
		col = 1
	end
end

def show(hash)
	hash.each do |key, val|
		puts key
		p val
		puts "======"
	end
end

def alghoritm_analyzer_second(array_top_sys, array_link_sys)
	workbook = WriteExcel.new('ruby.xls')
	generation_cycles = 5
	connectedness = (0.1..0.9).step(0.1).to_a.map{|num| num = num.round(1)}
	hash_of_results = {}
	num_of_prcs = 8
	3.times.each do
		connectedness.each do |correlation|
			buffer={}
			(1..6).to_a.each{|i| buffer[i] = [] }
			graph_number = 0
			generation_cycles.times.each do
				buffer_index = 1
				gen_graph = TaskGraphGenerator.new(1,10,num_of_prcs,correlation)
				graph_number += 1
				data_for_graph = gen_graph.generate_graph
				array_tops = []
				for i in 0..data_for_graph[:nodes].length-1
					array_tops << [data_for_graph[:nodes][i],data_for_graph[:nodes_weights][i]]
				end
				array_links = []
				for i in 0..data_for_graph[:links].length-1
					array_links << [data_for_graph[:links][i],data_for_graph[:links_weights][i]]
				end

				array_links.map!{|elm| elm = elm.flatten }
				array_obj = []
				array_tops.each{|elm| array_obj << TopTask.new(elm[0], elm[1]) }
				sort_graph = TaskGraph.new(array_obj, array_links.map{|elm| elm = [elm[0],elm[1]]})
				#First SORT RESULT
				sort_graph.sort1
				#Second SORT RESULT
				sort_graph.sort2
				#Third SORT RESULT
				sort_graph.sort3
				#Tops sum RESULT
				t1 = sort_graph.tops_sum # Work on 1 processor
				#T critical for graph RESULT
				t_crit = sort_graph.t_critical

				sort_array = [sort_graph.array_res1,sort_graph.array_res2,sort_graph.array_res3]

				#info_msg = "Graph(#{graph_number}),Correlation(#{correlation})"
				sort_array.each do |sorting|
					# Creating Graph for SORT and 1-st alghoritm
					taskGraph = TaskGraphModel.new(array_tops, array_links, sorting)
					taskGraph.order_graph
					system = SystemModel.new(array_top_sys,array_link_sys,1,1,:halfduplex)
					system.start(taskGraph)
					takts = system.construct_gant_diagram[0][0].length - 2
					k_burst = (t1/takts.to_f).round(4) #Coef burst
					k_es = (k_burst / num_of_prcs.to_f).round(4) #Coef effect. system
					k_ea = (t_crit / takts.to_f).round(4) #Coef effect. of alghoritm

					buffer[buffer_index].push([takts, k_burst, k_es, k_ea, system.alghoritm_work_time])

					buffer_index += 1
					# Creating Graph for SORT and 2-st alghoritm
					taskGraph = TaskGraphModel.new(array_tops, array_links, sorting)
					taskGraph.order_graph
					system = SystemModel.new(array_top_sys,array_link_sys,1,1,:halfduplex)
					system.start2(taskGraph)
					takts = system.construct_gant_diagram[0][0].length - 2
					k_burst = (t1/takts.to_f).round(4) #Coef burst
					k_es = (k_burst / num_of_prcs.to_f).round(4) #Coef effect. system
					k_ea = (t_crit / takts.to_f).round(4) #Coef effect. of alghoritm

					buffer[buffer_index].push([takts, k_burst, k_es, k_ea, system.alghoritm_work_time])

					buffer_index += 1
					#puts "=========="
				end
			end
			# Average of all coeff
			buffer.each do |key, val|
				res = val.transpose.map{|elm| elm.inject{|mem, val| mem + val } }.map{|elm| elm = (elm/generation_cycles).round(4) }
				hash_of_results["Research(#{key}) Correlation(#{correlation})"] = res
			end
		end
		sorted_hash = hash_of_results.sort_by{|key| key }
		#worksheet = "worksheet#{num_of_prcs}"
		write_to_xl(sorted_hash, workbook, num_of_prcs)
		hash_of_results = {}
		num_of_prcs += 8
	end
	workbook.close
end

array_top_sys = [0, 1, 2, 3, 4, 5, 6, 7]
array_link_sys = [[0, 1], [1, 2], [3, 2], [3, 0], [0, 4], [3, 7], [4, 7], [6, 7], [5, 6], [5, 4], [2, 6], [1, 5]]


alghoritm_analyzer_first(array_top_sys, array_link_sys)
#alghoritm_analyzer_second(array_top_sys, array_link_sys)
