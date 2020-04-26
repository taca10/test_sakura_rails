class SlackbotsController < ApplicationController
  skip_before_action :verify_authenticity_token

  CATEGORY = Struct.new(:name, :path)
  CATEGORIES = [
    CATEGORY.new("Tシャツ",   "tops/tshirt-cutsew/"),
    CATEGORY.new("カットソー", "tops/tshirt-cutsew/"),
    CATEGORY.new("シャツ",    "tops/shirt-blouse/"),
    CATEGORY.new("ポロシャツ", "tops/polo-shirt/"),
    CATEGORY.new("ニット",    "tops/knit-sweater/"),
    CATEGORY.new("パーカー",    "tops/parka/"),
    CATEGORY.new("スウェット",    "tops/sweat/"),
    CATEGORY.new("カーディガン",    "tops/cardigan/"),
    CATEGORY.new("アンサンブル",    "tops/ensemble/"),
    CATEGORY.new("ジャージ",    "tops/jersey/"),
    CATEGORY.new("タンクトップ",    "tops/tank-tops/")
  ].freeze

  def test
    WearScraping.fetch_wear_page("https://wear.jp/men-category/tops/knit-sweater/")
  end

  def event
    @body = JSON.parse(request.body.read)
    if @body['type'] == 'url_verification'
      return render json: @body['challenge']
    end

    number_of_retry = request.headers['HTTP_X_SLACK_RETRY_NUM']
    # リトライなら何も処理しない
    return head 200 if request.headers['HTTP_X_SLACK_RETRY_NUM'].present?

    slack_message = @body['event']['text'].delete('<@US68T0M1Q>').gsub(/[\r\n]/,"")
    category = CATEGORIES.find{ |category| category.name == slack_message }

    if @body['event']['type'] == 'message' && @body['event']['text'].include?('<@US68T0M1Q>')
      case @body['type']
      when 'event_callback'
        WearScraping.fetch_wear_page("https://wear.jp/men-category/#{category.path}")
      end
    end
  end
end
