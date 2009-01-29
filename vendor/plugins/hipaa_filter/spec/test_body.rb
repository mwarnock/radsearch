require 'rest-open-uri'
require 'active_support'

phi_hash = {:accession_number => ["1234", "6789"], :patient_id => ["jim", "sam"], :username => "mwarnock", :request_string => "study-stash.radiology.umm.edu/studies?id=2"}.to_json
puts phi_hash.inspect
puts open("http://localhost:8080/log/view.json", :method => :post, "content-type" => "text/plain", :body => phi_hash).read
