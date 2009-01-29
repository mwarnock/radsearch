# Uninstall hook code here
require 'fileutils'
require 'filetest'

#Stylesheets and Images
puts "FILE: Removing file public/stylesheets/som_style.css ..."
style_css = File.join('./', 'public', 'stylesheets', 'som_style.css')
FileUtils.rm(style_css, :verbose => true) if FileTest.exists?(style_css)
puts "FILE: Removing directory to public/stylesheets/som_images ..."
som_images = File.join('./', 'public', 'stylesheets','som_images')
FileUtils.rm_r(som_images, :verbose => true) if FileTest.exists?(som_images)

#Javascript
puts "FILE: Removing file public/javascripts/som_skin.js ..."
som_js = File.join('./', 'public', 'javascripts','som_skin.js')
FileUtils.rm(som_js, :verbose => true) if FileTest.exists?(som_js)

#Layouts and Partials
puts "FILE: Removing directory app/views/layouts/som_skin ..."
som_layouts = File.join('./', 'app', 'views', 'layouts', 'som_skin')
FileUtils.rm_r(som_layouts, :verbose => true) if FileTest.exists?(som_layouts)

