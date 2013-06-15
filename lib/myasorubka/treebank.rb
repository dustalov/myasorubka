# encoding: utf-8

# The Penn Treebank Project annotates naturally-occuring text for
# linguistic structure. Most notably, we produce skeletal parses
# showing rough syntactic and semantic information — a bank of
# linguistic trees.
#
# Treebanks are often created on top of a corpus that has already been
# annotated with part-of-speech tags. In turn, treebanks are sometimes
# enhanced with semantic or other linguistic information.
#
module Myasorubka::Treebank
  extend self

  # Convert the given tag from English Penn Treebank format to the English
  # representation in the MULTEXT-East format.
  #
  def english(tag)
    msd = Myasorubka::MSD.new(Myasorubka::MSD::English)

    case tag
    when 'CC' then
      msd[:pos] = :conjunction
      msd[:type] = :coordinating
    when 'CD' then
      msd[:pos] = :numeral
      msd[:type] = :cardinal
    when 'DT' then
      msd[:pos] = :determiner
    when 'IN' then
      msd[:pos] = :conjunction
      msd[:type] = :subordinating
    when 'JJ' then
      msd[:pos] = :adjective
    when 'JJR' then
      msd[:pos] = :adjective
      msd[:degree] = :comparative
    when 'JJS' then
      msd[:pos] = :adjective
      msd[:degree] = :superlative
    when 'MD' then
      msd[:pos] = :verb
      msd[:type] = :modal
    when 'NN' then
      msd[:pos] = :noun
      msd[:type] = :common
      msd[:number] = :singular
    when 'NNS'
      msd[:pos] = :noun
      msd[:type] = :common
      msd[:number] = :plural
    when 'NP'
      msd[:pos] = :noun
      msd[:type] = :proper
      msd[:number] = :singular
    when 'NPS'
      msd[:pos] = :noun
      msd[:type] = :proper
      msd[:number] = :plural
    when 'PDT' then
      msd[:pos] = :determiner
    when 'PP' then
      msd[:pos] = :pronoun
      msd[:type] = :personal
    when 'PP$' then
      msd[:pos] = :pronoun
      msd[:type] = :possessive
    when 'RB' then
      msd[:pos] = :adverb
    when 'RBR' then
      msd[:pos] = :adverb
      msd[:degree] = :comparative
    when 'RBS' then
      msd[:pos] = :adverb
      msd[:degree] = :superlative
    when 'TO' then
      msd[:pos] = :determiner
    when 'UH' then
      msd[:pos] = :interjection
    when 'VB' then
      msd[:pos] = :verb
      msd[:type] = :base
    when 'VBD' then
      msd[:pos] = :verb
      msd[:type] = :base
      msd[:tense] = :past
    when 'VBG' then
      msd[:pos] = :verb
      msd[:type] = :base
      msd[:vform] = :participle
      msd[:tense] = :present
    when 'VBN' then
      msd[:pos] = :verb
      msd[:type] = :base
      msd[:vform] = :participle
      msd[:tense] = :past
    when 'VBP' then
      msd[:pos] = :verb
      msd[:type] = :base
      msd[:tense] = :present
      msd[:number] = :singular
    when 'VBZ' then
      msd[:pos] = :verb
      msd[:type] = :base
      msd[:tense] = :present
      msd[:person] = :third
      msd[:number] = :singular
    when 'WDT' then
      msd[:pos] = :determiner
    when 'WP' then
      msd[:pos] = :pronoun
    when 'WP$' then
      msd[:pos] = :pronoun
      msd[:type] = :possessive
    when 'WRB' then
      msd[:pos] = :adverb
    else
      msd[:pos] = :residual
    end

    msd
  end
end
