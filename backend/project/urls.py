"""
URL configuration for backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import path, include
from route.views import get_route
from location.views import campus_list, campus_detail, create_campus, update_campus, delete_campus

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/routes/outdoor/", get_route),
    #the following are to get all campuses
    path("api/location/campuses/", campus_list, name="campus_list"),
    path("api/location/campuses/<int:campus_id>/", campus_detail, name="campus_detail"),
    path("api/location/campuses/create/", create_campus, name="create_campus"),
    path("api/location/campuses/<int:campus_id>/update/", update_campus, name="update_campus"),
    path("api/location/campuses/<int:campus_id>/delete/", delete_campus, name="delete_campus"),

]

