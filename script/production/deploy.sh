cd /var/www/html/test_sakura_rails
## 一応、Source読み込み
source ~/.bash_profile
## ファイルダウンロード
git pull
## DBをMigrateしてしまう。
bundle exec rails db:migrate RAILS_ENV=production
## 静的ファイルアップ
bundle exec rails assets:precompile
## APサーバー再起動
bundle exec rails unicorn:restart
