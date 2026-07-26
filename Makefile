NVIM ?= nvim
INIT := lua/package-info/tests/minimal_init.lua
FILE ?= lua/package-info/tests/suites

.PHONY: test lint clean

test:
	@PI_TEST_PATH=$(FILE) $(NVIM) --headless -u $(INIT) \
		-c "lua local ok, err = pcall(MiniTest.run) if not ok then io.stderr:write(tostring(err)) vim.cmd('silent! 1cquit') end"; \
		status=$$?; rm -rf temp; exit $$status

lint:
	stylua --check .
	luacheck .
	git ls-files '*.md' | xargs prettier --check

clean:
	rm -rf .tests temp
