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
