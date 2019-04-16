.PHONY: watch
watch:
	stack build --fast --pedantic --test --file-watch --exec \
	  'bash -c "pkill passphrase-me; stack exec passphrase-me &"'

.PHONY: release
release:
	heroku container:login
	heroku container:push web --app passphrase-me
	heroku container:release web --app passphrase-me
