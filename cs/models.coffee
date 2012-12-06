class Endbands.Models.Event extends Backbone.Model
	defaults:
		date: "-/-"
		pages: 0
	
	initialize: (data)->
		if not data.date
			date = new Date()
		else 
			date = new Date(data.date)
		
		month = date.getMonth()
		day = date.getDate() 
		@set("date",month+1 + "/" + day)
		
		
class Endbands.Collections.Events extends Backbone.Collection
	model: Endbands.Models.Event
	
	getLength: ->
		return @length
		
	comparator: (ev) ->
		return -ev.get("date")

class Endbands.Models.Book extends Backbone.Model
	defaults:
		title: "Untitled"
		author:
			first: "first"
			last: "last"
		eventCount: 0
		eventAvg: 0
		eventTotal: 0
		library: 0
		pageCount:"---"
		events: new Endbands.Collections.Events()
		
	initialize: (data)->
		@set("events", new Endbands.Collections.Events(data.events))
	
	

class Endbands.Collections.Books extends Backbone.Collection
	model: Endbands.Models.Book	


