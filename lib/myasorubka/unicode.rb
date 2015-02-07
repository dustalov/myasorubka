# This module provides downcase and upcase methods designed for Russian.
# The original code is written by Andrew Kozlov for the Petrovich library.
#
# https://github.com/petrovich/petrovich-ruby/blob/df705075542979ab85e1f2bf9a2024b1c0813e1a/lib/petrovich/unicode.rb
#
module Myasorubka::Unicode extend self
  # Russian capital letters.
  #
  RU_UPPERCASE = [
    "\u0410", "\u0411", "\u0412", "\u0413", "\u0414", "\u0415", "\u0416", "\u0417",
    "\u0418", "\u0419", "\u041A", "\u041B", "\u041C", "\u041D", "\u041E", "\u041F",
    "\u0420", "\u0421", "\u0422", "\u0423", "\u0424", "\u0425", "\u0426", "\u0427",
    "\u0428", "\u0429", "\u042A", "\u042B", "\u042C", "\u042D", "\u042E", "\u042F",
    "\u0401" # Ё
  ].join

  # Russian small letters.
  #
  RU_LOWERCASE = [
    "\u0430", "\u0431", "\u0432", "\u0433", "\u0434", "\u0435", "\u0436", "\u0437",
    "\u0438", "\u0439", "\u043A", "\u043B", "\u043C", "\u043D", "\u043E", "\u043F",
    "\u0440", "\u0441", "\u0442", "\u0443", "\u0444", "\u0445", "\u0446", "\u0447",
    "\u0448", "\u0449", "\u044A", "\u044B", "\u044C", "\u044D", "\u044E", "\u044F",
    "\u0451" # Ё
  ].join

  # Returns a copy of the given string having replaced
  # capital Russian letters with small ones.
  #
  # @param string [String] a string.
  # @return [String] a new string.
  #
  def downcase(string)
    string.tr(RU_UPPERCASE, RU_LOWERCASE).tap(&:downcase!)
  end

  # Returns a copy of the given string having replaced
  # small Russian letters with capital ones.
  #
  # @param string [String] a string.
  # @return [String] a new string.
  #
  def upcase(string)
    string.tr(RU_LOWERCASE, RU_UPPERCASE).tap(&:upcase!)
  end
end
