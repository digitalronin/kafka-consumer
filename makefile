setup:
	heroku create
	git push heroku master
	heroku open

clean:
	APP=$$(heroku apps:info | head -1 | sed 's/=== //'); heroku apps:destroy --confirm $${APP}

local-server:
	bundle exec puma -C config/puma.rb

deploy:
	git push heroku master

