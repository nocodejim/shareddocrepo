# Dev Containers Quick-Start Cheat Sheet

## Essential Commands (Command Palette - Ctrl+Shift+P)

| Command | Description |
|---------|-------------|
| `Dev Containers: Open Folder in Container...` | Open a folder from your filesystem in a container |
| `Dev Containers: Reopen in Container` | Open the current folder in a container |
| `Dev Containers: Rebuild Container` | Rebuild the active container |
| `Dev Containers: Reopen Locally` | Close the container and open folder locally |
| `Dev Containers: Attach to Running Container...` | Connect to an already running container |
| `Dev Containers: Add Dev Container Configuration Files...` | Add config files to current project |
| `Dev Containers: Install devcontainer CLI` | Install command line interface |

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Open Command Palette | `Ctrl+Shift+P` |
| Open Terminal | ``Ctrl+` `` |
| Open Settings | `Ctrl+,` |
| Quick Open (Files) | `Ctrl+P` |
| Toggle Explorer | `Ctrl+Shift+E` |
| Toggle Remote Explorer | N/A (click icon in Activity Bar) |

## Common Container Actions

| Action | How To |
|--------|--------|
| Start container | Open folder in container or attach to running container |
| Stop container | "Dev Containers: Reopen Locally" or close VSCode window |
| Restart container | "Dev Containers: Rebuild Container" |
| View logs | View > Output > select "Dev Containers" |
| Access terminal | Terminal > New Terminal |
| Port forwarding | View "Ports" panel or add to `devcontainer.json` |
| Add extension | Install in container or add to `devcontainer.json` |

## Container Status Indicators

| Indicator | Location | Meaning |
|-----------|----------|---------|
| ![Remote](https://code.visualstudio.com/assets/docs/devcontainers/containers/dev-containers-status-bar.png) | Bottom left | Connected to container |
| ![Local](https://code.visualstudio.com/assets/docs/remote/common/remote-local-status-bar.png) | Bottom left | Working locally |
| ![Building](https://code.visualstudio.com/assets/docs/devcontainers/containers/dev-container-progress.png) | Notifications | Container building |

## Java Development in Containers

| Action | How To |
|--------|--------|
| Run Java app | Right-click Java file > Run Java |
| Debug Java app | Right-click Java file > Debug Java |
| Run tests | Testing panel > Run All Tests |
| Maven tasks | Maven panel > Execute commands |
| View problems | View > Problems |
| Format code | Right-click > Format Document (`Shift+Alt+F`) |

## File Operations

| Action | How To |
|--------|--------|
| Create file | Explorer > New File icon |
| Create folder | Explorer > New Folder icon |
| Save file | `Ctrl+S` |
| Find in files | `Ctrl+Shift+F` |
| Find and replace | `Ctrl+H` |

## WSL Specific Operations

| Action | How To |
|--------|--------|
| Open WSL terminal | Terminal > New Terminal (if in WSL container) |
| Access WSL files | `\\wsl$\Ubuntu-24.04\home\username\` in Windows Explorer |
| Open folder in WSL | Remote Explorer > WSL > Ubuntu-24.04 > Open Folder |

## Container Configuration (`devcontainer.json`)

```json
{
  "name": "Project Name",               // Container name
  "image": "mcr.microsoft.com/...",     // Base image
  
  "customizations": {                   // VS Code customizations
    "vscode": {
      "settings": { ... },              // Container-specific settings
      "extensions": [ ... ]             // Extensions to install
    }
  },
  
  "forwardPorts": [8080, 8081],         // Ports to forward
  "postCreateCommand": "...",           // Commands to run after creation
  "remoteUser": "vscode"                // User to run as
}
```

## Maven Cheat Sheet

| Command | Description |
|---------|-------------|
| `mvn clean install` | Clean and build project |
| `mvn test` | Run tests |
| `mvn spring-boot:run` | Run Spring Boot application |
| `mvn dependency:tree` | Show dependency tree |

## Recommended Extensions for Java Microservices

* `vscjava.vscode-java-pack` - Java Extension Pack
* `vscjava.vscode-maven` - Maven for Java
* `vscjava.vscode-java-debug` - Debugger for Java
* `pivotal.vscode-spring-boot` - Spring Boot Tools
* `ms-azuretools.vscode-docker` - Docker
* `redhat.vscode-xml` - XML
* `sonarsource.sonarlint-vscode` - SonarLint

## Troubleshooting Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| Container won't start | Check Docker is running |
| Extensions not installing | Rebuild container |
| Java language server error | `Java: Clean Language Server Workspace` |
| Performance issues | Store project in WSL filesystem |
| "Not found" errors | Check paths and mounts |
| Port conflicts | Check `forwardPorts` or manually forward |

## Command Line Interface

| Command | Description |
|---------|-------------|
| `devcontainer open .` | Open current folder in container |
| `devcontainer build .` | Build container for current folder |
| `devcontainer up .` | Start container for current folder |
| `devcontainer exec .` | Execute command in container |
