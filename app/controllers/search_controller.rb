class SearchController < ApplicationController
  before_filter :authenticate
  hipaa_filter

  SearchState = Struct.new(:search_string, :page, :reasons_for, :contains_reason, :new_search, :anonymize)
  SearchResult = Struct.new(:sphinx_object, :error)

  def index
    @search_state = determine_search_state
    @search_result = search(@search_state) if @search_state.search_string
    if params[:page]
      render(:partial => "search/results", :locals => {:reports => @search_result.sphinx_object, :search_terms => @search_state.search_string }) if not @search_result.error and (@search_state.contains_reason or not @search_state.new_search)
    else
      render :action => :index
    end
  end

  def results
    @search_state = determine_search_state
    @search_result = search(@search_state)

    respond_to do |format|
      format.js { render :partial => "search/results", :locals => {:reports => @search_result.sphinx_object, :search_terms => @search_state.search_string } } if not @search_result.error and (@search_state.contains_reason or not @search_state.new_search)
      format.js { render :text => "<br /><span class=\"error-message\">You must specify a reason for the search</span>" } if not @search_result.error and not @search_state.contains_reason
      format.js { render :text => "<br /><span class=\"error-message\">#{@search_result.error}</span>" } if @search_result.error
    end
  end

  def use
  end

  private
  def search(state)
    begin
      reports = IdxReport.search(state.search_string, :page => state.page, :per_page => 10) if state.contains_reason or not state.new_search
      reports ||= []
      jsoned_reasons = (state.reasons_for.keys.inject([]) {|list,key| list.push(key) if state.reasons_for[key] == "1"; list }).to_json if state.contains_reason
      @search_log = SearchLog.create(:username => session[:username], :search_string => @search_state.search_string, :reason_for => jsoned_reasons) if state.contains_reason or not state.new_search
      SearchResult.new(reports)
    rescue Ultrasphinx::UsageError
      search_error = $!.to_s
      SearchResult.new([], search_error.gsub!("index idxreportidx: ", ""))
    end
  end

  def determine_search_state
    if params[:search]
      session[:search_string] = params[:search][:search_string]
      session[:reasons_for] = params[:reason_for]
      session[:reasons_for]["Review preparatory to research"] == "1" ? session[:anonymize] = true : session[:anonymize] = false
      session[:page] = 1
      SearchState.new(session[:search_string], 1, session[:reasons_for], session[:reasons_for].values.include?("1"), true, session[:anonymize])
    elsif session[:search_string]
      page = params[:page]
      page ? session[:page] = page : page = session[:page]
      SearchState.new(session[:search_string], page, session[:reasons_for], session[:reasons_for].values.include?("1"), true, session[:anonymize])
    else
      logger.debug("\n\In ELSE \n\n")
      SearchState.new
    end
  end

end
