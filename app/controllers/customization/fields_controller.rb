class Customization::FieldsController < ApplicationController
	def new
		entity = params.require(:entity)
		@field = Field.new(entity: entity)
	end

	def create
		@field = Field.new(
			params.require(:field)
			.permit(:name, :display_name, :type, :entity)
		)
		@field.save
		redirect_to action: 'edit'
	end

	def edit
		@field = Field.find(_id: params[:id])
	end

	def update
		@field = params.require(:entity)
	end

	def delete
	end
end
