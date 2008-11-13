class ReportsController < ApplicationController

  def search
    @search_string = params[:search]
    @search_string ||= params[:query]

    results = Report.find_by_sphinx(@search_string)

    respond_to do |format|
      format.json { render :json => (results.collect(&:attributes)).to_json }
      format.html
    end
  end

  def find_by
    @field = params[:field]
    @value = params[:value]

    if Report.respond_to?("find_by_#{@field}")
      report = Report.send("find_by_#{@field}", @value)

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
