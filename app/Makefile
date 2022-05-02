.PHONY: protos xcode

protos:
	protoc --swift_out=Protos/ -I ../protos/ ../protos/core.proto

xcode:
	open App.xcodeproj