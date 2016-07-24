class Relationship
	include Mongoid::Document

	field :from, type: String
	field :to, type: String
end
