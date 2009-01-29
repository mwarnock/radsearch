require File.join(File.dirname(__FILE__), "plugin_utils")

som_skin_plug = PluginUtils::Installer.new('som_skin') do |plugin|
  plugin.install_file("lib/som_style.css", "public/stylesheets", {
    :overwrite => true,
    :message => "FILE: Copying som_style to public/stylesheets ..."
  })
  plugin.install_file("lib/som_table_styles.css", "public/stylesheets", {
    :overwrite => true,
    :message => "FILE: Copying som_table_styles to public/stylesheets ..."
  })



  plugin.install_file("lib/som_skin.js", "public/javascripts", {
    :overwrite => true,
    :message => "FILE: Copying som_skin.js to public/javascripts ..."
  })

  plugin.install_file("lib/som_sortable_table.js", "public/javascripts", {
    :overwrite => true,
    :message => "FILE: Copying som_sortable_table.js to public/javascripts ..."
  })

  plugin.install_file("lib/layouts/application.html.erb", "app/views/layouts", {
    :overwrite => false,
    :message => "FILE: Copying application.html.erb to app/views/layouts/application.html.erb..."
  })

 plugin.install_directory("lib/som_images", "public/stylesheets", {
    :overwrite => true,
    :message => "FILE: Copying som_images directory to public/stylesheets..."
  })

 plugin.install_directory("lib/layouts/som_skin", "app/views/layouts", {
    :overwrite => true,
    :message => "FILE: Copying som_skin/lib/layouts/som_skin directory to app/views/layouts/som_skin..."
  })
end

som_skin_plug.install!

