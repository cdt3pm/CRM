class Relationship
	include Mongoid::Document

	ONE_TO_ONE = '1:1'
	ONE_TO_ONE_EMBEDDED = '1:1 Embedded'
	ONE_TO_N = '1:N'
	ONE_TO_N_EMBEDDED = '1:N Embedded'
	N_TO_N = 'N:N'
	TYPES = [
		ONE_TO_ONE,
		ONE_TO_ONE_EMBEDDED,
		ONE_TO_N,
		ONE_TO_N_EMBEDDED,
		N_TO_N
	]

	field :from, type: String
	field :to, type: String
	field :type, type: String
	field :from_name, type: String
	field :to_name, type: String
	field :through, type: String
	field :polymorphic, type: Boolean

	def self.get_relationship_methods_from_type(type)
		case type
		when ONE_TO_ONE
			[:has_one, :belongs_to]
		when ONE_TO_ONE_EMBEDDED
			[:embeds_one, :embedded_in]
		when ONE_TO_N
			[:has_many, :belongs_to]
		when ONE_TO_N_EMBEDDED
			[:embeds_many, :embedded_in]
		when N_TO_N
			#TODO: I think there are two ways to specify this.
		else
			raise "Relationship type invalid. must be one of #{TYPES.inspect}"
		end
	end

	def get_relationship_methods_from_type
		Relationship.get_relationship_methods_from_type(type)
	end

	def add_to_entity_classes
		from_method, to_method = get_relationship_methods_from_type

		Object.const_get(from).public_send(from_method, from_name, {
			class_name: to,
			inverse_of: to_name 
		})

		Object.const_get(to).public_send(to_method, to_name, {
			class_name: from,
			inverse_of: from_name 
		})
	end
end
