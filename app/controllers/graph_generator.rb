class TaskGraphGenerator

	def initialize(minWeight, maxWeight, n, corr)
		@minWeight = minWeight
		@maxWeight = maxWeight
		@n = n
		@correlation = corr
		@weightsLinkSum = 0 
	end	


	def generate_graph
		arrayNodes = (0..@n-1).to_a # Масив вершин!
		arrayNodesWeights = [] #Масив весов вершин!
		arrayNodes.length.times {arrayNodesWeights << rand(@minWeight..@maxWeight)}
		weightsNodeSum = 0 # Сума весов вершин
		weightsNodeSum = arrayNodesWeights.inject { |mem, var| mem + var }
		@weightsLinkSum = (weightsNodeSum/@correlation)-weightsNodeSum
		@weightsLinkSum = @weightsLinkSum.to_i # Округленая сума весов линков
		meanLinkWeight = (@weightsLinkSum/@n).round # Округленая велечина максимального веса линка
		
		
		wLink = rand(1..meanLinkWeight)
		wLink = 1 if wLink.nil?

		weightsArray = [] # Массив весов ЛИНКОВ, нужен для дублирования к основному массиву связей
		linksArray = [] # Результативный массив СВЯЗЕЙ. Тобишь сам граф


		while link = weight_counter(wLink)
			generate_link(arrayNodes,linksArray, link, weightsArray)
			
			if TaskGraphGenerator.cyclic?(linksArray)
				linksArray.pop
				@weightsLinkSum += weightsArray.last
				weightsArray.pop
			end
			wLink = rand(1..meanLinkWeight)
			wLink = 1 if wLink.nil?
		end
		return {nodes: arrayNodes, nodes_weights: arrayNodesWeights, links: linksArray, links_weights: weightsArray}
	end

	def generate_link(nodes, linksArray, linkW, weightsArray)
		link = nodes.sample(2)
		if !linksArray.include?(link)
			linksArray << link
			weightsArray << linkW
		else
			weightsArray[linksArray.index(link)] += linkW
		end
	end

	def weight_counter(wLink)
		if @weightsLinkSum > 0
			if @weightsLinkSum >= wLink
				@weightsLinkSum -= wLink
				return wLink
			elsif @weightsLinkSum <= wLink
				wLink = @weightsLinkSum
				@weightsLinkSum -= wLink
				return wLink
			end
		else
			return false
		end
	end

	def self.cyclic?(graph)
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


# new_graph = TaskGraphGenerator.new(1,10,50,0.78)
# test = new_graph.generate_graph
# p test[:nodes].length
# p test[:nodes_weights].length
# p test[:links].length
# p test[:links_weights].length