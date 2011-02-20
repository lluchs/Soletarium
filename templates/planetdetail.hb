<section class="planetdetail">
	<div class="left">
		<div class="tabs">
			<ul>
				{{#tabs}}
				<li class="tab" style="{{style}}"><a href="{{location}}">{{title}}</a></li>
				{{/tabs}}
			</ul>
		</div>
		<div class="content">
			<div class="text">
				{{{text}}}
			</div>
			<div class="image">
				<img src="{{image}}" alt="{{title}}">
			</div>
		</div>
	</div>
	<div class="rbar">
		<h1>{{title}}</h1>
		<a href="#/{{lang}}/main"><img src="images/Close.png" alt="Close"></a>
	</div>
</section>
