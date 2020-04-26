class WearScraping
  require 'mechanize'
  def self.fetch_wear_page(url=nil)
    agent = Mechanize.new
    page = agent.get(url)
    item_snaps = page.search(".like_mark")

    category_id = page.search(".coordinate")[0].attributes['data-categoryid'].value

    item_imgs = page.search(".image .img img")
    images = item_imgs.map { |item_img| "https:" + item_img.attributes["data-originalretina"].value }

    json_url = "https://wear.jp/common/json/coordinate_items.json?snap_ids="
    snap_id = item_snaps.map{ |item_snap| item_snap.attributes["data-snapid"].value }
    json_url += snap_id.join(',')
    json_url = "#{json_url}&category_id=#{category_id}"

    uri = URI.parse(json_url)
    json = Net::HTTP.get(uri)

    # ブランド名、値段、zozowownへのリンクがあるかどうか検索。
    cordinate_datas = JSON.parse(json)
    post_texts = []
    p 'sucess5'
    cordinate_datas.each do |cordinate_data|
      cordinate_data['lists'].each.with_index(0) do |list, i|
        list['items'].each do |item|
          if item['brand_name'].include?("&#") || item['ec_list'].blank?
            next
          end
          post_texts << "ブランド: " + item['brand_name'] \
          + " \n値段: "     + item['price'] \
          + " \n画像: "     + " https:" + item['item_image_215_url'] \
          + " \n着用画像: "  + " #{images[i]}"
        end
      end
    end
    post_texts = post_texts.each_slice(1).to_a

    post_texts = post_texts[0]

    Slack.configure do |config|
      config.token = ENV["SLACK_OAUTH_ACCESS_TOKEN"]
    end
    client = Slack::Web::Client.new

    post_texts.each do |post_text|
      client.chat_postMessage(
        as_user: 'true',
        channel: '#zozo_scraping',
        text: post_text
      )
    end

  end
end
