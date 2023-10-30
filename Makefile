install:
	install -T 2backup.sh $(DESTDIR)/usr/local/bin/2backup
	install -T bb.sh $(DESTDIR)/usr/local/bin/bb

update:
	git pull
	install -T 2backup.sh $(DESTDIR)/usr/local/bin/2backup

uninstall:
	rm $(DESTDIR)/usr/local/bin/2backup
	rm $(DESTDIR)/usr/local/bin/bb
