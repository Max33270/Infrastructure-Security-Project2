# -*- coding: utf-8 -*-
SECRET_KEY = "b'c8t+tm!0+9vid5=t+b=&9qm63fntffy!djqm@0tj5j!t%((!&g'"
SERVICE_URL = "http://seafile.linux.b2"
FILE_SERVER_ROOT = 'https://seafile.linux.b2/seafhttp'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'seahub_db',
        'USER': 'seafile',
        'PASSWORD': 'seafile',
        'HOST': '10.104.1.21',
        'PORT': '3306',
        'OPTIONS': {'charset': 'utf8mb4'},
    }
}
