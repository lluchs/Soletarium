<div class=missions>
	<ul>
	{{#missions}}
		<li class="{{status}}"><span class="flag {{flag}}"></span><i>{{year}}</i>: {{mission}}</li>
	{{/missions}}
	</ul>
	{{#summary}}
	<p>{{total}} - <span class=success>{{success}}</span> - <span class=partial>{{partial}}</span> - <span class=fail>{{fail}}</p>
	{{/summary}}
</div>
