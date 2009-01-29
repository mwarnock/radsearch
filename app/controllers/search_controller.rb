class SearchController < ApplicationController
  before_filter :authenticate
  hipaa_filter

  def index
  end

  def results
    @search_string = params[:search][:search_string]
    session[:search_terms] = @search_string
    @modality = params[:search][:modality]
    @reasons_for = params[:reason_for]
    contains_reason = @reasons_for.values.include?("1")
    @reports = IdxReport.search(@search_string) if contains_reason
    jsoned_reasons = (@reasons_for.keys.inject([]) {|list,key| list.push(key) if @reasons_for[key] == "1"; list }).to_json
    @search_log = SearchLog.create(:username => session[:username], :search_string => @search_string, :reason_for => jsoned_reasons)

    respond_to do |format|
      format.js { render :partial => "search/results", :locals => {:reports => @reports, :search_terms => @search_string} } if contains_reason
      format.js { render :text => "<br /><span class=\"error-message\">You must specify a reason for the search</span>" } if not contains_reason
      format.html
    end
  end

end
