<div id="planets">
	<div class="bg" id="bg-end"></div>
	<div class="bg" id="bg-sun"></div>
	{{#planets}}
	<div class="planet" id="{{id}}">
		{{#moons}}
		<div class="moon name" {{#caption}}style="left: {{x}}px; top: {{y}}px;"{{/caption}}>{{name}}</div>
		{{/moons}}
		<div class="name" {{#caption}}style="left: {{x}}px; top: {{y}}px;"{{/caption}}>{{name}}</div>
		<img src="images/{{id}}.png" alt="{{name}}">
	</div>
	{{/planets}}
</div>