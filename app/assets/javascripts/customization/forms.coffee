# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

//= require jquery-ui/ui/draggable
//= require jquery-ui/ui/droppable

#class Validators
#	@columnValidator: (value, formElement) ->
#		parent = formElement.destination.parent()
#		parentColumns = parent.attr 'data-property-columns'
#		if !parent.is('#formBuilder') and parentColumns <= value
#			'Parent container does not have enough columns'
#		else if parent.children().length - 1 + value > parentColumns
#		else
#			false

class FormElement
	@selector: '.form-builder-element'
	@generateName: ->
		randomHexString = Math.random().toString(16)
		randomHexString.substring(2, randomHexString.length)
	@properties: [{
		name: 'name'
		display: 'Name'
		type: 'string'
		maxLength: 64
		pattern: '[a-z][a-z_]+'
		patternMessage: 'Name must start with a letter, and contain letters, numbers, and underscores'
	}, {
		name: 'columns'
		display: 'Columns'
		type: 'number'
		min: 1
		max: 12
	}, {
		name: 'label'
		display: 'Label'
		type: 'string'
		maxLength: 64
	}]
	dataObject: null
	constructor: (@destination, @onForm = false) ->
		self = this
		@destination.draggable
			revert: 'invalid'
			zIndex: 100
			helper: 'clone'
		@destination.bind 'showproperties', this.showProperties
	propertyValue: (name) -> @destination.attr name
	properties: -> FormElement.properties
	showProperties: ->
	addedToForm: ->

class FieldElement extends FormElement
	@selector: '.form-builder-field'
	constructor: (@destination, @onForm) ->
		super @destination, @onForm
		@destination.draggable 'option', 'snap', FieldElement.selector

class ResourceElement extends FormElement
	@selector: '.form-builder-resource'
	constructor: (@destination) -> super @destination

class ContainerElement extends FormElement
	@accepts: FieldElement.selector + ',' + ResourceElement.selector
	@selector: '.form-builder-container'
	@initDroppable: (destination) ->
		destination.droppable
			accept: ContainerElement.accepts
			drop: FormBuilder.createDropCallback(
				ContainerElement,
				(element, ui) -> $(ui.helper).remove() if $(ui.helper).draggable('option', 'helper') != 'clone'
			)
	constructor: (@destination, @onForm = false) ->
		self = this
		super @destination, @onForm
		@destination.draggable 'option', 'snap', ContainerElement.selector
	generateName: -> 'Container' + super

# Properties for each element will be static
# All necessary values will be on data-property-{property-name} attributes on element
# These will be default values in toolbox and actual values on form
# Element classes will build the properties from the elements
#
# Form input json:
# {
# 	containerProperty: value
# 	children: [{
#			fieldProperty: value
# 	}]
# }
#
# Property json:
# {
# 	name: 'name'
#		type: 'string'
#		maxLength: 64
#		pattern: '[a-z][a-z-]+'
# 	value: 'field_gender'
#	}

class Property
	constructor: (@options, @formElement) ->
		@input = null

		switch @options.type
			when 'number'
				@input = $('<input></input>').attr 'type', 'number'
				@input.attr 'min', @options.min if @options.min is not undefined
				@input.attr 'max', @options.max if @options.max is not undefined
				@input.attr 'step', @options.step if @options.step is not undefined
			when 'dropdown'
				@input = $ '<select></select>'
				@input.append(
					$('<option></option>')
						.text option.name
						.val option.value
				) for option in @options.values
			when 'area'
				@input = $ '<textarea></textarea>'
			else
				@input = $('<input></input>').attr 'type', 'text'
				@input.attr 'maxlength', @options.maxLength if @options.maxLength is not undefined
				@input.attr 'pattern', @options.pattern if @options.pattern is not undefined

		@input.attr 'required', 'true' if @options.required
		@input
			.attr 'name', @options.name
			.attr 'class', 'form-builder-property'
			.change (e) -> @changeHandler @input.val()
			.val @options.value
	changeHandler: (value) ->
		for validator in @options.validators
			if message = validator value, @formElement
				@input.addClass 'invalid'
				@input.tooltip 'destroy'
				@input.tooltip title: message
				return false
			else if input.hasClass 'invalid'
				@input.removeClass 'invalid'
				@input.tooltip 'destroy'
				@input.tooltip title: @options.tooltip
		@formElement.attr 'data-' + @options.name, value
		@formElement.trigger 'propertychanged', @options.name, value
	render: (destination) ->

class FormBuilder
	@instance: null
	@accepts: ContainerElement.selector
	@selector: '#builder'
	@createDropCallback: (type, callback = null) ->
		(e, ui) ->
			try
				element = FormBuilder.childDropped ui, type
				callback element, ui if callback
			catch
				false
	@childDropped: (ui, droppableObjectType) ->
		element = $(ui.draggable).clone()
		offset = $(ui.helper).offset()
		elementAtDrop = FormBuilder.elementAtPoint(
			offset.left,
			offset.top + 10,
			droppableObjectType.accepts,
			droppableObjectType.selector
		)

		throw new Exception('Could not find matching element at point') unless elementAtDrop.length

		if elementAtDrop.filter(droppableObjectType.selector).length
			elementAtDrop.append(element)
		else
			elementAtDrop.after(element)

		# Element may have absolute position and dragging classes :(
		element
			.removeClass 'ui-draggable-dragging'
			.removeAttr 'style'
	@elementAtPoint: (x, y, selectors...) ->
		elements = $ document.elementsFromPoint(x, y)

		if selectors.length and elements.length
			closest = null

			# first check if our selectors are a direct match.
			# if not, check the closest of each element.
			for selector in selectors
				closest = elements.closest(selector).not '.ui-draggable-dragging'
				break if closest.length
			closest
		else if elements.length then elements else null
	@init: (destination) -> @instance = new FormBuilder destination
	@selectionDone: (e, ui) ->
		selectedItems = $ FormElement.selector + '.selected'

		if selectedItems.length is 1
			selectedItems.trigger 'showproperties'
		#else if selectedItems.length > 1
	constructor: (@destination, @formField) ->
		self = this
		@destination.droppable
			accept: FormBuilder.accepts
			drop: FormBuilder.createDropCallback FormBuilder, (element) -> ContainerElement.initDroppable(element)
		@destination.selectable
			filter: FormElement.selector
			selected: (e, ui) -> $(ui.selected).addClass('selected')
			stop: FormBuilder.selectionDone

$(document).ready ->
	FormBuilder.init $('#builder')
	$('#containers').find(ContainerElement.selector).each (i, el) -> new ContainerElement $(el)
	$('#fields').find(FieldElement.selector).each (i, el) -> new FieldElement $(el)
	$('#resources').find(ResourceElement.selector).each (i, el) -> new ResourceElement $(el)
