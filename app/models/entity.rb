class Entity
	include Mongoid::Document

	field :_id, type: String
	field :display_name, type: String, localize: true
	field :plural_display_name, type: String, localize: true
	field :parent, type: String

	after_create do 
		add_constant_for_entity
		
		if parent
			logger.debug "#{id} has a parent entity, cloning fields and children"
			clone_children(Field)
			clone_children(Relationship)
		end
	end

	def self.get_entity_class(name)
		Object.const_get(name.capitalize)
	end

	def add_constant_for_entity
		# assume id has already been classified?
		logger.debug "Adding constant for #{id}"

		begin
			mongo_client[id].create
		rescue Exception => e
			logger.debug "failed to create table for #{id}"
			logger.debug e.inspect
		end

		klass = Class.new(parent || Object) do
		 	include Mongoid::Document 
		end
		klass.store_in collection: id
		Object.const_set(id.capitalize, klass)
	end

	def clone_children(table)
		to_create = table.where(entity: parent).map do |object|
			new_object = object.clone
			new_object.entity = id
			new_object
		end

		logger.debug "Cloning #{to_create.inspect}"

		table.collection.insert(to_create)
	end
end
