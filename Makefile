.PHONY: clean generate regenerate test docs redocs

build: bin/stamper

rebuild: clean generate build

generate: bindings/TokenboundERC20/TokenboundERC20.go

regenerate: clean generate

bin/stamper: stamper/TokenboundERC20.go stamper/BindingERC721.go
	mkdir -p bin
	go build -o bin/stamper ./stamper

bindings/TokenboundERC20/TokenboundERC20.go: out/TokenboundERC20.sol/TokenboundERC20.json
	seer evm generate --foundry out/TokenboundERC20.sol/TokenboundERC20.json --cli --package TokenboundERC20 --struct TokenboundERC20 --output bindings/TokenboundERC20/TokenboundERC20.go

out/TokenboundERC20.sol/TokenboundERC20.json:
	forge build

out/TokenboundERC20.sol/BindingERC721.json:
	forge build

test:
	forge test -vvv

clean:
	rm -rf out/*
	rm stamper/TokenboundERC20.go stamper/BindingERC721.go

docs:
	forge doc

redocs: clean docs
