# Overview of repo
- `app/` folder contains all files and csv's required to run the web application

# Hosting through RStudio Shinyapps
The PANO application is hosted via [shinyapps](http://shinyapps.io/). All management and analytics regarding usage can be accessed through the associated shinyapps account. Deploying and stopping running instances must also be controlled through the account.

# Best practices regarding development
- All development is encouraged to occur on the dev branch and be merged into the master branch via a pull request


# Contributing walkthrough

## Get the project code on your local machine

### Fork the repository
![](examples/fork.png)
This will allow you to have your own copy of the project and helps keep the development process modular. For more information on forks, see: https://help.github.com/en/github/getting-started-with-github/fork-a-repo

### Clone the repository
- Open your teminal application and choose a location where you want to store this project
- Using git, clone the repository by typing `git clone https://github.com/YOUR_USERNAME/intervention-outcomes.git`
    - Replace YOUR_USERNAME with your github username in the command above
### Checkout the `dev` branch
- In your terminal, type `cd intervention-outcomes` to enter the project directory
- Next type `git checkout dev`, this will change your copy of the project code to the development branch
    - For more info on branching in git, see: https://guides.github.com/introduction/flow/

## Make/test changes
Edit the code on the `dev` branch as you would like and keep the master branch functional until you have tested/verified that the changes are not "code breaking".

## Commit/push changes
- Commit (make a snapshot) your changes on your local machine by typing `git commit -m "DESCRIPTION_OF_CHANGES"` in your terminal
    - Replace DESCRIPTION_OF_CHANGES with an actual description in the command above
- Push your changes to the remote machine (aka the github website) by typing `git push origin dev` in your terminal

## Merge into master branch and make a pull request
Once the `dev` branch is confirmed to be stable, you can create a pull request on github ![](examples/pr.png)
