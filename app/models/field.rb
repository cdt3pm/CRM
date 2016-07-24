class Field
	include Mongoid::Document

	field :name, type: String
	field :display_name, type: String
	field :entity, type: String
	field :type, type: String
	field :index, type: Boolean

	after_create { byebug; add_field_to_entity }

	def add_field_to_entity
		Entity.const_get(entity).field(name, type: type.constantize)
	end

	def update_index
		indexes = mongo_client[entity.to_sym].indexes

		if index
			indexes.create_one({ name.to_sym => 1 })
		else
			indexes.drop_one(name)
		end
	end
end
