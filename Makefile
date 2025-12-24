INSTALL_DIR = ${HOME}/.local

.PHONY : all clean install

all : mkmkv

mkmkv : mkmkv.sh
	shc -r -o mkmkv -f mkmkv.sh
	chmod +x mkmkv

clean :
	rm -f mkmkv mkmkv.sh.x.c

install :
	cp mkmkv ${INSTALL_DIR}/bin/mkmkv
