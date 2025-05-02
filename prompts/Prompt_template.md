i am looking to create a prompt template to accelerate AI assisted coding tasks

I have a preferred pattern where I want the assistant to configure the environment and setup the file structure via bash shell scripts that create all files and directories, initialize the git repo in the current folder, create a readme.md gitignore files, everything that is required for an optimally patterned repo and project. In order to properly set this up, I need to include input/output formats and folders 

I then require a set of artifacts that is the functioning code/website/app code that is the centerpiece and point of the prompt/exercise

I require a build and deploy script that will do everything required to get it up and running including acquiring dependencies (confirming the existence of the dependency, if it isn't there the script installs it and writes to a log for audit purposes) building docker images/venvs and running/deploying the container/pods based on the tech we've chosen

I require a comprehensive instruction markdown document with all aspects of the project from start to finish so any user of the repo can create from scratch or go straight to building and deploying or even just pulling and running a container without dealing with any of the code. Instructions to the developer can include patterns on how to properly version, release and docummentation the solution and it's artifacts (containers, helm packages, dependencies, CVE/Security/Dependabot)

I always include a Special Instructions: section of the prompt to give the AI some notes on who it's talking to
Consistently, these are the static as I am the dev on all of these projects

**The developer in this case is a novice, point out standard patters and why they exist.  Advising on Github best practices would be beneficial as well.

**They have no prior experience with Javascript or python (venv)

**Explain the concepts behind what you are suggesting and why it's structured that way

**When writing code that isn't the complete file, always put in the comments at the beginning and end of the code snippet, where EXACTLY in the existing code does that go

**VSCode, WSL ubuntu 24.04 distro, all documentation should be in markdown

An overarching theme of all of these requests will be adhering to devops principles with security always in mind.  we want to provide value as quickly as possible while still maintaing secure patterns and monitoring/feedback from our solution. 
*** Quality/testing/logging/code documentation should be built in all solutions at all points



Here is an example of an actual first prompt for a dev project
Can you create a standalone lightweight app, preferably in a container that will allow a user to import an existing collection given to them by a vendor or a person with a license and be able to effectively use the output of that collection in the lightweight/Free Postman IDE?

Can you create the interface in javascript or python platforms, your choice.

That includes a bash script to create well documented, robust logging and debugging code for the interface so that a user can just browse to a collection and hit "submit" and a ready to use artifact (cURL or JSON) is output to a directory called "exported_collections"

Create an additional bash script that takes the code created by the interface and deploys it in either a container or a docker compose

Include a 3rd artifact, a markdown file with explicit step by step instructions on how to properly use the 1st 2 artifacts.

Create a 4th artifact that is a well documented bash script that will initialize the folder the above code needs, create a readme.md and anything else needed for a complete solution.

Special Instructions:

The developer in this case is a novice

They have no prior experience with Javascript or python (venv)

Explain the concepts behind what you are suggesting and why it's structured that way

When writing code that isn't the complete file, always put in the comments at the beginning and end of the code snippet, where EXACTLY in the existing code does that go

Here is a second example"
i have a roughly 10 very small, 8 second mp4 files that i want to convert to animated svgs given a unique name and saved in a folder called export



Write me a standalone app or script that will convert any mp4 files in the directory mp4 to a animated svg of the mp4?



Can you create the app in python venv that has already been implemented and is where this script will run



This is a clean venv, any dependencies you will need, check to see if you have them, if not then they need to be added to the venv including all testing/automation/python libraries and their dependencies



Create a bash script to create well documented, robust logging and debugging code for the conversion script/app and includes proper logging and security measures



Create an additional bash script that takes the code created by the interface and deploys it in the venv, already activated



Include a 3rd artifact, a markdown file with explicit step by step instructions on how to properly use the 1st 2 artifacts.



Create a 4th artifact that is a well documented bash script that will initialize the folder the above code needs, create a readme.md and initialize the repo



Special Instructions:



The developer in this case is a novice



They have no prior experience with Javascript or python (venv)



Explain the concepts behind what you are suggesting and why it's structured that way



When writing code that isn't the complete file, always put in the comments at the beginning and end of the code snippet, where EXACTLY in the existing code does that go

98 lines of instructions to ask this question - how would I best create a "Madlibs" type app or intellisense-like vscode extension (Other more effective ideas are welcome) that will fill in the common code for the prompt and then asking me the specific questions about that particular project
So basically a prompt requirement wizard that interviews me and creates a prompt for me to use in the AI of my choice