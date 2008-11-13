class Report < ActiveRecord::Base
  
  def self.find_by_sphinx(query_string)
    res = Search.Query(query_string, 'reportidx')
    res["matches"].collect do |item| 
      Report.find(item["id"])
    end
  end

end
