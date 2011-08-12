<div class=missions>
	<a class=close href="#/{{lang}}/main/feature/missions">X</a>
	<ul>
	{{#missions}}
		<li class="{{status}}"><span class="flag {{flag}}"></span><i>{{year}}</i>: {{mission}}</li>
	{{/missions}}
	</ul>
	{{#summary}}
	<p><span class=total>{{total}}</span> - <span class=success>{{success}}</span> - <span class=partial>{{partial}}</span> - <span class=fail>{{fail}}</p>
	{{/summary}}
</div>
