# encoding: utf-8

require 'tempfile'
require 'iconv'

require 'myaso/msd/russian'

require 'myasorubka/adapters/aot/mrd_file'
require 'myasorubka/adapters/aot/tab_file'
require 'myasorubka/adapters/aot/msd'

# AOT dictionaries adapter.
#
# Required options are: <tt>:mrd</tt>, <tt>:tab</tt> and
# <tt>:language</tt>. If necessary, <tt>:encoding</tt> option
# may be given, too.
#
class Myasorubka::AOT
  attr_reader :mrd, :tab, :language, :encoding

  def initialize(configuration = {}) # :nodoc:
    @encoding = configuration[:encoding]
    @language = configuration[:language]

    to_tempfile(configuration[:mrd]).tap do |mrd_file|
      @mrd = Myasorubka::AOT::MRDFile.new(mrd_file, language)
      mrd_file.close
    end

    to_tempfile(configuration[:tab]).tap do |tab_file|
      @tab = Myasorubka::AOT::TabFile.new(tab_file, language)
      tab_file.close
    end
  end

  def run! db, logger # :nodoc:
    # gramtab -> msds
    tab.ancodes.each_with_index do |(ancode, attrs), msd_id|
      pos, grammemes = attrs[:pos], attrs[:grammemes]
      msd = Myasorubka::AOT::MSD.send(language, pos, grammemes)
      db.msds[msd_id] = Myasorubka::AOT::MSD.include_msd({
        'pos' => msd.pos.to_s,
        'ancode' => ancode # it is unnecessary, but let it be
      }, msd)
    end
    logger.info "MSDs: done (#{db.msds.size})"

    # prefixes -> prefixes
    mrd.prefixes.each_with_index do |prefix, id|
      db.prefixes[id] = { 'prefix' => prefix }
    end
    logger.info "Prefixes: done (#{db.prefixes.size})"

    # rules -> rules
    rule_id = 0
    mrd.rules.each_with_index do |rules, rule_set_id|
      rules.each do |suffix, ancode, prefix|
        db.rules[rule_id] = {
          'msd_id' => tab.ancodes[ancode][:id],
          'rule_set_id' => rule_set_id,
          'prefix' => prefix,
          'suffix' => suffix
        }
        rule_id += 1
        if 0 == rule_id % 1_000
          logger.info "Rules: now (#{rule_id}): #{suffix} => #{ancode}"
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
      db.stems[stem_id] = stem_hash

      db.rules.select_by_rule_set(rule_set_id).each do |rule_id|
        db.words[word_id] = {
          'stem_id' => stem_id,
          'rule_id' => rule_id
        }

        word_id += 1

        if 0 == word_id % 5_000
          last_word = db.assemble(word_id - 1)
          logger.info "Words: now (#{word_id}): #{last_word}"
        end
      end

      if 0 == (stem_id + 1) % 1_000
        last_stem = db.stems[stem_id]['stem']
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
          Iconv.open('UTF-8', encoding) do |cd|
            IO.foreach(source_filename).each do |line|
              temp.puts cd.iconv(line)
            end
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
