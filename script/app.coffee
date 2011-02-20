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
									# id herausfinden
									for id, pdata of general.planets
										if pdata.id is planet
											break
										else
											id = null
									# TODO: error
									return unless id?
									
									@currentPlanet = planet
									
									# Tabs auslesen
									tabs = []
									for tdata in lang.detail[planet].meta
										tabs.push
											style: "background-color: #{tdata.color}"
											location: "#{location.hash.match(/(.+\/planet\/\w+)/)[0]}/#{tdata.id}"
											title: tdata.title or tdata.id
									
									# HTML generieren und einsetzen
									$('#content').append interpolate templates.planetdetail, 
										title: lang.planets[id].name
										tabs: tabs
										lang: currentLang
										text: 'Platzhalter'
										image: "images/#{planet}.png"
								hide: ->
									$('.planetdetail').remove()
								sub:
									':tab':
										show: (tab) ->
											text = lang.detail[@currentPlanet][tab]
											# TODO: error
											return unless text?
											$('.planetdetail .text').html text
window.app = app # export
do go = ->
	if general? and templates?
		app.run '#/de/main'
		window.general = general
		window.templates = templates
	else
		setTimeout go, 1
