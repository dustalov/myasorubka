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
      @mrd = Myasorubka::AOT::MRDFile.new(mrd_file)
      mrd_file.close
    end

    to_tempfile(configuration[:tab]).tap do |tab_file|
      @tab = Myasorubka::AOT::TabFile.new(tab_file)
      tab_file.close
    end
  end

  def run! db, logger # :nodoc:
    logger.info "Started"

    # prefixes -> prefixes
    mrd.prefixes.each_with_index do |prefix, id|
      db.prefixes[id] = { 'prefix' => prefix }
    end
    logger.info "Prefixes: done (#{db.prefixes.size})"

    # rules -> suffixes
    suffix_id = 0
    mrd.rules.each do |rules|
      rules.each do |suffix, *anything|
        unless db.suffixes.has_suffix? suffix
          db.suffixes[suffix_id] = { 'suffix' => suffix }
          suffix_id += 1
        end
      end
    end
    logger.info "Suffixes: done (#{db.suffixes.size})"

    # lemmas + rules -> stems + words
    stem_id, word_id = 0, 0
    mrd.lemmas.each do |stem, rule_id, accent_id, session_id, lancode, prefix_id|
      unless word_stem_id = db.stems.first_stem(stem, rule_id)
        db.stems[stem_id] = { 'stem' => stem, 'rule_id' => rule_id }
        word_stem_id = stem_id
        stem_id += 1
      end

      mrd.rules[rule_id].each do |suffix, rancode, prefix|
        suffix_id = db.suffixes.first_suffix(suffix)

        pattern = tab.ancodes[rancode]
        pos = pattern[:pos]
        grammemes = pattern[:grammemes]

        if lancode && !lancode.empty?
          pattern = tab.ancodes[lancode]
          grammemes = "#{grammemes},#{pattern[:grammemes]}"
          #grammemes.insert(-1, ',').insert(-1, pattern[:grammemes])
        end

        msd = Myasorubka::AOT::MSD.send(language, pos, grammemes)

        db.words[word_id] = { 'msd' => msd,
                              'prefix' => prefix,
                              'stem_id' => word_stem_id,
                              'suffix_id' => suffix_id }
        word_id += 1

        if 0 == word_id % 1_000
          last_word = db.assemble(word_id - 1)
          logger.info "Words: now (#{word_id}): #{last_word}"
        end
      end

      if 0 == stem_id % 1_000
        last_stem = db.stems[stem_id - 1]['stem']
        logger.info "Stems: now (#{stem_id}): #{last_stem}"
      end
    end
    logger.info "Words: done (#{db.words.size})"
    logger.info "Stems: done (#{db.stems.size})"

    logger.info "Finished"
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
