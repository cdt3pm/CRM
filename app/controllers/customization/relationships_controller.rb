class Customization::RelationshipsController < ApplicationController
	def new
		@relationship = Relationship.new
	end

	def create
		relationship = Relationship.new(
			params.require(:relationship).permit(:from, :to, :type, :from_name, :to_name)
		)
		relationship.save
	end

	def edit
		@relationship = Relationship.find(params.require(:id))
	end

	def update
		relationship = params.require(:relationship).permit(:from, :to, :type, :from_name, :to_name)
		relationship.save
	end

	def delete
	end
end
