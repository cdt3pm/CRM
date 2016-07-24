class View
  include Mongoid::Document

	class Column
		attr_accessor :name, :field, :width, :join
	end

	class Join
		attr_accessor :fields, :relationship, :joins
	end

	field :entity, type: String
	field :name, type: String
	field :columns, type: Array
	field :joins, type: Hash
end
