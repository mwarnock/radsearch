class SearchController < ApplicationController
  before_filter :authenticate
  hipaa_filter

  def index
  end

  def results
    @page = params[:page]
    @page ||= 1
    if params[:search]
      @search_string = params[:search][:search_string]
      session[:search_string] = @search_string
      @reasons_for = params[:reason_for]
      contains_reason = @reasons_for.values.include?("1")
      new_search = true
    else
      @search_string = session[:search_string]
      new_search = false
    end

    @reports = IdxReport.search(@search_string, :page => @page, :per_page => 10) if contains_reason or not new_search
    @reports ||= []
    jsoned_reasons = (@reasons_for.keys.inject([]) {|list,key| list.push(key) if @reasons_for[key] == "1"; list }).to_json if contains_reason
    @search_log = SearchLog.create(:username => session[:username], :search_string => @search_string, :reason_for => jsoned_reasons) if contains_reason or not new_search

    respond_to do |format|
      format.js { render :partial => "search/results", :locals => {:reports => @reports, :search_terms => @search_string} } if contains_reason or not new_search
      format.js { render :text => "<br /><span class=\"error-message\">You must specify a reason for the search</span>" } if not contains_reason
      format.html
    end
  end

  def use
  end

end
