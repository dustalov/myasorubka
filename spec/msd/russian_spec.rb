# encoding: utf-8

require_relative '../spec_helper'
require 'csv'

class Myasorubka::MSD
  describe Russian do
    let(:filename) { File.expand_path('../../data/russian.tsv', __FILE__) }
    subject { CSV.open(filename, 'rb', col_sep: "\t", headers: true) }
    after { subject.close }

    it 'should be parsed' do
      subject.each do |row|
        sample, pos = row.delete('MSD').last, row.delete('CATEGORY').last
        sample.gsub! /-+$/, ''

        category = Russian.const_get(pos.upcase)
        msd = Myasorubka::MSD.new(Russian)
        msd[:pos] = pos.downcase.to_sym

        row.reject { |_, v| ['-', nil].include? v }.each do |k, v|
          msd[k.downcase.tr('-', '_').to_sym] = v.downcase.tr('-', '_').to_sym
        end

        msd.to_s.must_equal sample
      end
    end
  end
end
