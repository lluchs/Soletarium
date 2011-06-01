<div id="planets">
	<div class="bg" id="bg-end"><div></div></div>
	<div class="bg" id="bg-sun"><div></div></div>
	{{#planets}}
	<div class="planet" id="{{id}}" onclick="window.location = '#/{{../lang}}/main/planet/{{id}}'">
		{{#moons}}
		<div class="moon name" {{#caption}}style="left: {{x}}px; top: {{y}}px;"{{/caption}}>{{name}}</div>
		{{/moons}}
		<div class="name" {{#caption}}style="left: {{x}}px; top: {{y}}px;"{{/caption}}>{{name}}</div>
		<img src="images/planets/{{id}}.png" alt="{{name}}">
	</div>
	{{/planets}}
</div>