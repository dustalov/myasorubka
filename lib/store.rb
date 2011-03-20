# encoding: utf-8

require 'tokyocabinet'

class Myasorubka::Store
  include TokyoCabinet

  attr_reader :path, :mode

  STORAGES = [ :patterns, :prefixes, :rules, :rule_forms,
    :stems, :suffixes ]
  STORAGES.each { |s| attr_reader(s) }

  def initialize(path, mode = :read)
    @path = path
    @mode = if :manage == mode
      TDB::OWRITER | TDB::OCREAT
    else
      TDB::OREADER | TDB::ONOLCK
    end

    [ :patterns, :prefixes, :rules, :rule_forms,
      :stems, :suffixes ].each do |store_sym|
        filename = File.join(path, "#{store_sym}.tct")
        ivar = "@#{store_sym}".to_sym

        store = TDB.new
        if !store.open(filename, @mode)
          raise store.errmsg(store.ecode)
        end

        if :manage == mode && :rule_forms == store_sym
          store.setindex 'pattern_id', TDB::ITLEXICAL
          store.setindex 'rule_id', TDB::ITDECIMAL
          store.setindex 'suffix_id', TDB::ITDECIMAL
        elsif :manage == mode && :stems == store_sym
          store.setindex 'letter', TDB::ITLEXICAL
          store.setindex 'parent_id', TDB::ITDECIMAL
          store.setindex 'rule_id', TDB::ITDECIMAL
        elsif :manage == mode && :suffixes == store_sym
          store.setindex 'letter', TDB::ITLEXICAL
          store.setindex 'parent_id', TDB::ITDECIMAL
        end

        instance_variable_set(ivar, store)
    end
  end

  def inspect
    "\#<#{self.class.name} path='#{path}'>"
  end

  def close
    [ patterns, prefixes, rules, rule_forms,
      stems, suffixes ].each { |s| s.close }
  end
end
