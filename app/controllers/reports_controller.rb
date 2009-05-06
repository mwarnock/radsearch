# Radsearch
# Copyright (C) 2009 University of Maryland School of Medicine
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
