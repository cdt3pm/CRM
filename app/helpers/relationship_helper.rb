module RelationshipHelper
	class ::ActionView::Helpers::FormBuilder
		def relationship(relationship, entity_id, using_to_entity = true)
			entity, method = using_to_entity ? 
				[relationship.from, relationship.from_name] :
				[relationship.to, relationship.to_name]
			entity_class = Entity.const_get(entity)
			type = relationship.type

			if type == Relationship::ONE_TO_ONE || (using_to_entity && type == Relationship::ONE_TO_N)
				@template.select(@object_name,"#{method}_id",
					entity_class.all.collect { |e| [e.name, e.id] },
					include_blank: ''
				)
			elsif type == Relationship::ONE_TO_N
				@template.content_tag(:ul) do
						entity_class.where("#{method}_id".to_sym => @object.id)
							.collect { |e| @template.content_tag(:li, e.name) }
							.join
				end
			end
		end

		private
	end
end
