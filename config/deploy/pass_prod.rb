set :rails_env, "pass_prod"
set :application, "new_arrivals_prod"
set :domain,      "brahms.cul.columbia.edu"
set :deploy_to,   "/opt/passenger/#{application}/"
set :user, "deployer"
set :branch, @variables[:branch] || "brahms_prod"
set :scm_passphrase, ""

role :app, domain
role :web, domain
role :db,  domain, :primary => true


