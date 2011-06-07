<div class=missions>
	<ul>
	{{#missions}}
		<li class="flag {{flag}}">{{year}}: {{mission}}</li>
	{{/missions}}
	</ul>
	{{#summary}}
	<p>{{total}} - <span style="color: green">{{success}}</span> - <span style="color: yellow">{{partial}}</span> - <span style="color: red">{{fail}}</p>
	{{/summary}}
</div>
