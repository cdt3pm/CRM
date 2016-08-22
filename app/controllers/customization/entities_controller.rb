class Customization::EntitiesController < ApplicationController
	def new
		@entity = Entity.new
	end

	def create
		entity = Entity.new(
			params.require(:entity)
				.permit(:_id, :display_name, :plural_display_name)
		)
		entity.save
		redirect_to action: 'edit'
	end

	def edit
		@entity = Entity.find(params[:id])
	end

	def update
		entity = params.require(:entity).permit(:_id, :display_name, :plural_display_name)
		entity.save
	end

	def delete
		entity = Entity.find(params.require(:entity))
		entity.delete
	end
end
