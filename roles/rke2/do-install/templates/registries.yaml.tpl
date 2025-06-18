{%  if docker_mirror %}
mirrors:
  docker.io:
    endpoint:
      - "{{ docker_mirror }}"
{%  endif %}