from django.contrib import admin
from .models import SystemData, NetworkTraffic

# Register your models here
admin.site.register(SystemData)
admin.site.register(NetworkTraffic)

