{% from "gpg/map.jinja" import gpg with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

gpg_packages:
  pkg.installed:
    - pkgs: {{gpg.packages}}
