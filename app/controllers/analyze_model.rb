class TransferAnalyze

	attr_accessor :from, :to, :weight, :path

	def initialize(from, to, weight, path)
		@from = from
		@to = to
		@weight = weight
		create_sends(path)
	end

	def create_sends(path)
		@path = []
		for i in 0..path.length-1
			if path[i+1] != nil
				@path << SendAnalyze.new(path[i],path[i+1], @weight)
			end
		end
	end

	def delete_path
		if !@path.empty?
			@path.delete_at(0)
		end
	end


end

class SendAnalyze

	attr_accessor :from, :to, :work

	def initialize(from, to, work)
		@from = from
		@to = to
		@work = work
	end

end