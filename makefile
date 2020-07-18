setup:
	heroku create
	make set-heroku-config
	git push heroku master
	heroku open

# This assumes a set of files which contain Kafka config values, exported from
# a different heroku application. We need to set these values so that our app.
# can talk to the other app's Kafka instance.
set-heroku-config:
	for var in KAFKA_URL KAFKA_TRUSTED_CERT KAFKA_CLIENT_CERT KAFKA_CLIENT_CERT_KEY; do \
		heroku config:set $${var}="$$(cat $${var})"; \
	done

clean:
	APP=$$(heroku apps:info | head -1 | sed 's/=== //'); heroku apps:destroy --confirm $${APP}

local-server:
	bundle exec puma -C config/puma.rb

deploy:
	git push heroku master

