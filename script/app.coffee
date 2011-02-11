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
		
		
# das App
app = $.sammy '#container', ->
	@use Sammy.Handlebars, 'hb'
	@template_engine = 'hb'
	
	@lget 'main', ->
		# Header/Footer
		@$element().html @hb(templates.main, lang)
		
		# Planetenanzeige
		$('#content').html @hb(templates.planets, {planets: $.extend(true, [], general.planets, lang.planets)})
			
		# Position
		do positionPlanets
		$(window).resize(positionPlanets)
					
do go = ->
	if general? and templates?
		app.run '#/de/main'
		window.general = general
		window.templates = templates
	else
		setTimeout go, 1
