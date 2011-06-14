# encoding: utf-8

class Myasorubka::AOT
  # AOT-to-MSD morphosyntactic descriptors converter.
  #
  module MSD
    # Russian language.
    #
    def self.russian(pos_line, grammemes_line)
      grammemes = grammemes_line.split(',').map do |grammeme|
        grammeme.mb_chars.downcase.to_s
      end

      msd = Myaso::MSD.new(Myaso::MSD::Russian)

      case pos_line.mb_chars.upcase.to_s
        when 'С' then begin
          msd[:pos] = :noun
        end
        when 'П' then begin
          msd[:pos] = :adjective
        end
        when 'МС' then begin
          msd[:pos] = :pronoun
        end
        when 'Г' then begin
          msd[:pos] = :verb
        end
        when 'ПРИЧАСТИЕ' then begin
          msd[:pos] = :verb
          msd[:vform] = :participle
        end
        when 'ДЕЕПРИЧАСТИЕ' then begin
          msd[:pos] = :verb
          msd[:vform] = :gerund
        end
        when 'ИНФИНИТИВ' then begin
          msd[:pos] = :verb
          msd[:vform] = :infinitive
        end
        when 'МС-ПРЕДК' then begin
          msd[:pos] = :pronoun
          msd[:case] = :genititive
        end
        when 'МС-П' then begin
          msd[:pos] = :pronoun
          msd[:syntactic_type] = :adjectival
        end
        when 'ЧИСЛ' then begin
          msd[:pos] = :numeral
          msd[:type] = :cardinal
        end
        when 'ЧИСЛ-П' then begin
          msd[:pos] = :numeral
          msd[:type] = :ordinal
        end
        when 'Н' then begin
          msd[:pos] = :adverb
        end
        when 'ПРЕДК' then begin
          msd[:pos] = :adverb
        end
        when 'ПРЕДЛ' then begin
          msd[:pos] = :adposition
          msd[:type] = :preposition
        end
        when 'СОЮЗ' then begin
          msd[:pos] = :conjunction
        end
        when 'МЕЖД' then begin
          msd[:pos] = :interjection
        end
        when 'ЧАСТ' then begin
          msd[:pos] = :particle
        end
        when 'ВВОДН' then begin
          msd[:pos] = :adposition
        end
        when 'КР_ПРИЛ' then begin
          msd[:pos] = :adjective
          msd[:definiteness] = :short_art
        end
        when 'КР_ПРИЧАСТИЕ' then begin
          msd[:pos] = :verb
          msd[:vform] = :participle
          msd[:definiteness] = :short_art
        end
        #when '*' then begin
      else
        msd[:pos] = :residual
      end

      return msd.to_s if :residual == msd[:pos]

      # abbreviation
      unless :verb == msd[:pos]
        msd[:pos] = :abbreviation if grammemes.include? 'аббр'
      end

      # gender
      msd[:gender] = if grammemes.include? 'мр'
        :masculine
      elsif grammemes.include? 'жр'
        :feminine
      elsif grammemes.include? 'ср'
        :neuter
      elsif :noun == msd[:pos]
        :common
      end

      # animate
      unless [ :adjective, :verb ].include? msd[:pos]
        msd[:animate] = if grammemes.include? 'од'
          :yes
        elsif grammemes.include? 'но'
          :no
        end
      end

      # number
      msd[:number] = if grammemes.include? 'ед'
        :singular
      elsif grammemes.include? 'мн'
        :plural
      end

      # case
      msd[:case] = if grammemes.include? 'им'
        :nominative
      elsif grammemes.include? 'рд'
        :genitive
      elsif grammemes.include? 'дт'
        :dative
      elsif grammemes.include? 'вн'
        :accusative
      elsif grammemes.include? 'тв'
        :instrumental
      elsif grammemes.include? 'пр'
        :locative
      elsif grammemes.include? 'зв'
        :vocative
      end

      # second case
      if grammemes.include? '2'
        msd[:case2] = :partitive if :genitive == msd[:case]
        msd[:case2] = :locative if :locative == msd[:case]
      end

      # aspect
      msd[:aspect] = if grammemes.include? 'св'
        :perfective
      elsif grammemes.include? 'нс'
        :progressive
      end

      # voice
      msd[:voice] = if grammemes.include? 'дст'
        :active
      elsif grammemes.include? 'стр'
        :passive
      elsif :verb == msd[:pos]
        :medial
      end

      # tense
      unless :adverb == msd[:pos]
        msd[:tense] = if grammemes.include? 'нст'
          :present
        elsif grammemes.include? 'прш'
          :past
        elsif grammemes.include? 'буд'
          :future
        end
      end

      # imperative verb form
      msd[:vform] = :imperative if grammemes.include? 'пвл'

      # person
      msd[:person] = if grammemes.include? '1л'
        :first
      elsif grammemes.include? '2л'
        :second
      elsif grammemes.include? '3л'
        :third
      elsif grammemes.include? 'безл'
        nil
      end

      # invariability
      nil if grammemes.include? '0'

      # definiteness
      msd[:definiteness] = if grammemes.include? 'кр'
        :short_art
      end

      # degree
      unless :numeral == msd[:pos]
        msd[:degree] = if grammemes.include? 'сравн'
          :comparative
        end
      end

      # adjective type
      msd[:type] = :qualificative if grammemes.include? 'кач'

      # p msd
      msd.to_s
    end
  end
end
