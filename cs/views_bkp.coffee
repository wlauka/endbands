######################################	 MODAL	########################################
class Endbands.Views.Modal extends Backbone.View
	className:"modal"

	events: 
		"click div#modal-screen": "removeModal"
		"touchend div#modal-screen": "removeModal"
		"focus input":"clearDefaultTxt"
		"blur input":"setDefaultTxt"
	
	clearDefaultTxt: (ev) ->
		target = $(ev.currentTarget)
		if target.val() == target.attr('defaultValue') && (target.attr("data-keep") != "true")
			target.val("")
	
	setDefaultTxt: (ev) ->
		target = $(ev.currentTarget)
		if target.val().length == 0
			target.val(target.attr('defaultValue'))
			
		
	removeModal: (ev) =>
		@remove()
		
		
	render: () =>
		console.log "modal render"
		$(@el).html(@template)
		return @
		
######################################	ADD MODAL	####################################
class Endbands.Views.AddModal extends Endbands.Views.Modal
	events: _.extend(
		"click .cancel": "removeModal"
		"click .add":"createNewBook"
	, @prototype.events)
	
	createNewBook: (ev) ->
		data = $(ev.currentTarget).closest('form').serializeArray()
		newBook = new Endbands.Models.Book({"title":data[0].value,"author":{"first":data[1].value.split(" ")[0],"last":(data[1].value.substring(data[1].value.indexOf(" ")+1))}})
		newBook.get("events").reset()
		Endbands.app.books.add(newBook)
		@removeModal()
	initialize: ()->
		$.get("templates/add_modal.html", (tpl) =>
			@template = tpl
			@render()
		)

######################################	DETAILS MODAL	########################################
		
class Endbands.Views.DetailsModal extends Endbands.Views.Modal
	events: _.extend(
		"click .cancel": "removeModal"
		"click .save":"updateBook"
	, @prototype.events)
	
	initialize: ()->
		$.get "templates/details_modal.html", (tpl) =>
			@template = Handlebars.compile(tpl)
			@render()
	
	updateBook: (ev)->
		data = $(ev.currentTarget).closest('form').serializeArray()
		@model.set("title",data[0].value)
		@model.set("author",{"first":data[1].value.split(" ")[0],"last":(data[1].value.substring(data[1].value.indexOf(" ")+1))})
		# data2 = the list, how do I want to switch it
		@removeModal()
		
	render: () =>
		$(@el).html(@template(@model.toJSON()))
		return @
######################################	 BOOK THUMBNAIL	########################################

class Endbands.Views.BookThumbnailView extends Backbone.View
	tagName:"li"
	
	initialize: () ->
		$(@el).attr("class","book-thumb")
		$(@el).hammer({prevent_default:true})
			.on("tap", (ev) => @sendToBookPanel())
			.on("hold", (ev) =>
				console.log "hold"
				$("#viewport").append(new Endbands.Views.DetailsModal(model:@model).el)
				)
		$.get("templates/single_book.html", (tpl) => 
			@template = Handlebars.compile(tpl)
			@render()
		)
		$(@el).on('flipPanel',@sendToBookPanel)
		@model.bind("change",@render)
		
		
	sendToBookPanel: () =>
		# hacking away at it, creating new bookPanelView overtop causes double slides on swipe
		Endbands.app.bookPanel.model = @model
		Endbands.app.bookPanel.render()
		Endbands.app.main.backPanel()
		
	render: () =>
		$(@el).html(@template(@model.toJSON()))
		return @

######################################	 LIBRARY PANEL	########################################

class Endbands.Views.LibraryPanelView extends Backbone.View
	el:"#library"
	template:"single_book"
	yPos:0
	
	initialize: ->
		@attachListeners()
		@collection.bind('add',@updateDisplay)
		@render()
		
	updateDisplay: =>
		@render().delay(100).children().last().trigger("flipPanel")
		$target = $("#library .book-list")
		$target.animate({"top": -($target.height() - $("#viewport").height())},350,"easeOutSine")
		
	render: =>
		$("#library .book-list").empty()
		_.each(@collection.models, (mdl) ->
			$("#library .book-list").append(new Endbands.Views.BookThumbnailView(model:mdl).el)
		)
		return $("#library .book-list")
	attachListeners: ->
		that = this
		# drag listeners
		$target = $("#library .book-list")
		$target.hammer({prevent_default:true,stop_propagation:true, drag_horizontal:false})
			.on("dragstart", (ev) => 
				that.yPos = parseInt($target.css("top")) 
			)
			.on("drag", (ev) =>
				if ev.direction == "up"
					$target.css("top": ( @yPos - ev.distance ))
				else if ev.direction = "down"
					$target.css("top": ( @yPos + ev.distance ) )
			)
			.on("dragend", (ev) =>
				if parseInt($target.css("top")) > 0
					$target.animate({"top":0},250,"easeOutSine")
				else if Math.abs(parseInt($target.css("top"))) > ($target.height() - $("#viewport").height())
					$target.animate({"top": -($target.height() - $("#viewport").height())},250,"easeOutSine")
			)
		
		$addBtn = $("#library .buttons .add")
		$addBtn.hammer({prevent_default:true}).on("tap", (ev) -> $("#viewport").append(new Endbands.Views.AddModal().el))
	
########################################	BOOK EVENT	########################################
class Endbands.Views.BookEventView extends Backbone.View
	tagName:"li"
	
	initialize: () ->
		$(@el).attr("class","event")
		$(@el).hammer({prevent_default:true}).on("tap", (ev) => console.log @model.get('pages'))
		$.get("templates/event.html", (tpl) =>
			@template = Handlebars.compile(tpl)
			@render()
		)
	
	render: () =>
		$(@el).html(@template(@model.toJSON()))
		return @

########################################	BOOK PANEL	########################################
class Endbands.Views.BookPanelView extends Backbone.View
	el:"#book"
	template:"book_panel"
	yPos: 0
	newEvent:false	#quick sentinel for scroll vs new event
	
	initialize: ->
		@attachListeners()
		@render()
	
	updateModel: ->
		@model.set("eventCount", @model.get("events").length,{silent:true})
		@model.set("eventTotal", _.reduce(@model.get("events").models, (memo,evt) ->
				memo + evt.get('pages')
			, 0),{silent:true})
		@model.set("eventAvg", Math.floor(@model.get("eventTotal") / @model.get("eventCount")),{silent:true})
		
	attachListeners: ->
		that = this
		$(@el).hammer({prevent_default:true, drag_horizontal:false})
			.on("dragstart", (ev) => 
				that.yPos = parseInt($(@el).css("top")) 
				if ev.position.y <= 60	# top of the page, let's drag the slider
					@newEvent = true
			)
			.on("drag", (ev) =>
				if not @newEvent
					if ev.direction == "up"
						$(@el).css("top": ( @yPos - ev.distance ))
					else if ev.direction = "down"
						$(@el).css("top": ( @yPos + ev.distance ) )
				else
					@dragEventSlider(ev)
			)
			.on("dragend", (ev) =>
				if not @newEvent
					if parseInt($(@el).css("top")) > 0
						$(@el).animate({"top":0},250,"easeOutSine")
					else if Math.abs(parseInt($(@el).css("top"))) > ($(@el).height() - $("#viewport").height())
						$(@el).animate({"top": -($(@el).height() - $("#viewport").height())},250,"easeOutSine")
				else
					#console.log @distToPages(ev.distance)
					newEvent = new Endbands.Models.Event({"date": new Date(), "pages":@distToPages(ev.distance)})
					@model.get("events").push(newEvent)
					
					$(new Endbands.Views.BookEventView(model:newEvent).el).hide()
									.prependTo("ul.events")
									.delay(100)
									.slideDown(500)
									.queue(() => @render())
								
					
					$("#slider").animate({"top": "-568px"},1550,"easeOutElastic")
					@newEvent = false
			)
	
	dragEventSlider: (ev) ->
		$('#slider a').html(@distToPages(ev.distanceY))
		$('#slider').css('top', -568 + ev.distanceY)
	
	distToPages: (dist) ->
		val = Math.floor(dist/3 - 20)
		if val >= 0
			return val
		else
			return 0
	
	render: =>
		@updateModel()
		$.get("templates/" + @template + ".html", (tpl) => 
			template = Handlebars.compile(tpl)
			data = @model.toJSON()
			#data.events = data.events.toJSON()
			#console.log data
			$(@el).html(template(data))
			$evList = $(@el).children("ul.events")
			@model.get('events').each((event) ->
				
				$evList.prepend(new Endbands.Views.BookEventView(model:event).el)
				
			)
				
		)
		return @
		
########################################	MAIN VIEW	########################################

class Endbands.Views.MainView extends Backbone.View
	el:"#wrapper"
	panel:1
	totalPanels:3
	inTransition:false
	
	initialize: ->
		$(@el).hammer({prevent_default:true})
			.on("swipe", (ev) =>
				if not @inTransition
					@inTransition = true
					if ev.direction == "right"
						@forwardPanel()
					else if ev.direction == "left"
						@backPanel()
			)
		Endbands.app.bookPanel = new Endbands.Views.BookPanelView(model: @collection.at(0))
		Endbands.app.libraryPanel = new Endbands.Views.LibraryPanelView(collection: @collection)
		return @
			
	backPanel: ()=>
	
		if @panel > 1
			$(@el).animate({right:'+=320'},300)
			@panel--
			console.log @panel
			@inTransition = false
	forwardPanel: ()=>
		
		if @panel < @totalPanels
			$(@el).animate({right:'-=320px'},300)
			@panel++
			console.log @panel
			@inTransition = false

########################################	INIT	########################################

Endbands.init = () ->

	Endbands.app.libraries = [] # create empty array for tracking the library lists
	
	$ ->
		# load the data		
		$.ajax(
			url:"data.json",
			dataType:"json",
			cache:false,
			error: (xhr,status,thrown) ->
				console.log xhr, status, thrown
			success: (data) ->
				Endbands.app.books = new Endbands.Collections.Books(data)
				# console.log mybooks
				Endbands.app.main = new Endbands.Views.MainView(collection: Endbands.app.books)
				
		)

Handlebars.registerHelper('fullname', (author) ->
	return new Handlebars.SafeString(author.first + " " + author.last)
	)
		
				
		
	
		
