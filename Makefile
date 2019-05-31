build:
	echo "Please ensure no Docker containers are running with the same ports as this docker-compose.yml file"
	read -p "Press any key to continue..."
	docker-compose build --force-rm --no-cache
	docker-compose up -d
	docker-compose exec -e MIX_ENV=test application mix deps.get
	docker-compose exec -e MIX_ENV=test application mix compile --force
	docker-compose exec -e MIX_ENV=test application mix do event_store.create, event_store.init

start:
	docker-compose up -d

clean:
	docker-compose stop
	rm -rf deps
	rm -rf _build
	docker-compose up -d
	docker-compose exec application mix deps.get

stop:
	docker-compose stop
