require 'rubygems'
require 'rake/clean'
autoload :JSON, 'json'
autoload :YAML, 'yaml'
autoload :ERB, 'erb'
gem 'uglifier'
autoload :Uglifier, 'uglifier'
gem 'net-sftp'
autoload :Net, 'net/sftp'

BUILD_DIR = 'build'
CLEAN.include BUILD_DIR

def build dir
	File.join BUILD_DIR, dir
end

directory build 'lib'
directory build 'data'
directory build 'css'
directory build 'images'

# Task: copy files
def copyTask srcGlob, targetDirSuffix, taskSymbol
	targetDir = File.join BUILD_DIR, targetDirSuffix
	FileList[srcGlob].each do |f|
		target = File.join targetDir, File.basename(f)
		file target => [f] do |t|
			cp f, target
		end
		task taskSymbol => target
	end
end

# Task: copy files while preserving directory structure
def dirCopyTask srcGlob, targetDirSuffix, baseDir, taskSymbol
	targetDir = File.join BUILD_DIR, targetDirSuffix
	FileList[srcGlob].each do |f|
		target = File.join targetDir, f.slice(/#{baseDir}\/(.+)$/, 1)
		file target => [f] do |t|
			dir = File.dirname target
			mkdir_p dir unless File.directory? dir
			cp f, target
		end
		task taskSymbol => target
	end
end

# Task: copy content of files into a JSON-file
def jsonTask srcGlob, targetFile, taskSymbol, baseDir = nil
	task taskSymbol => targetFile
	file targetFile => FileList[srcGlob] do |t|
		data = {}
		t.prerequisites.each do |f|
			pos = data
			if baseDir
				def doDir dir, pos
					pos[dir] = {} if not pos[dir]
					return pos[dir]
				end
				
				# first slice out the base dir, then scan for dir names
				f.slice(/#{baseDir}\/(.+)$/, 1).scan(/(.+?)\//) do |dir|
					# for some reason, it can be an array
					dir = dir[0] if dir.kind_of? Array
					# move pos deeper
					pos = doDir dir, pos
				end
			end
			
			content = nil
			# extract yaml
			if f =~ /\.yaml$/
				begin
					content = YAML::load getContents f
				rescue
					# add the file to exceptions
					raise $!, "In file #{f}: #{$!}", caller
				end
			else
				content = getContents(f).gsub(/\r|\n|\t/, '')
			end
			
			# key: basename without extension
			# value: contents without newlines
			pos[File.basename(f).gsub(/\..*$/, '')] = content
		end
		writeJSON(t.name, data)
	end
end

# returns the contents of the file filename
def getContents(filename)
	File.open(filename, 'r') do |f|
		# read as UTF-8 and remove BOM
		return f.read.force_encoding('UTF-8').gsub("\xEF\xBB\xBF".force_encoding('UTF-8'), '')
	end
end

def writeFile(filename, content)
	File.open(filename, 'w') do |f|
		f.puts content
	end
end

# writes the data-object as JSON to filename
def writeJSON(filename, data)
	writeFile filename, JSON.fast_generate(data)
	puts filename
end

desc 'Uploads the build directory to the server'
task :upload => :default do
	server, user, password, base = getContents('.sftp').split "\n"
	Net::SFTP.start(server, user, :password => password) do |sftp|
		FileList['build/**/*.*'].each do |f|
			rf = base + f
			rstat = nil
			lstat = File.stat f
			begin
				sftp.file.open rf do |sftpfile|
					rstat = sftpfile.stat
				end
			rescue Net::SFTP::StatusException
			end
			#puts f, rf, lstat.mtime.to_s + ' | ' + Time.at(rstat.mtime).to_s, lstat.size.to_s + ' | ' + rstat.size.to_s
			# File modified?
			if !rstat || lstat.mtime.to_i > rstat.mtime && (lstat.size < 10000 || lstat.size != rstat.size || ['.json', '.css'].include?(File.extname(f)))
				puts 'Uploading ' + f
				sftp.upload f, rf
			end
			#puts '----'
		end
	end
end

desc 'Minifies JS'
task :minify do
	path = build 'index.html'
	html = File.read path
	scripts = ''
	html.sub! /<!-- begin scripts -->(.+)<!-- end scripts -->/m do #/
		scripts = $1
		'<script src="lib/min.js"></script>'
	end
	writeFile path, html
	
	js = ''
	scripts.scan /src="(.+?)"/ do
		file = build $1
		js += File.read file
		rm file
	end
	out = build 'lib/min.js'
	writeFile out, Uglifier.compile(js)
	puts out
end

task :unminify do
	rm_f build 'index.html'
	rm_f build 'lib/min.js'
	Rake::Task['after_unminify'].invoke
end
task :after_unminify => [:lib, :coffee, :files]

desc 'Creates feed'
task :feed

FileList[build 'data/*.json'].exclude(/\w{3}\.json$/).each do |f|
	lang = File.basename f, '.json'
	feed = ERB.new getContents 'ruby/feed.rxml'
	versions = JSON.parse!(getContents f)['versions']
	b = binding
	outputfile = build "feed-#{lang}.xml"
	file outputfile => [f, 'ruby/feed.rxml'] do
		File.open outputfile, 'w' do |out|
			out.puts feed.result b
		end
		puts outputfile
	end
	task :feed => outputfile
end

desc 'Creates language JSON files'
task :lang => build('data')

Dir.foreach('data') do |dir|
	# exactly two chars (en, de)
	if m = dir.match(/^\w{2}$/)
		lang = m[0]
		# create task
		jsonTask "data/#{lang}/**/*.*", build("data/#{lang}.json"), :lang, "data/#{lang}"
	end
end

desc 'Creates template JSON files'
task :template => build('data')
jsonTask 'templates/*', build('data/templates.json'), :template

desc 'Creates general JSON file'
task :general => build('data')
jsonTask 'data/*.yaml', build('data/general.json'), :general

desc 'Copys libs'
task :lib => build('lib')
copyTask 'script/*.js', 'lib', :lib

desc 'Compiles Coffee-Script'
task :coffee => build('lib')

FileList['script/*.coffee'].each do |source|
	target = build "lib/#{File.basename(source, '.coffee')}.js"
	task :coffee => [target]
	file target => [source] do  |t|
		sh "coffee -o #{build 'lib'} -c #{source}"
	end
end

desc 'Compiles Stylus to CSS'
begin
	style = "#{build('css')}/style.css"
	task :css => [build('css'), style]
	file style do
		sh "stylus css/style.styl --out #{build 'css'}"
	end

	FileList['css/*.styl'].each do |styl|
		file style => styl
	end
end

desc 'Copys static files'
task :files => [build('images')]
dirCopyTask 'images/**/*.*', 'images', 'images', :files
copyTask 'index.html', '', :files

task :default => [:coffee, :css, :lib, :general, :lang, :template, :files, :feed]
