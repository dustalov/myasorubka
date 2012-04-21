# encoding: utf-8

require 'tempfile'

require 'myaso/msd/russian'

require 'myasorubka/aot/mrd_file'
require 'myasorubka/aot/tab_file'
require 'myasorubka/aot/msd'

# AOT dictionaries adapter.
#
# Required options are: <tt>:mrd</tt>, <tt>:tab</tt> and
# <tt>:language</tt>. If necessary, <tt>:encoding</tt> option
# may be given, too.
#
class Myasorubka::AOT
  attr_reader :mrd, :tab, :language, :encoding

  def initialize(config = {}) # :nodoc:
    @encoding = config[:encoding]
    @language = config[:language]

    to_tempfile(config[:mrd]).tap do |mrd_file|
      @mrd = Myasorubka::AOT::MRDFile.new(mrd_file, language)
      mrd_file.close
    end

    to_tempfile(config[:tab]).tap do |tab_file|
      @tab = Myasorubka::AOT::TabFile.new(tab_file, language)
      tab_file.close
    end
  end

  def run! db, logger # :nodoc:
    # prefixes -> prefixes
    mrd.prefixes.each_with_index do |prefix, id|
      db.prefixes.set(id, 'prefix' => prefix)
    end
    logger.info "Prefixes: done (#{db.prefixes.size})"

    # rules -> rules
    rule_id = 0

    mrd.rules.each_with_index do |rules, rule_set_id|
      rules.each do |suffix, ancode, prefix|
        pos, grammemes = tab.ancodes[ancode].values_at(:pos, :grammemes)

        rule_hash = {
          'msd' => MSD.send(language, pos, grammemes).to_s,
          'rule_set_id' => rule_set_id
        }

        rule_hash.merge! 'prefix' => prefix if prefix && !prefix.empty?
        rule_hash.merge! 'suffix' => suffix if suffix && !suffix.empty?

        db.rules.set(rule_id, rule_hash)

        rule_id += 1

        if 0 == rule_id % 1_000
          logger.info "Rules: now (#{rule_id}): " \
                      "#{prefix}...#{suffix} => #{ancode}"
        end
      end
    end
    logger.info "Rules: done (#{db.rules.size})"

    # lemmas + rules -> stems + words
    word_id = 0
    mrd.lemmas.each_with_index do |lemma, stem_id|
      stem, rule_set_id, accent_id, session_id, ancode, prefix_id = lemma

      stem_hash = {
        'rule_set_id' => rule_set_id,
        'stem' => stem
      }

      if ancode_hash = tab.ancodes[ancode]
        stem_hash['msd_id'] = ancode_hash[:id]
      end

      db.stems.set(stem_id, stem_hash)

      db.rules.select_by_rule_set(rule_set_id).each do |rule_id|
        db.words.set(word_id, 'stem_id' => stem_id,
                              'rule_id' => rule_id)

        word_id += 1

        if 0 == word_id % 5_000
          last_word = db.words.assemble(word_id - 1)
          logger.info "Words: now (#{word_id}): #{last_word}"
        end
      end

      if 0 == (stem_id + 1) % 1_000
        last_stem = db.stems.find(stem_id)['stem']
        logger.info "Stems: now (#{stem_id + 1}): #{last_stem}"
      end
    end
    logger.info "Words: done (#{db.words.size})"
    logger.info "Stems: done (#{db.stems.size})"
  end

  private
    def to_tempfile(source_filename)
      Tempfile.new('myaso').tap do |temp|
        if encoding
          IO.foreach(source_filename).each do |line|
            temp.puts line.encode!('UTF-8', encoding)
          end
        else
          IO.foreach(source_filename).each do |line|
            temp.puts line
          end
        end
        temp.rewind
      end
    end
end
