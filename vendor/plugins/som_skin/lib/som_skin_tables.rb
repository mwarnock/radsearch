module SomSkin

    class SomTableColumn 
      include ActionView::Helpers::CaptureHelper
      include ActionView::Helpers::TagHelper

      attr_reader :name, :options
      attr_accessor :footer_proc, :footer_options

      def initialize(col_name, opts={}, &val_proc)
        @name = col_name
        @value_proc = val_proc
        @footer_proc = nil
        @footer_options = {}
        @options = opts
      end

      # TODO: Clean this up so that it properly creates column data
      #       like som table
      def evaluate(item)
        capture(item, &@value_proc)
      end

      def footerize
        return(content_tag(:td) { "&nbsp;" }) if @footer_proc.nil?
        foot_opts = {:style => "font-weight: bold; text-align: right;"}.merge!(@footer_options)
        content_tag(:td, foot_opts) { capture(&@footer_proc) }
      end

    end

  class SomHTMLTable
    class NoSuchColumnError < RuntimeError; end
    class FootingStyleMismatchError < RuntimeError; end

    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::JavascriptHelper

    def initialize(list, html_options = {})
      opts = html_options.dup
      @collection = list
      @columns = []
      @has_proc_footers = false
      @has_total_footers = (opts.delete(:total) == true)
      @sortable = (opts.delete(:sortable) == true)
      @table_options = {
        :border => 0,
        :cellspacing => 0,
        :cellpadding => 2        
      }.merge!(opts)
    end

    def column(col_name, opts={}, &blk)
      @columns.push(SomTableColumn.new(col_name, opts, &blk))
    end

    def footer(col_name, opts = {}, &blk)
      raise(FootingStyleMismatchError.new("You already specified that you were using automatic totaling!")) if @has_total_footers
      col = column_for(col_name)
      raise(NoSuchColumnError.new("No column for '#{col_name}'!")) unless col
      @has_proc_footers = true
      col.footer_proc = blk
      col.footer_options = opts
    end


    def to_s
      res = single_row_for_section("thead", :name, :class => "som_table_heading")
      res << make_proc_footers if @has_proc_footers
      res << make_total_footers if @has_total_footers
      tbl_tag_opts = @table_options.dup
      if @sortable
        tbl_tag_opts = tbl_tag_opts.merge!({ :id => "sorted_som_table" })
      end
      content_tag(:table, tbl_tag_opts) { res + create_rows } +
        sortable_js_tags
    end

    protected

    def sortable_js_tags
      return("\n") unless @sortable
      "\n" +
        javascript_tag("new SortableTable('sorted_som_table');") +
        "\n"
    end

    def column_for(col_name)
      @columns.detect { |c| c.name == col_name }
    end

    def values_for(col)
      @collection.map do |ele|
        col.send(:evaluate, ele)
      end
    end

    def make_footers
      content_tag(:tfoot) do
        content_tag(:tr) do
          @columns.inject("") do |accum, col|
            accum + (yield col)
          end
        end
      end
    end

    def make_proc_footers
      make_footers do |col|
        col.footerize
      end
    end

    def is_numeric?(val)
      return(true) if val.to_s.gsub(/,/, "").strip =~ /^[-+]?[0-9]*\.?[0-9]+$/
      false
    end

    def is_float?(val)
      val.to_s =~ /\./
      false
    end

    def numeric_total_from(vals)
      cproc = Proc.new do |vs, convert_method|
        vs.inject(0) do |acc, v|
          acc + v.send(convert_method)
        end
      end
      if (vals.any? { |v| !is_float?(v) })
        number_with_delimiter(cproc.call(vals, :to_i))
      else
        number_with_delimiter(number_with_precision(cproc.call(vals, :to_f), 2))
      end
    end
    
    def create_automatic_footer_for(col)
      col_vals = values_for(col)
      return(content_tag(:td, { :style => 'font-weight: bold;' }) { "--" }) if col_vals.any? { |v| !is_numeric?(v) }
      content_tag(:td, { :style => 'font-weight: bold; text-align: right;' }) { numeric_total_from(col_vals) }
    end

    def make_total_footers
      make_footers do |col|
        create_automatic_footer_for(col)
      end
    end

    def td_around_col_with(meth_sym, *args)
      @columns.inject("") do |accum, col|
        accum + content_tag(:td, col.options) { col.send(meth_sym.to_sym, *args).to_s.strip }
      end
    end

    def single_row_for_section(section_name, method_sym, opts = {})
      content_tag(section_name.to_sym) do
        content_tag(:tr, opts) { td_around_col_with(method_sym) }
      end
    end

    def create_rows
      even = true
      res = @collection.inject("") do |accum, item|
        cls_val = even ? "som_table_even" : "som_table_odd"
        val = accum + content_tag(:tr, :class => cls_val) { td_around_col_with(:evaluate, item) }
        even = !even
        val
      end
      content_tag(:tbody) { res }
    end
  end

  module Helpers
    def som_table_for(list, html_opts = {}, &blk)
      html_tbl = SomHTMLTable.new(list, html_opts)
      capture(html_tbl, &blk)
      concat(html_tbl.to_s, blk.binding)
    end
  end
end
