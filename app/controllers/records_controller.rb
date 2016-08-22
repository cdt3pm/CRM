class RecordsController < ApplicationController
	def index
		entity_name = params.require(:entity)
		@entity = Entity.find(entity_name)
		@records = Entity.get_entity_class(entity_name).all
	end

	def new
		form = params[:form]
		entity_name = params.require(:entity)
		@entity = Entity.find(entity_name)
		@record = Entity.get_entity_class(entity_name).new
		@fields = Field.where(entity: entity_name)
		@relationships = Relationship.where("to = '#{entity_name}' OR from = '#{entity_name}'")
	end

	def create
		entity = params.require(:entity)
		entity_class = Entity.get_entity_class(entity)
		record = entity_class.new(
			params.require(entity.to_sym).permit(*entity_class.attribute_names)
		)
		record.save
		redirect_to "/#{entity}/#{record.id}"
	end

	def edit
		entity_name = params.require(:entity)
		@entity = Entity.find(entity_name)
		@record = Entity.get_entity_class(entity_name).find(params.require(:id))
		@fields = Field.where(entity: entity_name)
		@relationships = Relationship.where("to = '#{entity_name}' OR from = '#{entity_name}'")
	end

	def update
	end

	def delete
	end
end
