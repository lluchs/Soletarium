# Gespeicherte Daten
general = null
templates = null
lang = null
currentLang = null

$.getJSON 'data/general.json', (data) ->
	general = data
$.getJSON 'data/templates.json', (data) ->
	templates = data
	
# Funktionen

# setLang = (l) ->
	# TODO: Fehlermeldung
	# return if l != 'de'
	
	# Sprache bereits geladen
	# return this if currentLang is l
	
	# Sprache laden
	# @load("data/#{l}.json").then (data) ->
		# lang = data
		# currentLang = l

# setzt die Position eines Planeten, berücksichtigt Offset
setPlanetPos = (i, x, y) ->
	e = $('#planets .planet').eq(i)
	e.css('left', "#{x - general.planets[i].offset.x}px") if x
	e.css('top', "#{y - general.planets[i].offset.y}px") if y

# setzt die dynamische Position der Planeten
positionPlanets = ->
	# Y-Position: 3/2 des verfügbaren Platzes
	ypos = ($('#planets').height() - $('#main > footer').height()) / 1.5
	# fester Abstand links/rechts
	padding = general.pdata.padding
	width = $('#planets').width() - padding.left - padding.right
	$('#planets .planet').each (i, e) ->
		# prozentuale Position
		xpos = padding.left + general.planets[i].xpos * width / 100
		setPlanetPos(i, xpos, ypos)

# Sammy-Helper: Language
Sammy.Application::lget = (path, fn) ->
	@get "#/:lang/#{path}", ->
		l = @params.lang
		# TODO: Fehlermeldung
		return if l != 'de'
		
		# Sprache bereits geladen
		if currentLang is l
			fn.apply(this, arguments)
		else
			# Sprache laden
			@load("data/#{l}.json").then (data) =>
				lang = data
				window.lang = lang
				currentLang = l
				fn.apply(this, arguments)
		
Sammy.Application::dlget = (path, fn) ->
	# Route speichern
	@droutes or= {}
	@droutes[path] = fn
	# momentaner Pfad
	@dpath or= []
	
	app = this
	
	# Route erstellen
	@lget path, ->
		# Pfad extrahieren
		p = path.split '/'
		# Unterschied feststellen
		diff = 0
		if app.dpath.toString() is p.toString()
			diff = p.length - 2
		else
			++diff while app.dpath[diff] is p[diff]
		# Unterschiede angleichen
		# Zunächst überflüssige Teile entfernen
		if diff isnt 0
			for i in [app.dpath.length-1..diff]
				# Pfad umwandeln, um eventuell vorhandene Route zu finden
				app.droutes[(app.dpath[j] for j in [0..i]).join '/']?.hide?()
		# Dann nötige Teile erstellen (inklusive Funktion des aktuellen Pfads)
		for i in [diff...p.length]
			# Pfad umwandeln, um eventuell vorhandene Route zu finden
			app.droutes[(p[j] for j in [0..i]).join '/']?.show.apply(this, arguments)
		# Neuer Pfad speichern
		app.dpath = p

# das App
app = $.sammy '#container', ->
	@raise_errors = true
	@use Sammy.Handlebars, 'hb'
	@template_engine = 'hb'
	
	@dlget 'main', 
		show: ->
			# Header/Footer
			@$element().html @hb(templates.main, lang)
			
			# Planetenanzeige
			$('#content').html @hb(templates.planets, {lang: currentLang, planets: $.extend(true, [], general.planets, lang.planets)})
				
			# Position
			do positionPlanets
			$(window).resize(positionPlanets)
	
	# Planetendetails
	@dlget 'main/planet/:planet',
		show: ->
			# id herausfinden
			for id, pdata of general.planets
				if pdata.id is @params.planet
					break
				else
					id = null
			# TODO: error
			return unless id?
			
			nid = general.planets[id].id
			$('#content').append @hb templates.planetdetail, 
				title: lang.planets[id].name
				lang: currentLang
				text: lang.detail[nid]
				image: "images/#{nid}.png"
		hide: ->
			$('.planetdetail').remove()
	
do go = ->
	if general? and templates?
		app.run '#/de/main'
		window.general = general
		window.templates = templates
	else
		setTimeout go, 1
