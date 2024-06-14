# Local Docker Build
resource "null_resource" "build_image" {
  provisioner "local-exec" {
    command = "docker build -t ravi2krishna/login-2418 ."
  }
}

# Docker Image
resource "docker_image" "login-2418" {
  name = "ravi2krishna/login-2418"
}

# Docker Container
resource "docker_container" "login_container" {
  image = docker_image.login-2418.latest
  name  = "login"
ports {
  internal = 80
  external = 80
}
}
