build:
	hugo --baseUrl http://developers.waylay.io/
	docker build -t eu.gcr.io/quiet-mechanic-140114/documentation:latest .

publish:
	gcloud docker -- push eu.gcr.io/quiet-mechanic-140114/documentation:latest

.PHONY: build publish
