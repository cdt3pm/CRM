class Customization::FormsController < ApplicationController
	def new
		entity = params.require(:entity_id)
		@form = Form.new(entity: entity)
		@fields = Field.where(entity: entity)
	end

	def create
	end

	def edit
	end

	def delete
	end
end
