# Create a repo to store your image
resource "aws_ecr_repository" "moon_ecr_repo" {
  name = "moon_ecr_repo"
}