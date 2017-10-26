.PHONY: all source-repo readmes clean

all: source-repo readmes push

source-repo:
	./get-source-repo.sh

readmes:
	./make-readmes.sh

push:
	./push-to-github.sh

clean:
	./make-clean.sh
