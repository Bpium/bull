.PHONY: build

build:
	@echo "🔹 git pull..."
	git pull
	@echo "🔹 clean proc..."
	npm run clean:scripts
	@echo "🔹 remove raw scripts"
	rm -rf rawScripts
	@echo "🔹 check dir rawScripts..."
	if [ ! -d rawScripts ]; then mkdir rawScripts; fi
	@echo "🔹 copy Lua..."
	npm run generate:raw:scripts
	@echo "🔹 Generate JS Lua..."
	npm run transform:commands
	@echo "✅ Build success"

link:
	npm run link

flush:
	redis-cli FLUSHALL