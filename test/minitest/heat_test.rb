# frozen_string_literal: true

require 'test_helper'

class Minitest::HeatTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Minitest::Heat::VERSION
  end

  def test_utf8_reads_unlabeled_bytes_as_utf8
    ['café'.b, 'café'.b.force_encoding(Encoding::US_ASCII)].each do |text|
      assert_equal 'café', Minitest::Heat.utf8(text)
      assert_equal Encoding::UTF_8, Minitest::Heat.utf8(text).encoding
    end
  end

  def test_utf8_replaces_bytes_that_are_not_valid_utf8
    latin1_bytes = 'café'.encode(Encoding::ISO_8859_1).b

    assert_equal "caf\uFFFD", Minitest::Heat.utf8(latin1_bytes)
  end

  def test_utf8_converts_text_in_other_encodings
    assert_equal 'café', Minitest::Heat.utf8('café'.encode(Encoding::ISO_8859_1))
  end

  def test_utf8_leaves_non_strings_alone
    assert_nil Minitest::Heat.utf8(nil)
  end
end
