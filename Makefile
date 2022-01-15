test: 
	mkdir -p temp
	nvim --headless -c "lua require('plenary.test_harness').test_directory('.', { minimal_init='./lua/package-info/tests/minimal.vim', sequential = true })"
	rm -rf temp
