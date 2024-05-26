default: setup

setup: \
	setup-xcodegen \
	setup-swift-lint \
	setup-swift-format \
        setup-post-commit-hook

setup-xcodegen:
	brew install xcodegen

setup-swift-lint:
	brew install swiftlint

setup-swift-format:
	brew install swift-format

setup-post-commit-hook:
	cat Scripts/format/post-commit.sh > .git/hooks/post-commit
	chmod +x .git/hooks/post-commit

.PHONY: setup setup-xcodegen setup-swift-lint setup-swift-format setup-post-commit-hook
