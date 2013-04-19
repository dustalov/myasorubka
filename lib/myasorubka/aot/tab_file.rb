# encoding: utf-8

# Tab file contains all possible full morphological  patterns for the
# words.
#
# One line in a Tab file looks like as follows:
#
#   <ancode> <useless_number> <pos> <grammemes>
#
# An ancode is an ID, which consists of two letters and which
# uniquely identifies a morphological pattern. A morphological pattern
# consists of:
#
#   <pos> and <grammemes>
#
# A MRD file refers to a Tab file, which is language-dependent.
#
class Myasorubka::AOT::TabFile
  attr_reader :ancodes, :language

  # :nodoc:
  def initialize(filename, ee = nil, ie = Encoding.default_external)
    @ancodes, @language, id = {}, language, -1
    encoding = { internal_encoding: ie, external_encoding: ee }

    File.readlines(filename, $/, encoding).each do |line, i|
      next if line.empty? or line.start_with?('//')
      ancode, _, pos, grammemes = line.split
      ancodes[ancode] = { id: id += 1, pos: pos, grammemes: grammemes || '' }
    end
  end
end
