set :rails_env, "passenger_dev"
set :application, "spectrum_dev"
set :domain,      "bronte.cul.columbia.edu"
set :deploy_to,   "/opt/passenger/#{application}/"
set :user, "deployer"
set :branch, @variables[:branch] || "spectrum_dev"
set :scm_passphrase, "Current user can full owner domains."

role :app, domain
role :web, domain
role :db,  domain, :primary => true


