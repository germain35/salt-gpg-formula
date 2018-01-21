{%- from "gpg/map.jinja" import gpg with context %}

include:
  - gpg.install
  {%- if gpg.config is defined %}
  - gpg.config
  {%- endif %}
  - gpg.delete
  - gpg.import