<div id="features">
	<ul>
	{{#features}}
		<li {{#if hidden}}style="display: none"{{/if}} data-feature="{{id}}"><div>{{title}}</div></li>
	{{/features}}
	</ul>
</div>
