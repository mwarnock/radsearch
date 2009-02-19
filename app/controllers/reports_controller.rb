class ReportsController < ApplicationController
  before_filter :authenticate
  hipaa_filter

  def index
    # Can this and it's view be removed??
  end

  def show
    @search_terms = session[:search_terms]
    @search_terms ||= []
    @report = IdxReport.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render :json => @report.attributes.to_json }
    end
  end

  def search
    @search_string = params[:search]
    @search_string ||= params[:query]

    results = IdxReport.search(@search_string)

    respond_to do |format|
      format.html
      format.json { render :json => (results.collect(&:attributes)).to_json }
    end
  end

  def find_by
    @field = params[:field]
    @value = params[:value]

    if IdxReport.respond_to?("find_by_#{@field}")
      report = IdxReport.send("find_by_#{@field}", @value)

      respond_to do |format|
        format.json do
          if report
            render :json => report.attributes.to_json
          else
            render :json => nil.to_json
          end
        end
      end
    else
      respond_to do |format|
        format.json { render :json => "Error: no such field in reports table" }
        format.html
      end
    end
  end

end
