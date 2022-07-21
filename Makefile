install:
	symfony new --webapp tmp || true
	rm -r tmp/.git
	cp -r /app/tmp/. /app
	rm -r tmp
	setfacl -dR -m u:$(uid):w .
	setfacl -R -m u:$(uid):w .
	setfacl -dR -m u:www-data:rwX var
	setfacl -R -m u:www-data:rwX var
	setfacl -dR -m u:www-data:w public
	setfacl -R -m u:www-data:w public
