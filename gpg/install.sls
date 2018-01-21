{%- from "gpg/map.jinja" import gpg with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

{%- if gpg.install_tools %}
gpg_tools_packages:
  pkg.installed:
    - pkgs: {{ gpg.tools_pkgs }}
{%- endif %}

gpg_packages:
  pkg.installed:
    - name: {{gpg.pkg}}
