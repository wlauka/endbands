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
		that = this
		$(@el).children().not(".modal-screen").each( (i) ->
			$(this).delay(200*i).animate({"top":"100%"},250,"easeInBack"
			,()->
				$(that.el).animate({"opacity":0},350,()-> that.remove())
			))
		
		
		
	render: () =>
		console.log "modal render"
		$(@el).html(@template).children().not(".modal-screen").each( (i) ->
			$(this).delay(200*i).animate({"top":0},350,"easeOutBack")
			)		
		return @
		
######################################	ADD MODAL	####################################
class Endbands.Views.AddModal extends Endbands.Views.Modal
	events: _.extend(
		"click .cancel": "removeModal"
		"click .add":"createNewBook"
	, @prototype.events)
	
	createNewBook: (ev) ->
		data = $(ev.currentTarget).closest('form').serializeArray()
		console.log data
		newBook = new Endbands.Models.Book({"title":data[0].value,"author":{"first":data[1].value.split(" ")[0],"last":(data[1].value.substring(data[1].value.indexOf(" ")+1))},"library":Endbands.app.main.panel-2,"pageCount":data[2].value})
		newBook.get("events").reset()
		Endbands.app.books.add(newBook)
		@removeModal()
	initialize: ()->
		$.get("templates/add_modal.html", (tpl) =>
			@template = tpl
			@render()
		)	
		
######################################	EDIT MODAL	####################################
class Endbands.Views.EditModal extends Endbands.Views.Modal
	deleteStatus: 0
		
	events: _.extend(
		"click .cancel": "removeModal"
		"click .save":"updateListName"
		"click .delete": "deleteList"
	, @prototype.events)
	
	updateListName: (ev) ->
		data = $(ev.currentTarget).closest('form').serializeArray()
		idx = _.indexOf(Endbands.app.libraries, _.where(Endbands.app.libraries, {"name":@model.name})[0])
		Endbands.app.libraries[idx].name = data[0].value
		$(Endbands.app.libraries[idx].view.el).find('h4').html(data[0].value)
		@removeModal()
		
	initialize: ()->
		$.get "templates/edit_modal.html", (tpl) =>
			@template = Handlebars.compile(tpl)
			@render()
		
	deleteList: ()->
		if @deleteStatus == 0
			$('.delete').html("Are you sure? Books will move to "+Endbands.app.libraries[0].name + ".")
			$('.delete').addClass("deleteConf")
			@deleteStatus++
		else
			Endbands.app.main.backPanel()
			Endbands.app.main.totalPanels--
			
			library = _.where(Endbands.app.libraries, {"name":@model.name})[0]
			
			libIdx = _.indexOf(Endbands.app.libraries, library)
			_.each(Endbands.app.books.models, (mdl) =>
				if mdl.get("library") == libIdx
						mdl.set("library", 0)
			)
			
			$(library.view.el).remove()
			Endbands.app.libraries = _.without(Endbands.app.libraries,library)
			@removeModal()
	
	render: () =>
		listData = @model # is just a regular object
		libIdx = _.indexOf(Endbands.app.libraries, _.where(Endbands.app.libraries, {"name":@model.name})[0])
		if libIdx == 0
			listData['del-status'] = "disabled"
		else 
			listData['del-status'] = ""
		$(@el).html(@template(listData)).children().not(".modal-screen").each( (i) ->
			$(this).delay(200*i).animate({"top":0},350,"easeOutBack")
			)		
		return @
			


######################################	DETAILS MODAL	########################################
		
class Endbands.Views.DetailsModal extends Endbands.Views.Modal
	deleteStatus: 0

	events: _.extend(
		"click .cancel": "removeModal"
		"click .save":"updateBook"
		"click .tabs li":"switchTabs"
		"click #new-list":"addNewList"
		"click .delete": "deleteBook"
	, @prototype.events)
	
	initialize: ()->
		$.get "templates/details_modal.html", (tpl) =>
			@template = Handlebars.compile(tpl)
			@render()
	
	addNewList: (ev) ->
		name = "new book list"
		Endbands.app.libraries.push({"name":name,"view": new Endbands.Views.LibraryPanelView(collection: Endbands.app.main.collection,"name":name)})
		$("#wrapper").append(_.last(Endbands.app.libraries).view.el)
		Endbands.app.main.totalPanels++
		$('#wrapper').css('width': Endbands.app.main.totalPanels * 100 + "%")
		count = Endbands.app.libraries.length-1
		html = '<li><input type="radio" name="list" value="'+count+'" id="list'+count+'"><label for="list'+count+'">'+name+'</label></li>'
		$(html).hide()
			.appendTo(".modal .list-select")
			.delay(100)
			.slideDown(500)
	
	deleteBook: (ev) ->
		if @deleteStatus == 0
			$('.delete').html("Are you sure... <span>Delete</span> this book?")
			$('.delete').addClass("deleteConf")
			@deleteStatus++
		else
			@model.destroy()
		
			Endbands.app.bookPanel.model = Endbands.app.books.models[0]
			Endbands.app.bookPanel.render()
			@removeModal()
	
	updateBook: (ev)->
		data = $(ev.currentTarget).closest('form').serializeArray()
		console.log data[2].value
		@model.set("title",data[0].value)
		@model.set("author",{"first":data[1].value.split(" ")[0],"last":(data[1].value.substring(data[1].value.indexOf(" ")+1))})
		@model.set("library",parseInt(data[3].value))
		@model.set("pageCount",data[2].value)
		console.log @model
		
		@removeModal()
	
	switchTabs: (ev) ->
		$target = $(ev.currentTarget)
		mode = $target.data("tab")
		if not $target.hasClass("selected")
			$(".tabs li").toggleClass("selected")
			$(".tab").fadeOut("fast").delay(150).filter("."+mode).fadeIn("fast")
		
		
		
	render: () =>
		bookData = $.extend(
			@model.toJSON(),
			{"lib-list":_.pluck(Endbands.app.libraries,"name")}
			)
		console.log bookData
		$(@el).html(@template(bookData)).children().not(".modal-screen").each( (i) ->
			$(this).delay(200*i).animate({"top":0},350,"easeOutBack")
			)		
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
		@model.bind("change:title",@render)
		@model.bind("change:library",@moveBook)
		@model.bind("destroy",@removeBook)
		
		
	sendToBookPanel: () =>
		# hacking away at it, creating new bookPanelView overtop causes double slides on swipe
		Endbands.app.bookPanel.model = @model
		Endbands.app.bookPanel.render()
		
		val = parseInt(@model.get('pageCount'))
		if isNaN(val)
			$('#slider span').html("I've read:")
		else
			$('#slider span').html("I'm now on page:")
		
		Endbands.app.main.goToFirst()
		
	moveBook: () =>
		_.pluck(Endbands.app.libraries,"view")[@model.get("library")].render()
		@removeBook()
		
	removeBook: () =>
		@remove()
	
	render: () =>
		$(@el).html(@template(@model.toJSON()))
		return @

######################################	 LIBRARY PANEL	########################################

class Endbands.Views.LibraryPanelView extends Backbone.View
	$bookList: null # set in render and use to reference the book list, should probably be it's own view, but w/e, prototype! 
	yPos:0
	
	
	initialize: ->
		@name = @options.name
		$(@el).addClass("library panel")
		@collection.bind('add',@updateDisplay)
		$.get("templates/library_panel.html", (tpl) =>
			@template = Handlebars.compile(tpl)
			@render()
		)
		
	updateDisplay: =>
		@render().delay(100).children().last().trigger("flipPanel")
		@$bookList.animate({"top": -(@$bookList.height() - $("#viewport").height())},350,"easeOutSine")
		
	render: =>
		$(@el).html(@template({"name":@name}))
		@$bookList = $(@el).children('.book-list')
		@$bookList.empty()
		libIdx = _.indexOf(_.pluck(Endbands.app.libraries,"view"), @)
		_.each(@collection.models, (mdl) =>
			if mdl.get("library") == libIdx
				@$bookList.append(new Endbands.Views.BookThumbnailView(model:mdl).el)
		)
		@attachListeners()
		return $("#library .book-list")
	attachListeners: ->
		that = this
		# drag listeners
		$target = that.$bookList
		$target.hammer({stop_propagation:true, drag_horizontal:false})
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
		
		$addBtn = $(that.el).find('.add')
		$addBtn.hammer({prevent_default:true}).on("tap", (ev) => 
			$("#viewport").append(new Endbands.Views.AddModal().el)
			#console.log _.indexOf(Endbands.app.libraries, @)  # test, gets the index of current library
		)
		
		$editBtn = $(that.el).find('.edit')
		$editBtn.hammer({prevent_default:true}).on("tap", (ev) => 
			$("#viewport").append(new Endbands.Views.EditModal(model:{'name':that.name}).el)
		)
	
########################################	BOOK EVENT	########################################
class Endbands.Views.BookEventView extends Backbone.View
	tagName:"li"
	
	initialize: () ->
		$(@el).attr("class","event")
		$(@el).hammer({drag_vertical:false,drag_horizontal:false,swipe:false}).on("tap", (ev) => console.log @model.get('pages'))
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
		@this
		$(@el).hammer({prevent_default:true, drag_horizontal:false})
			.on("dragstart", (ev) => 
				console.log "test"
				@yPos = parseInt($(@el).css("top")) 
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
		val = parseInt(@model.get('pageCount'))
		if isNaN(val)
			val = 0
		else
			val = @model.get('eventTotal')
		$('#slider a').html(val + @distToPages(ev.distanceY))
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
		Endbands.app.libraries.push({"name":"my library", "view": new Endbands.Views.LibraryPanelView(collection: @collection,name:"my library")})
		$("#wrapper").append(_.last(Endbands.app.libraries).view.el)
		Endbands.app.libraries.push({"name":"archive","view": new Endbands.Views.LibraryPanelView(collection: @collection,name:"archive")})
		$("#wrapper").append(_.last(Endbands.app.libraries).view.el)
		return @
	
	goToFirst: ()=>
		$(@el).animate({right:'0'},300,"easeInOutSine")
		@panel = 1
		@inTransition = false
	backPanel: ()=>
		if @panel > 1
			$(@el).animate({right:'+=320'},300)
			@panel--
			@inTransition = false
	forwardPanel: ()=>
		
		if @panel < @totalPanels
			$(@el).animate({right:'-=320px'},300)
			@panel++
			@inTransition = false

########################################	INIT	########################################

Endbands.init = () ->

	Endbands.app.libraries = [] # create empty array for tracking the library lists, this should be another model...
	
	
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
	
# https://gist.github.com/1048968
Handlebars.registerHelper 'each_with_index', (array, obj) ->
    buffer = ''
    for i in array
      item = {}
      item.index = _i
      item.value = i
      buffer += obj.fn(item)
    buffer
    
Handlebars.registerHelper 'equals', (lvalue, rvalue, options) ->
	if lvalue != rvalue
		return options.inverse(this)
	else
		return options.fn(this)
		
		
	
		
