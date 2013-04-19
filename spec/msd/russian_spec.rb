# encoding: utf-8

require_relative '../spec_helper'
require 'csv'

class Myasorubka::MSD
  describe Russian do
    before do
      table_filename = File.expand_path('../russian.tsv', __FILE__)
      @tsv = CSV.open(table_filename, 'rb', :col_sep => "\t")
      @header = @tsv.shift
    end

    after do
      @tsv.close
    end

    it 'should be parsed' do
      until @tsv.eof?
        Myasorubka::MSD.new(Russian, @tsv.shift.first[0]).must_be :valid?
      end
    end
  end
end
