
class Queue
	constructor: ->
		@queue = []
		@waiting = false
	add: (fn, ths, args) ->
		if @waiting
			@queue.push [fn, ths, args]
		else
			fn.apply ths, args
	
	pause: ->
		@waiting = true
	
	continue: ->
		@waiting = false
		for i, fn of @queue
			fn[0].apply fn[1], fn[2]
			if @waiting
				@queue = @queue[i...@queue.length]
				break
		@queue = []

class Deproute
	constructor: (@routes) ->
		# start without path
		@current = []
	# call a route
	runRoute: (path) ->
		# reset the queue
		@queue = new Queue
		# get difference
		diff = 0
		# this is probably a bit hacky
		if @current.toString() is path.toString()
			diff = path.length - 2
		else
			++diff while @current[diff] is path[diff]
		# adjust differences
		# remove obsolete parts
		if diff isnt 0 and diff isnt @current.length
			for i in [@current.length-1..diff]
				# try to call the route
				@getRoute(@current[0..i])?.hide?.apply this
		# Dann nötige Teile erstellen (inklusive Funktion des aktuellen Pfads)
		for i in [diff...path.length]
			# add function to the queue
			fn = @getRoute(path[0..i])?.show
			if fn?
				@queue.add fn, this, [@param]
		# Neuer Pfad speichern
		@current = path
		# debug
		console.log "Route: #{path.join '/'}"
		# tracking
		_gaq?.push ['_trackPageview', path]
	
	# returns the matching route
	getRoute: (path) ->
		# recursive function
		findMatch = (p, obj) =>
			# parameters
			param = []
			for key, content of obj
				# direct matches have priority, so save params for later
				if key[0] is ':'
					param.push key
					continue
				# match!
				if key is p[0]
					if p.length == 1
						# we're done
						return content
					else
						# search deeper
						if content.sub?
							m = findMatch p[1...p.length], content.sub
							return m if m?
			# try the parameters
			for key in param
				if p.length == 1
					# we're done with the first one
					@param = p[0]
					return obj[key];
				else
					# try it
					sub = obj[key].sub
					if sub?
						m = findMatch p[1...p.length], sub
						return m if m?
			# nothing found
			return null
		
		findMatch path, @routes
	
	runHash: ->
		route = location.hash
		# cut the #/
		@runRoute route[2...route.length].split '/'
	
	# run it!
	run: (defaultRoute) ->
		location.hash or= defaultRoute
		app = this
		window.addEventListener 'hashchange', (-> app.runHash.apply app), false
		do @runHash

# export
window.Deproute = Deproute
		