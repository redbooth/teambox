PHANTOMJS = phantomjs

test:
	@$(PHANTOMJS) spec/javascripts/runner.js

integration:
	@$(PHANTOMJS) spec/javascripts/integration.js

.PHONY: test integration
