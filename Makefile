build:
	hugo
	lessc -x themes/drone/static/less/index.less themes/drone/static/dist/style.min.css
	docker build -t eu.gcr.io/quiet-mechanic-140114/documentation:latest .

publish:
	gcloud docker -- push eu.gcr.io/quiet-mechanic-140114/documentation:latest

.PHONY: build publish
