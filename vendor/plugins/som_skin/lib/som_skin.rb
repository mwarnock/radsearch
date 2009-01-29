require File.join(File.dirname(__FILE__), 'som_skin_tables')

=begin rdoc
  = School of Medicine Skin and Helper Utilities
  By installing this plugin via rails plugin utilities the application.rhtml will be built with the School of Medicine skin.  Furthermore the user will have access to a number of helpful methods to limit the writing of HTML in his/her views.  By taking full advantage of these helper methods and templating classes we can avoid redundant coding, extend features without rewriting views, and DRY up much of the html used for formatting.  Please also pay attention to the javascript libraries and css classes provided in som_skin.js and som_skin.css respectively.

  ==How should I build tables?
  ===Controller Code
      @my_studies = Study.find(:all)
  ===View Code
      <% som_table_for @my_studies do |table_builder| %>
        <% table_builder.column "Patient ID" {|study| study.patient_id } %>
	<% table_builder.column "Final Report" {|study| display_final_report_for study }
      <% end %>

  ==How can I make items draggable?

  ==How do I encapsulate things with rounded corners?
      <% som_rounded_container do %>
        Here is where you can place your html or erb
      <% end %>
  More common methods for formatting include som_table_for and som_rounded_container
  More common methods for javascript include som_draggable_element and som_item_receiver
  The School of Medicine Skin plugin can be found at svn+ssh://radweb1.radiology.umm.edu//var/svn/plugins/som_skin
=end

module SomSkin
  #The Table class is the template builder for the helper som_table_for
  #It includes the html formatting and is the proper place to add generalized sorting code
  #and highlighting
  class TableBuilder
    attr_accessor :head, :collection, :columns, :options
    attr_reader :helpers

    #If a method called in a block is not found in the Table instance it is then passed to the view instance which has access to included helper methods
    def method_missing(method, *args, &block)
      helpers.send(method, *args, &block)
    end

    #Instantiates the Table class by setting up the initial variables
    def initialize(associated_collection, view_instance, options={}, *args)
      @collection = associated_collection
      @head = "<table class='' border='0' cellspacing='0' cellpadding='2'>"
      @helpers = view_instance
      @columns = []
      @options = options.reverse_merge({:precision => 2})
    end

    #Used to build a column of information in the table
    #The block is where the content of each row is determined
    def column(column_heading, args={}, &block) # :yields: collection_item
      total = 0.0
      cell_data = @collection.collect do |item| 
	args.reverse_merge!(:class => '')
        data_value = yield(item)

	total += data_value if data_value.class == Fixnum or data_value.class == Float
	total = "--" unless data_value.class == Fixnum or data_value.class == Float

	data_value = data_value.round(options[:precision]) if data_value.class == Float
        data_value = link_to(data_value.to_s, args[:link_to]) if args.has_key? :link_to
        data_value = link_to_function(data_value.to_s, args[:link_to_remote]) if args.has_key? :link_to_remote
        content_tag(:td, data_value, :class => args[:class])
      end
      columns<< {:heading => column_heading, :data => cell_data, :total => total}
    end

    #Builds the body of the table based on column data
    def body
      row_class_proc = lambda { cycle("even","odd", :name => @collection.object_id) } unless options[:cycle] == false
      row_class_proc = lambda { "even" } if options[:cycle] == false
      output = "<tr>"
      columns.each {|item| output += "<th class='text-heading'>#{item[:heading]}</th>" }
      output += "</tr>"
      (0...collection.size).to_a.each do |i|
        output += content_tag(:tr, (columns.collect {|item| item[:data][i] }).join("\n"), :class => row_class_proc.call)
      end
      return output
    end

    def foot
      @foot = ""
      if options[:total] == true
        @foot += "<tr>"
        columns.each do |c|
	  @foot += content_tag :td, c[:total], :style => "font-weight: bold;"
	end
	@foot += "</tr>"
      end
      @foot += "</table>"
    end

    # Creates the html for the entire table and returns it
    def render
      return self.head + self.body + self.foot
    end

  end

  class TabBuilder
    attr_reader :helpers

    #If a method called in a block is not found in the Table instance it is then passed to the view instance which has access to included helper methods
    def method_missing(method, *args, &block)
      helpers.send(method, *args, &block)
    end

    def initialize(active_tab_var, view_instance, options={}, *args)
      @active_tab_var = active_tab_var
      @tabs = []
      @helpers = view_instance
      @content_block_id = options[:update]
    end

    def tab(name, *args, &block)
      name == session[@active_tab_var] ?  li_class = "active" : li_class = ""
      @tabs << content_tag(:li, yield, :class => li_class)
    end

    def tab_link(*args)
      tab(args[0]) { link_to(*args) }
    end

    def tab_link_to_remote(*args)
      tab(args[0]) { link_to_remote(*args) }
    end

    def tab_updater(*args)
      tab(args[0]) { link_to_remote(*args) }
    end

    def render
      content_tag(:div, content_tag(:ul, @tabs.join("\n"), :class => "tabs primary"), :class => "tabs")
    end
  end

  class StackInterface
    def initialize
      @heading = "Stack Interface"
    end

    def heading(heading)
      @heading = heading
    end
  end

  module Helpers
    #Helper that instantiates the SOM Table builder
    def old_som_table_for(collection, options={}, *args, &block)
      smartie_table = SomSkin::TableBuilder.new(collection, self, options, args)
      yield smartie_table
      concat(smartie_table.render, block.binding)
    end

    #Helper that instantiates the Tab Builder
    def som_tab_builder(active_tab_var, options={}, *args, &block)
      smartie_tab_builder = SomSkin::TabBuilder.new(active_tab_var, self, options, *args)
      yield smartie_tab_builder
      concat(smartie_tab_builder.render, block.binding)
    end

    #Generalized method for creating check box like Ajax interfaces on boolean fields with Controller Model pairs
    def check_mark_button(object, boolean_method, options={})
      options.reverse_merge!({:true => "/stylesheets/som_images/greencheck_height18.gif", :false => "/stylesheets/som_images/greycheck_height18.gif"})
      controller_name = object.class.to_s.downcase.pluralize
      check_mark_id = "#{boolean_method.to_s}_#{object.id}"
      object.send(boolean_method) ? state = "false" : state = "true"
      content_tag :span, :id => "#{controller_name}_#{boolean_method.to_s}_#{object.id}" do
        link_to_remote(image_tag(options[object.send(boolean_method).to_s.to_sym], :border => 0), :url => {:controller => controller_name, :action => :update_boolean_field, :id => object.id, :field => boolean_method, :state => state}, :loading => "$('#{check_mark_id}').update('Loading')")
      end
    end

    def som_nav_block(heading, options={}, &block)
      render_som_block({:heading => heading, :partial => "blue_outline_left"}, options, &block)
    end

    def som_interface_block(heading, options={}, &block)
      render_som_block({:heading => heading, :partial => "blue_outline_right"}, options, &block)
    end

    def som_rounded_container(heading, options={}, &block)
      render_som_block({:heading => heading, :partial => "blue_outline_center"}, options, &block)
    end

    def render_som_block(args={}, options={}, &block)
      options.reverse_merge!(:if => "true")
      if eval(options[:if])
        concat(render(:partial => "layouts/som_skin/partials/#{args[:partial]}", :locals => {:heading => args[:heading], :body => capture(&block)}), block.binding)
      end
    end

    def som_draggable_element(id, element_attribute_hash={}, options={})
      grab_element_js = "var focused_element = $('#{id}');\n"
      hash_builder_js = ""
      element_attribute_hash.each {|key,value| hash_builder_js += "#{key}: '#{value}',"}
      hash_builder_js = "focused_element.server_side_attributes = {#{hash_builder_js.chop}}"
      return javascript_tag(grab_element_js + hash_builder_js) + draggable_element(id, options)
    end

    def som_item_receiver(id, options, url_hash={})
      url_hash.size > 0 ? url = url_for(url_hash) : url = "" 
      javascript_tag(%(var #{id}_reciever = new CollectionReceiver(#{id.to_json}, #{better_options_for_javascript(options)}, #{url.to_json});))
    end

    def better_options_for_javascript(options)
      options[:with]     ||= "'id=' + encodeURIComponent(element.id)"
      #options[:onDrop]   ||= "function(element){" + remote_function(options) + "}"
      options.delete_if { |key, value| ActionView::Helpers::PrototypeHelper::AJAX_OPTIONS.include?(key) }
      options[:accept] = array_or_string_for_javascript(options[:accept]) if options[:accept]    
      options[:hoverclass] = "'#{options[:hoverclass]}'" if options[:hoverclass]

      options_for_javascript(options)
    end
  end

  module ControllerMethods
    
    def update_boolean_field
      klass = params[:controller].singularize.classify.constantize
      @instance = klass.find(params[:id])
      params[:state] == "true" ? state = true : state = false
      @instance.update_attribute(params[:field], state)
      render :update do |page|
        page.replace_html "#{params[:controller]}_#{params[:field]}_#{@instance.id}", check_mark_button(@instance, params[:field])
      end
    end

  end
end
