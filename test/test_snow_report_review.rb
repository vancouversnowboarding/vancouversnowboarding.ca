#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'minitest/autorun'
require 'open3'
require 'tmpdir'

REVIEW_SCRIPT = File.expand_path('../bin/snow-report-review', __dir__)

class SnowReportReviewTest < Minitest::Test
  def with_temp_repo
    Dir.mktmpdir('snow-report-review-test') do |dir|
      Dir.chdir(dir) { yield(dir) }
    end
  end

  def write_post(root, date, body:, image: 'assets/images/2026-01-02-feature.jpg', featured: true)
    FileUtils.mkdir_p(File.join(root, '_posts'))
    FileUtils.mkdir_p(File.join(root, 'assets/images'))

    post_path = File.join(root, '_posts', "#{date}-#{date}-whistler-blackcomb-snow-report.md")
    File.write(
      post_path,
      <<~MD
        ---
        layout: post
        title: #{date} Whistler Blackcomb snow report
        date: "#{date}T14:10:00-07:00"
        tag: Whistler Blackcomb
        image: #{image}
        featured: #{featured}
        ---

        #{body}
      MD
    )
    post_path
  end

  def write_image(root, relative_path, content)
    path = File.join(root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    path
  end

  def run_review(root)
    Open3.capture3('ruby', REVIEW_SCRIPT, chdir: root)
  end

  def assert_review_passes(root)
    stdout, stderr, status = run_review(root)
    assert status.success?, "expected success, got status #{status.exitstatus}\nstdout: #{stdout}\nstderr: #{stderr}"
    assert_includes stdout, 'snow-report review: ok'
  end

  def assert_review_fails(root, expected_message)
    stdout, stderr, status = run_review(root)
    refute status.success?, "expected failure, got success\nstdout: #{stdout}\nstderr: #{stderr}"
    assert_includes stderr, expected_message
  end

  def test_valid_same_date_inline_image_passes
    with_temp_repo do |root|
      write_image(root, 'assets/images/2026-01-02-feature.jpg', 'feature')
      write_image(root, 'assets/images/2026-01-02-upper-olympic.jpg', 'body')
      write_post(
        root,
        '2026-01-02',
        body: "Warm and clear.\n\n![](/assets/images/2026-01-02-upper-olympic.jpg)"
      )

      assert_review_passes(root)
    end
  end

  def test_valid_angle_bracket_inline_image_passes
    with_temp_repo do |root|
      write_image(root, 'assets/images/2026-01-02-feature.jpg', 'feature')
      write_image(root, 'assets/images/2026-01-02-upper-olympic.jpg', 'body')
      write_post(
        root,
        '2026-01-02',
        body: "Warm and clear.\n\n![](</assets/images/2026-01-02-upper-olympic.jpg>)"
      )

      assert_review_passes(root)
    end
  end

  def test_valid_inline_image_with_title_passes
    with_temp_repo do |root|
      write_image(root, 'assets/images/2026-01-02-feature.jpg', 'feature')
      write_image(root, 'assets/images/2026-01-02-upper-olympic.jpg', 'body')
      write_post(
        root,
        '2026-01-02',
        body: "Warm and clear.\n\n![](/assets/images/2026-01-02-upper-olympic.jpg \"Upper Olympic\")"
      )

      assert_review_passes(root)
    end
  end

  def test_body_image_with_wrong_date_prefix_fails
    with_temp_repo do |root|
      write_image(root, 'assets/images/2026-01-02-feature.jpg', 'feature')
      write_image(root, 'assets/images/2026-01-03-upper-olympic.jpg', 'body')
      write_post(
        root,
        '2026-01-02',
        body: "Warm and clear.\n\n![](/assets/images/2026-01-03-upper-olympic.jpg)"
      )

      assert_review_fails(root, 'same report date prefix')
    end
  end

  def test_body_image_referencing_feature_image_fails
    with_temp_repo do |root|
      write_image(root, 'assets/images/2026-01-02-feature.jpg', 'feature')
      write_post(
        root,
        '2026-01-02',
        body: "Warm and clear.\n\n![](/assets/images/2026-01-02-feature.jpg)"
      )

      assert_review_fails(root, 'feature image must not appear in the body')
    end
  end

  def test_body_image_referencing_missing_file_fails
    with_temp_repo do |root|
      write_image(root, 'assets/images/2026-01-02-feature.jpg', 'feature')
      write_post(
        root,
        '2026-01-02',
        body: "Warm and clear.\n\n![](/assets/images/2026-01-02-upper-olympic.jpg)"
      )

      assert_review_fails(root, 'referenced body image does not exist')
    end
  end

  def test_existing_front_matter_validation_still_works
    with_temp_repo do |root|
      write_image(root, 'assets/images/2026-01-02-feature.jpg', 'feature')
      write_post(
        root,
        '2026-01-02',
        body: 'Warm and clear.',
        image: 'http://example.com/feature.jpg'
      )

      assert_review_fails(root, 'image must be inside assets/images')
    end
  end
end
