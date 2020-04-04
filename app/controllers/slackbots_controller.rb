class SlackbotsController < ApplicationController
  def test
    ZozoScraping.fetch_wear_page("https://wear.jp/men-category/tops/knit-sweater/")
  end
end
