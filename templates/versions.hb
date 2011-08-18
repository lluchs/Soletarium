<div id=versions>
	{{> header}}
	{{#versions}}
	<section>
		<h1>{{title}}</h1>
		<table>
			{{#version}}
				<tr>
					<td>v{{num}}:</td>
					<td>
						<ul>
							{{#each v}}
								<li>{{this}}</li>
							{{/each}}
						</ul>
					</td>
				</tr>
			{{/version}}
		</table>
	</section>
	{{/versions}}
</div>
