PHANTOMJS = phantomjs

test:
	@$(PHANTOMJS) spec/javascripts/runner.js

#integration:
	#@$(PHANTOMJS) spec/javascripts/runner.js

.PHONY: test
