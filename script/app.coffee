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
		@image = $('.image', planetdetail())
		if not @media
			do @image.hide
			$('.text', planetdetail()).css 'right', 0
			return
		
		if @media.length > 1
			ol = $('.caption ol', @image)
			m = this
			for i of @media
				li = $("<li><div></div></li>").addClass("c#{+i+1}").click (e) -> m.show $(this).data 'index'
				li.data 'index', i
				ol.append li
		
		@show 0
	show: (item) ->
		img = @image.children 'img'
		video = $('.video', @image)
		vfile = @media[item].video
		if vfile
			img.hide()
			video.replaceWith interpolate templates.video,
				url: "images/tab/#{@planet}/" + vfile
				youtube: @media[item].yt
				width: 550
				height: 309
			# old element is replaced now
			video = $('.video', @image)
			video.hover ->
				video.children('.yt').addClass 'show'
			, ->
				video.children('.yt').removeClass 'show'
		else
			video.empty().hide()
			img.show().attr('src', getPlanetImage(@media[item], @planet, 'med'))
			   .unbind('click')
			url = getPlanetImage(@media[item], @planet, 'high')
			if url
				img.click -> openWindow url
				img.css 'cursor', 'pointer'
			else
				img.css 'cursor', 'default'
		
		content = $('.caption .content', this.image)
		$('h1', content).text @media[item].caption
		$('div', content).html @media[item].desc
		
		li = $('.caption li', @image)
		li.removeClass 'r2'
		li.eq(item).addClass 'r2'

# Handlebars-Helper

registerPartials = ->
	# Header
	Handlebars.registerPartial 'header', templates.header

# Versionsliste
Handlebars.registerHelper 'version', (block) ->
	(for version in @versions
		v = (key for key of version)[0]
		block
			num: v
			v: version[v]
	).join ''

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

# positioniert das Detailfenster vertikal
positionDetails = ->
	e = $('header.logo')
	header = e.offset().top + e.height()
	footer = $('#features').offset().top
	detail = planetdetail()
	detail.css 'top', (footer + header - detail.height()) / 2

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

# gibt das aktuelle Detailfenster zurück
planetdetail = ->
	$('.planetdetail:not(.old)')

# Highlight für ausgewählter Tab
highlightTab = (tab) ->
	$('.tab', planetdetail()).removeClass('selected').eq(tab).addClass 'selected'

# öffnet in neuem Fenster
openWindow = (url, options = 'fullscreen') ->
	window.open url, options if url

# gibt den Bildpfad zurück
getPlanetImage = (img, planet, res) ->
	return if res is 'high' and img.nohr
	auto = (r) -> "#{img.auto or img.video}_#{r[0].toUpperCase() + r[1...r.length]}Res.jpg"
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
	
# erstellt ein Overlay zum Abdecken der Planeten
createFeatureOverlay = ->
	$('#planets').append '<div id="feature-overlay"></div>'
rmFeatureOverlay = ->
	do $('#feature-overlay').remove
	
# das App
app = new Deproute
	':lang':
		show: (l) ->
			return @notfound() if l != 'de'
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
						
						# only clickable if there is data to show
						$(e).attr('onclick', '').css('cursor', 'default') unless general.detail.planets[planet]?
					
					# Footer
					doResize adjustFooter
					# call after images finish loading
					$('#main > footer img').load ->
						adjustFooter()
						$(this).unbind 'load'
					
					# Position
					doResize positionPlanets
					
					# Features
					$('#content').append interpolate(templates.features, lang)
					# Verlinkung anpassen
					center = (e) ->
						t = $('div', e)
						t.css 'left', -(t.width() - e.width()) / 2
					li = $('#features li')
					t = this
					li.each (i, e) ->
						e = $(e)
						e.addClass 'c' + (i+1)
						e.hover -> center e
						e.bind 'highlight', ->
							e.addClass 'r2'
							center e
						e.click ->
							# highlight
							li.removeClass 'r2'
							
							prev = t.path[3]
							feature = e.data 'feature'
							if feature is 'standard' or feature is prev
								location.hash = "#/#{currentLang}/main"
							else
								e.trigger 'highlight'
								location.hash = "#/#{currentLang}/main/feature/#{feature}"
				sub:
					'planet':
						sub:
							':planet':
								show: (planet) ->
									# index herausfinden
									id = getIndex planet, general.planets
									
									return @notfound() unless id?
									
									@currentPlanet = planet
									loc = '#/' + @path[0...4].join '/'
									
									# Tabs auslesen
									tabs = []
									@tabs = {}
									for tdata, i in lang.detail[planet].meta
										tdata = extendDetailTab tdata, planet
										@tabs[tdata.id] = i
										tabs.push
											style: "background-color: #{tdata.color}"
											location: "#{loc}/#{tdata.id}"
											title: tdata.title or tdata.id
									
									# HTML generieren und einsetzen
									$('#content').append interpolate templates.planetdetail, 
										title: lang.planets[id].name
										tabs: tabs
										lang: currentLang
									
									# Tabs nehmen gesamten Platz ein
									tabc = $('.tabs', planetdetail())
									tabs = $('.tab', tabc)
									# tabc has 10px padding-left
									cwidth = tabc.width()
									width = 0
									tabs.each (i, e) ->
										width += $(e).width()
									newwidth = 0
									tabs.each (i, e) ->
										wdt = $(e).width() * cwidth / width
										newwidth += wdt
										$(e).width wdt
										$(e).children().addClass 'fill'
									
									# vertical positioning
									doResize positionDetails
									
									# Transitions
									planetdetail().css('display', 'none').fadeIn('slow')
									
									# Overlay
									createFeatureOverlay()
									$('#feature-overlay').click -> location.hash = "#/#{currentLang}/main"
									
									# bereits ein Tab aufgerufen?
									if not @path[4]
										location.hash = "#{loc}/#{lang.detail[planet].meta[0].id}"
								hide: ->
									rmFeatureOverlay()
									planetdetail().addClass('old').fadeOut 'slow', -> $(this).remove()
									rmResize positionDetails
								sub:
									':tab':
										show: (tab) ->
											text = lang.detail[@currentPlanet][tab]
											
											return @notfound() unless text?
											
											highlightTab @tabs[tab]
											
											$('.content', planetdetail()).html interpolate templates.planetdetailcontent,
												text: text
											tabs = lang.detail[@currentPlanet].meta
											t = extendDetailTab tabs[getIndex tab, tabs], @currentPlanet
											@tabMedia = new TabMedia t.media, @currentPlanet
									'media':
										show: ->
											highlightTab @tabs['media']
											media = []
											for tab in lang.detail[@currentPlanet].meta when tab.media
												media = media.concat extendDetailTab(tab, @currentPlanet).media
											
											$('.content', planetdetail()).html interpolate templates.planetdetailmedia,
												planet: @currentPlanet
												media: for m in media
													{
														thumb: getPlanetImage(m, @currentPlanet, 'low')
														caption: m.caption
														smallcaption: m.smallcaption
													}
											
											planet = @currentPlanet
											$('.content > .media', planetdetail()).children().each (i, e) ->
												url = media[i].yt and 'http://youtu.be/' + media[i].yt or
												      getPlanetImage(media[i], planet, 'high') or
												      getPlanetImage(media[i], planet, 'med')
												if url
													$(e).click -> openWindow url
												else
													$(e).css 'cursor', 'default'
					'feature':
						show: ->
							li = $('#features li')
							if not li.hasClass 'r2'
								feature = @path[3]
								if feature
									li.each (i, e) ->
										e = $(e)
										e.trigger 'highlight' if e.data('feature') is feature
						hide: ->
							$('#features li').removeClass 'r2'
						sub:
							'habzone':
								show: ->
									do createFeatureOverlay
									$('#planets').append templates.habzone
									doResize positionHabZone
								hide: ->
									do rmFeatureOverlay
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
							'albedo':
								show: ->
									do createFeatureOverlay
									do $('#bg-end').hide
									@albedo_bg = $('#planets').css 'background-image'
									$('#planets').css 'background-image', 'none'
									@albedo_previous = []
									for i, planet of general.planets
										e = $('#planets .planet img').eq(i)
										@albedo_previous.push e.attr 'src'
										e.attr 'src', "images/features/Albedo_#{planet.id}.png"
								hide: ->
									do rmFeatureOverlay
									do $('#bg-end').show
									$('#planets').css 'background-image', @albedo_bg
									for i of general.planets
										$('#planets .planet img').eq(i).attr 'src', @albedo_previous[i]
							'temperature':
								show: ->
									$('#planets').append templates.temperature
									$('#temperature').append "<img src='images/features/Temp_Graph_#{currentLang}.png' alt=''>"
									e = $('#temperature > div')
									padding = general.pdata.padding
									e.css 'left', padding.left
									e.css 'right', padding.right
								hide: ->
									do $('#temperature').remove
							'suns':
								show: ->
									createFeatureOverlay()
									$('#planets').append templates.suns
									goto = (p) => location.hash = "#/#{@path[0..3].join '/'}/#{p}"
									goto 1 unless @path[4]
									suns = $('#suns')
									# these elements are hidden on first/last page
									$('.left', suns).click ->
										suns.data 'dir', 'right'
										goto (+suns.data 'page')-1
									$('.right', suns).click ->
										suns.data 'dir', 'left'
										goto (+suns.data 'page')+1
								hide: ->
									$('#suns').remove()
								sub:
									':page':
										show: (page) ->
											url = (p) -> "images/features/suns_#{p}.jpg"
											suns = $('#suns').css 'background-image', "url(#{url page})"
											prev = suns.data 'page'
											# sliding animation
											if prev
												# width of images
												wdt = suns.width()
												# opposite direction of sliding
												dir = suns.data('dir')
												out = $('.out', suns).attr('src', url prev).css(dir, 0).show()
												$('.in', suns).attr('src', url page).css(dir, "-#{wdt}px").show().load ->
													# variables can't be used in object literal keys
													ani = {}
													ani[dir] = "+=#{wdt}px"
													img = $(this).add(out).animate ani, 1000, 'swing', ->
														# reset
														img.hide().css('left', 'auto').css('right', 'auto')
											suns.data 'page', page
											# first/last page
											$('.left, .right').show()
											switch page
												when '1' then $('.left', suns).hide()
												when general.features.suns.num then $('.right', suns).hide()
			'versions':
				show: ->
					$('#container').css('display', 'table').html interpolate templates.versions, lang
					$('#container ul li:first-child').remove() # *cough*
				hide: ->
					$('#container').css 'display', 'block'
			'meta':
				show: ->
					$('#container').html interpolate templates.meta, lang
window.app = app # export
do go = ->
	if general? and templates?
		registerPartials()
		app.run '#/de/main'
		window.general = general
		window.templates = templates
	else
		setTimeout go, 1
