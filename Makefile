.PHONY: coverage

OS := $(shell uname -s)

coverage:
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html
ifeq ($(OS),Darwin) # macOS
	open coverage/html/index.html
else # Windows (Git Bash / PowerShell with make)
	start coverage/html/index.html
endif