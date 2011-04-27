<div class="media">
	{{#media}}
	<div class="thumb">
		<img src="{{thumb}}" alt="{{caption}}">
		<div class="caption">
			{{#if smallcaption}}
				{{{smallcaption}}}
			{{else}}
				{{caption}}
			{{/if}}
		</div>
	</div>
	{{/media}}
</div>
