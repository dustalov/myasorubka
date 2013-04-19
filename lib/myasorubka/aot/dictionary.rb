# encoding: utf-8

# MRD file is a text file that contains a morphological dictionary of
# a natural language. MRD is an abbreviation of "morphological dictionary".
#
# All words in MRD file are written in UPPERCASE. One MRD file has the
# following sections: section of flexion and prefix models, section of
# accentual models, section of user sessions, session of prefix sets,
# section of lemmas.
#
class Myasorubka::AOT::Dictionary
  attr_reader :lines, :language
  attr_reader :rules_offset, :accents_offset, :logs_offset,
              :prefixes_offset, :lemmas_offset

  # The parser should be initialized by passing filename and language
  # parameters.
  #
  def initialize(filename, language = nil, ee = nil, ie = Encoding.default_external)
    encoding = { internal_encoding: ie, external_encoding: ee }
    @lines, @language = File.readlines(filename, $/, encoding), language

    @rules_offset = 0
    @accents_offset = rules_offset + rules.length + 1
    @logs_offset = accents_offset + accents.length + 1
    @prefixes_offset = logs_offset + logs.length + 1
    @lemmas_offset = prefixes_offset + prefixes.length + 1
  end

  # MRD file section handling helper class.
  #
  # Each section is a set of records, one per line. The number of
  # all records of the section is written in the very beginning of
  # the section ata separate line.
  #
  class Section
    include Enumerable

    attr_reader :lines, :offset, :length, :parser

    # :nodoc:
    def initialize(lines, offset, &block)
      @lines, @offset = lines, offset
      @length = lines[offset].strip.to_i
      @parser = block || proc { |s| s }
    end

    # :nodoc:
    def [] id
      if id < 0 or id >= length
        raise ArgumentError,
          'invalid id=%d when offset=%d and length=%d' %
          [id, offset, length]
      end

      parser.call(lines[offset + 1 + id].strip)
    end

    # :nodoc:
    def each(&block)
      length.times { |id| block.call self[id] }
    end
  end

  # Rules section accessor.
  #
  def rules
    @rules ||= Section.new(lines, rules_offset) do |line|
      line.split('%').map do |rule_line|
        next unless rule_line && !rule_line.empty?

        suffix, ancode, prefix = rule_line.split '*'

        case language
        when :russian then
          suffix &&= suffix.tr 'Ёё', 'Ее'
          prefix &&= prefix.tr 'Ёё', 'Ее'
        end

        [suffix, ancode[0..1], prefix]
      end.compact
    end
  end

  # Accents section accessor.
  #
  def accents
    @accents ||= Section.new(lines, accents_offset)
  end

  # Logs section accessor.
  #
  def logs
    @logs ||= Section.new(lines, logs_offset)
  end

  # Prefixes section accessor.
  #
  def prefixes
    @prefixes ||= Section.new(lines, prefixes_offset)
  end

  # Lemmas section accessor.
  #
  def lemmas
    @lemmas ||= Section.new(lines, lemmas_offset) do |line|
      stem, rule_id, accent_id, session_id, ancode, prefix_id = line.split

      case language
      when :russian then
        stem &&= stem.tr 'Ёё', 'Ее'
      end

      Array.new.tap do |result|
        result <<
          (stem == '#' ? nil : stem) <<
          rule_id.to_i <<
          accent_id.to_i <<
          session_id.to_i <<
          (ancode == '-' ? nil : ancode[0..1]) <<
          (prefix_id == '-' ? nil : prefix_id.to_i)
      end
    end
  end
end
