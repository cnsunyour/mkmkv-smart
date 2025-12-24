INSTALL_DIR = ${HOME}/.local

.PHONY : all install clean

all :
	@echo "Usage: make install | make clean"

install :
	mkdir -p ${INSTALL_DIR}/bin
	cp mkmkv.sh ${INSTALL_DIR}/bin/mkmkv
	chmod +x ${INSTALL_DIR}/bin/mkmkv

clean :
	@echo "Nothing to clean"
