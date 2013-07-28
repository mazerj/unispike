BINDIR ?= /auto/share/pypeextra

install:
	chmod +x *.sh unisync.py
	cp *.m tdtlocate.py $(BINDIR)
	cp p2muni.sh $(BINDIR)/p2muni
	cp p2mS2.sh $(BINDIR)/p2mS2
	cp xmeta.sh $(BINDIR)/xmeta
	cp auto-plx-uni.sh $(BINDIR)/auto-plx-uni
	cp unisync.py $(BINDIR)/unisync
	chmod -x *.sh unisync.py

SON:
	cat SON.tgz | (cd $(BINDIR); tar xfz -)

clean:
	@$(RM)  \#*~ .*~ *.pyc *svn-commit.tmp* TAGS

tags:
	etags *.m


