<div class=video>
	<video controls width="{{width}}" height="{{height}}">
		<source src="{{url}}.mp4" type="video/mp4" />
		<source src="{{url}}.webm" type="video/webm" />
	</video>
	{{#if youtube}}
		<div class=yt><a href="http://youtu.be/{{youtube}}">YouTube (HD)</a></div>
	{{/if}}
</div>
