# HipaaLog
require 'rest-open-uri'
module HipaaLog

  module ControllerFilters

    def hipaa_filter(*filters, &block)
      after_filter HipaaLog::PHIFilter, *filters
    end

  end

  class PHIFilter

    attr_accessor :context, :matches, :match_found, :sanitized_instance_variables, :view_log_hash

    #Class method used by after_filter
    def self.filter(controller)
      self.new(controller)
    end

    def self.log(phi_filter)
      accession_numbers = phi_filter.view_log_hash[:accession_number]
      patient_ids = phi_filter.view_log_hash[:patient_id]
      view_log_hash = phi_filter.view_log_hash.clone
      view_log_hash.delete(:accession_number) and view_log_hash.delete(:patient_id)
      view_log = ViewLog.create(view_log_hash)
      self.log_phi(AccessionNumberLog, view_log.id, accession_numbers) if view_log.id
      self.log_phi(PatientIdLog, view_log.id, patient_ids) if view_log.id
      view_log.id ? true : false
    end

    def self.log_phi(active_record_class, view_id, values)
      values.collect {|value| active_record_class.create(:view_id => view_id, :value => value) }
    end

    #Based on the context of a request (controller instance) this builds a class which:
    # -Iterates over the instance variables set in the controller method or other filters
    # -Determines variable type and descends complex variables in a tree like fasion
    # -Perform heuristical checks and add matches to the matches attribute
    def initialize(controller_context)
      self.context = controller_context
      self.matches = {}
      heuristics_hash.keys.each {|key| @matches[key] = []}
      self.match_found = false
      self.sanitized_instance_variables = context.instance_variables.inject([]) { |list, name| name =~ /^@_/ ? list : list << name.gsub("@","") }
      self.inspect_instance_variables
      context.session[:username] ? @username = context.session[:username] : @username = "anonymous"
      self.view_log_hash = self.matches.reverse_merge({:requesting_username => @username,
                                                        :requesting_ip => context.request.remote_ip,
                                                        :application_name => context.request.host, 
                                                        :request_uri => context.request.request_uri,
                                                        :created_at => Time.now.to_s(:db)
                                                      })
      self.class.log(self)
    end

    #Iterate over the instance variables created in the controller request
    def inspect_instance_variables
      sanitized_instance_variables.each do |ivar|
        ivar_value = context.instance_variable_get("@#{ivar}".to_sym)
        inspect_instance_variable(ivar, ivar_value)
      end
    end

    #Descendes into instance variables according to type
    def inspect_instance_variable(var_name, value)
      case variable_type_check(var_name, value)
      when :array
        value.each {|i| inspect_instance_variable(var_name, i) }
      when :active_record_instance
        value.attributes.each {|attr, value| inspect_instance_variable(attr, value) }
      when :basic
        heuristics_match(var_name, value)
      end
    end

    #reflection on variable ancestry to determine type
    def variable_type_check(var_name, value)
      if value.class.ancestors.include?(ActiveRecord::Base)
        :active_record_instance
      elsif value.class == Array
        :array
      else
        :basic
      end
    end

    #Matches the variable name against huristics and stores unique matches
    def heuristics_match(var_name, value)
      has_match = false
      heuristics_hash_for_match.each do |heuristic, phi_name|
        if var_name == heuristic.to_s
          add_if_unique(phi_name, value)
          self.match_found = true
          has_match = true
        end
      end
      return has_match
    end

    #determines if a value is unique within the specified match key and adds accordingly
    def add_if_unique(key, value)
      if not self.matches[key].include?(value)
        self.matches[key].push(value)
        return true
      else
        return false
      end
    end

    #This hash determines what variable names match phi tracked information
    def heuristics_hash
      #Edit me to add more heuristics to check see Hippa Filter wiki page for details
      {:accession_number => [:acc, :accession_no, :accession_number, :acc_no, :acc_number], :patient_id => [:mrn, :patient_id, :pat_id]}
    end

    def heuristics_hash_for_match
      reversed_hash = {}
      heuristics_hash.each {|key, value| value.each {|name| reversed_hash[name] = key} }
      reversed_hash
    end

  end

end
