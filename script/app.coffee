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

# wendet das Template an
interpolate = (template, data) ->
	compiled[template] or= Handlebars.compile template
	compiled[template] data

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
						
					# Position
					do positionPlanets
					$(window).resize(positionPlanets)
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
									
									# bereits ein Tab aufgerufen?
									if not location.hash.match(/.+\/planet\/\w+\/(\w+)/)?[1]
										location.hash = "#{loc}/#{lang.detail[planet].meta[0].id}"
								hide: ->
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
window.app = app # export
do go = ->
	if general? and templates?
		app.run '#/de/main'
		window.general = general
		window.templates = templates
	else
		setTimeout go, 1
