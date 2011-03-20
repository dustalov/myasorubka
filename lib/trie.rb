# encoding: utf-8

require 'active_support/secure_random'

class Myasorubka::Trie
  attr_reader :store

  def initialize(store)
    @store = store
    @node_id = -1
  end

  def put(line)
    parent_id = nil

    line.each_char do |letter|
      found_parent_id = nil

      query(proc { |query|
        query.addcond('letter',
          TokyoCabinet::TDBQRY::QCSTREQ, letter)
        if parent_id
          query.addcond('parent_id',
            TokyoCabinet::TDBQRY::QCNUMEQ, parent_id)
        else
          query.addcond('parent_id', TokyoCabinet::TDBQRY::QCSTRRX |
            TokyoCabinet::TDBQRY::QCNEGATE, '^(.+)$')
        end
        query.setlimit(1, 0)
      }) { |found_id| found_parent_id = found_id}

      unless found_parent_id
        @node_id += 1
        node_id = @node_id.to_s

        record = { 'letter' => letter }
        record['parent_id'] = parent_id if parent_id

        store[node_id] = record
        parent_id = node_id
      else
        parent_id = found_parent_id
      end
    end

    parent_id
  end

  def find(line)
    parent_id = nil

    line.each_char do |letter|
      found_parent_id = nil

      query(proc { |query|
        query.addcond('letter',
          TokyoCabinet::TDBQRY::QCSTREQ, letter)
        if parent_id
          query.addcond('parent_id',
            TokyoCabinet::TDBQRY::QCNUMEQ, parent_id)
        else
          query.addcond('parent_id', TokyoCabinet::TDBQRY::QCSTRRX |
            TokyoCabinet::TDBQRY::QCNEGATE, '^(.+)$')
        end
        query.setlimit(1, 0)
      }) { |found_id| found_parent_id = found_id }

      return nil unless found_parent_id
      parent_id = found_parent_id
    end

    parent_id
  end

  private
    def query(query_setup, &block)
      TokyoCabinet::TDBQRY.new(store).
        tap(&query_setup).
        search.each(&block)
    end
end
