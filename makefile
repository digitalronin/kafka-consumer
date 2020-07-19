clean:
	APP=$$(heroku apps:info | head -1 | sed 's/=== //'); heroku apps:destroy --confirm $${APP}
