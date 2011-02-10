<div id="planets">
	<img src="images/bg-end.png" alt="Background" id="bg-end">
	<img src="images/bg-sun.png" alt="Sun" id="bg-sun">
	{{#planets}}
	<div class="planet" id="{{id}}">
		{{#moons}}
		<div class="moon name" {{#caption}}style="left: {{x}}; top: {{y}};"{{/caption}}>{{name}}</div>
		{{/moons}}
		<div class="name" {{#caption}}style="left: {{x}}px; top: {{y}}px;"{{/caption}}>{{name}}</div>
		<img src="images/{{id}}.png" alt="{{name}}">
	</div>
	{{/planets}}
</div>