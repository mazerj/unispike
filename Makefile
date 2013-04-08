BINDIR=/auto/share/pypeextra

install:
	chmod +x *.sh dbfind unisync.py
	cp *.m dbfind tdtlocate.py $(BINDIR)
	cp p2muni.sh $(BINDIR)/p2muni
	cp p2mS2.sh $(BINDIR)/p2mS2
	cp xmeta.sh $(BINDIR)/xmeta
	cp auto-plx-uni.sh $(BINDIR)/auto-plx-uni
	cp unisync.py $(BINDIR)/unisync
	chmod -x *.sh dbfind unisync.py

SON:
	cat SON.tgz | (cd /auto/share/matlab-local; tar xfz -)

clean:
	@$(RM)  \#*~ .*~ *.pyc *svn-commit.tmp* TAGS

tags:
	etags *.m


