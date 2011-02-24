require 'rubygems'
require 'json'
require 'yaml'
require 'rake/clean'

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
					# move pos deeper
					pos = doDir dir, pos
				end
			end
			
			content = nil
			# extract yaml
			if f =~ /\.yaml$/
				content = YAML.load_file(f)
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
		return f.gets nil
	end
end

# writes the data-object as JSON to filename
def writeJSON(filename, data)
	File.open(filename, 'w') do |f|
		f.puts JSON.fast_generate(data)
	end
	puts filename
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

desc 'Copys static files'
task :files => [build('css'), build('images')]
copyTask 'css/*', 'css', :files
dirCopyTask 'images/**/*.*', 'images', 'images', :files
copyTask 'index.html', '', :files

task :default => [:coffee, :lib, :general, :lang, :template, :files]
