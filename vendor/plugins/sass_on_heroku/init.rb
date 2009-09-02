if RAILS_ENV == 'production'
	ActionController::Dispatcher.middleware.use SassOnHeroku
end