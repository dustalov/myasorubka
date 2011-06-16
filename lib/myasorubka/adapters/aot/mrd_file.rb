# encoding: utf-8

class Myasorubka::AOT # :nodoc:
  # MRD file is a text file which contains one morphological
  # dictionary for one natural language. MRD is an abbreviation
  # of "morphological dictionary".
  #
  # All words in MRD file are written in UPPERCASE. One MRD file
  # consists of the following sections: section of flexion and
  # prefix models, section of accentual models, section of user
  # sessions, session of prefix sets, section of lemmas.
  #
  class MRDFile
    attr_reader :lines
    attr_reader :rules_offset, :accents_offset, :logs_offset,
                :prefixes_offset, :lemmas_offset

    def initialize(mrd_file) # :nodoc:
      mrd_file.rewind
      @lines = mrd_file.read.force_encoding('UTF-8').lines.to_a

      @rules_offset = 0
      @accents_offset = @rules_offset + rules.length + 1
      @logs_offset = @accents_offset + accents.length + 1
      @prefixes_offset = @logs_offset + logs.length + 1
      @lemmas_offset = @prefixes_offset + prefixes.length + 1
    end

    # MRD file section handling helper class.
    #
    # Each section is a set of records, one per line. The number of
    # all records of the section  is written in the very beginning of
    # the section ata separate line.
    #
    class Section
      attr_reader :lines, :offset, :length, :parser

      def initialize(lines, offset, &parser_block) # :nodoc:
        @lines = lines
        @offset = offset
        @length = lines[offset].strip.to_i
        @parser = parser_block
      end

      def [] id # :nodoc:
        if id < 0 || id >= length
          raise ArgumentError, "invalid id=#{id} when " \
                               "offset=#{offset} and "\
                               "length=#{length}"
        end
        parser.call(lines[offset + 1 + id].strip)
      end

      def each &block # :nodoc:
        length.times do |id|
          block.call self[id]
        end
      end

      def each_with_index &block # :nodoc:
        length.times do |id|
          block.call self[id], id
        end
      end
    end

    # Rules section accessor.
    #
    def rules
      @rules ||= Section.new(lines, rules_offset) do |line|
        line.split('%').map_with_index do |rule_line|
          next unless rule_line && !rule_line.empty?
          suffix, ancode, prefix = rule_line.split('*')
          [ suffix, ancode.mb_chars[0..1].to_s, prefix || '' ]
        end.delete_if { |x| !x }
      end
    end

    # Accents section accessor.
    #
    def accents
      @accents ||= Section.new(lines, accents_offset) { |line| line }
    end

    # Logs section accessor.
    #
    def logs
      @logs ||= Section.new(lines, logs_offset) { |line| line }
    end

    # Prefixes section accessor.
    #
    def prefixes
      @prefixes ||= Section.new(lines, prefixes_offset) { |line| line }
    end

    # Lemmas section accessor.
    #
    def lemmas
      @lemmas ||= Section.new(lines, lemmas_offset) do |line|
        stem, rule_id, accent_id,
          session_id, ancode, prefix_id = line.split
        [ stem, rule_id.to_i, accent_id.to_i, session_id.to_i,
          ancode == '-' ? nil : ancode.mb_chars[0..1].to_s,
          prefix_id == '-' ? nil : prefix_id.to_i ]
      end
    end
  end
end
