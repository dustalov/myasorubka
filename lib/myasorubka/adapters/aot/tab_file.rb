# encoding: utf-8

class Myasorubka::AOT
  # Tab file contains all possible full morphological  patterns for the
  # words.
  #
  # One line in a Tab file looks like as follows:
  #
  #   <ancode> <unused_number> <part_of_speech> <grammems>
  #
  # An ancode is an ID, which consists of two letters and which
  # uniquely identifies a morphological pattern. A morphological pattern
  # consists of:
  #
  #   <part_of_speech> and <grammemes>
  #
  # A MRD file refers to a Tab file, which is language-dependent.
  #
  class TabFile
    attr_reader :ancodes

    def initialize(tab_file) # :nodoc:
      @ancodes = {}

      tab_file.rewind
      tab_file.each do |line|
        line.force_encoding('UTF-8').strip!
        next if line.empty? || line.start_with?('//')
        ancode, unused_number, pos, grammemes = line.split

        ancodes[ancode] = { :pos => pos, :grammemes => grammemes || '' }
      end
    end
  end
end
