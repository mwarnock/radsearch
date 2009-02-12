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
      @reasons_for["Review preparatory to research"] == "1" ? session[:anonymize] = true : session[:anonymize] = false
      new_search = true
    else
      @search_string = session[:search_string]
      new_search = false
    end

    begin
      @reports = IdxReport.search(@search_string, :page => @page, :per_page => 10) if contains_reason or not new_search
      @reports ||= []
      jsoned_reasons = (@reasons_for.keys.inject([]) {|list,key| list.push(key) if @reasons_for[key] == "1"; list }).to_json if contains_reason
      @search_log = SearchLog.create(:username => session[:username], :search_string => @search_string, :reason_for => jsoned_reasons) if contains_reason or not new_search
    rescue Ultrasphinx::UsageError
      search_error = $!.to_s
      search_error.gsub!("index idxreportidx: ", "")
    end

    respond_to do |format|
      format.js { render :partial => "search/results", :locals => {:reports => @reports, :search_terms => @search_string} } if not search_error and (contains_reason or not new_search)
      format.js { render :text => "<br /><span class=\"error-message\">You must specify a reason for the search</span>" } if not search_error and not contains_reason
      format.js { render :text => "<br /><span class=\"error-message\">#{search_error}</span>" } if search_error
    end
  end

  def use
  end

end
