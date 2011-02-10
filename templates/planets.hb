<div id="planets">
	<img src="images/bg-end.png" alt="Background" id="bg-end">
	<img src="images/bg-sun.png" alt="Sun" id="bg-sun">
	{{#planets}}
	<div class="planet" id="{{id}}">
		<div class="name">{{name}}</div>
		<img src="images/{{id}}.png" alt="{{name}}">
	</div>
	{{/planets}}
</div>