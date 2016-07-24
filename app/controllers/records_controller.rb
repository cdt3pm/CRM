class RecordsController < ApplicationController
	def index
	end

	def new
		form = params[:form]
		@entity = params.require(:entity)
		@record = Entity.const_get(entity).new
		@fields = Fields.where(entity: entity)
	end

	def create
	end

	def edit
	end

	def update
	end

	def delete
	end
end
