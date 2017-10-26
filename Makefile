.PHONY: build all source-repo readmes fixlinks push clean



build: source-repo readmes fixlinks

all: build push


source-repo:
	./get-source-repo.sh

readmes:
	./make-readmes.sh

fixlinks:
	./fix-links.sh

push:
	./push-to-github.sh

clean:
	./make-clean.sh
