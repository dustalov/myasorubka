# A wrapper around mystem's internal binary format.
#
module Myasorubka::Mystem::Binary extend self
  # https://github.com/yandex/tomita-parser/blob/master/src/library/lemmer/dictlib/yx_gram_enum.h
  GRAMMEMES = {
    127 => :postposition,
    128 => :adjective,
    129 => :adverb,
    130 => :composite,
    131 => :conjunction,
    132 => :interjunction,
    133 => :numeral,
    134 => :particle,
    135 => :preposition,
    136 => :substantive,
    137 => :verb,
    138 => :adj_numeral,
    139 => :adj_pronoun,
    140 => :adv_pronoun,
    141 => :subst_pronoun,
    142 => :article,
    143 => :part_of_idiom,
    144 => :reserved,
    145 => :abbreviation,
    146 => :irregular_stem,
    147 => :informal,
    148 => :distort,
    149 => :contracted,
    150 => :obscene,
    151 => :rare,
    152 => :awkward,
    153 => :obsolete,
    154 => :subst_adjective,
    155 => :first_name,
    156 => :surname,
    157 => :patronymic,
    158 => :geo,
    159 => :proper,
    160 => :present,
    161 => :notpast,
    162 => :past,
    163 => :future,
    164 => :past2,
    165 => :nominative,
    166 => :genitive,
    167 => :dative,
    168 => :accusative,
    169 => :instrumental,
    170 => :ablative,
    171 => :partitive,
    172 => :locative,
    173 => :vocative,
    174 => :singular,
    175 => :plural,
    176 => :gerund,
    177 => :infinitive,
    178 => :participle,
    179 => :indicative,
    180 => :imperative,
    181 => :conditional,
    182 => :subjunctive,
    183 => :short,
    184 => :full,
    185 => :superlative,
    186 => :comparative,
    187 => :possessive,
    188 => :person1,
    189 => :person2,
    190 => :person3,
    191 => :feminine,
    192 => :masculine,
    193 => :neuter,
    194 => :mas_fem,
    195 => :perfect,
    196 => :imperfect,
    197 => :passive,
    198 => :active,
    199 => :reflexive,
    200 => :impersonal,
    201 => :animated,
    202 => :inanimated,
    203 => :praedic,
    204 => :parenth,
    205 => :transitive,
    206 => :intransitive,
    207 => :definite,
    208 => :indefinite,
    209 => :sim_conj,
    210 => :sub_conj,
    211 => :pronoun_conj,
    212 => :correlate_conj,
    213 => :aux_verb
  }.freeze

  # Convert an array with mystem grammeme codes into a MSD.
  #
  def to_msd(grammemes)
    msd = Myasorubka::MSD.new(Myasorubka::MSD::Russian)

    grammemes.sort.each do |code|
      case GRAMMEMES[code]
      # Nomenus
      when :postposition then msd[:pos] = :adposition
      when :adjective then msd[:pos] = :adjective; msd[:type] = :qualificative; msd[:degree] = :positive
      when :adverb then msd[:pos] = :adverb
      when :conjunction then msd[:pos] = :conjunction
      when :interjunction then msd[:pos] = :interjection
      when :numeral then msd[:pos] = :numeral; msd[:type] = :cardinal
      when :particle then msd[:pos] = :particle
      when :preposition then msd[:pos] = :adposition; msd[:type] = :preposition
      when :substantive then msd[:pos] = :noun; msd[:type] = :common
      when :verb then msd[:pos] = :verb; msd[:type] = :main
      when :adj_numeral then msd[:pos] = :numeral; msd[:type] = :ordinal
      when :adj_pronoun then msd[:pos] = :pronoun; msd[:syntactic_type] = :adjectival
      when :adv_pronoun then msd[:pos] = :pronoun; msd[:syntactic_type] = :adverbial
      when :subst_pronoun then msd[:pos] = :pronoun; msd[:syntactic_type] = :nominal
      when :abbreviation then msd[:pos] = :abbreviation
      when :first_name then msd[:type] = :proper
      when :surname then msd[:type] = :proper
      when :patronymic then msd[:type] = :proper
      when :geo then msd[:type] = :proper
      when :proper then msd[:type] = :proper
      # Tempus
      when :present then msd[:tense] = :present
      # TODO: how to handle :notpast tense?
      when :past then msd[:tense] = :past
      when :future then msd[:tense] = :future
      when :past2 then msd[:tense] = :past
      # Casus
      when :nominative then msd[:case] = :nominative
      when :genitive then msd[:case] = :genitive
      when :dative then msd[:case] = :dative
      when :accusative then msd[:case] = :accusative
      when :instrumental then msd[:case] = :instrumental
      when :ablative then msd[:case] = :genitive
      when :partitive then msd[:case] = :genitive; msd[:case2] = :partitive
      when :locative then msd[:case] = :genitive; msd[:case2] = :locative
      when :vocative then msd[:case] = :vocative
      # Numerus
      when :singular then msd[:number] = :singular
      when :plural then msd[:number] = :plural
      # Modus
      when :gerund then msd[:vform] = :gerund
      when :infinitive then msd[:vform] = :infinitive
      when :participle then msd[:vform] = :participle
      when :indicative then msd[:vform] = :indicative
      when :imperative then msd[:vform] = :imperative
      when :conditional then msd[:vform] = :conditional
      # Gradus
      when :short then msd[:definiteness] = :short_art
      when :full then msd[:definiteness] = :full_art
      when :superlative then msd[:degree] = :superlative
      when :comparative then msd[:degree] = :comparative
      when :possessive then msd[:type] = :possessive
      # Personae
      when :person1 then msd[:person] = :first
      when :person2 then msd[:person] = :second
      when :person3 then msd[:person] = :third
      # Gender
      when :feminine then msd[:gender] = :feminine
      when :masculine then msd[:gender] = :masculine
      when :neuter then msd[:gender] = :neuter
      when :mas_fem then msd[:gender] = :common
      # Perfectum-Imperfectum
      when :perfect then msd[:aspect] = :perfective
      when :imperfect then msd[:aspect] = :progressive
      # Voice
      when :passive then msd[:voice] = :passive
      when :active then msd[:voice] = :active
      when :reflexive then msd[:type] = :reflexive
      # Animated
      when :animated then msd[:animate] = :yes
      when :inanimated then msd[:animate] = :no
      # Transitivity
      when :definite then msd[:definiteness] = :full_art
      when :indefinite then msd[:definiteness] = :short_art
      # Definiteness
      when :sim_conj then msd[:type] = :coordinating
      when :sub_conj then msd[:type] = :subordinating
      when :aux_verb then msd[:type] = :auxiliary
      else
      end
    end

    msd.prune!
  end
end
