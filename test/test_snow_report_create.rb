#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'fileutils'
require 'minitest/autorun'
require 'optparse'
require 'tmpdir'

load File.expand_path('../bin/snow-report-create', __dir__)

class SnowReportCreateTest < Minitest::Test
  def with_tmp_chdir
    Dir.mktmpdir('snow-report-create-test') do |dir|
      Dir.chdir(dir) { yield(dir) }
    end
  end

  def sample_image_metadata
    {
      feature_image: 'assets/images/2026-01-02-feature.jpg',
      body_candidates: [
        { path: '/assets/images/2026-01-02-upper-village-2.jpg', label: 'upper village 2' },
        { path: '/assets/images/2026-01-02-lower_jersey-cream.jpg', label: 'lower jersey cream' }
      ]
    }
  end

  def test_image_discovery_excludes_feature_and_sorts
    with_tmp_chdir do
      FileUtils.mkdir_p('assets/images')
      File.write('assets/images/2026-01-02-feature.jpg', 'x')
      File.write('assets/images/2026-01-02-zeta-run.jpg', 'x')
      File.write('assets/images/2026-01-02-alpha-run-2.jpg', 'x')
      File.write('assets/images/2026-01-03-alpha-run.jpg', 'x')

      metadata = collect_image_metadata('2026-01-02')

      assert_equal 'assets/images/2026-01-02-feature.jpg', metadata[:feature_image]
      assert_equal [
        '/assets/images/2026-01-02-alpha-run-2.jpg',
        '/assets/images/2026-01-02-zeta-run.jpg'
      ], metadata[:body_candidates].map { |item| item[:path] }
    end
  end

  def test_label_normalization_preserves_case_digits_and_sequence_suffix
    label = normalize_image_label('assets/images/2026-01-02-New_Jersey-cream-express-6-2.JPG', '2026-01-02')
    assert_equal 'New Jersey cream express 6 2', label

    second_label = normalize_image_label('assets/images/2026-01-02-PXL__20260202--114500.jpg', '2026-01-02')
    assert_equal 'PXL 20260202 114500', second_label
  end

  def test_prompt_contains_image_rules_and_metadata
    prompt = ruby_prompt(
      reference_excerpt: "One.\n\nTwo.",
      date: '2026-01-02',
      summary: 'rate 4, bright',
      rating: 4,
      stars: '★★★★☆',
      image_metadata: sample_image_metadata
    )
    review = review_prompt(
      reference_excerpt: "One.\n\nTwo.",
      draft_body: "Draft.\n\n![](/assets/images/2026-01-02-upper-village-2.jpg)",
      date: '2026-01-02',
      summary: 'rate 4, bright',
      rating: 4,
      stars: '★★★★☆',
      image_metadata: sample_image_metadata
    )

    [prompt, review].each do |text|
      assert_includes text, 'If body candidate images exist, include at least 1 in the body.'
      assert_includes text, 'Never use the feature image inside the body.'
      assert_includes text, 'Keep it concise: exactly 2 short prose paragraphs.'
      assert_includes text, 'Use only facts that are explicitly supported by the provided summary or image labels.'
      assert_includes text, 'If a fact is not provided, leave it unsaid.'
      assert_includes text, 'Do not invent weather, visibility, hut, or food details.'
      assert_includes text, 'Paragraph 1 may cover weather and visibility if provided.'
      assert_includes text, 'Paragraph 2 should cover snow quality, busyness, and race-event impacts if provided.'
      assert_includes text, 'If the summary does not provide a detail, omit it instead of guessing.'
      assert_includes text, 'A caption line and standalone Markdown image line may appear between those paragraphs and do not count as prose paragraphs.'
      assert_includes text, 'Each image must be on its own line.'
      assert_includes text, 'Any caption or lead-in text should be on a separate line immediately before the image.'
      assert_includes text, 'Do not append image markdown to a sentence.'
      assert_includes text, 'Do not append image markdown to a sentence or dump images as a tail gallery.'
      assert_includes text, '/assets/images/2026-01-02-upper-village-2.jpg'
      assert_includes text, 'upper village 2'
      assert_includes text, 'assets/images/2026-01-02-feature.jpg'
    end
  end

  def test_validation_accepts_allowed_body_image_usage
    validate_body_image_links!(
      body: "Visibility was decent.\n\n![](/assets/images/2026-01-02-upper-village-2.jpg)\n\nCrowds built after lunch.",
      image_metadata: sample_image_metadata
    )
  end

  def test_validation_rejects_feature_image_in_body
    error = assert_raises(RuntimeError) do
      validate_body_image_links!(
        body: "![](/assets/images/2026-01-02-feature.jpg)",
        image_metadata: sample_image_metadata
      )
    end
    assert_includes error.message, 'feature image'
  end

  def test_validation_rejects_unknown_image_path
    error = assert_raises(RuntimeError) do
      validate_body_image_links!(
        body: "![](/assets/images/2026-01-02-not-allowed.jpg)",
        image_metadata: sample_image_metadata
      )
    end
    assert_includes error.message, 'unknown image path'
  end

  def test_validation_rejects_missing_body_image_when_candidates_exist
    error = assert_raises(RuntimeError) do
      validate_body_image_links!(
        body: "No image links here.",
        image_metadata: sample_image_metadata
      )
    end
    assert_includes error.message, 'at least 1 body image'
  end

  def test_validation_rejects_inline_image_usage_in_prose
    error = assert_raises(RuntimeError) do
      validate_body_image_links!(
        body: "Warm sun with a thin layer of cloud kept visibility steady east-west despite a bit of glare, and the Chick Pea Hut garage door wide open filled the deck with cinnamon bun aroma as cheerful crews shuffled past; ![](/assets/images/2026-01-02-upper-village-2.jpg)",
        image_metadata: sample_image_metadata
      )
    end
    assert_includes error.message, 'own line'
  end

  def test_fact_validation_rejects_unsupported_weather_visibility_and_food_details
    error = assert_raises(RuntimeError) do
      validate_body_facts!(
        body: "Grey skies kept temps just below freezing while a fine spitting drizzle blurred visibility to the tree line; the mid-mountain hut served thick broth and toasted bannock.\n\n![](/assets/images/2026-01-02-upper-village-2.jpg)\n\nSnow quality stayed essentially icy, with Pony Trail standing out as the worst section.",
        summary: "rate 1. Extremely icy. Simply Don't go there. Pony Trail was particularly bad."
      )
    end

    assert_includes error.message, 'unsupported'
  end

  def test_fact_validation_allows_supported_weather_and_visibility_details
    validate_body_facts!(
      body: "Sunny skies kept visibility good across the open slopes.\n\n![](/assets/images/2026-01-02-upper-village-2.jpg)\n\nIt stayed extremely icy, and Pony Trail was particularly bad.",
      summary: "rate 1. Sunny. Visibility was good. Extremely icy. Pony Trail was particularly bad."
    )
  end

  def test_review_retry_flow_with_stubbed_codex_runner
    image_metadata = {
      feature_image: 'assets/images/2026-01-02-feature.jpg',
      body_candidates: [{ path: '/assets/images/2026-01-02-upper-village-2.jpg', label: 'upper village 2' }]
    }
    responses = [
      { 'body' => "First draft.\n\n![](/assets/images/2026-01-02-upper-village-2.jpg)" },
      { 'verdict' => 'fix', 'body' => "Fixed draft.\n\n![](/assets/images/2026-01-02-upper-village-2.jpg)" },
      { 'verdict' => 'pass', 'body' => '' }
    ]
    contexts = []

    final_body = generate_reviewed_body(
      root: '/tmp/fake-root',
      model: 'gpt-5.1-codex-mini',
      reference_excerpt: "Ref para 1.\n\nRef para 2.",
      date_string: '2026-01-02',
      summary: 'rate 4, bright',
      rating: 4,
      stars: '★★★★☆',
      image_metadata: image_metadata,
      codex_runner: lambda do |args|
        contexts << args.fetch(:context)
        responses.shift
      end
    )

    assert_equal ['draft generation', 'review', 'review retry'], contexts
    assert_equal "Fixed draft.\n\n![](/assets/images/2026-01-02-upper-village-2.jpg)", final_body
  end
end
