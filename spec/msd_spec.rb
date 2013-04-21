# encoding: utf-8

require_relative 'spec_helper'

module Myasorubka
  describe MSD do
    describe 'Initializer' do
      module ValidFoo; CATEGORIES = []; end
      module InvalidFoo; end

      it 'should work when appropriate Language is given' do
        MSD.new(ValidFoo).must_be :valid?
      end

      it 'should not work when Language has not CATEGORIES' do
        lambda { MSD.new(InvalidFoo) }.must_raise ArgumentError
      end

      it 'should work when Language is given with empty MSD line' do
        MSD.new(ValidFoo, nil).must_be :valid?
        MSD.new(ValidFoo, '').must_be :valid?
      end

      it 'should have empty grammemes, virgin POS and defined language' do
        msd = MSD.new(ValidFoo)
        msd[:pos].must_be_nil
        msd.grammemes.must_equal({})
        msd.language.must_equal ValidFoo
      end
    end

    describe 'Attributes' do
      subject { MSD.new(MSD::Russian) }

      it 'should change POS over []=' do
        subject[:pos] = :residual
        subject[:pos].must_equal :residual
      end

      it 'should change grammemes over []=' do
        subject[:pos] = :verb

        subject[:tense].must_be_nil
        subject[:tense] = :past
        subject[:tense].must_equal :past
      end

      it 'should have reader for POS' do
        subject[:pos] = :residual
        subject.pos.must_equal subject[:pos]
      end

      it 'can merge attributes hash into itself' do
        attrs = { :pos => :conjunction, :type => :coordinating,
                  :formation => :simple }
        subject.merge! attrs
        pos = attrs.delete :pos

        subject.pos.must_equal pos
        subject.grammemes.must_equal attrs
      end

      it 'can self-validate' do
        subject[:pos] = :interjection
        subject.must_be :valid?
      end

      it 'should break the validation when descriptors are invalid' do
        subject[:pos] = :zalupa
        subject.wont_be :valid?
      end

      it 'can generate regexp based on POS and grammemes' do
        subject[:pos] = :verb
        subject[:type] = :main

        re = subject.to_regexp
        ('Vmp' =~ re).must_equal 0
        ('Nc-pl' =~ re).must_be_nil
      end
    end

    describe 'Generator' do
      subject { MSD.new(MSD::Russian) }

      it 'should raise InvalidDescriptor when POS tag is not set' do
        lambda { subject[:number] = :singular }.
          must_raise MSD::InvalidDescriptor
      end

      it 'should raise InvalidDescriptor when POS tag is invalid' do
        subject[:pos] = :zalupa
        lambda { subject.to_s }.must_raise MSD::InvalidDescriptor
      end

      it 'should generate valid MSD lines when POS/grammemes are valid too' do
        subject[:pos] = :noun
        subject.to_s.must_equal 'N'

        subject[:animate] = :yes
        subject.to_s.must_equal 'N----y'

        subject[:number] = :singular
        subject.to_s.must_equal 'N--s-y'

        subject[:animate] = nil
        subject.to_s.must_equal 'N--s'

        subject[:type] = :common
        subject.to_s.must_equal 'Nc-s'
      end
    end

    describe 'Parser' do
      it 'should parse correctly composed MSD lines' do
        msd = MSD.new(MSD::Russian, 'Ncmsnn')
        msd.pos.must_equal :noun
        msd.grammemes.must_equal({
          :type => :common, :gender => :masculine, :number => :singular,
          :case => :nominative, :animate => :no
        })

        msd = MSD.new(MSD::Russian, 'Vm--1p---p')
        msd.pos.must_equal :verb
        msd.grammemes.must_equal({
          :type => :main, :person => :first, :number => :plural,
          :aspect => :progressive
        })
      end

      it 'should parse MSD lines generated by itself' do
        gen = MSD.new(MSD::Russian)
        gen[:pos] = :pronoun
        gen[:person] = :third
        gen[:gender] = :masculine
        gen[:number] = :singular
        gen[:case] = :instrumental

        msd = MSD.new(gen.language, gen.to_s)
        msd.pos.must_equal gen.pos
        msd.grammemes.must_equal gen.grammemes
      end
    end
  end
end