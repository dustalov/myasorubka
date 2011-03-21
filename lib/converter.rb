# encoding: utf-8

require 'tempfile'
require 'iconv'

class Myasorubka::Converter
  attr_reader :path
  attr_reader :morphs, :gramtab, :encoding

  def initialize(morphs, gramtab, encoding)
    @path = Dir.getwd

    @morphs = morphs
    @gramtab = gramtab
    @encoding = encoding || 'UTF-8'
  end

  def execute!
    puts " == Processing '#{gramtab}'..."
    to_tempfile(gramtab).tap do |file|
      print ' * Patterns: '
      load_patterns(file)
      puts

      file.close
    end

    puts " == Processing '#{morphs}'..."
    to_tempfile(morphs).tap do |file|
      print ' * Prefixes: '
      file.rewind
      load_prefixes(file)
      puts

      print ' * Suffixes: '
      file.rewind
      load_suffixes(file)
      puts

      print ' * Rules: '
      file.rewind
      load_rules(file)
      puts

      print ' * Stems: '
      file.rewind
      load_stems(file)
      puts

      file.close
    end

    puts " == Thanks."
    store.close
    nil
  end

  def load_patterns(gramtab_file)
    i = 0

    gramtab_file.each do |line|
      line.strip!
      next if line.empty? || line.start_with?('//')

      # [ ancode, letter, part, grammemes ]
      parts = line.split
      parts << '' while parts.size < 4

      store.patterns[parts.first] = {
        'grammemes' => parts[3],
        'pos' => parts[2]
      }

      if (i + 1) % 50 == 0
        STDOUT.print(i + 1)
        STDOUT.print ' '
        STDOUT.flush
      end

      i += 1
    end

    STDOUT.print(i + 1) unless (i + 1) % 50 == 0
    nil
  end

  def load_prefixes(file)
    3.times { morphs_foreach(file) }
    morphs_foreach(file) do |line, index|
      store.prefixes[index] = { 'prefix' => line }
    end
  end

  def load_suffixes(file)
    trie = Myasorubka::Trie.new(store.suffixes)

    morphs_foreach(file) do |line, *index|
      line.split('%').each do |rule_line|
        next unless rule_line && !rule_line.empty?

        suffix_line = rule_line.split('*').first.reverse
        trie.put(suffix_line)
      end
    end
  end

  def load_rules(file)
    trie = Myasorubka::Trie.new(store.suffixes)

    morphs_foreach(file) do |line, index|
      rule = store.rules[index] || {}
      rule['frequency'] = 0

      line.split('%').each_with_index do |rule_line, rule_index|
        next unless rule_line && !rule_line.empty?

        parts = rule_line.split('*')
        parts << '' while parts.size < 3
        parts[1] = parts[1].slice!(0...2).to_s
        parts[0].reverse!

        rule_form = {
          'pattern_id' => parts[1],
          'prefix' => parts[2],
          'rule_id' => index
        }

        suffix_id = trie.find(parts[0])
        rule_form['suffix_id'] = suffix_id if suffix_id

        store.rule_forms["#{index}-#{rule_index}"] = rule_form
      end

      store.rules[index] = rule
    end
  end

  def load_stems(file)
    4.times { morphs_foreach(file) }
    trie = Myasorubka::Trie.new(store.stems)

    morphs_foreach(file) do |line, *index|
      stem_line, rule_id = line.split

      stem_id = trie.put(stem_line.reverse)

      stem = store.stems[stem_id]
      stem['rule_id'] = rule_id

      store.stems[stem_id] = stem

      rule = store.rules[rule_id]
      frequency = rule['frequency'].to_i || 0
      rule['frequency'] = frequency + 1
      store.rules[rule_id] = rule
    end
  end

  private
    def store
      @store ||= Myasorubka::Store.new(path, :manage)
    end

    def to_tempfile(source_filename)
      Tempfile.new('myaso').tap do |temp|
        Iconv.open('UTF-8', encoding) do |cd|
          IO.foreach(source_filename).each do |line|
            temp.puts cd.iconv(line)
          end
        end
        temp.rewind
      end
    end

    def morphs_foreach(morphs_file, &block)
      index = morphs_file.readline.to_i.times do |i|
        line = morphs_file.readline
        # anyway we must pass the entire section
        next unless block
        line.force_encoding('UTF-8').strip!
        block.call(line, i)

        if (i + 1) % 50 == 0
          STDOUT.print(i + 1)
          STDOUT.print ' '
          STDOUT.flush
        end
      end

      return unless block
      STDOUT.print index unless index % 50 == 0
      nil
    end
end
