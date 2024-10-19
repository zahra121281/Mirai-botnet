from django.db import models

class SystemData(models.Model):
    hostname = models.CharField(max_length=100)
    os_info = models.TextField()
    kernel_version = models.CharField(max_length=50)
    architecture = models.CharField(max_length=40)
    users = models.TextField()
    ip_addresses = models.TextField()
    cpu_info = models.TextField()
    memory_info = models.TextField()
    disk_usage = models.TextField()
    usb_devices = models.TextField()
    system_time = models.DateTimeField()
    
    def __str__(self):
        return self.hostname

from datetime import datetime

class NetworkTraffic(models.Model):
    interface = models.CharField(max_length=50)
    ip_source = models.GenericIPAddressField()          # Source IP
    ip_destination = models.GenericIPAddressField()     # Destination IP
    port_source = models.IntegerField()                 # Source Port
    port_destination = models.IntegerField()            # Destination Port
    pid_sender = models.IntegerField(null=True, blank=True)  # Process ID of sender (nullable)
    
    capture_date = models.DateField(auto_now_add=True)  # Date when the packet was captured
    capture_time = models.TimeField()   

    def __str__(self):
        return f"{self.interface} - {self.ip_source}:{self.port_source} -> {self.ip_destination}:{self.port_destination} at {self.capture_date} {self.capture_time}"