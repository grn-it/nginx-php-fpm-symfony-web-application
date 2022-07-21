install:
	symfony new --webapp tmp || true
	rm -r tmp/.git
	cp -r /app/tmp/. /app
	rm -r tmp
	setfacl -dR -m u:$(uid):rw .
	setfacl -R -m u:$(uid):rw .
	setfacl -dR -m u:www-data:rwX var
	setfacl -R -m u:www-data:rwX var
	setfacl -dR -m u:www-data:rw public
	setfacl -R -m u:www-data:rw public
