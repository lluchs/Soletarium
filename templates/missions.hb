<div class=missions>
	<div class=nano>
		<ul class=content>
		{{#missions}}
			<li class="{{status}}"><span class="flag {{flag}}"></span><i>{{year}}</i>: {{mission}}</li>
		{{/missions}}
		</ul>
	</div>
	{{#summary}}
	<p><span class=total>{{total}}</span> - <span class=success>{{success}}</span> - <span class=partial>{{partial}}</span> - <span class=fail>{{fail}}</p>
	{{/summary}}
	<a class=close href="#/{{lang}}/main/feature/missions">X</a>
</div>
