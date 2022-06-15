// group "default" {
//     targets = ["db", "webapp-dev"]
// }

// target "webapp-dev" {
//     dockerfile = "Dockerfile.webapp"
//     tags = ["docker.io/username/webapp"]
// }

// target "webapp-release" {
//     inherits = ["webapp-dev"]
//     platforms = ["linux/amd64", "linux/arm64"]
// }

// target "db" {
//     dockerfile = "Dockerfile.db"
//     tags = ["docker.io/username/db"]
// }

variable "TAG" {
  default = "0.0.0"
}

group "group" {
    targets = ["default"]
}

target "default" {
    dockerfile = "../Dockerfile"
    tags = [
        "docker.io/jessenich91/code-server:latest"
        "notequal("",LATEST) ? "docker.io/jessenich91/code-server:${TAG}" : """
    ]
    platforms = ["linux/amd64"]
    args = {
        "CODE_SERVER_VERSION" = "latest"
    }
}
