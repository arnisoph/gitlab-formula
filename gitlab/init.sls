#!jinja|yaml

{% from 'gitlab/defaults.yaml' import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('gitlab:lookup')) %}

include: {{ datamap.sls_include|default(['gitlab._setup', 'gitlab._config', 'gitlab._service']) }}
extend: {{ datamap.sls_extend|default({}) }}
