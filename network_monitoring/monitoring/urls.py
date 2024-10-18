from django.urls import path
from .views import SystemDataList, SystemDataDetail, NetworkTrafficList, NetworkTrafficDetail

urlpatterns = [
    path('api/system-data/', SystemDataList.as_view(), name='system_data_list'),
    path('api/system-data/<int:pk>/', SystemDataDetail.as_view(), name='system_data_detail'),
    path('api/network-traffic/', NetworkTrafficList.as_view(), name='network_traffic_list'),
    path('api/network-traffic/<int:pk>/', NetworkTrafficDetail.as_view(), name='network_traffic_detail'),
]


