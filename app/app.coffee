express = require "express"
util    = {} #TODO: Find a better pattern to do this.

# Global paths
static_path      = "#{__dirname}/../public"
lib_path         = "#{__dirname}/../lib"
util_path        = "#{__dirname}/../util"
helpers_path     = "#{__dirname}/helpers"
models_path      = "#{__dirname}/models"
views_path       = "#{__dirname}/views"
controllers_path = "#{__dirname}/controllers"
routes_path      = "#{__dirname}/routes"

###
Global configuration
###
module.exports.boot_up_application = (app) ->
  app.configure ->

    # -- Define view engine with its options
    app.set "views", views_path
    app.set "view engine", "ejs"
    app.enable "jsonp callback"

    # -- Set uncompressed html output and disable layout templating
    app.locals( pretty: true, layout: false)

    # -- Parses x-www-form-urlencoded request bodies (and json)
    app.use express.bodyParser()
    app.use express.methodOverride()

    # ## CORS middleware
    # see: http://stackoverflow.com/questions/7067966/how-to-allow-cors-in-express-nodejs
    app.use (req, res, next) ->
      res.header "Access-Control-Allow-Origin", "*"
      res.header "Access-Control-Allow-Methods", "GET,PUT,POST,DELETE"
      res.header "Access-Control-Allow-Headers", "Content-Type, Authorization"
      res.header "Cache-Control", "private, max-age=0"
      res.header "Expires", new Date().toUTCString()
      if "OPTIONS" is req.method
        res.send 200
      else
        next()

    # -- Express Static Resources
    app.use express.static(static_path)
    app.use express.favicon("#{static_path}/images/favicon.ico")

    # -- App helpers
    util.auto_loader = require "#{util_path}/auto_loader"
    util.auto_loader.autoload(helpers_path, app)
    util.auto_loader.autoload(lib_path, app)
    util.auto_loader.autoload(models_path, app)
    util.auto_loader.autoload(controllers_path, app)

    # -- Express routing
    app.use app.router
    require(routes_path)(app)