class ControllerModel

	attr_accessor :id, :connection, :links, :physical_links

	def initialize(id, connection, physical_links)
		@id = id
		@connection = connection # Fullduplex / Halfduplex
		@active_links = []
		@links = []
		physical_links.times{ @active_links << Connect.new }
	end

	def self.duplicate_links(model)
		model.each do |proc|
			proc.links.each{|lnk| proc.controller.links << lnk.controller }
		end
		#ControllerModel.show_controllers_links(model)
	end

	def self.show_controllers_links(model)
		model.each do |proc| 
			print "Prc:#{proc.id}: Controller links:"
			proc.controller.links.each{|cont| print "#{cont.id}:" }
			print "\n"
		end
	end

	def get_free_connect
		@active_links.each do |connect|
			return connect if !connect.status
		end
		return false
	end


end

class Connect

	attr_accessor :weight, :status, :send, :get, :link, :work_counter

 def initialize
 	@status = false
 	@send = nil
 	@get = nil
 	@link = nil
 	@work_counter = 0

 end

 def work?
 	return @status
 end

 def turn_on
 	@status = true
 end

end

class Link

	attr_accessor :from, :to, :weight, :path, :work_counter, :add, :final, :done, :from_name

	def initialize(from, to, weight, from_name)
		@from = from
		@from_name = from_name
		@to = to
		@weight = weight
		@path = []
		@work_counter = weight
		@add = false
		@final = false
		@done = false
	end


end

class Transfer

	attr_accessor :send_connect, :get_connect, :work_counter, :link

	def initialize(c1,c2)
		@send_connect = c1
		@get_connect = c2
		@link = nil
		@work_counter = 0
	end

end