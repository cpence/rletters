
# For a successful RLetters deployment, you *must* configure the connection
# details for at least one server of type :web and at least one server of type
# :worker. These can be the same server.

# At least one :web server must be tagged with the property primary: true, and
# this server will be in charge of performing database migrations and seeding.
# Similarly, the primary :worker server will be in charge of running the
# maintenance tasks (and should have been so configured in Ansible).

# What follows is mostly the original Capistrano documentation for configuring
# servers in this file, slightly modified for our use case.


# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{web worker}, primary: true
# server "www2.example.com", user: "deploy", roles: %w{web}


# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :web, %w{user1@primary.com user2@additional.com}
# role :worker,  %w{deploy@example.com}


# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web worker},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
