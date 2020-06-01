args <- commandArgs(trailingOnly = TRUE)

name_acc <- args[1]
token_acc <- args[2]
secret_acc <- args[3]
appId_deploy <- args[4]
appName_deploy <- args[5]

rsconnect::setAccountInfo(name=name_acc,
			  token=token_acc,
			  secret=secret_acc)
rsconnect::deployApp(appId = appId_deploy, appName = appName_deploy, launch.browser = FALSE, forceUpdate = getOption("rsconnect.force.update.apps", TRUE), appDir = "/home/coder/projects/app/", server = 'shinyapps.io')
