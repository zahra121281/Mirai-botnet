# Generated by Django 4.2.16 on 2024-10-17 22:10

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('monitoring', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='systemdata',
            name='active_connections',
        ),
        migrations.RemoveField(
            model_name='systemdata',
            name='active_services',
        ),
        migrations.RemoveField(
            model_name='systemdata',
            name='all_users',
        ),
        migrations.RemoveField(
            model_name='systemdata',
            name='env_vars',
        ),
        migrations.RemoveField(
            model_name='systemdata',
            name='installed_packages',
        ),
        migrations.RemoveField(
            model_name='systemdata',
            name='open_ports',
        ),
        migrations.RemoveField(
            model_name='systemdata',
            name='processes',
        ),
        migrations.AlterField(
            model_name='systemdata',
            name='architecture',
            field=models.CharField(max_length=40),
        ),
    ]