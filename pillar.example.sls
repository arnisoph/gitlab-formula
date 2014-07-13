gitlab:
  db:
    host: postgreshost.domain.local
    password: myultracryptopassword42
  gravatar:
    enabled: False
  domain: gitlabhost.domain.local
  https: true
  shell:
    ca_file: /etc/ssl/certs/gitlabhost.domain.local.ca.pem
    ca_path: /etc/ssl/certs/


# PostgreSQL DB backend with https://github.com/bechtoldt/postgresql-formula
postgresql:
  lookup:
    server:
      config:
        pg_hba:
          config:
            - name: allow access from gitlab system to gitlab db
              type: host
              database: gitlab
              user: gitlab
              address: {{ salt['dig.A']('gitlabhost.domain.local')[0] }}/32
              auth_method: md5
  users:
    - name: gitlab
      password: myultracryptopassword42
  databases:
    - name: gitlab
      encoding: SQL_ASCII
      lc_collate: C
      lc_ctype: C
      template: template1

# nginx webserver with https://github.com/bechtoldt/nginx-formula
nginx:
  vhosts:
    gitlab:
      plain: |
        upstream gitlab {

          ## Uncomment if you have set up unicorn to listen on a unix socket (recommended).
          server unix:/home/git/gitlab/tmp/sockets/gitlab.socket;

          ## Uncomment if unicorn is configured to listen on a tcp port.
          ## Check the port number in /home/git/gitlab/config/unicorn.rb
          # server 127.0.0.1:8080;
        }

        ## This is a normal HTTP host which redirects all traffic to the HTTPS host.
        server {
          listen *:80;
          ## Replace git.example.com with your FQDN.
          server_name git.example.com;
          server_tokens off;
          ## root doesn't have to be a valid path since we are redirecting
          root /nowhere;
          rewrite ^ https://$server_name$request_uri permanent;
        }

        server {
          listen 443 ssl;
          ## Replace git.example.com with your FQDN.
          server_name git.example.com;
          server_tokens off;
          root /home/git/gitlab/public;

          ## Increase this if you want to upload large attachments
          ## Or if you want to accept large git objects over http
          client_max_body_size 20m;

          ## Strong SSL Security
          ## https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
          ssl on;
          ssl_certificate /etc/ssl/certs/gitlab.domain.local.crt.pem;
          ssl_certificate_key /etc/ssl/private/gitlab.domain.local.key.pem;

          ssl_ciphers 'ECDHE-RSA-AES128-SHA256:AES128-GCM-SHA256:HIGH:!MD5:!aNULL:!EDH:!RC4';

          ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
          ssl_session_cache  builtin:1000  shared:SSL:10m;

          ...
