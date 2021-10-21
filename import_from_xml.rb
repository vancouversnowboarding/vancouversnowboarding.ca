require 'time'
require 'yaml'
require 'nokogiri'

doc = Nokogiri::XML(File.read('vancouversnowboarding.wordpress.com-2021-10-21-16_32_02/vancouversnowboarding.wordpress.2021-10-21.000.xml'))

grouped = doc.xpath('//item').group_by { _1.xpath('./wp:post_type').text }
attachments = grouped['attachment']
posts = grouped['post']

# (attachments, pages, posts) = doc.xpath('//item').map {|item|
#   post_type = item.xpath('./wp:post_type').text
# 
#   case post_type
#   when 'attachment'
#     [item, nil, nil]
#   when 'page'
#     [nil, item, nil]
#   when 'nav_menu_item'
#     next
#   when 'post'
#     [nil, nil, item]
#   else
#     raise "Must not happen: post_type: #{post_type}"
#   end
# }.compact.transpose

attachment_url_by_parent = attachments.to_h { [_1.xpath('./wp:post_parent').text, _1.xpath('./wp:attachment_url').text ] }
attachment_url_by_id = attachments.to_h { [_1.xpath('./wp:post_id').text, _1.xpath('./wp:attachment_url').text] }

# TODO page
posts.each do |item|
  img = attachment_url_by_parent[item.xpath('./wp:post_id').text]
  unless img
    xml = item.xpath('./wp:postmeta').find { _1.xpath('./wp:meta_key').text == '_thumbnail_id' }
    key = xml && xml.xpath('./wp:meta_value').text
    img = attachment_url_by_id[key]
  end
  post_name = item.xpath('./wp:post_name').text

  hash = {
    'layout' => 'post',
    'title' => item.xpath('./title').text,
    'date' => Time.parse(item.xpath('./pubDate').text),
    # 'link' => item.xpath('./link').text,
    'tag' => item.xpath('./category').text,
    'image' => img,
    # 'slug' => post_name,
  }
  filename =
    case item.xpath('./link').text
      in %r"(\d{4})/(\d{2})/(\d{2})/([^/]+)/?$"
      "./_posts/#{$1}-#{$2}-#{$3}-#{$4}.md"
    else
      raise 'link did not match'
    end
  File.open(filename, 'w') do |io|
    p filename
    output = <<~"EOS"
    #{hash.to_yaml}
    ---
    #{item.xpath('./content:encoded').text}
    EOS

    if true
      io.puts(output)
    else
      puts output
      exit
    end
  end
end


# p hashes.map { _1[:category] }.uniq # ["", "Uncategorized", "Grouse mountain", "Seymour mountain", "Revelstoke Mountain Resort"]
