class Entity
	include Mongoid::Document

	field :_id, type: String
	field :display_name, type: String, localize: true
	field :plural_display_name, type: String, localize: true
	field :parent, type: String

	after_create { add_constant_for_entity }

	def add_constant_for_entity
		# assume id has already been classified?
		byebug

		begin
			mongo_client[id].create
		rescue Exception => e
		end

		Entity.const_set(id, Class.new(parent || Object) { include Mongoid::Document })

		if parent
			clone_children(Field)
			clone_children(Relationship)
		end
	end

	def clone_children(table)
		to_create = table.where(entity: parent).map do |object|
			new_object = object.clone
			new_object.entity = id
			new_object
		end

		table.collection.insert(to_create)
	end
end
