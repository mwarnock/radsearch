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

class IdxReport < ActiveRecord::Base
  is_indexed :fields => [:report, :dept], :concatenate => [{:fields => ['assisting', 'attending'], :as => 'radiologist'}]


  def self.search(words, sql_options={})
    sphinx_search = Ultrasphinx::Search.new({:query => words, :indexes => "idxreportidx"}.merge(sql_options))
    sphinx_search.excerpt
  end

  def image_status
  end

  def formated_patient_id
    self.patient_id.gsub(/^0+/, "")
  end

end
