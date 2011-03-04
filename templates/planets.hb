<div id="planets">
	<div class="bg" id="bg-end"><img src="images/layout/bg-end.svg" alt=""></div>
	<div class="bg" id="bg-sun"><img src="images/layout/bg-sun.svg" alt=""></div>
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