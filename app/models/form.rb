class Form
  include Mongoid::Document

	class Section
		attr_accessor :items, :name, :label, :number_of_columns
	end

	class Item
		attr_accessor :label, :name, :type, :visible, :column, :row, :colspan, :rowspan
	end

	class Field < Item
		attr_accessor :field, :read_only, :relationship
	end

	class Resource < Item
		attr_accessor :id
	end

	field :entity, type: String
	field :name, type: String
	field :sections, type: Array
end
