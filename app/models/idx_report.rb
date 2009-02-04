class IdxReport < ActiveRecord::Base

  def self.search(words, sql_options={})
    sphinx = Sphinx::Client.new
    sphinx.SetServer("localhost", 3312)
    sphinx.SetMatchMode(Sphinx::Client::SPH_MATCH_EXTENDED)
    results = sphinx.Query(words,'idxreportidx')
    docs = results['matches'].collect do |doc|
      doc['id']
    end

    if sql_options.has_key?(:conditions) and sql_options[:conditions].class == Array
      sql_options[:conditions] = ["id in (?) AND (#{sql_options[:conditions][0]})", docs].push(*sql_options[:conditions].slice(1,sql_options[:conditions].length))
    elsif sql_options.has_key?(:conditions) and sql_options[:conditions].class == String
      sql_options[:conditions] = ["id in (?) and (#{sql_options[:conditions]})", docs]
    else
      sql_options[:conditions] = ['id in (?)', docs]
    end

    sql_options.reverse_merge!(:order => "id ASC")
    find(:all, sql_options)
  end

  def image_status
  end

  def formated_patient_id
    self.patient_id.gsub(/^0+/, "")
  end

end
