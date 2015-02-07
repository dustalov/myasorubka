# encoding: utf-8

# AOT-to-MSD morphosyntactic descriptors translator.
#
class Myasorubka::AOT::Tags
  def self.join(hash, msd)
    msd.grammemes.inject(hash) { |h, (k, v)| h[k.to_s] = v.to_s; h }
  end

  # Russian language helpers.
  #
  module Russian
    def self.gender(msd, grammemes)
      msd[:gender] = if grammemes.include? 'мр'
        :masculine
      elsif grammemes.include? 'жр'
        :feminine
      elsif grammemes.include? 'ср'
        :neuter
      elsif grammemes.include? 'мр-жр'
        :common
      end
      msd
    end

    def self.animate(msd, grammemes)
      msd[:animate] = if grammemes.include? 'од'
        :yes
      elsif grammemes.include? 'но'
        :no
      end
      msd
    end

    def self.number(msd, grammemes)
      msd[:number] = if grammemes.include? 'ед'
        :singular
      elsif grammemes.include? 'мн'
        :plural
      end
      msd
    end

    def self.case(msd, grammemes)
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
      msd
    end

    def self.case2(msd, grammemes)
      if grammemes.include? '2'
        msd[:case2] = :partitive if :genitive == msd[:case]
        msd[:case2] = :locative if :locative == msd[:case]
      end
      msd
    end

    def self.aspect(msd, grammemes)
      msd[:aspect] = if grammemes.include? 'св'
        :perfective
      elsif grammemes.include? 'нс'
        :progressive
      end
      msd
    end

    def self.voice(msd, grammemes)
      msd[:voice] = if grammemes.include? 'дст'
        :active
      elsif grammemes.include? 'стр'
        :passive
      elsif :verb == msd[:pos]
        :medial
      end
      msd
    end

    def self.tense(msd, grammemes)
      msd[:tense] = if grammemes.include? 'нст'
        :present
      elsif grammemes.include? 'прш'
        :past
      elsif grammemes.include? 'буд'
        :future
      end
      msd
    end

    def self.person(msd, grammemes)
      msd[:person] = if grammemes.include? '1л'
        :first
      elsif grammemes.include? '2л'
        :second
      elsif grammemes.include? '3л'
        :third
      elsif grammemes.include? 'безл'
        nil
      end
      msd
    end

    def self.definiteness(msd, grammemes)
      msd[:definiteness] = if grammemes.include? 'кр'
        :short_art
      end
      msd
    end

    def self.degree(msd, grammemes)
      msd[:degree] = if grammemes.include? 'сравн'
        :comparative
      elsif grammemes.include? 'прев'
        :superlative
      end
      msd
    end
  end

  # Russian language.
  #
  def self.russian(pos_line, grammemes_line)
    grammemes = grammemes_line.split(',').map do |grammeme|
      Myasorubka::Unicode.downcase(grammeme)
    end

    msd = Myasorubka::MSD.new(Myasorubka::MSD::Russian)

    if grammemes.include? 'aббр'
      msd[:pos] = :abbreviation
      msd[:syntactic_type] = if 'Н' == pos_line
        :adverbial
      else
        :nominal
      end
      pos_line = 'АББР'
    end

    case Myasorubka::Unicode.upcase(pos_line)
    when 'С' then begin
      msd[:pos] = :noun
      msd[:type] = if (grammemes & [ 'имя', 'фам', 'отч', 'жарг', 'арх', 'проф', 'опч' ]).empty?
        :common
      else
        :proper
      end
      [ :gender, :number, :case, :animate, :case2 ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'П' then begin
      msd[:pos] = :adjective
      msd[:type] = if grammemes.include? 'кач'
        :qualificative
      elsif grammemes.include? 'притяж'
        :possessive
      end
      msd[:degree] = :positive
      msd[:definiteness] = :full_art
      [ :degree, :gender, :number, :case, :definiteness ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'МС' then begin
      msd[:pos] = :pronoun
      msd[:type] = :possessive if grammemes.include? 'притяж'
      [ :person, :gender, :number, :case, :animate ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'МС-ПРЕДК' then begin
      msd[:pos] = :pronoun
      msd[:type] = :possessive if grammemes.include? 'притяж'
      msd[:case] = :genitive
      [ :person, :gender, :number, :animate ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'МС-П' then begin
      msd[:pos] = :pronoun
      msd[:type] = :possessive if grammemes.include? 'притяж'
      msd[:syntactic_type] = :adjectival
      [ :person, :gender, :number, :case, :animate ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'Г' then begin
      msd[:pos] = :verb
      msd[:type] = :main
      msd[:vform] = if grammemes.include? 'пвл'
        :imperative 
      end
      msd[:definiteness] = :full_art
      [ :tense, :person, :number, :gender, :voice, :definiteness,
        :aspect, :case ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'ПРИЧАСТИЕ' then begin
      msd[:pos] = :verb
      msd[:vform] = :participle
      msd[:definiteness] = :full_art
      [ :tense, :person, :number, :gender, :voice, :definiteness,
        :aspect, :case ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'ДЕЕПРИЧАСТИЕ' then begin
      msd[:pos] = :verb
      msd[:vform] = :gerund
      msd[:definiteness] = :full_art
      [ :tense, :person, :number, :gender, :voice, :definiteness,
        :aspect, :case ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'ИНФИНИТИВ' then begin
      msd[:pos] = :verb
      msd[:vform] = :infinitive
      msd[:definiteness] = :full_art
      [ :tense, :person, :number, :gender, :voice, :definiteness,
        :aspect, :case ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'ЧИСЛ' then begin
      msd[:pos] = :numeral
      msd[:type] = :cardinal
      [ :gender, :number, :case, :animate ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'ЧИСЛ-П' then begin
      msd[:pos] = :numeral
      msd[:type] = :ordinal
      [ :gender, :number, :case, :animate ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'Н' then begin
      msd[:pos] = :adverb
      msd[:degree] = :positive
      [ :degree ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'ПРЕДК' then begin
      msd[:pos] = :adverb
      msd[:degree] = :positive
      [ :degree ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when 'ПРЕДЛ' then begin
      msd[:pos] = :adposition
      msd[:type] = :preposition
      [ :case ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
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
      msd[:type] = if grammemes.include? 'кач'
        :qualificative
      elsif grammemes.include? 'притяж'
        :possessive
      end
      msd[:degree] = :positive
      [ :degree, :gender, :number, :case ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
      msd[:definiteness] = :short_art
    end
    when 'КР_ПРИЧАСТИЕ' then begin
      msd[:pos] = :verb
      msd[:vform] = :participle
      [ :tense, :person, :number, :gender, :voice,
        :aspect, :case ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
      msd[:definiteness] = :short_art
    end
    when 'АББР' then begin
      [ :gender, :number, :case ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    when '*' then begin
      msd[:pos] = :crutch
      [ :gender, :animate, :number, :case, :case2, :aspect,
        :voice, :tense, :person, :definiteness,
        :degree ].each do |attribute|
        Russian.send(attribute, msd, grammemes)
      end
    end
    else
      msd[:pos] = :residual
    end

    msd
  end
end
