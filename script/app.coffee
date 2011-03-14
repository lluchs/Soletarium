# Gespeicherte Daten
general = null
templates = null
compiled = {}
lang = null
currentLang = null

$.getJSON 'data/general.json', (data) ->
	general = data
$.getJSON 'data/templates.json', (data) ->
	templates = data

# Klassen

# Tab-Bilderrotation
class TabMedia
	constructor: (@media, @planet) ->
		@pos = 0
		@image = $('.planetdetail .image')
		if not @media
			do @image.hide
			$('.planetdetail .text').css 'right', 0
			return
		do @show
		@image.children('.back').click => do @back
		@image.children('.forward').click => do @forward
	show: ->
		@image.children('img').attr('src', getPlanetImage(@media[@pos], @planet, 'med'))
		                      .unbind('click')
							  .click => window.open(getPlanetImage(@media[@pos], @planet, 'high'), 'fullscreen')
		@image.children('.caption').text @media[@pos].caption
	back: ->
		--@pos
		@pos = @media.length-1 if @pos < 0
		do @show
	forward: ->
		++@pos
		@pos = 0 if @pos is @media.length
		do @show

# Funktionen

# fügt den Eventhandler hinzu und ruft die Funktion auf
doResize = (fn) ->
	do fn
	$(window).resize fn

# entfernt den Eventhandler
rmResize = (fn) ->
	$(window).unbind 'resize', fn

# wendet das Template an
interpolate = (template, data) ->
	compiled[template] or= Handlebars.compile template
	compiled[template] data

# setzt die Position eines Planeten, berücksichtigt Offset
setPlanetPos = (i, x, y) ->
	e = $('#planets .planet').eq(i)
	e.css('left', "#{x - general.planets[i].offset.x}px") if x
	e.css('top', "#{y - general.planets[i].offset.y}px") if y

# rechnet die X-Position in Pixeln aus
calcPlanetX = (percent) ->
	# fester Abstand links/rechts
	padding = general.pdata.padding
	width = $('#planets').width() - padding.left - padding.right
	return padding.left + percent * width / 100

# rechnet die Y-Position in Pixeln aus
calcPlanetY = ->
	$('#planets').height() / 1.7

# setzt die dynamische Position der Planeten
positionPlanets = ->
	# Y-Position: mittig
	ypos = calcPlanetY()
	
	$('#planets .planet').each (i, e) ->
		# prozentuale Position
		xpos = calcPlanetX general.planets[i].xpos
		setPlanetPos(i, xpos, ypos)

# positioniert die habitale Zone, ähnlich wie Planeten
positionHabZone = ->
	habzone = $('#habzone')
	# Angaben in Prozent
	data = general.features.habzone
	xpos = data.x
	wdt = data.wdt
	left = calcPlanetX(xpos)
	habzone.css 'left', left
	habzone.width calcPlanetX((xpos+wdt))-left

# positioniert die Sonnenwindgrafik, sodass die Erde am selben Ort bleibt
positionSolWind = ->
	e = $('#solwind')
	# Offset der Erde in der Grafik
	offset = general.features.solwind.offset
	# Position der Erde
	x = calcPlanetX general.planets[2].xpos
	y = calcPlanetY()
	e.css('left', "#{x - offset.x}px")
	e.css('top', "#{y - offset.y}px")

# passt den Footer an
adjustFooter = ->
	footer = $('#main > footer')
	footer.css 'height', 'auto'
	hgt = $('#container').height()
	max = 797 # Höhe des Hintergrunds - 1 (IE9)
	if hgt - footer.height() > max
		# footer vergrößern, damit der Hintergrund alles ausfüllt
		footer.height hgt - max
	
	# Inhalt anpassen
	$('#content').height hgt - footer.height()

# verschiebt das Detailfenster bei Bedarf
positionDetails = ->
	e = $('.planetdetail')
	win = $(window).width()
	max = 1200
	space = 50
	space = (win - max)/2 if win - 2*space > max
	e.css 'left', space
	e.css 'right', space

# gibt den Bildpfad zurück
getPlanetImage = (img, planet, res) ->
	auto = (r) -> "#{img.auto}_#{r[0].toUpperCase() + r[1...r.length]}Res.jpg"
	return "images/tab/#{planet}/#{img[res] or auto(res)}"

# gibt den Index zurück
getIndex = (id, obj) ->
	for index, data of obj
		if data.id is id
			break
		else
			index = null
	return index
		
# erweitert die Tabs des gegeben Planets um allgemeine Daten
extendDetailTab = (tdata, planet) ->
	$.extend true, tdata, general.detail.all[tdata.id], general.detail.planets[planet][tdata.id]
		
# das App
app = new Deproute
	':lang':
		show: (l) ->
			# TODO: Fehlermeldung
			return if l != 'de'
			# Sprache bereits geladen
			if currentLang isnt l
				do @queue.pause
				$.getJSON "data/#{l}.json", (data) =>
					lang = data
					window.lang = lang
					currentLang = l
					do @queue.continue
		sub:
			'main': 
				show: ->
					# Header/Footer
					$('#container').html interpolate(templates.main, lang)
					
					# Planetenanzeige
					$('#content').html interpolate(templates.planets, {lang: currentLang, planets: $.extend(true, [], general.planets, lang.planets)})
					
					# Events
					$('#planets .planet').each (i, e) ->
						planet = general.planets[i].id
						$(e).mouseenter ->
							$('img', this).attr('src', "images/planets/#{planet}_Hover.png")
						$(e).mouseleave ->
							$('img', this).attr('src', "images/planets/#{planet}.png")
					
					# Footer
					doResize adjustFooter
					
					# Position
					doResize positionPlanets
					
					# Features
					$('#content').append interpolate(templates.features, lang)
					# Verlinkung anpassen
					# breitestes Element finden
					maxwdt = 0
					li = $('#features li')
					li.each (i, e) ->
						e = $(e)
						wdt = e.width()
						maxwdt = wdt if wdt > maxwdt
						e.click ->
							feature = e.data 'feature'
							if feature is 'standard'
								location.hash = "#/#{currentLang}/main"
							else
								location.hash = "#/#{currentLang}/main/feature/#{feature}"
					# alle Elemente bekommen die gleiche Breite
					li.width maxwdt
				sub:
					'planet':
						sub:
							':planet':
								show: (planet) ->
									# index herausfinden
									id = getIndex planet, general.planets
									# TODO: error
									return unless id?
									
									@currentPlanet = planet
									loc = location.hash.match(/.+\/planet\/\w+/)[0]
									
									# Tabs auslesen
									tabs = []
									for tdata in lang.detail[planet].meta
										tdata = extendDetailTab tdata, planet
										tabs.push
											style: "background-color: #{tdata.color}"
											location: "#{loc}/#{tdata.id}"
											title: tdata.title or tdata.id
									
									# HTML generieren und einsetzen
									$('#content').append interpolate templates.planetdetail, 
										title: lang.planets[id].name
										tabs: tabs
										lang: currentLang
									
									# Positionierung
									doResize positionDetails
									
									# bereits ein Tab aufgerufen?
									if not location.hash.match(/.+\/planet\/\w+\/(\w+)/)?[1]
										location.hash = "#{loc}/#{lang.detail[planet].meta[0].id}"
								hide: ->
									rmResize positionDetails
									$('.planetdetail').remove()
								sub:
									':tab':
										show: (tab) ->
											text = lang.detail[@currentPlanet][tab]
											# TODO: error
											return unless text?
											$('.planetdetail .content').html interpolate templates.planetdetailcontent,
												text: text
											tabs = lang.detail[@currentPlanet].meta
											t = extendDetailTab tabs[getIndex tab, tabs], @currentPlanet
											@tabMedia = new TabMedia t.media, @currentPlanet
									'media':
										show: ->
											media = []
											for tab in lang.detail[@currentPlanet].meta when tab.media
												media = media.concat extendDetailTab(tab, @currentPlanet).media
											
											$('.planetdetail .content').html interpolate templates.planetdetailmedia,
												planet: @currentPlanet
												media: for m in media
													{
														thumb: getPlanetImage(m, @currentPlanet, 'low')
														caption: m.caption
													}
											
											planet = @currentPlanet
											$('.planetdetail .content > .media').children().each (i, e) ->
												$(e).click -> window.open(getPlanetImage(media[i], @planet, 'high'), 'fullscreen')
					'feature':
						sub:
							'habzone':
								show: ->
									$('#planets').append templates.habzone
									doResize positionHabZone
								hide: ->
									do $('#habzone').remove
									rmResize positionHabZone
							'solwind':
								show: ->
									do $('#planets .planet').hide
									$('#planets').append templates.solwind
									doResize positionSolWind
								hide: ->
									do $('#planets .planet').show
									do $('#solwind').remove
									rmResize positionSolWind
window.app = app # export
do go = ->
	if general? and templates?
		app.run '#/de/main'
		window.general = general
		window.templates = templates
	else
		setTimeout go, 1
