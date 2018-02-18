# Walllpaper 👨🏻‍🎨

**Important Notice (18 Feb 2018):** [Dribbble retired most of their API endpoints](http://developer.dribbble.com/changes/) which made this server useless, therefore we've taken down our server. The marketing pages are now stored on Github and the walllpaper data is now served statically from the iOS device.

The server side code of [Walllpaper App](https://itunes.apple.com/us/app/keynote/id1050415023?mt=8), written in Swift.

<img src="/Public/images/github-header.png?raw=true" width="888">

Walllpaper turns [Dribbble](https://dribbble.com) shots into wallpapers by extending the color on the edges.

In the future I might open source the iOS app code too...

## 🤖 Before building (dependencies)

* Install [Vapor Toolbox](https://github.com/vapor/toolbox)

### macOS:
* Run ```brew install mysql``` followed by ```mysql_secure_installation``` to setup a database
* Install [Xcode](https://developer.apple.com/xcode/)
* Run ```vapor xcode```, this will create the Xcode project

### Ubuntu (server):
* Run ```sudo apt-get install libcurl3```
* Run ```apt-get install mysql-server libmysqlclient-dev python-mysqldb``` followed by ```mysql_secure_installation``` to setup a database

### Database:
* Create a MySQL database called ```walllpaper```, e.g. using the mysql CLI: ```CREATE DATABASE walllpaper;```
* [Config/mysql.json](Config/mysql.json) contains the database credentials

## 🚧 Building

### macOS:
* Run the ```App``` target in Xcode
* Walllpaper should now be running on [http://localhost:8080](http://localhost:8080)

## 📖 Documentation

Visit the Vapor web framework's [documentation](http://docs.vapor.codes) for instructions on how to use this package.

## 💧 Community

Join the welcoming community of fellow Vapor developers in [Slack](http://vapor.team).

## 🔧 Compatibility

This package has been tested on macOS and Ubuntu.
