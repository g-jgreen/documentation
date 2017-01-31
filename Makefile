build:
	hugo --baseUrl http://130.211.103.225/
	docker build -t eu.gcr.io/quiet-mechanic-140114/documentation:latest .

publish:
	gcloud docker -- push eu.gcr.io/quiet-mechanic-140114/documentation:latest

.PHONY: build publish
