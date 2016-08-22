class Field
	include Mongoid::Document

	TYPES = [ 'String', 'Number', 'Date' ]

	field :name, type: String
	field :display_name, type: String
	field :entity, type: String
	field :type, type: String
	field :index, type: Boolean

	after_create { add_to_entity_class }

	def self.get_field_method_from_type(type)
		case type
		when 'String'
			'text_field'
		else
			'text_field'
		end
	end

	def get_field_method_from_type
		Field.get_field_method_from_type(type)
	end

	def add_to_entity_class
		Entity.get_entity_class(entity).field(name, type: type.constantize)
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
