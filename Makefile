.PHONY: all source-repo readmes clean

all: source-repo readmes

source-repo:
	./get-source-repo.sh

readmes:
	./make-readmes.sh

clean:
	./make-clean.sh
